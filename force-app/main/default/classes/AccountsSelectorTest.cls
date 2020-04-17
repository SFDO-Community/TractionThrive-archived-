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
	static Account account;
	static Contact contact;
	static User communityUser;
	static Account childAccount;
	static Account divisionAccount;

	@TestSetup
	static void prepareData() {

		account = TestUtils.createCommunityAccount('A BC Hospital for Testing Use Only', true);
		contact = TestUtils.createCommunityContact('Watson-Testing', false);
		contact.AccountId = account.Id;
		insert contact;

		childAccount = new Account(
				Name = 'Child Account',
				ParentId = account.Id,
				RecordTypeId = Constants.HOSPITAL_RECORDTYPE_ID,
				BillingState = 'BC',
				Health_Authority__c = 'Division Test'
		);

		insert childAccount;

		divisionAccount = new Account(
				Name = 'Division Account',
				ParentId = account.Id,
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
		prepareData();
		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getAccountByRecordType(Constants.HOSPITAL_RECORDTYPE_ID);
			System.assert(accounts.size() > 0);
		}
	}

	@IsTest
	static void getChildAccountsByParent() {
		prepareData();
		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getChildAccountsByParent(account.Id);
			System.assert(accounts.size() == 2);
			System.assertEquals(childAccount.Id, accounts[0].Id);
		}
	}

	@IsTest
	static void getHospitalsByAuthorityName() {
		prepareData();
		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getHospitalsByAuthorityName(account.Name);
			System.assert(accounts.size() > 0);
		}
	}

	@IsTest
	static void getDivisionTree() {
		prepareData();
		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getDivisionTree();
			System.assert(accounts.size() > 0);
		}
	}

	@IsTest
	static void getAccount() {
		prepareData();
		System.runAs(communityUser) {
			List<Account> accounts = AccountsSelector.getAccount(new Set<Id>{account.Id, childAccount.Id, divisionAccount.Id});
			System.assert(accounts.size() == 3);
		}
	}
}