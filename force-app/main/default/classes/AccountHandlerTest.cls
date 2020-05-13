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
 * @description Test class for AccountHandler
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-05-12
 */
@IsTest
public with sharing class AccountHandlerTest {

    private final static String HA_ACCOUNT_NAME = 'Test AHT health auth';
    private final static String HOSP_ACCOUNT_NAME = 'Test AHT hospital';
    private final static String DIV_ACCOUNT_NAME = 'Test AHT division';

    @TestSetup
    static void setupData() {
        Account healthAuth = TestUtils.createAccountByRecordType(HA_ACCOUNT_NAME, Constants.HEALTH_AUTH_RECORDTYPE_ID, null, TRUE);
        Account hospital = TestUtils.createAccountByRecordType(HOSP_ACCOUNT_NAME, Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, TRUE);
    }

    @IsTest
    static void accountHealthAuthNameUpdate(){
        String name = HA_ACCOUNT_NAME;

        Test.startTest();
        Account healthAuth = TestUtils.createAccountByRecordType(name, Constants.HEALTH_AUTH_RECORDTYPE_ID, null, true);
        Account hospital = TestUtils.createAccountByRecordType('hospital', Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, true);
        Account division = TestUtils.createAccountByRecordType('division', Constants.DIVISION_RECORDTYPE_ID, hospital.Id, true);
        Test.stopTest();

        healthAuth = [SELECT ID, Health_Authority__c FROM Account WHERE Id = :healthAuth.Id];
        hospital = [SELECT ID, Health_Authority__c FROM Account WHERE Id = :hospital.Id];
        division = [SELECT ID, Health_Authority__c FROM Account WHERE Id = :division.Id];

        System.assertEquals(name, healthAuth.Health_Authority__c, 'Expected health auth name to be stamped');
        System.assertEquals(name, hospital.Health_Authority__c, 'Expected health auth name to be stamped');
        System.assertEquals(name, division.Health_Authority__c, 'Expected health auth name to be stamped');
    }

    @IsTest
    static void groupCreatedOnInsertHospital(){
        Account healthAuth = [SELECT Id FROM Account WHERE Name = :HA_ACCOUNT_NAME];
        String name = HOSP_ACCOUNT_NAME + '2';

        Test.startTest();
        Account hospital = TestUtils.createAccountByRecordType(name, Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, TRUE);
        Test.stopTest();

        List<Group> hospitalGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName LIKE :'%' + hospital.Id ORDER BY DeveloperName];

        System.assertEquals(2, hospitalGroup.size(), 'Expected two groups to exist');
        System.assertEquals(GroupHandler.generateGroupName(hospital, Constants.EDIT_ACCESS), hospitalGroup[0].Name, 'Expected a group to be created with this name');
        System.assertEquals(GroupHandler.generateGroupName(hospital, Constants.READ_ACCESS), hospitalGroup[1].Name, 'Expected a group to be created with this name');
    }

    @IsTest
    static void groupCreatedOnInsertHealthAuthority(){
        String name = HA_ACCOUNT_NAME + '2';

        Test.startTest();
        Account healthAuth = TestUtils.createAccountByRecordType(name, Constants.HEALTH_AUTH_RECORDTYPE_ID, null, TRUE);
        Test.stopTest();

        List<Group> haGroups = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName LIKE :'%' + healthAuth.Id ORDER BY DeveloperName];

        System.assertEquals(2, haGroups.size(), 'Expected two groups to exist');
        System.assertEquals(GroupHandler.generateGroupName(healthAuth, Constants.EDIT_ACCESS), haGroups[0].Name, 'Expected a group to be created with this name');
        System.assertEquals(GroupHandler.generateGroupName(healthAuth, Constants.READ_ACCESS), haGroups[1].Name, 'Expected a group to be created with this name');
    }

    @IsTest
    static void groupDeletedOnDeleteAccount(){
        Account healthAuth = [SELECT Id FROM Account WHERE Name = :HA_ACCOUNT_NAME];
        String name = HOSP_ACCOUNT_NAME + '2';

        Account hospital = TestUtils.createAccountByRecordType(name, Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, TRUE);
        Test.startTest();
        delete hospital;
        delete healthAuth;
        Test.stopTest();

        List<Group> hospitalGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName LIKE :'%' + hospital.Id ORDER BY DeveloperName];
        List<Group> haGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName LIKE :'%' + healthAuth.Id ORDER BY DeveloperName];

        System.assertEquals(0, hospitalGroup.size(), 'Expected no groups to exist');
        System.assertEquals(0, haGroup.size(), 'Expected no groups to exist');
    }


    @IsTest
    static void hospitalSharedToHealthAuthorityGroupOnInsert(){
        String name = HOSP_ACCOUNT_NAME + '2';
        Account healthAuth = [SELECT Id, Name, RecordTypeId FROM Account WHERE Name = :HA_ACCOUNT_NAME];

        Test.startTest();
        Account hospital = TestUtils.createAccountByRecordType(name, Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, FALSE);
        hospital.Health_Authority__c = HA_ACCOUNT_NAME;
        insert hospital;
        Test.stopTest();

        List<AccountShare> accShares = [
                SELECT Id, AccountAccessLevel, UserOrGroupId
                FROM AccountShare
                WHERE AccountId =: hospital.Id
                AND RowCause =: Constants.SHARING_REASON_MANUAL
                ORDER BY AccountAccessLevel DESC ];

        System.assertEquals(2,accShares.size(), 'Expected new hospital to be shared with parent health authority group');
        System.assertEquals(Constants.EDIT_ACCESS,accShares[0].AccountAccessLevel, 'Expected one share to be edit access');
        System.assertEquals(Constants.READ_ACCESS,accShares[1].AccountAccessLevel, 'Expected one share to be read access');

        Set<Id> groupIds = new Set<Id>();
        for(AccountShare accountShare : accShares) {
            groupIds.add(accountShare.UserOrGroupId);
        }

        List<Group> groups = [
                SELECT Id, Name, DeveloperName
                FROM Group
                WHERE Id =: groupIds
                ORDER BY DeveloperName
        ];

        System.assertEquals(GroupHandler.generateGroupDeveloperName(healthAuth.Id, Constants.EDIT_ACCESS),groups[0].DeveloperName, 'Expected share to be created to group with this developer Name');
        System.assertEquals(GroupHandler.generateGroupName(healthAuth, Constants.EDIT_ACCESS),groups[0].Name, 'Expected share to be created to group with this Name');
        System.assertEquals(GroupHandler.generateGroupDeveloperName(healthAuth.Id, Constants.READ_ACCESS),groups[1].DeveloperName, 'Expected share to be created to group with this developer Name');
        System.assertEquals(GroupHandler.generateGroupName(healthAuth, Constants.READ_ACCESS),groups[1].Name, 'Expected share to be created to group with this Name');
    }

    @IsTest
    static void divisionSharedWithHospitalGroupsOnInsert(){
        String name = DIV_ACCOUNT_NAME + '2';
        Account hospital = [SELECT Id, Name, RecordTypeId FROM Account WHERE Name = :HOSP_ACCOUNT_NAME];
        Account healthAuth = [SELECT Id, Name, RecordTypeId FROM Account WHERE Name = :HA_ACCOUNT_NAME];

        Test.startTest();
        Account division = TestUtils.createAccountByRecordType(name, Constants.DIVISION_RECORDTYPE_ID, hospital.Id, FALSE);
        division.Health_Authority__c = HA_ACCOUNT_NAME;
        insert division;
        Test.stopTest();

        List<AccountShare> accShares = [
                SELECT Id, AccountAccessLevel, UserOrGroupId
                FROM AccountShare
                WHERE AccountId =: division.Id
                AND RowCause =: Constants.SHARING_REASON_MANUAL
                ORDER BY AccountAccessLevel DESC ];

        System.assertEquals(4,accShares.size(), 'Expected new division to be shared with parent hospital & HA groups');
        System.assertEquals(Constants.EDIT_ACCESS,accShares[0].AccountAccessLevel, 'Expected one share to be edit access');
        System.assertEquals(Constants.EDIT_ACCESS,accShares[1].AccountAccessLevel, 'Expected two shares to be edit access');
        System.assertEquals(Constants.READ_ACCESS,accShares[2].AccountAccessLevel, 'Expected one share to be read access');
        System.assertEquals(Constants.READ_ACCESS,accShares[3].AccountAccessLevel, 'Expected two shares to be read access');

        Set<Id> groupIds = new Set<Id>();
        for(AccountShare accountShare : accShares) {
            groupIds.add(accountShare.UserOrGroupId);
        }

        List<Group> groups = [
                SELECT Id, Name, DeveloperName
                FROM Group
                WHERE Id IN: groupIds
                ORDER BY Name Desc
        ];

        System.assertEquals(4, groups.size(), 'Expected account to be shared with 4 groups');
        System.assertEquals(GroupHandler.generateGroupDeveloperName(hospital.Id, Constants.READ_ACCESS),groups[0].DeveloperName, 'Expected read share to be created to group with this developer Name');
        System.assertEquals(GroupHandler.generateGroupName(hospital, Constants.READ_ACCESS),groups[0].Name, 'Expected read share to be created to group with this Name');
        System.assertEquals(GroupHandler.generateGroupDeveloperName(healthAuth.Id, Constants.READ_ACCESS),groups[1].DeveloperName, 'Expected read share to be created to group with this developer Name');
        System.assertEquals(GroupHandler.generateGroupName(healthAuth, Constants.READ_ACCESS),groups[1].Name, 'Expected read share to be created to group with this Name');
        System.assertEquals(GroupHandler.generateGroupDeveloperName(hospital.Id, Constants.EDIT_ACCESS),groups[2].DeveloperName, 'Expected edit share to be created to group with this developer Name');
        System.assertEquals(GroupHandler.generateGroupName(hospital, Constants.EDIT_ACCESS),groups[2].Name, 'Expected edit share to be created to group with this Name');
        System.assertEquals(GroupHandler.generateGroupDeveloperName(healthAuth.Id, Constants.EDIT_ACCESS),groups[3].DeveloperName, 'Expected edit share to be created to group with this developer Name');
        System.assertEquals(GroupHandler.generateGroupName(healthAuth, Constants.EDIT_ACCESS),groups[3].Name, 'Expected edit share to be created to group with this Name');
    }
}