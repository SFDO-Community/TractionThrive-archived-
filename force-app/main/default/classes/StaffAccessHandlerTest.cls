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
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-05-13
 */
@IsTest
private class StaffAccessHandlerTest {

    private final static String HA_ACCOUNT_NAME = 'Test SAHT Health Auth';
    private final static String HOSP_ACCOUNT_NAME = 'Test SAHT hospital';
    private final static String HOSP_CONTACT_NAME = 'Test SAHT Hosp contact';

    @TestSetup
    static void testSetup() {
        Account healthAuth = TestUtils.createAccountByRecordType(HA_ACCOUNT_NAME, Constants.HEALTH_AUTH_RECORDTYPE_ID, null, TRUE);

        Account hospital = TestUtils.createAccountByRecordType(HOSP_ACCOUNT_NAME, Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, FALSE);
        hospital.Health_Authority__c = HA_ACCOUNT_NAME;
        insert hospital;

        Contact testContact = TestUtils.createCommunityContact(HOSP_CONTACT_NAME, FALSE);
        testContact.AccountId = hospital.Id;
        insert testContact;
    }

    @IsTest
    static void stampStaffIdOnFacility() {
        Account hospital = [SELECT Id, Name FROM Account WHERE RecordTypeId = :Constants.HOSPITAL_RECORDTYPE_ID AND Name = :HOSP_ACCOUNT_NAME];
        Contact testContact = [SELECT Id, Name FROM Contact WHERE AccountId = :hospital.Id LIMIT 1];

        Staff_Access__c testAccess = TestUtils.createReadStaffAccess(testContact.Id, hospital.Id, false);

        Test.startTest();
        insert testAccess;
        Test.stopTest();

        testAccess = [SELECT Id, Staff_Record_ID__c, Staff__c FROM Staff_Access__c WHERE Id = :testAccess.Id];

        System.assertEquals(testAccess.Staff__c, testAccess.Staff_Record_ID__c, 'Expected Id to be stamped correctly in field');
    }
}
