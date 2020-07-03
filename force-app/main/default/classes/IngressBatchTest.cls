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
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-05-28
 */
@IsTest
public with sharing class IngressBatchTest {
	private final static String jsonBody = '{"justATest":"Test"}';
	private final static String jsonBodyError = '{"success": false, "apiName": "test-api", "version": "1.0", "correlationId": "g7w633gxuhsu", "timestamp": "2015-07-04T21:00:00","errorDetails": [{"code": "AC", "message": "jahsa", "additionalInfo": "2015-07-04T21:00:00"}]}';

	@TestSetup
	static void prepareData() {
		Test.setMock(HttpCalloutMock.class, new StatusReportHttpCalloutMock());
		Data_Sharing__c dataSharingCustomSetting = new Data_Sharing__c(
				Client_ID__c = 'ClientIDTest',
				Client_Secret__c = 'ClientSecretTest',
				Endpoint__c = 'EndPointTest',
				Is_Active__c = true
		);
		insert dataSharingCustomSetting;

		Account departmentParent = new Account(
				RecordTypeId = Constants.HOSPITAL_RECORDTYPE_ID,
				Name = 'DepartmentTestParent',
				ShippingStreet = '13364 102 avenue',
				ShippingCity = 'Surrey',
				ShippingState = 'Bc',
				ShippingPostalCode = 'V3T5L8',
				ShippingCountry = 'Canada',
				ShippingLatitude = 49.187930196516376,
				ShippingLongitude = -122.8515252928122
		);
		insert departmentParent;
		Account department = new Account(
				Name = 'DepartmentTest',
				ParentId = departmentParent.Id,
				BillingStreet = 'testBillingStreet',
				BillingState = 'testBillingState',
				BillingCountry = 'testBillingCountry',
				ShippingStreet = '13364 102 avenue',
				ShippingCity = 'Surrey',
				ShippingState = 'Bc',
				ShippingPostalCode = 'V3T5L8',
				ShippingCountry = 'Canada',
				ShippingLatitude = 49.187930196516376,
				ShippingLongitude = -122.8515252928122
		);
		insert department;

		List<Status_Report__c> statusReportsEquipment = new List<Status_Report__c>();
		for (Integer i = 0; i < 51; i++) {
			Status_Report__c statusReport = new Status_Report__c(
					Type__c = 'Ventilator Beds',
					Status__c = 'Total',
					Date_Time__c = System.now(),
					Count__c = 2,
					Category__c = 'Equipment',
					Department__c = department.Id
			);
			statusReportsEquipment.add(statusReport);
		}
		insert statusReportsEquipment;

		List<Status_Report__c> statusReportsPatient = new List<Status_Report__c>();
		for (Integer i = 0; i < 51; i++) {
			Status_Report__c statusReport = new Status_Report__c(
					Type__c = 'Ventilator Beds',
					Status__c = 'Total',
					Date_Time__c = System.now(),
					Count__c = 2,
					Category__c = 'Patient',
					Department__c = department.Id
			);
			statusReportsPatient.add(statusReport);
		}
		insert statusReportsPatient;
	}

	@IsTest
	public static void IngressBatch_sendStatusReportsData_success() {
		Test.setMock(HttpCalloutMock.class, new StatusReportHttpCalloutMock());
		Test.startTest();
		IngressBatch batchInstance = new IngressBatch();
		Database.executeBatch(batchInstance);
		Test.stopTest();
		List<Account> accounts = [SELECT Id, External_ID__c, RecordTypeId FROM Account];
		for(Account thisAccount : accounts){
			if(thisAccount.RecordTypeId == Constants.HOSPITAL_RECORDTYPE_ID){
				System.assertEquals('49.18793/-122.85153-2-DepartmentTestParent', thisAccount.External_ID__c);
			}else if(thisAccount.RecordTypeId == Constants.DIVISION_RECORDTYPE_ID){
				System.assertEquals('49.18793/-122.85153-3-DepartmentTest', thisAccount.External_ID__c);
			}
		}
		List<Status_Report__c> statusReports = [SELECT Id, Is_Sent_To_Aggregator__c, Aggregate_Send_Error__c FROM Status_Report__c];
		for (Status_Report__c statusReport : statusReports) {
			System.assertEquals(true, statusReport.Is_Sent_To_Aggregator__c);
			System.assertEquals(null, statusReport.Aggregate_Send_Error__c);
		}
	}

	@IsTest
	public static void IngressBatch_sendStatusReportsData_error() {
		Test.setMock(HttpCalloutMock.class, new StatusReportHttpCalloutMockError());
		Test.startTest();
		IngressBatch batchInstance = new IngressBatch();
		Database.executeBatch(batchInstance, 100);
		Test.stopTest();
		List<Status_Report__c> statusReports = [SELECT Id, Is_Sent_To_Aggregator__c, Aggregate_Send_Error__c FROM Status_Report__c WHERE Is_Sent_To_Aggregator__c = false];
		System.assertEquals(100, statusReports.size());
		for (Status_Report__c statusReport : statusReports) {
			System.assertEquals(false, statusReport.Is_Sent_To_Aggregator__c);
			System.assertEquals('Error code 400: '+jsonBodyError, statusReport.Aggregate_Send_Error__c);
		}
	}

	@IsTest
	public static void IngressBatch_sendStatusReportsData_scheduledJob() {
		String jobName = 'Scheduled Job Test';
		Test.setMock(HttpCalloutMock.class, new StatusReportHttpCalloutMockError());
		System.schedule(jobName, '0 45 * * * ?', new IngressBatch());
		CronJobDetail ctd = [SELECT Id, Name, JobType FROM CronJobDetail WHERE Name =: jobName Limit 1];
		System.assertEquals(jobName, ctd.Name);
		//check if the job is 7—Scheduled Apex
		System.assertEquals('7', ctd.JobType);
	}

	@IsTest
	public static void IngressBatch_sendStatusReportsData_querySize() {
		Test.setMock(HttpCalloutMock.class, new StatusReportHttpCalloutMockError());
		Database.BatchableContext bc;
		IngressBatch batchInstance = new IngressBatch();
		Database.QueryLocator queryLocator = batchInstance.start(bc);
		List<Status_Report__c> statusReports = Database.query(queryLocator.getQuery());
		System.assertEquals(100, statusReports.size());

	}

	private with sharing class StatusReportHttpCalloutMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody(jsonBody);
			response.setStatusCode(201);
			return response;
		}
	}

	private with sharing class StatusReportHttpCalloutMockError implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody(jsonBodyError);
			response.setStatusCode(400);
			return response;
		}
	}
}
