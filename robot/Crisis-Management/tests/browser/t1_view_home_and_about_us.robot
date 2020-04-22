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

Verify Origina Store Is On About Us
    Click Link  link=About Us
    # Checks first few words of story
    Page Should Contain  Thrive Health is a Vancouver

Setup Staff
      &{main_account} =  API Create Account  Regional_Health_Authority   Name=Automtion Health Services
      &{hospital} =      API Create Account  Hospital                    Name=Robot Hospital        ParentId=&{main_account}[Id]
      &{division} =      API Create Account  Division                    Name=COVID19 Division      ParentId=&{hospital}[Id]
      &{staff} =         API Create Contact  &{division}[Id]             Resident 
      Go To Page         Detail              Contact                     object_id=&{staff}[Id]
      Page Should Contain  Thrive Health is a Vancouver


*** Test Cases ***

Navigate To Community Home
    Login To Community As Julian Joseph
    Verify Traction Thrive Image Link Visible
    Verify User Details On Home Tab     Julian Joseph       Julian Account      Traction Children's Hospital   
    Verify Origina Store Is On About Us