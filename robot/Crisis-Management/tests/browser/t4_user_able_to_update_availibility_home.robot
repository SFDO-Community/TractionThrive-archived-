*** Settings ***

Resource        robot/Crisis-Management/resources/NPSP/NPSP.robot
Resource        robot/Crisis-Management/resources/CrisisManagement.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Crisis-Management/resources/NPSP/ContactPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
Suite Teardown  Delete Records and Close Browser


***Keywords***

Verify There Is 1 Availibility At Julian Account
    @{assignment_assigned}=               Salesforce Query  Assignment__c   
    ...                                   select=Id   
    ...                                   Available__c=Assigned      
    ...                                   Staff__r.Email=jjoseph@salesforce.com
    ...                                   Care_Facility__r.Name=Julian Account
    Store Session Record                  Assignment__c                    
    ...                                   ${assignment_assigned}[0][Id]
    ${num_of_assiangment_assigned}=       Get Length	        
    ...                                   ${assignment_assigned}
    Should Be Equal As Integers	          ${num_of_assiangment_assigned}	        1

Verify There Is 1 Unavailibility
    @{assignment_not_available}=          Salesforce Query  Assignment__c   
    ...                                   select=Id   
    ...                                   Available__c=Not Available     
    ...                                   Staff__r.Email=jjoseph@salesforce.com
    Store Session Record                  Assignment__c                    
    ...                                   ${assignment_not_available}[0][Id]
    ${num_of_assiangment_not_available}=  Get Length	        
    ...                                   ${assignment_not_available}
    Should Be Equal As Integers	          ${num_of_assiangment_not_available}	   1

Verify There Are 14 Availibilities
    Wait Until Element Is Visible         //*[@class="cmp-availability-date-wrap"]  #Availibility Buttons
    ${count} =                            Get Element Count   //*[@class="cmp-availability-date-wrap"]  #Count Buttons
    Should Be Equal As Strings            ${count}                            14

Set 1st Availibility to Not Available
    Click Element                         //*/li[1]/c-staff-availability-item/div/div/div[2]/div/div[@data-available="Available"]  #1st Availibility Button
    Click Element                         //*/span[1]/label/span[@class="slds-radio_faux"]  #Not Available Option
    Click Element                         //*//div/a[2]/span[@class="slds-m-left_x-small"]  #OK Button
    Element Text Should Be                //*/li[1]/c-staff-availability-item/div/div/div[2]/div/div[1][@class="cmp-availability"]  Not Available  #1st Availibility Button

Set 4th Availibility to Availible at Julian Account
    Click Element                         //*/li[4]/c-staff-availability-item/div/div/div[2]/div/div[@data-available="Available"]  #4th Availibility Button
    Click Element                         //*/li[4]/c-staff-availability-item/div/div[2]/div[1]/div/lightning-radio-group/fieldset/div/div/span[3]/label/span[@class="slds-radio_faux"]  #Assigned Option
    Click Element                         //*/li[4]/c-staff-availability-item/div/div[2]/div[2]/div/a[2]/span[@class="slds-m-left_x-small"]  #OK Button
    Element Text Should Be                //*/li[4]/c-staff-availability-item/div/div/div[1]/div[3]/span[@class="cmp-facility-name"]  Julian Account  #Account


*** Test Cases ***

User is able to update availability from Staff Tab
    Login To Community As Julian Joseph
    Verify There Are 14 Availibilities
    Set 1st Availibility to Not Available
    Set 4th Availibility to Availible at Julian Account
    Verify There Is 1 Availibility At Julian Account
    Verify There Is 1 Unavailibility