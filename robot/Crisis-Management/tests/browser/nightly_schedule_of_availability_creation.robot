*** Settings ***

Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/ContactPageObject.py
Suite Setup     Run keywords
...             Open Test Browser

#Suite Teardown  Delete Records and Close Browser

***Variables***
#${main_account}         Automtion Health Services
${role}                 Resident
&{staff_fields}         Status=on staff

*** Test Cases ***
Check nightly schedule
    ${main_account}=    API Create Account  Regional_Health_Authority
    ${contact}=     API Create Contact      ${main_account}[Id]     ${role}
    Go To Page              Detail           Contact   object_id=${contact}[Id]
   #${count}=     Get Related List Count               Availabilities  
   Click Related Item Link    title=Availabilities  heading=Availabilities
   Verify Availability Details      14