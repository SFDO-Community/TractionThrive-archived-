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
    ...                  Email=${first_name}${last_name}@example.com
    ...                  Role_Global__c=${Role}
    ...                  Status__c=On staff
    ...                  &{fields}
    &{contact} =     Salesforce Get  Contact  ${contact_id}
    [return]         &{contact}

API Create Community User
    [Arguments]   ${profile_name}   &{staff}
    @{profile}=   Salesforce Query  Profile   select=Id   name=${profile_name}
    ${user_id} =  Salesforce Insert  User
    ...                  FirstName=&{staff}[FirstName]
    ...                  LastName=&{staff}[LastName]
    ...                  Email=&{staff}[Email]
    ...                  Alias=&{staff}[FirstName]
    ...                  Contactid=&{staff}[Id]
    ...                  Username=&{staff}[Email]
    ...                  CommunityNickname=&{staff}[FirstName]
    ...                  IsActive=true
    ...                  EmailenCodingKey=UTF-8
    ...                  LanguageLocaleKey=en_US
    ...                  TimezonesIdKey=Asia/Dubai
    ...                  LocalesIdKey=en_US
    ...                  ProfileId=${profile}[0][Id]
    &{user} =     Salesforce Get   User  ${user_id}
    [return]         &{user}

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

Login To Community As Resident
    @{staff} =                         Salesforce Query    Contact    select=Id,Name,Role_Global__c,Account.Name       email=johndoe@tt.com
    Set Global Variable                @{RESIDENT}         @{staff}
    Go To Page                         Detail              Contact    object_id=${RESIDENT}[0][Id]
    Login To Community As User