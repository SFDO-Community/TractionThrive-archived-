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
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-18
 */
public with sharing class ResourceStatusTrackerCtrl {

    /**
     * @description     Gets the latest count of a given resource within the community users department
     * @param type      The type of status report you are retrieving, eg. Beds, respirators
     * @param status    The status of the count - e.g. available, in use, totoal
     */
    @AuraEnabled
    public static Status_Report__c getStatusReport(String resourceType, String status, Id divisionId) {
        try {
            Status_Report__c statusReport = StatusReportSelector.getLatestStatusReport(resourceType, status, divisionId);

            return statusReport;
        } catch (Exception e) {
            throw new AuraHandledException(JSON.serialize(e.getTypeName() + ': ' + e.getMessage() + ' - ' + e.getStackTraceString()));
        }
    }

    /**
     * @description             Updates the count of a given item
     * @param resourceType      The resource you are retrieving the status of, eg. Beds, respirators
     * @param status            The status of the count - e.g. available, in use, total
     * @param count             The number of that item
     */
    @AuraEnabled
    public static void updateLatestCountForUserDepartment(String resourceType, String status, Id divisionId, Integer count) {
        try {
            String category = Constants.getStatusReportTypeMapping().get(resourceType);

            Status_Report__c statusReport = new Status_Report__c(
                    Department__c = divisionId,
                    Type__c = resourceType,
                    Status__c = status,
                    Category__c = category,
                    Count__c = count,
                    Date_Time__c = System.now()
            );
            SecureDml insertObject = new SecureDml();
            insertObject.dmlInsert(statusReport);
        } catch (Exception e) {
            throw new AuraHandledException(JSON.serialize(e.getTypeName() + ': ' + e.getMessage() + ' - ' + e.getStackTraceString()));
        }
    }
}