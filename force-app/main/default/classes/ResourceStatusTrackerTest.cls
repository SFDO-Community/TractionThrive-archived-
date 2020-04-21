/*
    Copyright (c) 2020, Traction Sales And Marketing Inc.
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
 * @description Test class for ResourceStatusTrackerCtrl
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-18
 */
@IsTest
private class ResourceStatusTrackerTest {

    private final static String resourceType = Status_Report__c.Type__c.getDescribe().getPicklistValues()[0].value;
    private final static String resourceStatus = Status_Report__c.Status__c.getDescribe().getPicklistValues()[0].value;

    private final static String HA_ACCOUNT_NAME = 'Test HA Account RSTT';
    private final static String HOSP_ACCOUNT_NAME = 'Test HOSP Account RSTT';
    private final static String DIV_ACCOUNT_NAME = 'Test DIV Account RSTT';

    @TestSetup
    static void setup() {
        Account healthAuth = TestUtils.createAccountByRecordType(HA_ACCOUNT_NAME, Constants.HEALTH_AUTH_RECORDTYPE_ID, null, TRUE);

        Account hospital = TestUtils.createAccountByRecordType(HOSP_ACCOUNT_NAME, Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, FALSE);
        hospital.Health_Authority__c = HA_ACCOUNT_NAME;
        insert hospital;

        Account division = TestUtils.createAccountByRecordType(DIV_ACCOUNT_NAME, Constants.DIVISION_RECORDTYPE_ID, hospital.Id, FALSE);
        division.Health_Authority__c = HA_ACCOUNT_NAME;
        insert division;

        Contact testContact = TestUtils.createCommunityContact('Test RSTT Contact', FALSE);
        testContact.AccountId = hospital.Id;
        insert testContact;

        User communityUser = TestUtils.createCommunityUser(Constants.getCommunityProfileName(), testContact.Id);

        System.runAs(new User(Id = UserInfo.getUserId())){
            insert communityUser;
        }

        Status_Report__c statusReport = new Status_Report__c(
                Department__c = division.Id,
                Type__c = resourceType,
                Status__c = resourceStatus,
                Category__c = Constants.getStatusReportTypeMapping().get(resourceType),
                Count__c = 15,
                Date_Time__c = System.now()
        );
        System.runAs(communityUser) {
            insert statusReport;
            Datetime yesterday = Datetime.now().addDays(-1);
            Test.setCreatedDate(statusReport.Id, yesterday);
        }
    }

    @IsTest
    static void getResourceCount() {
        User testUsr = [SELECT Id, Contact.AccountId FROM User WHERE Profile.Name = :Constants.getCommunityProfileName() ORDER BY CreatedDate DESC LIMIT 1];
        Account department = [SELECT Id FROM Account WHERE RecordTypeId = :Constants.DIVISION_RECORDTYPE_ID ORDER BY CreatedDate DESC];

        Status_Report__c statusReport;
        Test.startTest();
        System.runAs(testUsr) {
            statusReport = ResourceStatusTrackerCtrl.getStatusReport(resourceType, resourceStatus, department.Id);
        }
        Test.stopTest();

        System.assertEquals(department.Id, statusReport.Department__c, 'Expected department to match');
        System.assertEquals(15, statusReport.Count__c, 'Expected count to match');
    }

    @IsTest
    static void setResourceCount() {
        User testUsr = [SELECT Id, Contact.AccountId FROM User WHERE Profile.Name = :Constants.getCommunityProfileName() ORDER BY CreatedDate DESC LIMIT 1];
        Account department = [SELECT Id FROM Account WHERE RecordTypeId = :Constants.DIVISION_RECORDTYPE_ID ORDER BY CreatedDate DESC];

        Test.startTest();
        System.runAs(testUsr) {
            ResourceStatusTrackerCtrl.updateLatestCountForUserDepartment(resourceType, resourceStatus, department.Id, 44);
        }
        Test.stopTest();

        System.runAs(testUsr) {
            Status_Report__c statusReport = ResourceStatusTrackerCtrl.getStatusReport(resourceType, resourceStatus, department.Id);
            System.assertEquals(44, statusReport.Count__c, 'Expected count to be updated');
        }
    }

    @IsTest
    static void setResourceCount_error() {
        final Boolean exceptionThrown;
        User testUsr = [SELECT Id, Contact.AccountId FROM User WHERE Profile.Name = :Constants.getCommunityProfileName() ORDER BY CreatedDate DESC LIMIT 1];

        Test.startTest();
        System.runAs(testUsr) {
            try {
                ResourceStatusTrackerCtrl.updateLatestCountForUserDepartment(null, null, null, null);
                exceptionThrown = false;
            } catch(AuraHandledException ex) {
                exceptionThrown = true;
            }
        }
        Test.stopTest();
        System.assert(exceptionThrown);
    }
}