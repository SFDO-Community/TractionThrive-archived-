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
 * @date    2020-05-27
 */
@IsTest
public with sharing class StatusReportsHandlerTest {
	private final static String jsonBody = '{"justATest":"Test"}';
	private final static String jsonBodyError = '{"success": false, "apiName": "test-api", "version": "1.0", "correlationId": "g7w633gxuhsu", "timestamp": "2015-07-04T21:00:00","errorDetails": [{"code": "AC", "message": "jahsa", "additionalInfo": "2015-07-04T21:00:00"}]}';
	@TestSetup
	static void prepareData() {
		Data_Sharing__c dataSharingCustomSetting = new Data_Sharing__c(
				Client_ID__c = 'ClientIDTest',
				Client_Secret__c = 'ClientSecretTest',
				Endpoint__c = 'EndPointTest',
				Is_Active__c = true
		);
		insert dataSharingCustomSetting;
	}

	@IsTest
	public static void sendStatusReportRequest() {
		Test.setMock(HttpCalloutMock.class, new StatusReportHttpCalloutMock());
		Status_Report__c statusReport = new Status_Report__c(
				Type__c = 'Ventilator Beds',
				Status__c = 'Total',
				Date_Time__c = System.now(),
				Count__c = 2,
				Category__c = 'Equipment',
				Department__c = '0010U000012J6S8'
		);

		IngressAsset wrappedAsset = new IngressAsset(statusReport);
		wrappedAsset.getJsonString();
		Test.startTest();
		insert statusReport;
		Test.stopTest();

		List<Status_Report__c> statusReports = [Select Id, Aggregate_Send_Error__c, Is_Sent_To_Aggregator__c FROM Status_Report__c];
		System.assertEquals(1, statusReports.size());
		System.assertEquals(true, statusReports[0].Is_Sent_To_Aggregator__c);
		System.assertEquals(null, statusReports[0].Aggregate_Send_Error__c);
	}

	@IsTest
	public static void sendStatusReportRequest_error() {
		Test.setMock(HttpCalloutMock.class, new StatusReportHttpCalloutMockError());
		Status_Report__c statusReport = new Status_Report__c(
				Type__c = 'Ventilator Beds',
				Status__c = 'Total',
				Date_Time__c = System.now(),
				Count__c = 2,
				Category__c = 'Equipment',
				Department__c = '0010U000012J6S8'
		);

		IngressAsset wrappedAsset = new IngressAsset(statusReport);
		wrappedAsset.getJsonString();
		Test.startTest();
		insert statusReport;
		Test.stopTest();

		List<Status_Report__c> statusReports = [Select Id, Aggregate_Send_Error__c, Is_Sent_To_Aggregator__c FROM Status_Report__c];
		System.assertEquals(1, statusReports.size());
		System.assertEquals(false, statusReports[0].Is_Sent_To_Aggregator__c);
		System.assertEquals('Error code 400: '+jsonBodyError, statusReports[0].Aggregate_Send_Error__c);
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