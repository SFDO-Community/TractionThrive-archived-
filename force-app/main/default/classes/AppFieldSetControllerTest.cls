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
 * @description Test class for AppFieldSet
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-04-19
 */
@IsTest
public with sharing class AppFieldSetControllerTest {
	static User communityUser;
	static Contact testContact;

	@TestSetup
	static void setup() {
		Account account = TestUtils.createAccountByRecordType('Test RSTT Account', Constants.DIVISION_RECORDTYPE_ID, null, TRUE);

		testContact = TestUtils.createCommunityContact('Test RSTT Contact', FALSE);
		testContact.AccountId = account.Id;
		insert testContact;

		communityUser = TestUtils.createCommunityUser(Constants.getCommunityProfileName(), testContact.Id);

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert communityUser;
		}
	}

	@IsTest
	static void insertSObject() {
		setup();
		System.runAs(communityUser) {
			String statusField = UTIL_Namespace.StrTokenNSPrefix('Status__c');
			String contactToInsert = '{"LastName": "TheLastName", "'+statusField+'": "On staff" }';
			AppFieldSetController.insertSObject(contactToInsert, 'Contact');
			List<Contact> contacts = [SELECT Id, LastName FROM Contact WHERE LastName = 'TheLastName'];
			System.assert(contacts.size() == 1);
		}
	}

	@IsTest
	static void updateSObject() {
		setup();
		System.runAs(communityUser) {
			String statusField = UTIL_Namespace.StrTokenNSPrefix('Status__c');
			String contactToUpdate = '{"Id": "'+testContact.Id+'", "LastName": "TheLastName", "'+statusField+'": "On staff" }';
			SObject updatedContact = AppFieldSetController.updateSObject(contactToUpdate, 'Contact');
			List<Contact> contacts = [SELECT Id, LastName FROM Contact WHERE LastName = 'TheLastName'];
			System.assert(contacts.size() == 1);
			System.assertEquals(testContact.Id, contacts[0].Id);
			System.assertNotEquals(testContact.LastName, contacts[0].LastName);
		}
	}

	@IsTest
	static void getRecordToEdit() {
		setup();
		System.runAs(communityUser) {
			AppFieldSetController.EditObjectData objectToEdit = AppFieldSetController.getRecordToEdit(testContact.Id, new List<String>{'FirstName', 'LastName'});
			System.assert(objectToEdit.editedObject != null);
		}
	}

	@IsTest
	static void getFieldsFromList() {
		setup();
		System.runAs(communityUser) {
			List<AppFieldSetController.FieldSetMember> result = AppFieldSetController.getFieldsFromList(new List<String>{'FirstName', 'LastName'}, 'Contact');
			System.assert(result.size() == 2);
		}
	}

	@IsTest
	static void searchGenericLookup() {
		setup();
		Account acc = TestUtils.createCommunityAccount('Test', true);
		System.runAs(communityUser) {
			List<Id> fixedSearchResults = new List<Id>();
			fixedSearchResults.add(acc.Id);
			Test.setFixedSearchResults(fixedSearchResults);
			List<LookupSearchResult> lookupResults = AppFieldSetController.searchGenericLookup('Test', new List<String>(), 'Account' );
			System.assertNotEquals(0, lookupResults.size());

		}
	}
}