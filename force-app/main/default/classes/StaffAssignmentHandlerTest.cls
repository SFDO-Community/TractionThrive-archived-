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
 * Created by mmanik on 3/29/2020.
 */

@IsTest
private class StaffAssignmentHandlerTest {
//    public static Integer bulkNumber = 200;
//    public static Contact testContact;
//    public static User communityUser;
//    public static Account healthAuth;
//    public static Account hospital;
//
//    static {
//        healthAuth = TestUtils.createAccountByRecordType('TestAccount', Constants.HEALTH_AUTH_RECORDTYPE_ID, null, TRUE);
//        hospital = TestUtils.createAccountByRecordType('TestHospital', Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, FALSE);
//        hospital.Health_Authority__c = 'TestAuthority';
//        insert hospital;
//        testContact = TestUtils.createCommunityContact('Test Contact', FALSE);
//        testContact.AccountId = hospital.Id;
//        insert testContact;
//        communityUser = TestUtils.createCommunityUser(Constants.COMMUNITY_PROFILE_NAME, testContact.Id);
//        System.runAs(new User(Id = UserInfo.getUserId())) {
//            insert communityUser;
//        }
//    }
//
//    @IsTest
//    static void insertSharingForAccounts() {
//        // Query job sharing records.
//        List<AccountShare> accShares = AccountShareSelector.getAccountShares(healthAuth.Id, communityUser.Id);
//        System.assertEquals(0, accShares.Size(),'User must have no access record');
//        Staff_Access__c testAssignment = new Staff_Access__c(
//                Staff__c = testContact.Id,
//                Care_Facility__c = healthAuth.Id
//        );
//        Test.startTest();
//        insert testAssignment;
//        Test.stopTest();
//        accShares = AccountShareSelector.getAccountShares(healthAuth.Id, communityUser.Id);
//        System.assertEquals(1, accShares.Size(),'User must have no access record');
//        System.assertEquals(accShares[0].AccountAccessLevel, Constants.READ_ACCESS);
//    }
//
//    @IsTest
//    static void deleteSharingForAccounts() {
//        // Query job sharing records.
//        Staff_Access__c testAssignment = new Staff_Access__c(
//                Staff__c = testContact.Id,
//                Care_Facility__c = healthAuth.Id
//        );
//        insert testAssignment;
//        List<AccountShare> accShares = AccountShareSelector.getAccountShares(healthAuth.Id, communityUser.Id);
//        System.assertEquals(1, accShares.Size(),'User must have 1 access record');
//        Test.startTest();
//        delete testAssignment;
//        Test.stopTest();
//        accShares = AccountShareSelector.getAccountShares(healthAuth.Id, communityUser.Id);
//        System.assertEquals(0, accShares.Size(),'User must have no access record');
//    }
}