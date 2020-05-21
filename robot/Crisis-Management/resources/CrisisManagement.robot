*** Settings ***
Resource       cumulusci/robotframework/Salesforce.robot
Library        DateTime
Library        CrisisManagement.py
Library        cumulusci.robotframework.PageObjects
...            robot/Crisis-Management/resources/ContactPageObject.py

*** Variables ***


*** Keywords ***
Capture Screenshot and Delete Records and Close Browser
    [Documentation]         Captures screenshot if a test fails, deletes session records and closes the browser
    Run Keyword If Any Tests Failed      Capture Page Screenshot
    Close Browser
    Delete Session Records

API Create Contact
    [Arguments]      ${account}     ${Role}     &{fields}
    ${contact_id} =  Salesforce Insert  Contact
    ...                  FirstName=${faker.first_name()}
    ...                  LastName=${faker.last_name()}
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
   
API Get Id
    [Documentation]         Returns the ID of a record identified by the given field_name and field_value input for a specific object
    [Arguments]             ${obj_name}    &{fields}
    @{records} =            Salesforce Query      ${obj_name}
    ...                         select=Id
    ...                         &{fields}
    &{Id} =                 Get From List  ${records}  0
    [return]                &{Id}[Id]

API Get Name Based on Id
    [Documentation]         Returns the Name of a record identified by the given field_name and field_value input for a specific object
    [Arguments]             ${obj_name}    ${field_name}     ${field_value}
    @{records} =            Salesforce Query      ${obj_name}
    ...                         select=Name
    ...                         ${field_name}=${field_value}
    &{Name} =               Get From List  ${records}  0
    [return]                &{Name}[Name]

Login To Community As Julian Joseph
    @{community_contact}=   Salesforce Query  Contact   select=Id,Name   email=jjoseph@salesforce.com
    Go To Page              Details           Contact   object_id=${community_contact}[0][Id]
    Login To Community As User

Go To Julian Joseph
    @{community_contact}=   Salesforce Query  Contact   select=Id,Name   email=jjoseph@salesforce.com
    Go To Page              Detail           Contact   object_id=${community_contact}[0][Id]

Go to community
    [Documentation]             Go to the given CONTACT_ID detail page and log in to community as that user
    [Arguments]                 ${contact_id}

    Go to record home           ${contact_id}  
    Current page should be      Detail      Contact
    Login to community as user
    Current page should be      Home        Community