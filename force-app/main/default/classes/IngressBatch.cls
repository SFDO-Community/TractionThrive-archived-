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
global with sharing class IngressBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {
	private static final Boolean IS_DATA_SHARING_ACTIVE = DataSharingSettingsController.getSettings().Is_Active__c;
	private static final String ENDPOINT_ASSETS = DataSharingSettingsController.getSettings().Endpoint__c+'assets';
	private static final String ENDPOINT_INFECTIONS = DataSharingSettingsController.getSettings().Endpoint__c+'infections';

	public Database.QueryLocator start(Database.BatchableContext BC){
		String queryString = 'SELECT Type__c, Status__c, Date_Time__c, Count__c, Category__c, Department__r.ShippingStreet, Department__r.ShippingCity, Department__r.ShippingCountry, ' +
				'Department__r.ShippingState, Department__r.ShippingPostalCode, Department__c, Department__r.Name, Department__r.Parent.ParentId, Department__r.Parent.Parent.Name, ' +
				'Department__r.ParentId, Department__r.Parent.Name, Department__r.BillingStreet, Department__r.BillingState, ' +
				'Department__r.External_ID__c, Department__r.Parent.Parent.External_ID__c, Department__r.Parent.External_ID__c, ' +
				'Department__r.BillingCountry, Is_Sent_To_Aggregator__c ' +
				'FROM Status_Report__c WHERE Is_Sent_To_Aggregator__c = false';
		return Database.getQueryLocator(queryString);
	}

	public void execute(Database.BatchableContext BC, List<Status_Report__c> statusReports){
		doExecute(statusReports);
	}

	@TestVisible
	private void doExecute(List<Status_Report__c> scope) {
		if (IS_DATA_SHARING_ACTIVE) {
			List<Status_Report__c> statusReportsToUpdate = new List<Status_Report__c>();
			for (Status_Report__c statusReport : scope) {
				if (statusReport.Category__c == 'Equipment' || statusReport.Category__c == 'Supplies') {
					IngressAsset asset = new IngressAsset(statusReport);
					Status_Report__c statusReportToUpdate = ingressRequest(asset.getJsonString(), statusReport.Id, ENDPOINT_ASSETS);
					statusReportsToUpdate.add(statusReportToUpdate);
				} else if (statusReport.Category__c == 'Patient') {
					IngressInfection infection = new IngressInfection(statusReport);
					Status_Report__c statusReportToUpdate = ingressRequest(infection.getJsonString(), statusReport.Id, ENDPOINT_INFECTIONS);
					statusReportsToUpdate.add(statusReportToUpdate);
				}
			}
			update statusReportsToUpdate;
		}
	}

	public static Status_Report__c ingressRequest(String jsonToSend, Id statusReportId, String endpoint) {
		HttpResponse response = IngressRestRequest.sendRequest(jsonToSend, endpoint);

		Status_Report__c statusReportToUpdate = new Status_Report__c(
				Id = statusReportId
		);

		//Write the appropriate fields
		switch on response.getStatusCode() {
			when 201, 204 {
				//If success then set the field to true
				statusReportToUpdate.Is_Sent_To_Aggregator__c = true;
			} when else {
				//If an error then populate the aggregate send error with the response body
				statusReportToUpdate.Aggregate_Send_Error__c = 'Error code '+response.getStatusCode()+': ' +response.getBody();
			}
		}
		return statusReportToUpdate;
	}

	public void execute(SchedulableContext ctx) {
		IngressBatch batchInstance = new IngressBatch();
		Database.executeBatch(batchInstance, 100);
	}
	public void finish(Database.BatchableContext BC) {}
}
