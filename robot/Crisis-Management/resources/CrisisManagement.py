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
from BaseObjects import BaseCMPage
from locators_48 import cm_lex_locators as locators_48

# from locators_49 import cm_lex_locators as locators_49
locators_by_api_version = {
    # 49.0: locators_49,   # summer '20
    48.0: locators_48,   # spring '20
}
# will get populated in _init_locators
cm_lex_locators = {}

@selenium_retry
class CrisisManagement(BaseCMPage,SalesforceRobotLibraryBase):
    
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