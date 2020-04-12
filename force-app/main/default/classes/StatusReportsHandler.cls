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

    private static final String BED_TYPE = 'Ventilator Beds';
    @TestVisible private static final String IN_USE = 'In Use';
    @TestVisible private static final String AVAILABLE = 'Available';
    @TestVisible private static final String INACTIVE = 'Inactive';

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
     * Update the accounts bed amount with Count__c
     * from the recently created status report based on its status
     */
    public void stampBedCountOnDivision(){
        Map<Id, Account> accountIdToAccount = new Map<Id, Account>();
        for(Status_Report__c statusReport : statusReports) {
            if (statusReport.Department__c != null && statusReport.Type__c == BED_TYPE) {
                accountIdToAccount.put(statusReport.Department__c, filterAccountsByStatus(statusReport));
            }
        }
        if(!accountIdToAccount.isEmpty()) {
            SecureDml updateObject = new SecureDml();
            updateObject.dmlUpdate(accountIdToAccount.values());
        }
    }

    /**
     * Filter all the accounts and associate the Count__c to each field
     * base on the status report status
     *
     * @param statusReport the status report record
     *
     * @return the accounts to be updated
     */
    private Account filterAccountsByStatus(Status_Report__c statusReport) {
        Account account = new Account(
                    Id = statusReport.Department__c
        );
        if (statusReport.Status__c == AVAILABLE) {
            account.Beds_Available__c = statusReport.Count__c;
        } else if (statusReport.Status__c == IN_USE) {
            account.Beds_in_Use__c = statusReport.Count__c;
        } else if (statusReport.Status__c == INACTIVE) {
            account.Beds_Inactive__c = statusReport.Count__c;
        }
        return account;
    }
}