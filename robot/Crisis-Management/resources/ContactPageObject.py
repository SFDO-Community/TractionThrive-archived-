import time
from cumulusci.robotframework.pageobjects import DetailPage
from cumulusci.robotframework.pageobjects import ListingPage
from cumulusci.robotframework.pageobjects import pageobject
from selenium.webdriver.common.alert import Alert
from selenium.common.exceptions import UnexpectedAlertPresentException
from BaseObjects import BaseCMPage
from CrisisManagement import cm_lex_locators


@pageobject("Detail", "Contact")
class ContactDetailPage(BaseCMPage,DetailPage):
    object_name = "Contact"

    def login_to_community_as_user(self):
        """ Click on 'Show more actions' drop down and select the option to log in to community as user """
        locator_login_link = cm_lex_locators["contact_locators"]["link"].format("Log in to Community as User")
        self.selenium.wait_until_page_contains_element(
            locator_login_link,
            error="'Log in to community as user' option is not available in the list of actions"
        )
        self.selenium.click_element(locator_login_link)
        self.selenium.wait_until_location_contains("/TractionThrive/s/",timeout=60, message="Community page did not load in 1 min")
        landing_tab=cm_lex_locators["link-text"].format("Home")
        status=self.selenium.get_webelement(landing_tab).get_attribute("class")
        assert "active" in status, "Community landing tab is not Home"

    def _is_current_page(self):
        """ Verify we are on the Contact detail page
            by verifying that the url contains '/view'
        """
        self.selenium.wait_until_location_contains("/view", timeout=60, message="Detail page did not load in 1 min")
        self.selenium.location_should_contain("/lightning/r/Contact/",message="Current page is not a Contact record detail view")



@pageobject("Listing", "Contact")
class ContactListingPage(BaseCMPage, ListingPage):
    object_name = "Contact"

    def click_delete_account_button(self):
        """Clicks on Delete Account button inside the iframe"""
        self.selenium.wait_until_location_contains("/delete", message="Account delete page did not load in 30 seconds")
        self.npsp.select_frame_and_click_element("vfFrameId","button","Delete Account")