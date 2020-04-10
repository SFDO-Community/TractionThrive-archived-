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
 * Created by pserquiz on 3/29/2020.
 */
@IsTest(IsParallel=true)
public with sharing class StaffAssignmentServiceTest {
	static Account account;
	static Contact contact;
	static User communityUser;

	@TestSetup
	static void prepareData() {

		account = TestUtils.createCommunityAccount('A BC Hospital for Testing Use Only', true);
		contact = TestUtils.createCommunityContact('Watson-Testing', false);
		contact.AccountId = account.Id;
		insert contact;

		communityUser = TestUtils.createCommunityUser(Constants.COMMUNITY_PROFILE_NAME, contact.Id);

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert communityUser;
		}
	}


	@IsTest
	static void deleteAccountSharing() {
		prepareData();
		List<AccountShare> accShareBefore = [SELECT Id, AccountId FROM AccountShare WHERE AccountId = :account.Id];

		Test.startTest();
		Staff_Access__c staffAssignment = new Staff_Access__c(Staff__c = contact.Id, Care_Facility__c = account.Id, Name = 'Full Access');
		insert staffAssignment;
		delete staffAssignment;
		Test.stopTest();

		List<AccountShare> accShareAfter = [SELECT Id, AccountId FROM AccountShare WHERE AccountId = :account.Id];

		System.assertEquals(accShareBefore.size(), accShareAfter.size(), 'Should get the same acc shares as before since it should be deleted in the trigger onBeforeDelete');
	}
}