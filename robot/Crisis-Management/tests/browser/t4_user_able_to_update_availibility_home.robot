*** Settings ***

Resource        robot/Crisis-Management/resources/NPSP/NPSP.robot
Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/NPSP/ContactPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
# Suite Teardown  Delete Records and Close Browser

***Keywords***

Verify Traction Thrive Image Link Works
    Click Link  link=Traction Thrive

Verify User Details Are Visible
    SeleniumLibrary.Page Should Contain  Julian Joseph
    SeleniumLibrary.Page Should Contain  Resident
    SeleniumLibrary.Page Should Contain  JJ Corp

Verify Origina Store Is On About Us
    Click Link  link=About Us
    # Checks first few words of story
    SeleniumLibrary.Page Should Contain  Thrive Health is a Vancouver

*** Test Cases ***

Navigate To Community Home
    Login To Community As Julian Joseph
    ${count} =  SeleniumLibrary.Get Element Count   //*[@class="cmp-availability-date-wrap"]
    Should Be Equal As Strings     ${count}    14

    Click Element  //*[@class="cmp-availability"]
    Click Element  //*/span[1]/label/span[@class="slds-radio_faux"]
    Click Element  //*//div/a[2]/span[@class="slds-m-left_x-small"]