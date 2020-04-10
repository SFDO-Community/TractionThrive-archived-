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
 * Created by mmanik on 3/28/2020.
 */

public with sharing class StaffAssignmentController {

    static final Integer MAX_RESULTS = 5;

    // custom lookup for sfdc-ui-lookup-lwc - https://github.com/pozil/sfdc-ui-lookup-lwc/tree/master/src-sample
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchLookup(String searchTerm, List<String> selectedIds, String objectApiName) {
        if(objectApiName != NULL && objectApiName == 'Contact'){
            return searchAccountLookup(searchTerm, selectedIds);
        }else if(objectApiName != NULL && objectApiName == 'Account'){
            return searchContactLookup(searchTerm, selectedIds);
        }
        return NULL;
    }

    private static List<LookupSearchResult> searchAccountLookup(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                        RETURNING
                        Account(Id, Name, Parent_Facility_Name__c, Parent.Parent_Facility_Name__c,
                                BillingCity WHERE id NOT IN :selectedIds)
                LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            String subtitleString = (account.Parent.Parent_Facility_Name__c != null) ? account.Parent.Parent_Facility_Name__c + ' / ' : '';
            subtitleString +=   (account.Parent_Facility_Name__c != null) ? account.Parent_Facility_Name__c + ' / ' : '';
            subtitleString +=   account.Name;
            results.add(
                    new LookupSearchResult(
                            account.Id,
                            'Account',
                            accountIcon,
                            account.Name,
                            subtitleString

                    )
            );
        }


        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    private static List<LookupSearchResult> searchContactLookup(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                        RETURNING
                        Contact(Id, Name, Account.Name WHERE id NOT IN :selectedIds)
                LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Contact & convert them into LookupSearchResult
        String contactIcon = 'standard:contact_list';
        Contact[] contacts = (List<Contact>) searchResults[0];
        for (Contact thisContact : contacts) {
            results.add(
                    new LookupSearchResult(
                            thisContact.Id,
                            'Contact',
                            contactIcon,
                            thisContact.Name,
                            thisContact.Account.Name
                    )
            );
        }


        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled
    public static Staff_Access__c save(Id lookupSelectionId, Id recordId) {
        Staff_Access__c thisAssignment = new Staff_Access__c();
        String apiNameFromWhichEvenFired;
        if(recordId != NULL){
        apiNameFromWhichEvenFired = recordId.getSObjectType().getDescribe().getName();
        }
        thisAssignment.Care_Facility__c = lookupSelectionId;
        thisAssignment.Staff__c = recordId;
        if(apiNameFromWhichEvenFired  == 'Account'){
            thisAssignment.Care_Facility__c = recordId;
            thisAssignment.Staff__c = lookupSelectionId;
        }
        try {
            SecureDml insertObject = new SecureDml();
            insertObject.dmlInsert(thisAssignment);
        }
        catch(Exception e) {
            System.debug('HERE ' + e);
            throw new AuraHandledException(e.getMessage() + ' : RECORD -> ' + JSON.serializePretty(thisAssignment));
        }
        return thisAssignment;
    }

    @AuraEnabled
    public static String getObjectAPIName(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();

    }
}