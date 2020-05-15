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
 * @description Class to hold shared constants
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-24
 */
public with sharing class Constants {

    //Record Type Ids
    public final static Id HEALTH_AUTH_RECORDTYPE_ID = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Regional_Health_Authority').recordTypeId;
    public final static Id HOSPITAL_RECORDTYPE_ID = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Hospital').recordTypeId;
    public final static Id DIVISION_RECORDTYPE_ID = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Division').recordTypeId;
    
    //Availability
    public final static String AVAILABLE_ASSIGNMENT_STATUS = 'Available';
    public final static String NOT_AVAILABLE_ASSIGNMENT_STATUS = 'Not Available';

    //Community Profile
    public static String getCommunityProfileName() {
        return [
                SELECT Id, Name, UserLicense.Name
                FROM Profile
                WHERE UserLicense.Name = 'Customer Community Login' AND Name LIKE '%Admin%'
                LIMIT 1
        ].Name;
    }

    //Access level
    public final static String READ_ACCESS = 'Read';
    public final static String EDIT_ACCESS = 'Edit';
    //Status Report Categories
    public static Map<String, String> getStatusReportTypeMapping() {
        Status_Report_Type_Mapping__mdt[] mappings = [
                SELECT  Id,
                        Category__c,
                        Type__c
                FROM Status_Report_Type_Mapping__mdt
        ];

        Map<String,String> typeMap = new Map<String, String>();

        for (Status_Report_Type_Mapping__mdt mapping : mappings) {
            typeMap.put(mapping.Type__c, mapping.Category__c);
        }

        return typeMap;
    }

    //Contact
    public final static String NP_Role = 'NP - Nurse Practitioner';
    public final static String RN_Role = 'RN - Registered Nurse';
    public final static String MD_Role = 'MD - Medical Doctor';
    public final static String NOT_AVAILABLE_STATUS = 'Not Available';
    public final static String AVAILABLE_STATUS = 'On staff';


}