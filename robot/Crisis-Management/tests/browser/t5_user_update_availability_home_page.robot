*** Settings ***

Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/ContactPageObject.py
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Delete Records and Close Browser
...             Reset Availibility Records


***Keywords***

Locate John Done On Staff Page
    Click Link                        link=Staff
    Wait Until Page Contains          Recently Viewed
    Click Element                     //*/a[@title="Select List View"]
    Click Element                     //*[contains(text(), "Detailed Staff List")]
    Wait Until Element Is Visible     //*/a[@title="Aarika Mewhirter"]
    Press Keys                        //*/input[@name="Contact-search-input"]
    ...                               John Doe
    ...                               ENTER
    Wait Until Element Is Visible     //*/a[@title="John Doe"]
    Click Element                     //*/a[@title="John Doe"]

Set 1st Availibility To Not Available
    Click Element                     //*/li[1]//*/div[1][contains(text(), "Available")]
    Click Element                     //*/span[contains(text(), "Not Available")]
    Click Element                     //*/span[contains(text(), "OK")]

Verify 1st Availibility Is Not Available
    Page Should Contain Element       //*/li[1]//*/div[1][contains(text(), "Not Available")]

Set 2nd Availibility To Assigned To Facility
    Click Element                     //*/li[2]//*/div[1][contains(text(), "Available")]
    Click Element                     //*/span[contains(text(), "Assigned")]
    Wait Until Page Contains Element  //*/input[@title="COVID19 Division"]
    Click Element                     //*/span[contains(text(), "OK")]

Verify 2nd Availibitly Is Assigned To Facility
    Page Should Contain Element       //*/li[2]//*/div[1][contains(text(), "Assigned")]
    Page Should Contain Element       //*/span[contains(text(), "COVID19 Division")]

Verify Availibility Related List Contains Correct Values
    Go To Page                        Detail
    ...                               Contact
    ...                               object_id=${RESIDENT}[0][Id]
    Click Related Item Link           title=Availabilities
    ...                               heading=Availabilities
    Page Should Contain               Not Available
    Page Should Contain               Assigned
    Page Should Contain               COVID19 Division

Reset Availibility Records
    @{records} =                      Salesforce Query                  Assignment__c         select=id,Available__c,Care_Facility__c
    ...                               Staff__c=${RESIDENT}[0][Id]
    FOR  ${record}  IN  @{records}
        Salesforce Update             Assignment__c         ${record['Id']}         Available__c=Available      Care_Facility__c=${null}
    END


*** Test Cases ***

User Updates Availibility From Staff Tab
    Login To Community As Resident
    Locate John Done On Staff Page
    Set 1st Availibility To Not Available
    Verify 1st Availibility Is Not Available
    Set 2nd Availibility To Assigned To Facility
    Verify 2nd Availibitly Is Assigned To Facility
    Verify Availibility Related List Contains Correct Values