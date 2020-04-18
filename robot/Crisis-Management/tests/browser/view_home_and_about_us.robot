*** Settings ***

Resource        robot/Crisis-Management/resources/NPSP/NPSP.robot
Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         robot/Crisis-Management/resources/CrisisManagement.py
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/NPSP/ContactPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
Suite Teardown  Delete Records and Close Browser

***Keywords***


*** Test Cases ***

Navigate To Community Home
    Login To Community As Julian Joseph
    SeleniumLibrary.Page Should Contain  Julian Joseph
    SeleniumLibrary.Page Should Contain  Resident
    SeleniumLibrary.Page Should Contain  JJ Corp
    Click Link  link=Traction Thrive
    Click Link  link=About Us
