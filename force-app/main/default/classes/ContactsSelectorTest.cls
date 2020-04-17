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
 * @description Test class for ContactsSelector
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-04-16
 */
@IsTest
public with sharing class ContactsSelectorTest {
	static Account account;
	static Contact contact;
	static User communityUser;
	static List<Assignment__c> assignments;

	@TestSetup
	static void prepareData() {

		account = TestUtils.createCommunityAccount('A BC Hospital for Testing Use Only', true);
		contact = TestUtils.createCommunityContact('Watson-Testing', false);
		contact.AccountId = account.Id;
		insert contact;

		assignments = new List<Assignment__c> {
				new Assignment__c(Staff__c = contact.Id, Care_Facility__c = account.Id, Available__c = 'Assigned', Date__c = Date.today()),
				new Assignment__c(Staff__c = contact.Id, Available__c = 'Not Available', Date__c = Date.today().addDays(1))
		};

		insert assignments;

		communityUser = TestUtils.createCommunityUser(Constants.getCommunityProfileName(), contact.Id);

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert communityUser;
		}
	}

	@IsTest
	static void selectContactById() {
		prepareData();
		System.runAs(communityUser) {
			List<Contact> contacts = ContactsSelector.selectContactById(contact.Id);

			System.assert(contacts.size() == 1);
			System.assertEquals(contact.Id, contacts[0].Id);
		}
	}

	@IsTest
	static void getCurrentUser() {
		prepareData();
		System.runAs(communityUser) {
			User currentUser = ContactsSelector.getCurrentUser();
			List<Contact> contacts = ContactsSelector.getCurrentContact(currentUser);

			System.assert(contacts.size() == 1);
			System.assertEquals(communityUser.Id, currentUser.Id);
			System.assertEquals(communityUser.ContactId, contacts[0].Id);
		}
	}

	@IsTest
	static void getContactsWithRelatedAssignments() {
		prepareData();
		System.runAs(communityUser) {
			List<Contact> contacts = ContactsSelector.getContactsWithRelatedAssignments();
			System.assert(contacts.size() > 0);
			System.assertEquals(assignments.size(), contacts[0].Assignments__r.size());
		}
	}

	@IsTest
	static void getContactsWithRelatedUsers() {
		prepareData();
		System.runAs(communityUser) {
			List<Contact> contacts = ContactsSelector.getContactsWithRelatedUsers(new Set<Id>{contact.Id});
			System.assert(contacts.size() == 1);
			System.assertEquals(communityUser.Id, contacts[0].Users[0].Id);
		}
	}
}