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
 * Created by mmanik on 3/29/2020.
 */
@IsTest
private class StaffAssignmentControllerTest {

    public static Account account;
    public static Contact contact1;
    public static Contact contact2;
    public static User user;

   static {
       System.runAs(new User(Id = UserInfo.getUserId())){
           // NOTE: Temporary workaround to be able to deploy to prod
        account = TestUtils.createCommunityAccount('A BC Hospital for Testing Use Only', true);
        contact1 = TestUtils.createCommunityContact('Watson-Testing', false);
        contact1.AccountId = account.Id;
        insert contact1;

        contact2 = TestUtils.createCommunityContact('Test', false);
        contact2.AccountId = account.Id;
        insert contact2;
        user = TestUtils.createCommunityUser(Constants.COMMUNITY_PROFILE_NAME, contact1.Id);
        insert user;
        }

    }

    @IsTest
    static void saveTest() {
            Staff_Access__c assignmentCreated = StaffAssignmentController.save(account.Id, contact1.Id);
            System.assertNotEquals(NULL, assignmentCreated.Id, 'Assignment record must be inserted');
            try {
                Staff_Access__c assignmentError = StaffAssignmentController.save(NULL, NULL);
            }
            catch (AuraHandledException ex) {
                System.assertNotEquals(null, ex);
            }
    }

    @IsTest
    static void searchAccountLookupTest() {
        Account acc = TestUtils.createCommunityAccount('Test', true);
        List<Id> fixedSearchResults = new List<Id>();
        fixedSearchResults.add(acc.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        List<LookupSearchResult> results = StaffAssignmentController.searchLookup('Test', new List<String>(), 'Contact');
        System.assertNotEquals(0, results.size());
    }

    @IsTest
    static void searchContactLookupTest() {
        List<Id> fixedSearchResults = new List<Id>();
        fixedSearchResults.add(contact2.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        List<LookupSearchResult> results = StaffAssignmentController.searchLookup('Test', new List<String>(), 'Account');
        System.assertNotEquals(0, results.size());
    }


}