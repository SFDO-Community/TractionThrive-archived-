*** Settings ***

Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/ContactPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Staff
# Suite Teardown  Delete Records and Close Browser



***Keywords***

Verify Traction Thrive Image Link Visible
    Wait Until Page Contains Element    link=Traction Thrive

Verify User Details Are Visible
    Page Should Contain  Julian Joseph
    Page Should Contain  Resident
    Page Should Contain  Julian Account

Verify Origin Store Is On About Us
    Click Link  link=About Us
    # Checks first few words of story
    Page Should Contain  Thrive Health is a Vancouver

Setup Staff
    &{main_account} =                  API Create Account  Regional_Health_Authority   Name=Automtion Health Services
    &{hospital} =                      API Create Account  Hospital                    Name=Robot Hospital        ParentId=&{main_account}[Id]
    Set Suite Variable                 &{hospital} 
    &{division} =                      API Create Account  Division                    Name=COVID19 Division      ParentId=&{hospital}[Id]
    Set Suite Variable                 &{division} 
    &{staff} =                         API Create Contact  &{division}[Id]             Resident 
    API Create Community User          &{staff}
    Set Suite Variable                 &{staff} 
    Go To Page                         Detail              Contact                     object_id=&{staff}[Id]
    # Enable Community Login
    # Click Element    //*/input[1][@name="save"]
    # Handle Alert        action=ACCEPT

*** Test Cases ***

Navigate To Community Home
    # Login To Community As Julian Joseph
    Login To Community As User
    Verify Traction Thrive Image Link Visible
    Verify User Details On Home Tab     &{staff}[Name]   &{staff}[Role_Global__c]    &{division}[Name]      &{hospital}[Name]   
    Verify Origin Store Is On About Us