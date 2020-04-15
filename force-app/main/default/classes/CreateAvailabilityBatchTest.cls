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

@IsTest
private class CreateAvailabilityBatchTest {
    public static Integer bulkNumber = 200;
    public static List<Contact> staff;

    static{
        TestUtils.insertContactCustomSettings(FALSE);
        Account careCenter = TestUtils.createCommunityAccount('Test Account', TRUE);
        staff = TestUtils.createBulkContacts(FALSE, bulkNumber, careCenter.Id);
    }

    @IsTest
    static void createAvailabilityWithAvailableStatus() {
        insert staff;
        List<Assignment__c> availabilities = [Select Id from Assignment__c];
        Integer defaultAvailabilities = Integer.ValueOf(Update_Contact__c.getInstance().Number_of_days_Availaible__c) * bulkNumber;
        Integer TotalAssignments = defaultAvailabilities + bulkNumber;
        System.assertEquals(defaultAvailabilities, availabilities.size(), 'There must be ' + defaultAvailabilities + ' assignment records');

        Test.startTest();
        SchedulableContext sc = null;
        CreateAvailabilityBatch availabilityBatch = new CreateAvailabilityBatch();
        availabilityBatch.execute(sc);
        Test.stopTest();

        availabilities = [Select Staff__c, Available__c from Assignment__c];
        for(Assignment__c thisAssignment : availabilities){
            System.assertEquals(thisAssignment.Available__c, Constants.AVAILABLE_ASSIGNMENT_STATUS,
                    'Assignment status must be ' + Constants.AVAILABLE_ASSIGNMENT_STATUS);
        }
        System.assertEquals(TotalAssignments, availabilities.size(), 'There must be ' + TotalAssignments + ' assignment records');
    }

    @IsTest
    static void createAvailabilityWithNotAvailableStatus() {
        for(Contact thisContact : staff){
            thisContact.Status__c = Constants.NOT_AVAILABLE_STATUS;
        }
        insert staff;
        List<Assignment__c> availabilities = [Select Id from Assignment__c];
        Integer defaultAvailabilities = Integer.ValueOf(Update_Contact__c.getInstance().Number_of_days_Availaible__c) * bulkNumber;
        Integer TotalAssignments = defaultAvailabilities + bulkNumber;
        System.assertEquals(defaultAvailabilities, availabilities.size(), 'There must be ' + defaultAvailabilities + ' assignment records');

        Test.startTest();
        SchedulableContext sc = null;
        CreateAvailabilityBatch availabilityBatch = new CreateAvailabilityBatch();
        availabilityBatch.execute(sc);
        Test.stopTest();

        availabilities = [Select Staff__c, Available__c from Assignment__c];
        for(Assignment__c thisAssignment : availabilities){
            System.assertEquals(thisAssignment.Available__c, Constants.NOT_AVAILABLE_ASSIGNMENT_STATUS,
                                                    'Assignment status must be ' + Constants.NOT_AVAILABLE_ASSIGNMENT_STATUS);
        }
        System.assertEquals(TotalAssignments, availabilities.size(), 'There must be ' + TotalAssignments + ' assignment records');
    }

}
