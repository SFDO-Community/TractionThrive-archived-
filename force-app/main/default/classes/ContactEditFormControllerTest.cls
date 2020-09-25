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
 * @description Test class for ContactEditFormController
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-03-28
 */
@IsTest(isParallel=true)
public with sharing class ContactEditFormControllerTest {
	static Account account;
	static Contact contact;
	static User communityUser;
	static List<Credential__c> credentials;

	@TestSetup
	static void prepareData() {

		account = TestUtils.createCommunityAccount('A BC Hospital for Testing Use Only', true);
		contact = TestUtils.createCommunityContact('Watson-Testing', false);
		contact.AccountId = account.Id;
		insert contact;

		credentials = new List<Credential__c> {
				new Credential__c(Staff__c = contact.Id, Care_Facility__c = account.Id, Type__c = 'Resident'),
				new Credential__c(Staff__c = contact.Id, Care_Facility__c = account.Id, Type__c = 'Full')
		};

		insert credentials;

		communityUser = TestUtils.createCommunityUser(Constants.getCommunityProfileName(), contact.Id);
		//insert user;

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert communityUser;
		}
	}

	@IsTest
	static void getInitData() {
		prepareData();
		System.runAs(communityUser) {
			ContactEditFormController.InitData initData = ContactEditFormController.getInitData();

			System.assertNotEquals(null, initData.contactData.contact, 'Should return the contact record');
			System.assertNotEquals(null, initData.contactData.user, 'Should return the user record');
			System.assert(initData.skillsPicklistValues.size() > 0, 'Should return all the picklist values');
			System.assert(initData.credentials.size() == 2, 'Should return the credentials associated with the contact');
		}
	}

	@IsTest
	static void updateContact() {
		prepareData();
		contact.Phone = '3333333333';
		System.runAs(communityUser) {
			ContactEditFormController.InitData initData = ContactEditFormController.updateContact(contact);
			System.assertEquals(contact.Phone, initData.contactData.contact.Phone, 'Should return the changed field');
		}
	}

	@IsTest
	static void updateContactWithRemoveField() {
		prepareData();
		contact.Phone = '3333333333';
		String contactRecordStr = '{"attributes":{"type":"Contact"},"Id":"'+contact.Id+'","LastName":"'+contact.LastName+'","Role_Global__c":"'+contact.Role_Global__c+'","Status__c":"'+contact.Status__c+'","AccountId":"'+contact.AccountId+'","Phone":"'+contact.Phone+'","Release_Date__c":"2020-04-21"}';
		Contact contactUpdate = (Contact) JSON.deserialize(contactRecordStr, Contact.class);
		System.runAs(communityUser) {
			ContactEditFormController.InitData initData = ContactEditFormController.updateContact(contactUpdate);
			System.assertEquals(contact.Phone, initData.contactData.contact.Phone, 'Should return the changed field');
		}
	}

	// @IsTest
	static void updateCredential() {
		prepareData();
		Credential__c credentialToUpdate = credentials[0];
		credentialToUpdate.Type__c = 'Full';
		System.runAs(communityUser) {
			Credential__c updatedCredential = ContactEditFormController.updateCredential(credentials[0]);
			System.assertEquals(credentialToUpdate.Type__c, updatedCredential.Type__c);
		}
	}

	@IsTest
	static void updateCredential_Fail() {
		prepareData();
		System.runAs(communityUser) {
			try {
				Credential__c updatedCredential = ContactEditFormController.updateCredential(null);
			} catch(Exception e) {
				System.assertEquals('Script-thrown exception', e.getMessage());
			}
		}
	}

	@IsTest
	static void insertCredential() {
		prepareData();
		Credential__c credentialToInsert = new Credential__c(Staff__c = contact.Id, Care_Facility__c = account.Id, Type__c = 'Resident');
		System.runAs(communityUser) {
			Credential__c newCredential = ContactEditFormController.insertCredential(credentialToInsert);
			System.assertNotEquals(null, newCredential.Id);
		}
	}

	@IsTest
	static void getCredentialsTypePicklistValues() {
		prepareData();
		System.runAs(communityUser) {
			Map<String, String> picklistValues = ContactEditFormController.getCredentialsTypePicklistValues();
			System.assert(picklistValues.size() > 0);
		}
	}

	@IsTest
	static void deleteCredential() {
		prepareData();
		System.runAs(communityUser) {
			ContactEditFormController.deleteCredential(credentials[0].Id);
			System.assert([SELECT Id FROM Credential__c WHERE Id =: credentials[0].Id].size() == 0);
		}
	}
}