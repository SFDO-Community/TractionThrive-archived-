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
 * @description Utility class containing shared methods for test classes
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-18
 */

@IsTest
public class TestUtils {
    public static Account createCommunityAccount(String name, Boolean doInsert) {

        Account ret = new Account(
                Name = name,
                RecordTypeId = Constants.HOSPITAL_RECORDTYPE_ID,
                BillingState = 'BC',
                Health_Authority__c = 'Health Authority Test'
        );

        if(doInsert){
            insert ret;
        }

        return ret;
    }

    public static Account createHealthAuthority(String name, Boolean doInsert) {

        Account ret = new Account(
                Name = name,
                RecordTypeId = Constants.HEALTH_AUTH_RECORDTYPE_ID,
                BillingState = 'BC',
                Health_Authority__c = name
        );

        if(doInsert){
            insert ret;
        }

        return ret;
    }

    public static Account createHospital(String name, Id healthAuthorityId, Boolean doInsert) {
        String healthAuthName = [SELECT Id, Name FROM Account WHERE Id = :healthAuthorityId].Name;

        Account ret = new Account(
                Name = name,
                RecordTypeId = Constants.HOSPITAL_RECORDTYPE_ID,
                BillingState = 'BC',
                Health_Authority__c = healthAuthName,
                ParentId = healthAuthorityId
        );

        if(doInsert){
            insert ret;
        }

        return ret;
    }

    public static Account createAccountByRecordType(String name, Id RecordTypeId, Id parentId, Boolean doInsert) {

        Account ret = new Account(
                Name = name,
                RecordTypeId = RecordTypeId,
                ParentId = parentId,
                BillingState = 'BC'
        );

        if(doInsert){
            insert ret;
        }

        return ret;
    }

    public static Contact createCommunityContact(String name, Boolean doInsert) {
        Contact ret = new Contact(
                LastName = name,
                Role_Global__c = 'MD - Medical Doctor',
                Status__c = 'On staff'
        );

        if(doInsert){
            insert ret;
        }

        return ret;
    }

    public static List<Contact> createBulkContacts(Boolean doInsert, Integer numberOfContacts, Id AccountId) {
        List<Contact> contacts = new List<Contact>();
        for(Integer count = 0; count < numberOfContacts; count++){
            Contact thisContact = new Contact(
                    LastName = 'TestName' + count,
                    Role_Global__c = 'MD - Medical Doctor',
                    Status__c = 'On staff',
                    AccountId = AccountId
            );
            contacts.add(thisContact);
        }

        if(doInsert){
            insert contacts;
        }

        return contacts;
    }

    public static User createCommunityUser(String profileName, Id contactId) {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name =: profileName];

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(
                FirstName = 'test',
                LastName = 'test',
                Email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id,
                IsActive = true,
                ContactId = contactId
        );
        return u;
    }

    public static User createAdminUser() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator'];

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(
                FirstName = 'test',
                LastName = 'test',
                Email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id,
                IsActive = true
        );
        return u;
    }

    public static void insertContactCustomSettings(Boolean insertRoles) {
        Update_Contact__c setting = new Update_Contact__c();
        if(insertRoles){
            setting.Role__c = 'MD - Medical Doctor;RN - Registered Nurse';
        }
        setting.Number_of_days_Availaible__c = 14;
        insert setting;
    }

    public static Staff_Access__c createStaffAccess(Id contactId, Id facilityId, Boolean doInsert) {
        Staff_Access__c result = new Staff_Access__c(
                Name = 'N/A',
                Staff__c = contactId,
                Care_Facility__c = facilityId
        );

        if(doInsert){
            insert result;
        }

        return result;
    }

    public static Staff_Access__c createReadStaffAccess(Id contactId, Id facilityId, Boolean doInsert) {
        Staff_Access__c result = new Staff_Access__c(
                Name = 'N/A',
                Staff__c = contactId,
                Care_Facility__c = facilityId,
                Access_Level__c = Constants.READ_ACCESS
        );

        if(doInsert){
            insert result;
        }

        return result;
    }

    public static Staff_Access__c createEditStaffAccess(Id contactId, Id facilityId, Boolean doInsert) {
        Staff_Access__c result = new Staff_Access__c(
                Name = 'N/A',
                Staff__c = contactId,
                Care_Facility__c = facilityId,
                Access_Level__c = Constants.EDIT_ACCESS
        );

        if(doInsert){
            insert result;
        }

        return result;
    }
}