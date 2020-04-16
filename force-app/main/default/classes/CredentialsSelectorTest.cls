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
 * @description Test class for CredentialsSelector
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-03-29
 */
@IsTest(IsParallel=true)
public with sharing class CredentialsSelectorTest {
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
	static void selectCredentialsByContactId() {
		prepareData();
		System.runAs(communityUser) {
			List<Credential__c> contactCredentials = CredentialsSelector.selectCredentialsByContactId(contact.Id);

			System.assert(contactCredentials.size() == 2);
		}
	}

	@IsTest
	static void selectCredentialsByContactId_Fail() {
		prepareData();
		System.runAs(communityUser) {
			try {
				List<Credential__c> contactCredentials = CredentialsSelector.selectCredentialsByContactId('fakeId');
			}catch (Exception e) {
				System.assertEquals('Invalid id: fakeId', e.getMessage(), 'should return an exception');
			}
		}
	}

	@IsTest
	static void selectCredentialsById() {
		prepareData();
		System.runAs(communityUser) {
			Credential__c contactCredential = CredentialsSelector.selectCredentialsById(credentials[0].Id);

			System.assertNotEquals(null, contactCredential, 'Should return a credential');
			System.assertEquals(credentials[0].Type__c, contactCredential.Type__c, 'The selected credential should have the same type');
		}
	}

	@IsTest
	static void selectCredentialsById_Fail() {
		prepareData();
		System.runAs(communityUser) {
			try {
				Credential__c contactCredential = CredentialsSelector.selectCredentialsById('fakeId');
			}catch (Exception e) {
				System.assertEquals('Invalid id: fakeId', e.getMessage(), 'should return an exception');
			}
		}
	}

}