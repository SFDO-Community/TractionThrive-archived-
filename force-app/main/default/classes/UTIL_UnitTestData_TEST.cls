/*
    Copyright (c) 2011, Salesforce.org
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
* @author Salesforce.org
* @date 2011 (1.x)
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description Provides automated generation of unit test data for tests throughout the org 
*/
@isTest
public class UTIL_UnitTestData_TEST { 
    
    public static Contact getContact() {
    	Contact contact =  new Contact(FirstName = 'Test', LastName = 'Testerson' + Datetime.now().getTime(), OtherCity = 'Seattle');
    	Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.AllowSave = true;
        contact.setOptions(dmo);
        return contact;
    }
    
    public static List<Contact> getMultipleTestContacts(Integer n) {
        List<contact> ContactsToAdd = new List<contact>();
        for(Integer i=0; i<n; i++) {
            Contact newCon = new Contact(FirstName = i + 'Test' + i, LastName = i + 'Contact_forTests' + i, OtherCity = 'Seattle');
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            newCon.setOptions(dmo);
            ContactsToAdd.add(newCon);
        }
        return ContactsToAdd;
    }

    public static List<Account> getMultipleTestAccounts(Integer n, ID recTypeId) {
        List<Account> AcctsToAdd = new List<Account>();
        for(Integer i=0; i<n; i++) {
            Account acc = new Account(Name = i + 'Yet Another Org ' + i, RecordTypeId = recTypeId, Website = i + 'salesforce.org');
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            acc.setOptions(dmo);
            AcctsToAdd.add(acc);
        }
        return AcctsToAdd;
    }

    public static User createNewUserForTests(String strUsername) {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u;	
        // to work around mixed DML errors during tests, you must create user account in its own transaction. got this
        // hack from the web.
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {        
	        u = new User(alias = 'jsmith', email='jsmith@acme.com', emailencodingkey='UTF-8', lastname='Smith', 
	            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
	            username=strUsername);
	        insert u;
        }
        return u;
    }

    @isTest
    private static void getContactTest() {
        Contact testContact = UTIL_UnitTestData_API.getContact();
        system.assert(testContact != null);
    }

    @isTest
    private static void getMultipleTestContactsTest() {
        Integer contactCount = 5;
        List<Contact> testContacts = UTIL_UnitTestData_API.getMultipleTestContacts(contactCount);
        system.assert(testContacts != null);
        system.assert(!testContacts.isEmpty());
        system.assertEquals(contactCount, testContacts.size());
    }

    @isTest
    private static void getMultipleTestAccountsTest() {
        Integer accountCount = 5;
        Id recordTypeId = Constants.HOSPITAL_RECORDTYPE_ID;
        List<Account> testAccounts = UTIL_UnitTestData_API.getMultipleTestAccounts(accountCount, recordTypeId);
        system.assert(testAccounts != null);
        system.assert(!testAccounts.isEmpty());
        system.assertEquals(accountCount, testAccounts.size());
    }

    @isTest
    private static void createNewUserForTesting() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt + '@test' + orgId + '.org';
        User testUser = UTIL_UnitTestData_API.createNewUserForTests(uniqueName);
        system.assert(testUser != null);
        system.assert(testUser.Id != null);
        system.assertEquals(uniqueName, testUser.Username);
    }

    @isTest
    private static void testSandboxEmailToRealEmail() {
        UTIL_UnitTestData_API.isSandbox();
        String fixedEmail = UTIL_UnitTestData_API.sandboxEmailToRealEmail('awheeler=universalcontainers.com@example.com');
        System.assertEquals('awheeler@universalcontainers.com', fixedEmail);
    }
}