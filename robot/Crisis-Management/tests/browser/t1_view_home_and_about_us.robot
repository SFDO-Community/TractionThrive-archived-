*** Settings ***

Resource        robot/Crisis-Management/resources/NPSP/NPSP.robot
Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/NPSP/ContactPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
Suite Teardown  Delete Records and Close Browser


***Keywords***

Verify Traction Thrive Image Link Works
    Click Link  link=Traction Thrive

Verify User Details Are Visible
    Page Should Contain  Julian Joseph
    Page Should Contain  Resident
    Page Should Contain  Julian Account

Verify Origina Store Is On About Us
    Click Link  link=About Us
    # Checks first few words of story
    Page Should Contain  Thrive Health is a Vancouver


*** Test Cases ***

Navigate To Community Home
    Login To Community As Julian Joseph
    Verify Traction Thrive Image Link Works
    Verify User Details Are Visible
    Verify Origina Store Is On About Us