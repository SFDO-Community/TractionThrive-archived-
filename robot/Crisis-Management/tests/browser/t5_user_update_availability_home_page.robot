*** Settings ***

Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/ContactPageObject.py
Suite Setup     Open Test Browser
# Suite Teardown  Delete Records and Close Browser



***Keywords***



*** Test Cases ***

