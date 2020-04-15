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
 * @description Test class for StatusReports
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-03-25
 */
@IsTest
private with sharing class StatusReportsTest {
	//	@TestSetup
	//	static void setup() {
	//		Account account = TestUtils.createCommunityAccount('Test Account', FALSE);
	//		account.Beds_Available__c = 0;
	//		account.Beds_in_Use__c = 0;
	//		account.Beds_Inactive__c = 0;
	//		account.RecordTypeId = Constants.DIVISION_RECORDTYPE_ID;
	//		insert account;
	//
	//		Contact testContact = TestUtils.createCommunityContact('Test Contact', FALSE);
	//		testContact.AccountId = account.Id;
	//		insert testContact;
	//
	//		User communityUser = TestUtils.createCommunityUser(Constants.COMMUNITY_PROFILE_NAME, testContact.Id);
	//
	//		System.runAs(new User(Id = UserInfo.getUserId())){
	//			insert communityUser;
	//		}
	//	}
	//
	//	@IsTest
	//	static void test_afterInsertStatusReport() {
	//		User testUsr = [SELECT Id FROM User WHERE Profile.Name = :Constants.COMMUNITY_PROFILE_NAME ORDER BY CreatedDate DESC LIMIT 1];
	//		Account accountBeforeTriggerRuns = [SELECT Id, Beds_Available__c, Beds_in_Use__c, Beds_Inactive__c FROM Account LIMIT 1];
	//		//no data was created, all the values should be 0
	//		System.assertEquals(0, accountBeforeTriggerRuns.Beds_Available__c);
	//		System.assertEquals(0, accountBeforeTriggerRuns.Beds_in_Use__c);
	//		System.assertEquals(0, accountBeforeTriggerRuns.Beds_Inactive__c);
	//
	//		Test.startTest();
	//		System.runAs(testUsr) {
	//			insert new Status_Report__c(Name = 'test available', Count__c = 1, Status__c = StatusReportsHandler.AVAILABLE, Type__c = 'Ventilator Beds', Department__c = accountBeforeTriggerRuns.Id, Category__c = 'Equipment');
	//			insert new Status_Report__c(Name = 'test in use', Count__c = 2, Status__c = StatusReportsHandler.IN_USE, Type__c = 'Ventilator Beds', Department__c = accountBeforeTriggerRuns.Id, Category__c = 'Equipment');
	//			insert new Status_Report__c(Name = 'test inactive', Count__c = 3, Status__c = StatusReportsHandler.INACTIVE, Type__c = 'Ventilator Beds', Department__c = accountBeforeTriggerRuns.Id, Category__c = 'Equipment');
	//		}
	//		Test.stopTest();
	//
	//		Account accountAfterTriggerRuns = [SELECT Id, Beds_Available__c, Beds_in_Use__c, Beds_Inactive__c FROM Account LIMIT 1];
	//
	//		//after the trigger runs each of the types should have its own Count__c value
	//		System.assertEquals(1, accountAfterTriggerRuns.Beds_Available__c);
	//		System.assertEquals(2, accountAfterTriggerRuns.Beds_in_Use__c);
	//		System.assertEquals(3, accountAfterTriggerRuns.Beds_Inactive__c);
	//	}
	//
	//	@IsTest
	//	static void test_afterInsertStatusReportWithNoStatus() {
	//		User testUsr = [SELECT Id FROM User WHERE Profile.Name = :Constants.COMMUNITY_PROFILE_NAME ORDER BY CreatedDate DESC LIMIT 1];
	//		Account accountBeforeTriggerRuns = [SELECT Id, Beds_Available__c FROM Account LIMIT 1];
	//		//no data was created, all the values should be 0
	//		System.assertEquals(0, accountBeforeTriggerRuns.Beds_Available__c);
	//
	//		Test.startTest();
	//		System.runAs(testUsr) {
	//			insert new Status_Report__c(Name = 'test available', Count__c = 1, Type__c = 'Ventilator Beds', Department__c = accountBeforeTriggerRuns.Id, Category__c = 'Equipment');
	//		}
	//		Test.stopTest();
	//
	//		Account accountAfterTriggerRuns = [SELECT Id, Beds_Available__c FROM Account LIMIT 1];
	//
	//		//after the trigger runs, because no status was set, it shouldnt update the account
	//		System.assertEquals(0, accountAfterTriggerRuns.Beds_Available__c);
	//	}
}
