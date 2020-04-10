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

@IsTest
public with sharing class ContactHandlerTest {

    public static Integer bulkNumber = 200;
    public static List<Contact> staff;

    static {
        Account careCenter = TestUtils.createCommunityAccount('Test Account', TRUE);
        staff = TestUtils.createBulkContacts(FALSE, bulkNumber, careCenter.Id);
    }

    @IsTest
    static void insertAssignmentsWithAvailableStatus() {
        TestUtils.insertContactCustomSettings(FALSE);
        Integer numberOfAssignments = Integer.valueOf(Update_Contact__c.getInstance().Number_of_days_Availaible__c);
        List<Assignment__c> availabilities = [Select Id from Assignment__c];
        System.assertEquals(0, availabilities.size(), 'There must be 0 assignment record');

        Test.startTest();
        insert staff;
        Test.stopTest();
        staff = ContactsSelector.getContactsWithRelatedAssignments();
        availabilities = [Select Id, Available__c from Assignment__c];
        for(Contact thisContact : staff){
            System.assertEquals(numberOfAssignments, thisContact.Assignments__r.size(), 'There must be ' + numberOfAssignments +  ' assignment record');
        }
        availabilities = [Select Id, Available__c from Assignment__c];
        for(Assignment__c thisAssignment : availabilities){
            System.assertEquals(thisAssignment.Available__c, Constants.AVAILABLE_ASSIGNMENT_STATUS,
                    'Assignment status must be ' + Constants.AVAILABLE_ASSIGNMENT_STATUS);
        }

    }

    @IsTest
    static void insertAssignmentsWithNotAvailableStatus() {
        TestUtils.insertContactCustomSettings(FALSE);
        for(Contact thisContact : staff){
            thisContact.Status__c = Constants.NOT_AVAILABLE_STATUS;
        }
        Integer numberOfAssignments = Integer.valueOf(Update_Contact__c.getInstance().Number_of_days_Availaible__c);
        List<Assignment__c> availabilities = [Select Id from Assignment__c];
        System.assertEquals(0, availabilities.size(), 'There must be 0 assignment record');

        Test.startTest();
        insert staff;
        Test.stopTest();
        staff = ContactsSelector.getContactsWithRelatedAssignments();
        for(Contact thisContact : staff){
            System.assertEquals(numberOfAssignments, thisContact.Assignments__r.size(), 'There must be ' + numberOfAssignments +  ' assignment record');
        }
        availabilities = [Select Id, Available__c from Assignment__c];
        for(Assignment__c thisAssignment : availabilities){
            System.assertEquals(thisAssignment.Available__c, Constants.NOT_AVAILABLE_ASSIGNMENT_STATUS,
                    'Assignment status must be ' + Constants.NOT_AVAILABLE_ASSIGNMENT_STATUS);
        }

    }

    @IsTest
    static void insertAssignmentsForSpecificRoles() {
        TestUtils.insertContactCustomSettings(TRUE);
        Integer numberOfAssignments = Integer.valueOf(Update_Contact__c.getInstance().Number_of_days_Availaible__c);
        List<Assignment__c> availabilities = [Select Id from Assignment__c];
        System.assertEquals(0, availabilities.size(), 'There must be 0 assignment record');

        for(Contact thisContact : staff){
            thisContact.Role_Global__c = Constants.NP_Role;
        }
        staff[0].Role_Global__c = Constants.RN_Role;
        staff[1].Role_Global__c = Constants.MD_Role;

        Test.startTest();
        insert staff;
        Test.stopTest();
        staff = ContactsSelector.getContactsWithRelatedAssignments();
        for(Contact thisContact : staff){
            if(thisContact.Role_Global__c == Constants.NP_Role){
                System.assertEquals(0, thisContact.Assignments__r.size(), 'There must be 0 assignment record');
            }else{
                System.assertEquals(numberOfAssignments, thisContact.Assignments__r.size(), 'There must be ' + numberOfAssignments +  ' assignment record');
            }
        }

    }

    @IsTest
    static void deleteAssignments() {
        TestUtils.insertContactCustomSettings(FALSE);
        insert staff;
        Integer numberOfAssignments = Integer.valueOf(Update_Contact__c.getInstance().Number_of_days_Availaible__c);
        Integer totalAssignments = bulkNumber * numberOfAssignments;
        List<Assignment__c> availabilities = [Select Id from Assignment__c];
        System.assertEquals(totalAssignments, availabilities.size(), 'There must be ' + totalAssignments +  ' assignment record');

        Test.startTest();
        for(Contact thisContact : staff){
            thisContact.Role_Global__c = Constants.NP_Role;
        }
        delete staff;
        Test.stopTest();
        staff = ContactsSelector.getContactsWithRelatedAssignments();
        availabilities = [Select Id, Available__c from Assignment__c];
        System.assertEquals(0, staff.size(), 'There must be ' + numberOfAssignments +  ' assignment record');
        System.assertEquals(0, availabilities.size(), 'There must be ' + availabilities.size() +  ' assignment record');
    }

    @IsTest
    static void updateAssignmentsToNotAvailable() {
        TestUtils.insertContactCustomSettings(FALSE);
        insert staff;
        Integer numberOfAssignments = Integer.valueOf(Update_Contact__c.getInstance().Number_of_days_Availaible__c);
        Integer totalAssignments = bulkNumber * numberOfAssignments;
        List<Assignment__c> availabilities = [Select Id from Assignment__c WHERE Available__c = :Constants.AVAILABLE_ASSIGNMENT_STATUS];
        System.assertEquals(totalAssignments, availabilities.size(), 'There must be ' + totalAssignments +  ' assignment record');

        Test.startTest();
        for(Contact thisContact : staff){
            thisContact.Status__c = Constants.NOT_AVAILABLE_STATUS;
        }
        update staff;
        Test.stopTest();
        availabilities = [Select Id, Available__c from Assignment__c WHERE Available__c = :Constants.NOT_AVAILABLE_ASSIGNMENT_STATUS];
        System.assertEquals(totalAssignments, availabilities.size(),
                                'There must be ' + availabilities.size() +  ' assignment record with Not available status');
    }
    @IsTest
    static void updateAssignmentsToAvailable() {
        TestUtils.insertContactCustomSettings(FALSE);
        for(Contact thisContact : staff){
            thisContact.Status__c = Constants.NOT_AVAILABLE_STATUS;
        }
        insert staff;
        Integer numberOfAssignments = Integer.valueOf(Update_Contact__c.getInstance().Number_of_days_Availaible__c);
        Integer totalAssignments = bulkNumber * numberOfAssignments;
        List<Assignment__c> availabilities = [Select Id from Assignment__c WHERE Available__c = :Constants.NOT_AVAILABLE_ASSIGNMENT_STATUS];
        System.assertEquals(totalAssignments, availabilities.size(), 'There must be ' + totalAssignments +  ' assignment record');
        Test.startTest();
        for(Contact thisContact : staff){
            thisContact.Status__c = Constants.AVAILABLE_STATUS;
        }
        update staff;
        Test.stopTest();
        availabilities = [Select Id, Available__c from Assignment__c WHERE Available__c = :Constants.AVAILABLE_ASSIGNMENT_STATUS];
        System.assertEquals(totalAssignments, availabilities.size(),
                'There must be ' + availabilities.size() +  ' assignment record with Not available status');
    }
}