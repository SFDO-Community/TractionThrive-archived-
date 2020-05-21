*** Settings ***
Resource       robot/Crisis-Management/resources/CrisisManagement.robot
Library        DateTime
Suite Setup    Setup Accounts


*** Keywords ***
Setup Accounts
    &{main_account} =       API Create Account              Regional_Health_Authority   Name=Automtion Health Services
    Set Suite Variable      &{main_account}
    &{hospital} =           API Create Account  Hospital    Name=Robot Hospital         ParentId=&{main_account}[Id]
    Set Suite Variable      &{hospital}
    &{division} =           API Create Account  Division    Name=COVID19 Division       ParentId=&{hospital}[Id]
    Set Suite Variable      &{division}

User1
    &{staff} =  API Create Contact  &{division}[Id]    Resident     FirstName=John      LastName=Doe    Email=johndoe@tt.com
    API Create Community User     Customer Community - Medical Staff     &{staff}

User2
    &{staff} =  API Create Contact  &{division}[Id]    RN - Registered Nurse     FirstName=Jane      LastName=Smith    Email=janesmith@tt.com
    API Create Community User     Customer Community - Medical Staff     &{staff}

User3
    &{staff} =  API Create Contact  &{main_account}[Id]    MD - Medical Doctor     FirstName=Summer      LastName=Edison    Email=summeredison@tt.com
    API Create Community User     Customer Community - Health Authority     &{staff}

User4
    &{staff} =  API Create Contact  &{hospital}[Id]    MD - Medical Doctor     FirstName=Aly      LastName=Robert    Email=alyrobert@tt.com
    API Create Community User     Customer Community - Hospital Administrator     &{staff}

*** Test Cases ***
Setup User1
    ${profile}=   Salesforce Query  User   select=Id   Username=johndoe@tt.com
    ${length} =  Get Length  ${profile}
    Run Keyword If  ${length}==0    User1

Setup User2
    ${profile}=   Salesforce Query  User   select=Id   Username=janesmith@tt.com
    ${length} =  Get Length  ${profile}
    Run Keyword If  ${length}==0    User2

Setup User3
    ${profile}=   Salesforce Query  User   select=Id   Username=summeredison@tt.com
    ${length} =  Get Length  ${profile}
    Run Keyword If  ${length}==0    User3

Setup User4
    ${profile}=   Salesforce Query  User   select=Id   Username=alyrobert@tt.com
    ${length} =  Get Length  ${profile}
    Run Keyword If  ${length}==0    User4
