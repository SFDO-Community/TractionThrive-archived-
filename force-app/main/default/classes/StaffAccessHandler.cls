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
public with sharing class StaffAccessHandler {

    private List<Staff_Access__c> access;
    private Map<Id, Staff_Access__c> oldAccess;

    /**
    * @description          Constructor
    *
    * @param access     [Trigger.new access]
    * @param oldAccess  [Trigger.oldMap access]
    */
    public StaffAccessHandler(List<Staff_Access__c> access, Map<Id, Staff_Access__c> oldAccess) {
        this.access = access;
        this.oldAccess = oldAccess;
    }

    /**
     * @description Stamps the staff id on the record for duplicate rule
     */
    public void stampStaffIdOnRecord(){
        if(!Schema.SObjectType.AccountShare.isCreateable()) {
            throw new AuraHandledException('User has no permission to perform this action');
        }

        for(Staff_Access__c thisAssignment : access){
            thisAssignment.Staff_Record_ID__c = thisAssignment.Staff__c;
        }
    }
}