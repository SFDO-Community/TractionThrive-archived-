*** Settings ***

Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/ContactPageObject.py
...             robot/Crisis-Management/resources/CommunityHomePageObject.py
Suite Setup     Run keywords
...             Initialize test data
...             Open Test Browser
Suite Teardown  Capture Screenshot and Delete Records and Close Browser


***Keywords***
Initialize test data
    [Documentation]                 Getting contact id
    ${CONTACT_ID} =                 API get id          Contact     Name=John Doe
    Set suite variable              ${CONTACT_ID}


*** Test Cases ***

Navigate To Community Home
    Go to thrive home
    Go to community                                 ${CONTACT_ID}
    Verify User Details On Community Home Tab       Name=John Doe   
    ...                                             Role=Resident    
    ...                                             Account=COVID19 Division
    Click actions button                            Edit
    Update staff information                        Save
    ...                                             Mobile=${faker.phone_number()}
    ...                                             Phone=${faker.phone_number()}
    ...                                             Competencies=Critical Care
    Update credential information                   Add     COVID19 Division    
    ...                                             Registrant Type=Full  
