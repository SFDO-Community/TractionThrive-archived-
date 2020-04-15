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
 * @author  Manik, Traction on Demand
 * @date    2020-03-26
 */

public with sharing class ContactHandler {

    private List<Contact> contacts;
    private Map<Id, Contact> oldContacts;
    /**
    * @description          Constructor
    *
    * @param contacts     [Trigger.new Contacts]
    * @param oldContacts  [Trigger.oldMap Contacts]
    */
    public ContactHandler(List<Contact> contacts, Map<Id, Contact> oldContacts) {
        this.contacts = contacts;
        this.oldContacts = oldContacts;
    }

    public void createAssignments(){
       Update_Contact__c contactSetting = Update_Contact__c.getInstance();
        //This value is a backup value just in case if custom setting is not there If custom setting exist then it is not used.
        Integer numberOfAssignments = 14;
        List<String> roles = NULL;
        if(contactSetting != NULL){
            numberOfAssignments = Integer.valueOf(contactSetting.Number_of_days_Availaible__c);
            roles = (contactSetting.Role__c != null) ? contactSetting.Role__c.split(';') : NULL;
        }
        List<Assignment__c> assignments = new List<Assignment__c>();
        for(Contact thisContact : (List<Contact>)Trigger.New){
            if(roles == NULL || roles.contains(thisContact.Role_Global__c)){
                String status = (thisContact.Status__c == Constants.NOT_AVAILABLE_STATUS)
                                        ? Constants.NOT_AVAILABLE_ASSIGNMENT_STATUS : Constants.AVAILABLE_ASSIGNMENT_STATUS;
                createBulkAssignments(numberOfAssignments, thisContact.Id, assignments, status);
            }
        }
        SecureDml insertObject = new SecureDml();
        insertObject.dmlInsert(assignments);
    }

    private void createBulkAssignments(Integer numberOfAssignments, Id contactId, List<Assignment__c> assignments, String status) {
        for(Integer count = 0; count < numberOfAssignments; count++){
            Assignment__c thisAssignment = new Assignment__c(
                    Date__c = Date.today() + count,
                    Available__c = status,
                    Staff__c = contactId,
                    User_Updated__c = FALSE
            );
            assignments.add(thisAssignment);
        }
    }

    public void deleteAssignments(){
        List<Assignment__c> assignments = AvailabilitySelector.getAssignments(contacts);
        if(assignments.size()>0){
            SecureDml deleteObject = new SecureDml();
            deleteObject.dmlDelete(AvailabilitySelector.getAssignments(contacts));
        }
    }

    public void updateAssignments(){
        List<Contact> contactList = filterContactsWithStatusChange();
        Map<Id, Contact> filteredContactMap = new Map<Id, Contact>(contactList);
        List<Assignment__c> assignments = AvailabilitySelector.getFutureAssignments(contactList);
        for(Assignment__c thisAssignment : assignments){
            Contact relatedContact = filteredContactMap.get(thisAssignment.Staff__c);
            thisAssignment.Available__c = (relatedContact.Status__c == Constants.NOT_AVAILABLE_STATUS)
                                    ?  Constants.NOT_AVAILABLE_ASSIGNMENT_STATUS : Constants.AVAILABLE_ASSIGNMENT_STATUS;
        }
        if(assignments.size()>0){
            SecureDml updateObject = new SecureDml();
            updateObject.dmlUpdate(assignments);
        }
    }

    private List<Contact> filterContactsWithStatusChange() {
        List<Contact> contactList = new List<Contact>();
        for(Contact thisContact : contacts){
            Contact oldContact = oldContacts.get(thisContact.Id);
            if(oldContact.Status__c != thisContact.Status__c){
                contactList.add(thisContact);
            }
        }
        return contactList;
    }
}
