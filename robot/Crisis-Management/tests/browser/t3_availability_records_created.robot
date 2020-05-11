*** Settings ***

Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library
...             cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/ContactPageObject.py
...             robot/Crisis-Management/resources/CrisisManagement.py

Suite Setup     Run keywords
...             Open Test Browser

Suite Teardown  Delete Records and Close Browser

*** Variables ***
${Last_name}   tractionuser
${status}    Not Available


*** Test Cases ***

Navigate To Community Home
   # Login as admin and create a new staff wit status Not Available
    Go To Page                                           Listing                                 Contact
    Click Object Button                                  New
    Wait For Modal                                       New                                     Staff
    Populate Modal Form
    ...                                                  Last Name=${Last_name}

    Populate Lookup Field                                Account Name                            Robot Hospital
    Select Value From Dropdown                           Status                                  ${status}
    Click Modal Button                                   Save
    Wait Until Modal Is Closed
    Current Page Should Be                               Detail                                  Contact
    Navigate And Verify Availability Related List        ${status}                               14