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

public with sharing class StaffAssignmentHandler {


    //private List<Staff_Access__c> assignments;
    //private Map<Id, Staff_Access__c> oldAssignments;
    /**
    * @description          Constructor
    *
    * @param assignments     [Trigger.new assignments]
    * @param oldAssignments  [Trigger.oldMap assignments]
    */
	/*
    public StaffAssignmentHandler(List<Staff_Access__c> assignments, Map<Id, Staff_Access__c> oldAssignments) {
        this.assignments = assignments;
        this.oldAssignments = oldAssignments;
    }

    public void shareAccountsWithUser(){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Contact> contactMap;
        Map<Id, Account> accountMap;
        List<AccountShare> accountShares = new List<AccountShare>();
        for(Staff_Access__c thisAssignment : assignments){
            contactIds.add(thisAssignment.Staff__c);
            accountIds.add(thisAssignment.Care_Facility__c);
        }
        contactMap = new Map<Id, Contact>(ContactsSelector.getContactsWithRelatedUsers(contactIds));
        accountMap = new Map<Id, Account>(AccountsSelector.getAccount(accountIds));
        for(Staff_Access__c thisAssignment : assignments){
            Contact thisContact = contactMap.get(thisAssignment.Staff__c);
            Account thisAccount = accountMap.get(thisAssignment.Care_Facility__c);
            List<User> thisContactUserList = thisContact.Users;
            thisAssignment.Name = thisContact.Name + ' - ' + thisAccount.Name;
            if(thisContactUserList != NULL && thisContactUserList.Size() > 0){
                AccountShare accShare = new AccountShare ();
                accShare.AccountId = thisAssignment.Care_Facility__c;
                accShare.UserOrGroupId  = thisContactUserList[0].Id; //we will never have more than 1 users
                accShare.AccountAccessLevel   = Constants.READ_ACCESS;
                accShare.OpportunityAccessLevel   = Constants.READ_ACCESS;
                accountShares.add(accShare);
            }
        }
        if(accountShares.size()>0){
            insert accountShares;
        }
    }


    public void deleteAccountSharing(){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<AccountShare> accountSharesToDelete = new List<AccountShare>();
        for(Staff_Access__c thisAssignment : assignments){
            contactIds.add(thisAssignment.Staff__c);
            accountIds.add(thisAssignment.Care_Facility__c);
        }
        for(Contact thisContact : ContactsSelector.getContactsWithRelatedUsers(contactIds)){
            List<User> thisContactUserList = thisContact.Users;
            if(thisContactUserList != NULL && thisContactUserList.Size() > 0){
                userIds.add(thisContactUserList[0].Id);
            }
        }

        accountSharesToDelete = AccountShareSelector.getAccountShares(accountIds, userIds);
        if(accountSharesToDelete.size()>0){
            delete accountSharesToDelete;
        }
    }

	*/
}