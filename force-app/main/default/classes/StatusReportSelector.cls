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
 * @description Selector class for status report records
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-22
 */
public with sharing class StatusReportSelector {

    /**
     * @description Gets the latest status report of a resource
     *
     * @param resourceType  E.g. ventilator beds, patients with symptoms
     * @param status        E.g. in use, available, inactive
     * @param departmentId  The location of this resource
     *
     * @return Status_Report__c
     */
    public static Status_Report__c getLatestStatusReport(String resourceType, String status, Id departmentId) {
        Status_Report__c result;
        List<Status_Report__c> statusReport = [
                SELECT Id,
                        Count__c,
                        Department__c,
                        LastModifiedDate,
                        LastModifiedBy.Name,
                        CreatedDate
                FROM Status_Report__c
                WHERE Department__c = :departmentId
                AND Type__c = :resourceType
                AND Status__c = :status
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];

        if(!statusReport.isEmpty()) {
            result = statusReport[0];
        }
        return result;
    }
}