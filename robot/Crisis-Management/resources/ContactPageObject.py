from cumulusci.robotframework.pageobjects import DetailPage
from cumulusci.robotframework.pageobjects import ListingPage
from cumulusci.robotframework.pageobjects import pageobject
from BaseObjects import BaseCMPage
from CrisisManagement import cm_lex_locators
from locators_48 import npsp_lex_locators


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

    def enable_community_login(self):
        enable_link = cm_lex_locators["contact_locators"]["link"].format("Enable Customer User")
        self.selenium.wait_until_page_contains_element(
            enable_link,
            error="'Enable Customer User' option is not available in the list of actions"
        )
        self.selenium.click_element(enable_link)
        self.selenium.wait_until_location_contains("/setup/ManageUsers/",timeout=60, message="User setup page did not load in 1 min")



        
    def _is_current_page(self):
        """ Verify we are on the Contact detail page
            by verifying that the url contains '/view'
        """
        self.selenium.wait_until_location_contains("/view", timeout=60, message="Detail page did not load in 1 min")
        self.selenium.location_should_contain("/lightning/r/Contact/",message="Current page is not a Contact record detail view")
        
    def update_field_value(self,field_name,old_value,new_value):
        """Delete the old value in specified field by clicking on delete icon and update with new value"""
        locator=npsp_lex_locators['delete_icon'].format(field_name,old_value)
        self.selenium.get_webelement(locator).click() 
        self.salesforce.populate_lookup_field(field_name,new_value)


    def waitfor_actions_dropdown_and_click_option(self,option):
        """Wait for the Action dropdown menu to load from the contact details page
           Click on the desired option passed as a parameter
        """
        loc=npsp_lex_locators['contacts_actions_dropdown_menu']
        self.selenium.wait_until_element_is_visible(loc)
        self.selenium.click_link(option)

@pageobject("Listing", "Contact")
class ContactListingPage(BaseCMPage, ListingPage):
    object_name = "Contact"
   
    def click_delete_account_button(self):
        """Clicks on Delete Account button inside the iframe"""
        self.selenium.wait_until_location_contains("/delete", message="Account delete page did not load in 30 seconds")
        self.npsp.select_frame_and_click_element("vfFrameId","button","Delete Account")    

    


