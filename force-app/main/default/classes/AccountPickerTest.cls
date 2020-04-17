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
 * @description Test class for accountPickerCtrl
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-24
 */
@IsTest
public with sharing class AccountPickerTest {

    private final static String HA_ACCOUNT_NAME = 'Test HA Account APT';
    private final static String HOSP_ACCOUNT_NAME = 'Test HOSP Account APT';
    private final static String DIV_ACCOUNT_NAME = 'Test DIV Account APT';
    private final static String HA2_ACCOUNT_NAME =  HA_ACCOUNT_NAME + '2';

    @TestSetup
    static void setup() {
        Account healthAuth = TestUtils.createAccountByRecordType(HA_ACCOUNT_NAME, Constants.HEALTH_AUTH_RECORDTYPE_ID, null, TRUE);

        Account hospital = TestUtils.createAccountByRecordType(HOSP_ACCOUNT_NAME, Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, FALSE);
        hospital.Health_Authority__c = HA_ACCOUNT_NAME;
        insert hospital;

        Account division = TestUtils.createAccountByRecordType(DIV_ACCOUNT_NAME, Constants.DIVISION_RECORDTYPE_ID, hospital.Id, FALSE);
        division.Health_Authority__c = HA_ACCOUNT_NAME;
        insert division;


        Account healthAuth2 = TestUtils.createAccountByRecordType(HA2_ACCOUNT_NAME, Constants.HEALTH_AUTH_RECORDTYPE_ID, null, TRUE);

        Account hospital2 = TestUtils.createAccountByRecordType(HOSP_ACCOUNT_NAME + '2', Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, FALSE);
        hospital2.Health_Authority__c = HA_ACCOUNT_NAME;
        insert hospital2;

        Account division2 = TestUtils.createAccountByRecordType(DIV_ACCOUNT_NAME + '2', Constants.DIVISION_RECORDTYPE_ID, hospital.Id, FALSE);
        division2.Health_Authority__c = HA_ACCOUNT_NAME;
        insert division2;

        Contact testContact = TestUtils.createCommunityContact('Test Contact', FALSE);
        testContact.AccountId = hospital.Id;
        insert testContact;

        User communityUser = TestUtils.createCommunityUser(Constants.getCommunityProfileName(), testContact.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert communityUser;
        }
    }

    @IsTest
    static void getHealthAuthorities() {
        User communityUser = [SELECT Id FROM User WHERE Profile.Name = :Constants.getCommunityProfileName() ORDER BY CreatedDate DESC LIMIT 1];

        List<Account> childHospitals;
        Test.startTest();
        System.runAs(communityUser) {
            childHospitals = AccountPickerCtrl.getChildHospitals(HA_ACCOUNT_NAME);
        }
        Test.stopTest();

        System.assertEquals(2, childHospitals.size(), 'Expected 2 hospitals to be returned');
    }

    @IsTest
    static void getChildAccounts() {
        User communityUser = [SELECT Id, ContactId FROM User WHERE Profile.Name = :Constants.getCommunityProfileName() ORDER BY CreatedDate DESC LIMIT 1];
        Account account = [SELECT Id, ParentId, Parent.ParentId FROM Account WHERE Name =: DIV_ACCOUNT_NAME AND RecordTypeId = :Constants.DIVISION_RECORDTYPE_ID LIMIT 1];
        Account hosp2 = [SELECT Id, ParentId, Parent.ParentId FROM Account WHERE Name =: HOSP_ACCOUNT_NAME + '2' AND RecordTypeId = :Constants.HOSPITAL_RECORDTYPE_ID LIMIT 1];

        Staff_Access__c staffAccess = TestUtils.createStaffAccess(communityUser.ContactId, hosp2.Id, TRUE);

        List<Account> childDivisions;
        List<Account> childHospitals;
        Test.startTest();
        System.runAs(communityUser) {
            childDivisions = AccountPickerCtrl.getChildAccounts(account.ParentId);
            childHospitals = AccountPickerCtrl.getChildAccounts(account.Parent.ParentId);
        }
        Test.stopTest();

        System.assertEquals(2, childDivisions.size(), 'Expected 2 child divisions to be returned');
        System.assertEquals(2, childHospitals.size(), 'Expected 2 child hospitals to be returned as access has been granted');
    }

    @IsTest
    static void getAccountSelectionHospitalUser() {
        User communityUser = [SELECT Id, ContactId FROM User WHERE Profile.Name = :Constants.getCommunityProfileName() ORDER BY CreatedDate DESC LIMIT 1];
        Account account = [SELECT Id, ParentId, Parent.ParentId FROM Account WHERE Name =: DIV_ACCOUNT_NAME AND RecordTypeId = :Constants.DIVISION_RECORDTYPE_ID LIMIT 1];
        Account hosp2 = [SELECT Id, ParentId, Parent.ParentId FROM Account WHERE Name =: DIV_ACCOUNT_NAME + '2' AND RecordTypeId = :Constants.DIVISION_RECORDTYPE_ID LIMIT 1];

        Staff_Access__c staffAccess = TestUtils.createStaffAccess(communityUser.ContactId, hosp2.Id, TRUE);

        AccountPickerCtrl.AccountData accountData;
        Test.startTest();
        System.runAs(communityUser) {
            accountData = AccountPickerCtrl.getAccountSelections();
        }
        Test.stopTest();

        System.assertEquals(HA_ACCOUNT_NAME, accountData.currentHealthAuthority, 'Expected this HA name');
        System.assertEquals(HOSP_ACCOUNT_NAME, accountData.currentHospital.Name, 'Expected this Hospital name');
        System.assertEquals(null, accountData.currentDivision.Name, 'Expected no division to be selected');
        System.assertEquals(1, accountData.healthAuthorities.size(), 'Expected one HA');
        System.assertEquals(1, accountData.authorityHospitalMap.get(accountData.currentHealthAuthority).size(), 'Expected 1 hospital');
        System.assertEquals(2, accountData.hospitalDivisionMap.get(accountData.currentHospital.Id).size(), 'Expected 2 divisions');
    }
}