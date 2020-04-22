*** Settings ***

Resource       robot/Crisis-Management/resources/NPSP/NPSP.robot
...            cumulusci/robotframework/Salesforce.robot
Library        DateTime
Library        CrisisManagement.py
...            robot/Crisis-Management/resources/ContactPageObject.py

*** Variables ***


*** Keywords ***
Login To Community As Julian Joseph
    @{community_contact}=   Salesforce Query  Contact   select=Id,Name   email=jjoseph@salesforce.com
    Go To Page              Details           Contact   object_id=${community_contact}[0][Id]
    Login To Community As User

Go To Julian Joseph
    @{community_contact}=   Salesforce Query  Contact   select=Id,Name   email=jjoseph@salesforce.com
    Go To Page              Details           Contact   object_id=${community_contact}[0][Id]