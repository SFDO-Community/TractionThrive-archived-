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
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-27
 */
@IsTest
private with sharing class AllResourceTest {

    private final static String HA_ACCOUNT_NAME = 'Test HA Account APT';
    private final static String HOSP_ACCOUNT_NAME = 'Test HOSP Account APT';
    private final static String DIV_ACCOUNT_NAME = 'Test DIV Account APT';

    @TestSetup
    static void setup() {
        Account healthAuth = TestUtils.createAccountByRecordType(HA_ACCOUNT_NAME, Constants.HEALTH_AUTH_RECORDTYPE_ID, null, TRUE);
        Account hospital = TestUtils.createAccountByRecordType(HOSP_ACCOUNT_NAME, Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, TRUE);
        Account division = TestUtils.createAccountByRecordType(DIV_ACCOUNT_NAME, Constants.DIVISION_RECORDTYPE_ID, hospital.Id, TRUE);

        Contact testContact = TestUtils.createCommunityContact('Test Contact', FALSE);
        testContact.AccountId = division.Id;
        insert testContact;

        User communityUser = TestUtils.createCommunityUser(Constants.COMMUNITY_PROFILE_NAME, testContact.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert communityUser;
        }
    }

    @IsTest
    static void getContactInfo() {
        User communityUser = [SELECT Id FROM User WHERE Profile.Name = :Constants.COMMUNITY_PROFILE_NAME ORDER BY CreatedDate DESC LIMIT 1];

        User currentUser;
        Test.startTest();
        System.runAs(communityUser) {
            currentUser = AllResourceCtrl.getUserProfile();
        }
        Test.stopTest();

        System.assertEquals(communityUser.Id, currentUser.Id, 'Expected current user to be returned');
        System.assertEquals(Constants.COMMUNITY_PROFILE_NAME, currentUser.Profile.Name, 'Expected correct profile to be returned');
    }
}