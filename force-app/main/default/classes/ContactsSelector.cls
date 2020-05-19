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
 * @description Selector class for contacts records
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-23
 */
public with sharing class ContactsSelector {

    /**
     * @description Gets current user's contact info
     * @param       currentUser
     * @return      List of contacts
     */
    public static List<Contact> getCurrentContact(User currentUser) {
        List<Contact> currentContact = [
                SELECT Id,
                        Name,
                        Department,
                        Email,
                        MobilePhone,
                        Phone,
                        Skills__c,
                        toLabel(Skills__c) SkillLabel,
                        Role_Global__c,
                        toLabel(Role_Global__c) RoleGlobalLabel,
                        AccountId,
                        Account.Name,
                        Account.RecordTypeId,
                        Account.Health_Authority__c,
                        Account.Parent.Name,
                        Account.Parent.Id,
                        Account.Parent.Parent.Name,
                        Account.Parent.Parent.Id
                FROM Contact
                WHERE Id = :currentUser.ContactId
        ];
        return currentContact;
    }

    /**
     * @description Gets current user info
     * @return      User
     */
    public static User getCurrentUser() {
        User currentUser = [
                SELECT Id,
                        ContactId,
                        Contact.AccountId,
                        UserRole.Name,
                        Profile.Name,
                        SmallPhotoUrl,
                        FullPhotoUrl
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];

        return currentUser;
    }

    public static List<Contact> getContactsWithRelatedAssignments() {

        return [SELECT Id, Role_Global__c,
                    (select Date__c from Assignments__r WHERE Staff__c != NULL AND Date__c >= TODAY)
               FROM Contact];
    }

    public static List<Contact> getContactsWithRelatedUsers(Set<Id> contactIds) {
        return [SELECT Id, Name,
                    (select Id, Name from Users )
                FROM Contact    WHERE ID IN :contactIds];
    }

    public static List<Contact> selectContactById(Id contactId) {
        List<Contact> cont = [SELECT Id, FirstName, Status__c,toLabel(Status__c) StatusLabel, LastName, AccountId, Account.Name  FROM Contact WHERE Id = :contactId];
        return cont;
    }
}