*** Settings ***
Resource       cumulusci/robotframework/Salesforce.robot
Library        DateTime
Library        CrisisManagement.py
Library        cumulusci.robotframework.PageObjects
...            robot/Crisis-Management/resources/ContactPageObject.py

*** Variables ***


*** Keywords ***
API Create Contact
    [Arguments]      ${account}     ${Role}     &{fields}
    ${first_name} =  Generate Random String
    ${last_name} =   Generate Random String
    ${contact_id} =  Salesforce Insert  Contact
    ...                  FirstName=${first_name}
    ...                  LastName=${last_name}
    ...                  AccountId=${account}
    ...                  Role_Global__c=${Role}
    ...                  Status__c=On staff
    ...                  &{fields}  
    &{contact} =     Salesforce Get  Contact  ${contact_id}
    [return]         &{contact}

API Create Account
    [Arguments]      ${type}    &{fields}
    ${name} =        Generate Random String
    ${rt_id} =       Get Record Type Id  Account  ${type}
    ${account_id} =  Salesforce Insert  Account
    ...                  Name=${name}
    ...                  RecordTypeId=${rt_id}
    ...                  &{fields}
    &{account} =     Salesforce Get  Account  ${account_id}
    [return]         &{account}
   

Login To Community As Julian Joseph
    @{community_contact}=   Salesforce Query  Contact   select=Id,Name   email=jjoseph@salesforce.com
    Go To Page              Details           Contact   object_id=${community_contact}[0][Id]
    Login To Community As User

Go To Julian Joseph
    @{community_contact}=   Salesforce Query  Contact   select=Id,Name   email=jjoseph@salesforce.com
    Go To Page              Detail           Contact   object_id=${community_contact}[0][Id]