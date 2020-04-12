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
 * @description Controller class for the contactCard aura component
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-19
 */
public with sharing class ContactCardCtrl {

    /**
     * @description Finds the community users contact info to display on their home page
     * @return      ContactData
     */
    @AuraEnabled
    public static ContactData getContactInfo() {
        Contact result;

        User currentUser = ContactsSelector.getCurrentUser();

        if(currentUser.ContactId != null) {
            List<Contact> currentContact = ContactsSelector.getCurrentContact(currentUser);
            result = currentContact[0];
        } else {
            result = new Contact(
                    Role_Global__c = currentUser.UserRole.Name
            );
        }

        return new ContactData(currentUser, result);
    }

    public class ContactData {
        @AuraEnabled public User user;
        @AuraEnabled public Contact contact;

        public ContactData(User user, Contact contact) {
            this.user = user;
            this.contact = contact;
        }
    }
}