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
@isTest(isParallel=true)
public class StaffAvailabilityControllerTests {

	static Account account;
	static Contact contact;
	static User user;
	static List<Assignment__c> assignments;


	@TestSetup
	static void prepareData() {

		// NOTE: Temporary workaround to be able to deploy to prod
		String COMMUNITY_PROFILE_NAME = [
			SELECT Id, Name, UserLicense.Name
			FROM Profile
			WHERE UserLicense.Name = 'Customer Community Plus Login'AND (Name LIKE '%Admin%' OR Name LIKE '%Staff%')
			LIMIT 1
		].Name;

		account = TestUtils.createCommunityAccount('A BC Hospital for Testing Use Only', true);
		contact = TestUtils.createCommunityContact('Watson-Testing', false);
		contact.AccountId = account.Id;
		insert contact;

		assignments = new List<Assignment__c> {
				new Assignment__c(Staff__c = contact.Id, Care_Facility__c = account.Id, Available__c = 'Assigned', Date__c = Date.today()),
				new Assignment__c(Staff__c = contact.Id, Available__c = 'Not Available', Date__c = Date.today().addDays(1))
		};

		insert assignments;

		user = TestUtils.createCommunityUser(COMMUNITY_PROFILE_NAME, contact.Id);
		//insert user;

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert user;
		}

	}

	@IsTest
	static void  getAssignmentData() {
		prepareData();

		System.runAs(user) {
			StaffAvailabilityController.AssignmentData data = StaffAvailabilityController.getAssignmentData(null);

			System.assertEquals(assignments.size(), data.assignmentRecords.size());
			System.assertEquals(14, data.assignments.size());
			System.assertEquals(contact.Status__c, data.contact.Status__c);
		}
	}

	// @IsTest
	static void  updateStaffStatus() {
		prepareData();

		System.runAs(user) {
			Contact data = StaffAvailabilityController.updateStaffStatus(contact.Id, false);
			System.assert(data != null);
			System.assertEquals(Constants.NOT_AVAILABLE_STATUS, data.Status__c);
		}
	}

	@IsTest
	static void save() {
		prepareData();

		System.runAs(user) {
			Date assignDate = Date.today().addDays(100);
			Assignment__c assignmentNew = new Assignment__c(Staff__c = contact.Id, Care_Facility__c = account.Id, Available__c = 'Assigned', Date__c = assignDate);
			Assignment__c assignmentError = new Assignment__c(Staff__c = contact.Id, Care_Facility__c = account.Id, Available__c = 'Assigned');

			Assignment__c assignmentCreated = StaffAvailabilityController.save(assignmentNew);

			System.assertEquals(assignDate, assignmentCreated.Date__c);


			try {
				Assignment__c assignmentErrorCreated = StaffAvailabilityController.save(assignmentError);
			}
			catch (AuraHandledException ex) {
				System.assertNotEquals(null, ex);
			}
		}
	}

	@IsTest
	static void searchAccountLookup() {
		Account acc = TestUtils.createCommunityAccount('Test', true);

		List<Id> fixedSearchResults = new List<Id>();
		fixedSearchResults.add(acc.Id);
		Test.setFixedSearchResults(fixedSearchResults);

		List<LookupSearchResult> results = StaffAvailabilityController.searchAccountLookup('Test', new List<String>());
		System.assertNotEquals(0, results.size());
	}

}
