from cumulusci.robotframework.pageobjects import HomePage
from cumulusci.robotframework.pageobjects import pageobject
from selenium.webdriver.support.ui import Select
import datetime
import time
from BaseObjects import BaseCMPage
from CrisisManagement import cm_lex_locators

@pageobject("Home", "Community")
class CommunityHomePage(BaseCMPage,HomePage):

    def _is_current_page(self):
        """ Verify we are on the Community Home page
            by verifying the 'Home' tab
        """
        locator = cm_lex_locators["community_home_locators"]["home_tab"]
        self.selenium.wait_until_page_contains_element(
            locator,
            error="Community Home page not available"
        )

    def _select_dropdown_value(self,locator,key,value):
        """Helper function which selects the values of a dropdown based on key & label"""
        self.selenium.wait_until_page_contains_element(locator)
        self.selenium.set_focus_to_element(locator)
        field = self.selenium.get_webelement(locator)
        self.selenium.click_element(field)
        self.selenium.wait_until_element_is_visible(
                locator,
                error=f"'{key}' drop down, '{locator}' is not available on the page")
        dropdown_value_locator = cm_lex_locators["community_home_locators"]["dropdown_values"].format(value)
        field = self.selenium.get_webelement(dropdown_value_locator)
        self.selenium.click_element(field)

    def click_actions_button(self,action):
        """ This clicks on the Edit button(pencil icon) seen on the community Home page."""
        locator = cm_lex_locators["community_home_locators"]["contact_info_buttons"].format(action)
        self.selenium.wait_until_page_contains_element(
            locator,
            error="Edit button/pencil icon not available on the Community Home Page"
        )
        field = self.selenium.get_webelement(locator)
        self.selenium.driver.execute_script("arguments[0].click()", field)
        self.selenium.capture_page_screenshot()

    def update_credential_information(self,action,facility,**kwargs):
        """ This updates the credential information on the community page."""
        for key, value in kwargs.items():
            print("I AM IN Upate credential FUNCT")
            if action == 'Add' and key == 'Registrant Type':
                self.click_actions_button(action)
                self.verify_facility_info(facility)
                locator = cm_lex_locators["community_home_locators"]["dropdown"].format(key)
                self._select_dropdown_value(locator,key,value)
            self.click_actions_button("Save")
            self.selenium.capture_page_screenshot()
            

    def update_staff_information(self,action,**kwargs):
        """ This verifies the disabled fields and also updates the staff information on the community page."""
        self.verify_disabled_fields()
        for key, value in kwargs.items():
            if key == 'Mobile':
                locator = cm_lex_locators["community_home_locators"]["staff_contact_info"].format(key)
                self.selenium.wait_until_page_contains_element(locator,
                error=f"'{key}' with the '{value}' is not available in the community page")
                self.salesforce._populate_field(locator,value)
            elif key == 'Phone':
                locator = cm_lex_locators["community_home_locators"]["staff_contact_info"].format(key)
                self.selenium.wait_until_page_contains_element(locator,
                error=f"'{key}' with the '{value}' is not available in the community page")
                self.salesforce._populate_field(locator,value)
            elif key == 'Competencies':
                locator = cm_lex_locators["community_home_locators"]["dropdown"].format(key)
                self.selenium.wait_until_page_contains_element(locator,
                error=f"'{key}' with the '{value}' is not available in the community page")
                self._select_dropdown_value(locator,key,value)
        self.click_actions_button(action)
        self.selenium.capture_page_screenshot()

    def verify_facility_info(self,facility):
        """Verifies the facility info in the community"""
        locator = cm_lex_locators["community_home_locators"]["facility_info"].format("Care Facility", facility)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Facility info with the '{locator}' is not available on the Community"
        )

    def verify_disabled_fields(self):
        """Verify the following fields are disabled info in the community:
            Care Facility, Email, Staff Name
        """
        facility_locator = cm_lex_locators["community_home_locators"]["disabled_field"].format("Care Facility")
        email_locator = cm_lex_locators["community_home_locators"]["disabled_field"].format("Email")
        staff_locator = cm_lex_locators["community_home_locators"]["disabled_field"].format("Staff Name")
        self.selenium.wait_until_page_contains_element(
            facility_locator,
            error=f"Facility name with the '{facility_locator}' is not available on the Community"
        )
        self.selenium.wait_until_page_contains_element(
            email_locator,
            error=f"Email info with the '{email_locator}' is not available on the Community"
        )
        self.selenium.wait_until_page_contains_element(
            staff_locator,
            error=f"Staff name with the '{staff_locator}' is not available on the Community"
        )

    def verify_toast_message(self,toast_message):
        """Verifies the toast message"""
        pass

    def verify_user_details_on_community_home_tab(self,**kwargs):
        """Verifies user's name,role and account information on the community home page"""
        for key, value in kwargs.items():
            if key == 'Name':
                locator = cm_lex_locators["community_home_locators"]["staff_info"].format(value)
                self.selenium.wait_until_page_contains_element(locator,
                error=f"'{key}' with the '{value}' is not available in the community page")
            elif key == 'Role':
                locator = cm_lex_locators["community_home_locators"]["staff_info"].format(value)
                self.selenium.wait_until_page_contains_element(locator,
                error=f"'{key}' with the '{value}' is not available in the community page")
            elif key == 'Account':
                locator = cm_lex_locators["community_home_locators"]["staff_info"].format(value)
                self.selenium.wait_until_page_contains_element(locator,
                error=f"'{key}' with the '{value}' is not available in the community page")


    def click_user_info(self,value):
        """ Click on user name on the Community Home page
        """
        locator = cm_lex_locators["community_home_locators"]["user_info"].format(value)
        field = self.selenium.get_webelement(locator)
        self.selenium.click_element(field)
        