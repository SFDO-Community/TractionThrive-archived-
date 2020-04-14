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
 * @description Test class for StatusReportSelector
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-03-29
 */
@IsTest(IsParallel=true)
public with sharing class StatusReportSelectorTest {
	private final static String resourceType = Status_Report__c.Type__c.getDescribe().getPicklistValues()[0].value;
	private final static String resourceStatus = Status_Report__c.Status__c.getDescribe().getPicklistValues()[0].value;
	private final static String PROFILE_NAME = Constants.COMMUNITY_PROFILE_NAME;

	@TestSetup
	static void setup() {
		Account account = TestUtils.createAccountByRecordType('Test RSTT Account', Constants.DIVISION_RECORDTYPE_ID, null, TRUE);

		Contact testContact = TestUtils.createCommunityContact('Test RSTT Contact', FALSE);
		testContact.AccountId = account.Id;
		insert testContact;

		User communityUser = TestUtils.createCommunityUser(PROFILE_NAME, testContact.Id);

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert communityUser;
		}

		Status_Report__c statusReport = new Status_Report__c(
				Department__c = account.Id,
				Type__c = resourceType,
				Status__c = resourceStatus,
				Category__c = Constants.getStatusReportTypeMapping().get(resourceType),
				Count__c = 15,
				Date_Time__c = System.now()
		);
		System.runAs(communityUser) {
			insert statusReport;
			Datetime yesterday = Datetime.now().addDays(-1);
			Test.setCreatedDate(statusReport.Id, yesterday);
		}
	}

	@IsTest
	static void getLatestStatusReport() {
		User testUsr = [SELECT Id, Contact.AccountId FROM User WHERE Profile.Name = :PROFILE_NAME ORDER BY CreatedDate DESC LIMIT 1];
		Account account = [SELECT Id FROM Account ORDER BY CreatedDate DESC];
		List<Status_Report__c> statusReport = [SELECT Id, Department__c FROM Status_Report__c];

		System.runAs(testUsr) {
			Status_Report__c latestStatusReport = StatusReportSelector.getLatestStatusReport(resourceType, resourceStatus, account.Id);

			System.assertEquals(statusReport[0].Id, latestStatusReport.Id);
			System.assertEquals(account.Id, latestStatusReport.Department__c);
		}

	}
}