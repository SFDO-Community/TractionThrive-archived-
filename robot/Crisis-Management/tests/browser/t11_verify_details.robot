*** Settings ***

Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library
...             cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/ContactPageObject.py
...             robot/Crisis-Management/resources/CrisisManagement.py
...             robot/Crisis-Management/resources/CommunityHomePageObject.py

Suite Setup     Run keywords
...             Open Test Browser

Suite Teardown  Delete Records and Close Browser


*** Test Cases ***
Verify_community_user_detail
    ${community_contact}=   API Get Id      Contact     Name=John Doe
    Go to record home           ${community_contact}
    Current page should be      Detail      Contact
    Login to community as user
    Click Element     title:John Doe
    Click Element      title:My Account
    Page Should Contain  COVID19 Division
    Page Should Contain  Robot Hospital