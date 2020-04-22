from cumulusci.robotframework.pageobjects import DetailPage
from cumulusci.robotframework.pageobjects import pageobject
from BaseObjects import BaseCMPage
from locators_48 import cm_lex_locators



@pageobject("Detail", "Contact")
class ContactDetailPage(BaseCMPage,DetailPage):
    object_name = "Contact"

    def login_to_community_as_user(self):
        """ Click on 'Show more actions' drop down and select the option to log in to community as user """
        locator_actions = cm_lex_locators["contact_locators"]["show_more_actions"]
        locator_login_link = cm_lex_locators["contact_locators"]["login_to_community"]
        locator_login_error = cm_lex_locators["contact_locators"]["community_login_error"]

        self.selenium.wait_until_page_contains_element(
            locator_login_link,
            error="'Log in to community as user' option is not available in the list of actions"
        )
        self.selenium.click_element(locator_login_link)