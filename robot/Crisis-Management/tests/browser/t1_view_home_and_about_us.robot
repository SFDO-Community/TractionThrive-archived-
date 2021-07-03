*** Settings ***

Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/ContactPageObject.py
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser


***Keywords***

Verify Traction Thrive Image Link Visible
    Wait Until Page Contains Element    link=Traction Thrive

Verify Origin Store Is On About Us
    Click Link  link=About Us
    # Checks first few words of story
    Page Should Contain  Thrive Health is a Vancouver

Verify User Deatils For Resident
    Verify User Details On Home Tab     ${RESIDENT}[0][Name]   ${RESIDENT}[0][Role_Global__c]    ${RESIDENT}[0][Account][Name]


*** Test Cases ***

Navigate To Community Home
    # Login To Community As Julian Joseph
    [tags]                  unstable
    Login To Community As User
    Verify Traction Thrive Image Link Visible
    Verify User Details On Home Tab     &{staff}[Name]   &{staff}[Role_Global__c]    &{division}[Name]      &{hospital}[Name]
    Verify Origin Store Is On About Us