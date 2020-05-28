import logging
import warnings
import time
import random
import string
from datetime import datetime
from datetime import timedelta


from robot.libraries.BuiltIn import RobotNotRunningError
from selenium.common.exceptions import ElementNotInteractableException
from selenium.common.exceptions import StaleElementReferenceException
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import NoSuchWindowException
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.common.keys import Keys
from SeleniumLibrary.errors import ElementNotFound
from simple_salesforce import SalesforceMalformedRequest
from simple_salesforce import SalesforceResourceNotFound
from selenium.webdriver import ActionChains
from cumulusci.robotframework.utils import selenium_retry
from cumulusci.robotframework.utils import capture_screenshot_on_error
from email.mime import text
from cumulusci.tasks.apex.anon import AnonymousApexTask
from cumulusci.core.config import TaskConfig
from robot.libraries.BuiltIn import BuiltIn
from tasks.salesforce_robot_library_base import SalesforceRobotLibraryBase
from locators_48 import cm_lex_locators as locators_48


# from locators_49 import cm_lex_locators as locators_49
locators_by_api_version = {
    # 49.0: locators_49,   # summer '20
    48.0: locators_48,   # spring '20
}
# will get populated in _init_locators
cm_lex_locators = {}
npsp_lex_locators = {}

@selenium_retry
class CrisisManagement(SalesforceRobotLibraryBase):
    
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = 1.0

    def __init__(self, debug=False):
        self.debug = debug
        self.current_page = None
        self._session_records = []
        self.val=0
        self.payment_list= []
        # Turn off info logging of all http requests 
        logging.getLogger('requests.packages.urllib3.connectionpool').setLevel(logging.WARN)
        self._init_locators()

    @capture_screenshot_on_error
    def select_value_from_dropdown(self,dropdown,value):
        """Select given value in the dropdown field"""
        elelocator = "//div[contains(@class,'forcePageBlockSectionRow')]/div[contains(@class,'forcePageBlockItem')]/div[contains(@class,'slds-hint-parent')]/div[@class='slds-form-element__control']/div[.//span[text()='{}']][//div[contains(@class,'uiMenu')]//a[@class='select']]"

        locator = elelocator.format(dropdown)
        self.selenium.scroll_element_into_view(locator)
        self.selenium.get_webelement(locator).click()
        #self.wait_for_locator('popup')
        self.selenium.click_link(value)

    def check_if_element_exists(self, xpath):
        elements =self.selenium.get_element_count(xpath)
        return True if elements > 0 else False

    def get_url_formatted_object_name(self,name):
        """Returns a map with BaseURl and the namespace formatted object name"""
        out = {}
        base_url = self.cumulusci.org.lightning_base_url
        object_name = "{}{}".format(self.cumulusci.get_namespace_prefix(), name)
        out['baseurl'] = base_url
        out['objectname'] = object_name
        return out

    @capture_screenshot_on_error
    def populate_modal_form(self,**kwargs):
        """Populates modal form with the field-value pairs
        supported keys are any input, textarea, lookup, checkbox, date and dropdown fields"""
    
        for key, value in kwargs.items():
            locator = cm_lex_locators["modal-form"]["label"].format(key)
            if self.check_if_element_exists(locator):
                ele=self.selenium.get_webelements(locator)
                for e in ele:
                    classname=e.get_attribute("class")
                    #                     print("key is {} and class is {}".format(key,classname))
                    if "Lookup" in classname and "readonly" not in classname:
                        self.salesforce.populate_lookup_field(key,value)
                        print("Executed populate lookup field for {}".format(key))
                        break
                    elif "Select" in classname and "readonly" not in classname:
                        self.select_value_from_dropdown(key,value)
                        print("Executed select value from dropdown for {}".format(key))
                        break
                    elif "Checkbox" in classname and "readonly" not in classname:
                        if value == "checked":
                            locator = cm_lex_locators["checkbox"]["model-checkbox"].format(key)
                            self.selenium.get_webelement(locator).click()
                            break
                    elif "Date" in classname and "readonly" not in classname:
                        self.open_date_picker(key)
                        self.pick_date(value)
                        print("Executed open date picker and pick date for {}".format(key))
                        break
                    else:
                        try :
                            self.search_field_by_value(key,value)
                            print("Executed search field by value for {}".format(key))
                        except Exception :
                            try :
                                self.salesforce.populate_field(key,value)
                                print("Executed populate field for {}".format(key))
                        
                            except Exception:
                                print ("class name for key {} did not match with field type supported by this keyword".format(key))
        
            else:
                raise Exception("Locator for {} is not found on the page".format(key))

    def _init_locators(self):
        try:
            client = self.cumulusci.tooling
            response = client._call_salesforce(
                'GET', 'https://{}/services/data'.format(client.sf_instance))
            self.latest_api_version = float(response.json()[-1]['version'])
            if not self.latest_api_version in locators_by_api_version:
                warnings.warn("Could not find locator library for API %d" % self.latest_api_version)
                self.latest_api_version = max(locators_by_api_version.keys())
        except RobotNotRunningError:
            # We aren't part of a running test, likely because we are
            # generating keyword documentation. If that's the case, assume
            # the latest supported version
            self.latest_api_version = max(locators_by_api_version.keys())
        locators = locators_by_api_version[self.latest_api_version]
        cm_lex_locators.update(locators)

    @property
    def builtin(self):
        return BuiltIn()

    @property
    def cumulusci(self):
        return self.builtin.get_library_instance("cumulusci.robotframework.CumulusCI")

    @property
    def pageobjects(self):
        return self.builtin.get_library_instance("cumulusci.robotframework.PageObjects")

    @property
    def salesforce(self):
        return self.builtin.get_library_instance('cumulusci.robotframework.Salesforce')

    @property
    def selenium(self):
        return self.builtin.get_library_instance("SeleniumLibrary")

    def _check_if_element_exists(self, xpath):
        """ Checks if the given xpath exists
            this is only a helper function being called from other keywords
        """
        elements = int(self.selenium.get_element_count(xpath))
        return True if elements > 0 else False

    def _get_namespace_prefix(self, name):
        parts = name.split('__')
        if parts[-1] == 'c':
            parts = parts[:-1]
        if len(parts) > 1:
            return parts[0] + '__'
        else:
            return ''

    def get_cm_namespace_prefix(self):
        if not hasattr(self.cumulusci, '_describe_result'):
            self.cumulusci._describe_result = self.cumulusci.sf.describe()
        objects = self.cumulusci._describe_result['sobjects']
        level_object = [o for o in objects if o['label'] == 'Staff'][0]
        return self._get_namespace_prefix(level_object['name'])    

    def go_to_thrive_home(self):
        """ Navigates to the Home view of the SAL app """
        url = self.cumulusci.org.lightning_base_url
        url = "{}/lightning/page/home".format(url)
        self.selenium.go_to(url)
        self.salesforce.wait_until_loading_is_complete()

    def verify_user_details_on_home_tab(self,*args):
        """Verifies that details specified on list is visible on home tab of community page"""
        for value in args:
            self.selenium.page_should_contain(value)

    def get_locator(self, path, *args, **kwargs):
        """ Returns a rendered locator string from the npsp_lex_locators
            dictionary.  This can be useful if you want to use an element in
            a different way than the built in keywords allow.
        """ 
        locator = cm_lex_locators
        for key in path.split('.'):
            locator = locator[key]
        main_loc = locator.format(*args, **kwargs)
        return main_loc

    def wait_for_locator(self, path, *args, **kwargs):
        """Waits for 60 sec for the specified locator"""
        main_loc = self.get_locator(path,*args, **kwargs)    
        self.selenium.wait_until_element_is_visible(main_loc, timeout=60)    

    def click_element_with_locator(self, path, *args, **kwargs):
        """Pass the locator and its values for the element you want to click """
        locator=self.get_locator(path, *args, **kwargs)  
        self.selenium.click_element(locator)         

    def format_all(self, loc, value):
        """ Formats the given locator with the value for all {} occurrences """
        count = loc.count('{')

        if count == 1:
            return loc.format(value)
        elif count == 2:
            return loc.format(value, value)
        elif count == 3:
            return loc.format(value, value, value)

    def select_frame_with_value(self, value):
        """ Selects frame identified by the given value
        value should be the 'id', 'title' or 'name' attribute value of the webelement used to identify the frame
        """
        locator = cm_lex_locators["frame"]
        locator = self.format_all(locator, value)
        self.selenium.wait_until_element_is_visible(locator, timeout=60)
        self.selenium.select_frame(locator)
    