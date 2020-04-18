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

from tasks.salesforce_robot_library_base import SalesforceRobotLibraryBase
from BaseObjects import BaseNPSPPage

from locators_48 import npsp_lex_locators as locators_48
from locators_47 import npsp_lex_locators as locators_47


locators_by_api_version = {
    48.0: locators_48,   # spring '20
    47.0: locators_47,   # winter '20
}

contact_locators = {
    "community_login_error": "//div[contains(@class, 'slds-modal__container')]/div[contains(@class, 'modal-body')]/div[contains(text(), 'Looks like this portal user is not a member of a community or your community is down')]",
    "login_to_community": "//a[@title='Log in to Community as User']",
    "show_more_actions": "//div[contains(@class, 'actionsContainer')]/descendant::li[contains(@class, 'oneActionsDropDown')]/descendant::a[contains(@title, 'more actions')]",
}

@selenium_retry
class CrisisManagement(BaseNPSPPage,SalesforceRobotLibraryBase):
    
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = 1.0

    def login_to_community_as_user(self):
        """ Click on 'Show more actions' drop down and select the option to log in to community as user """
        locator_actions = contact_locators["show_more_actions"]
        locator_login_link = contact_locators["login_to_community"]
        locator_login_error = contact_locators["community_login_error"]

        self.selenium.wait_until_page_contains_element(
            locator_login_link,
            error="'Log in to community as user' option is not available in the list of actions"
        )
        self.selenium.click_element(locator_login_link)