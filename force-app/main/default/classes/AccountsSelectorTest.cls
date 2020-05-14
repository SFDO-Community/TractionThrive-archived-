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
 * @description Test class for AccountsSelector
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-04-16
 */
@IsTest
public with sharing class AccountsSelectorTest {
	static Account healthAuth;
	static Account hospital;
	static Account divisionAccount;
	static Contact contact;
	static User communityUser;

	@TestSetup
	static void prepareData() {

		healthAuth = TestUtils.createAccountByRecordType('A BC Health Auth for Testing Use Only', Constants.HEALTH_AUTH_RECORDTYPE_ID, null, true);
		contact = TestUtils.createCommunityContact('Watson-Testing', false);
		contact.AccountId = healthAuth.Id;
		insert contact;

		hospital = new Account(
				Name = 'Child Account',
				ParentId = healthAuth.Id,
				RecordTypeId = Constants.HOSPITAL_RECORDTYPE_ID,
				BillingState = 'BC',
				Health_Authority__c = 'Division Test'
		);

		insert hospital;

		divisionAccount = new Account(
				Name = 'Division Account',
				ParentId = hospital.Id,
				RecordTypeId = Constants.DIVISION_RECORDTYPE_ID,
				BillingState = 'BC',
				Health_Authority__c = 'Division Test'
		);

		insert divisionAccount;

		communityUser = TestUtils.createCommunityUser(Constants.getCommunityProfileName(), contact.Id);

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert communityUser;
		}
	}

	@IsTest
	static void getAccountByRecordType() {
		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getAccountByRecordType(Constants.HOSPITAL_RECORDTYPE_ID);
			System.assert(accounts.size() > 0);
		}
	}

	@IsTest
	static void getChildAccountsByParent() {
		healthAuth = [SELECT Id FROM Account WHERE RecordTypeId = :Constants.HEALTH_AUTH_RECORDTYPE_ID];
		hospital = [SELECT Id FROM Account WHERE RecordTypeId = :Constants.HOSPITAL_RECORDTYPE_ID];

		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getChildAccountsByParent(healthAuth.Id);
			System.assertEquals(1, accounts.size());
			System.assertEquals(hospital.Id, accounts[0].Id);
		}
	}

	@IsTest
	static void getHospitalsByAuthorityName() {
		healthAuth = [SELECT Id, Name FROM Account WHERE RecordTypeId = :Constants.HEALTH_AUTH_RECORDTYPE_ID];

		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getHospitalsByAuthorityName(healthAuth.Name);
			System.assert(accounts.size() > 0);
		}
	}

	@IsTest
	static void getDivisionTree() {
		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getDivisionTree();
			System.assert(accounts.size() > 0);
		}
	}

	@IsTest
	static void getAccount() {
		healthAuth = [SELECT Id FROM Account WHERE RecordTypeId = :Constants.HEALTH_AUTH_RECORDTYPE_ID];
		hospital = [SELECT Id FROM Account WHERE RecordTypeId = :Constants.HOSPITAL_RECORDTYPE_ID];
		divisionAccount = [SELECT Id FROM Account WHERE RecordTypeId = :Constants.DIVISION_RECORDTYPE_ID];

		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getAccount(new Set<Id>{
					healthAuth.Id, hospital.Id, divisionAccount.Id});
			System.assert(accounts.size() == 3);
		}
	}
}