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
 * @description
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-22
 */
//@SecurityException Needs access to update the division account
public with sharing class StatusReportsHandler {

//    private static final String BED_TYPE = 'Ventilator Beds';
//    @TestVisible private static final String IN_USE = 'In Use';
//    @TestVisible private static final String AVAILABLE = 'Available';
//    @TestVisible private static final String INACTIVE = 'Inactive';
//
	private static final Boolean IS_DATA_SHARING_ACTIVE = DataSharingSettingsController.getSettings().Is_Active__c;
	private static final String ENDPOINT_ASSETS = DataSharingSettingsController.getSettings().Endpoint__c;
	private static final String ENDPOINT_INFECTIONS = DataSharingSettingsController.getSettings().Endpoint__c;
	private List<Status_Report__c> statusReports;
	private Map<Id, Status_Report__c> oldStatusReports;

	/**
	* @description          Constructor
	*
	* @param statusReports     [Trigger.new StatusReports]
	* @param oldStatusReports  [Trigger.oldMap StatusReports]
	*/
	public StatusReportsHandler(List<Status_Report__c> statusReports, Map<Id, Status_Report__c> oldStatusReports) {
		this.statusReports = statusReports;
		this.oldStatusReports = oldStatusReports;
	}

	/**
     * @description Sends the created status report to mulesoft
     */
	public void sendStatusReportRequest() {
		stampExternalIdsOnAccounts(statusReports[0].Id);
		List<Status_Report__c> statusReportsForIntegration = StatusReportSelector.getStatusReportForIntegration(statusReports);
		if (IS_DATA_SHARING_ACTIVE) {
			if (statusReportsForIntegration[0].Category__c == 'Equipment' || statusReportsForIntegration[0].Category__c == 'Supplies') {
				IngressAsset asset = new IngressAsset(statusReportsForIntegration[0]);
				futureRequest(asset.getJsonString(), statusReportsForIntegration[0].Id, ENDPOINT_ASSETS);
			} else if (statusReportsForIntegration[0].Category__c == 'Patient') {
				IngressInfection asset = new IngressInfection(statusReportsForIntegration[0]);
				futureRequest(asset.getJsonString(), statusReportsForIntegration[0].Id, ENDPOINT_INFECTIONS);
			}
		}
	}

	@Future(callout=true)
	public static void futureRequest(String jsonToSend, Id statusReportId, String endpoint) {
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

		System.enqueueJob(new UpdateStatusReport(new List<Status_Report__c>{statusReportToUpdate}));
	}

	/**
	 * Class to queue the update after a request has been sent
	 */
	public class UpdateStatusReport implements Queueable {

		List <Status_Report__c> statusReportToUpdate= new List<Status_Report__c>();

		public UpdateStatusReport (List<Status_Report__c> statusReportsToUpdate )
		{
			this.statusReportToUpdate = statusReportsToUpdate ;
		}
		public void execute(QueueableContext context)
		{
			update statusReportToUpdate;
		}
	}

	/**
		 * @description Stamp external Id on accounts
     */
	private static void stampExternalIdsOnAccounts(Id statusReportId) {
		Status_Report__c statusReport = StatusReportSelector.getStatusReportForExternalId(statusReportId);
		Set <Id> accountIds = new Set<Id>();
		if(statusReport.Department__r != NULL){
			accountIds.add(statusReport.Department__r.Id);
			accountIds.add(statusReport.Department__r.ParentId);
			if(statusReport.Department__r.Parent != NULL){
				accountIds.add(statusReport.Department__r.Parent.ParentId);
			}
		}
		List<Account> accounts = AccountsSelector.getAccountsForExternalId(accountIds);
		for(Account thisAccount : accounts){
			thisAccount.External_ID__c = String.valueOf(thisAccount.ShippingLatitude.setScale(5));
			thisAccount.External_ID__c += '/'+String.valueOf(thisAccount.ShippingLongitude.setScale(5));
			if(thisAccount.RecordTypeId == Constants.HEALTH_AUTH_RECORDTYPE_ID){
				thisAccount.External_ID__c += '-1-';
			}else if(thisAccount.RecordTypeId == Constants.HOSPITAL_RECORDTYPE_ID){
				thisAccount.External_ID__c += '-2-';
			}else if(thisAccount.RecordTypeId == Constants.DIVISION_RECORDTYPE_ID){
				thisAccount.External_ID__c += '-3-';
			}
			thisAccount.External_ID__c += thisAccount.Name.replaceAll('[^a-zA-Z0-9\\s+]', '').replaceAll(' ', '');
		}
		update  accounts;
	}

//
//    /**
//     * Update the accounts bed amount with Count__c
//     * from the recently created status report based on its status
//     */
//    public void stampBedCountOnDivision(){
//        Map<Id, Account> accountIdToAccount = new Map<Id, Account>();
//        for(Status_Report__c statusReport : statusReports) {
//            if (statusReport.Department__c != null && statusReport.Type__c == BED_TYPE) {
//                accountIdToAccount.put(statusReport.Department__c, filterAccountsByStatus(statusReport));
//            }
//        }
//        if(!accountIdToAccount.isEmpty()) {
//            SecureDml updateObject = new SecureDml();
//            updateObject.dmlUpdate(accountIdToAccount.values());
//        }
//    }
//
//    /**
//     * Filter all the accounts and associate the Count__c to each field
//     * base on the status report status
//     *
//     * @param statusReport the status report record
//     *
//     * @return the accounts to be updated
//     */
//    private Account filterAccountsByStatus(Status_Report__c statusReport) {
//        Account account = new Account(
//                    Id = statusReport.Department__c
//        );
//        if (statusReport.Status__c == AVAILABLE) {
//            account.Beds_Available__c = statusReport.Count__c;
//        } else if (statusReport.Status__c == IN_USE) {
//            account.Beds_in_Use__c = statusReport.Count__c;
//        } else if (statusReport.Status__c == INACTIVE) {
//            account.Beds_Inactive__c = statusReport.Count__c;
//        }
//        return account;
//    }
}