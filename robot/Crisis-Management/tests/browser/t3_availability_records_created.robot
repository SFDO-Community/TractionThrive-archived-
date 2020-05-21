*** Settings ***

Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library
...             cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/ContactPageObject.py
...             robot/Crisis-Management/resources/CrisisManagement.py

Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data

Suite Teardown  Delete Records and Close Browser

***Keywords***

# Set up all the required data for the test based on the keyword requests
Setup Test Data
    &{main_account} =                  API Create Account  Regional_Health_Authority   Name=Automtion Health Services
    &{hospital} =                      API Create Account  Hospital                    Name=Robot_test Hospital        ParentId=&{main_account}[Id]
    Set Suite Variable                 &{hospital}

*** Variables ***
${status1}    On staff
${status2}    Not Available


*** Test Cases ***

1. Create a new staff with status equals on staff
   # Login as admin and create a new staff wit status Not Available
    Go To Page                                           Listing                                 Contact
    Click Object Button                                  New
    Wait For Modal                                       New                                     Staff
    Populate Modal Form
    ...                                                  First Name=${faker.first_name()}
    ...                                                  Last Name=${faker.last_name()}
    ...                                                  Status=${status1}
    Populate Lookup Field                                Facility Name                            &{hospital}[Name]

    Click Modal Button                                   Save
    Wait Until Modal Is Closed
    Current Page Should Be                               Detail                                  Contact
    Navigate And Verify Availability Related List        Available                               14

2 Create a new staff with status equals Not Available
    Go To Page                                           Listing                                 Contact
    Click Object Button                                  New
    Wait For Modal                                       New                                     Staff
    Populate Modal Form
    ...                                                  First Name=${faker.first_name()}
    ...                                                  Last Name=${faker.last_name()}
    ...                                                  Status=${status1}
    Populate Lookup Field                                Account Name                            &{hospital}[Name]
    Select Value From Dropdown                           Status                                  ${status2}
    Click Modal Button                                   Save
    Wait Until Modal Is Closed
    Current Page Should Be                               Detail                                  Contact
    Navigate And Verify Availability Related List        ${status2}                               14
