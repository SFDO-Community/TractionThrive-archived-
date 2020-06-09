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
public with sharing class IngressRestRequestTest {
	private final static String jsonBody = '{"justATest":"Test"}';

	@TestSetup
	static void prepareData() {
		Data_Sharing__c dataSharingCustomSetting = new Data_Sharing__c(
			Client_ID__c = 'ClientIDTest',
			Client_Secret__c = 'ClientSecretTest',
			Endpoint__c = 'https://endpointtest.com/'
		);
		insert dataSharingCustomSetting;
	}

	@IsTest
	public static void testPostCallout() {
		Data_Sharing__c customSetting = [SELECT Endpoint__c FROM Data_Sharing__c];
		Test.setMock(HttpCalloutMock.class, new StatusReportHttpCalloutMock());
		Test.startTest();
		HttpResponse response = IngressRestRequest.sendRequest(jsonBody, customSetting.Endpoint__c);
		Test.stopTest();

		String contentType = response.getHeader('Content-Type');
		String actualValue = response.getBody();
		System.assert(contentType == 'application/json');
		System.assertEquals(actualValue, jsonBody);
		System.assertEquals(201, response.getStatusCode());
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
}