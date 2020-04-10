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
 * Created by mmanik on 3/26/2020.
 */

public with sharing class AvailabilityService {

    public static void createAvailabilityRecords(List<Contact> availableContacts) {
        List<Assignment__c> assignmentsToInsert = new List<Assignment__c>();
        Update_Contact__c contactSetting = Update_Contact__c.getInstance();
        List<String> roles = (contactSetting != NULL && contactSetting.Role__c != NULL) ? contactSetting.Role__c.split(';') : NULL;

        for(Contact thisContact : availableContacts){
            if(roles == NULL || roles.contains(thisContact.Role_Global__c)){
                Assignment__c thisAssignment = new Assignment__c(
                        Date__c = (thisContact.Assignments__r != null && thisContact.Assignments__r.size()>0 && thisContact.Assignments__r[0].Date__c != NULL)
                                                                    ? thisContact.Assignments__r[0].Date__c + 1 : Date.today(),
                        Available__c =  (thisContact.Status__c == Constants.NOT_AVAILABLE_STATUS)
                                                ? Constants.NOT_AVAILABLE_ASSIGNMENT_STATUS : Constants.AVAILABLE_ASSIGNMENT_STATUS,
                        Staff__c = thisContact.Id,
                        User_Updated__c = FALSE
                );
                assignmentsToInsert.add(thisAssignment);
            }
        }
        SecureDml insertObject = new SecureDml();
        insertObject.dmlInsert(assignmentsToInsert);
    }
}