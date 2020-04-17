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
 * @date    2020-03-26
 */

global with sharing class CreateAvailabilityBatch implements Schedulable, Database.Batchable<SObject>  {

    public Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'SELECT Id, Role_Global__c, Status__c, ' +
                                 '(' +
                                    'SELECT Date__c from Assignments__r ' +
                                    'WHERE Staff__c != NULL AND Date__c >= TODAY ' +
                                    'ORDER BY Date__c ' +
                                    'DESC LIMIT 1 '+
                                 ') '+
                              'FROM Contact';
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext BC, List<Contact> contacts){
        AvailabilityService.createAvailabilityRecords(contacts);
    }

    public void execute(SchedulableContext ctx) {
        CreateAvailabilityBatch batchInstance = new CreateAvailabilityBatch();
        Database.executeBatch(batchInstance);
    }
    public void finish(Database.BatchableContext BC) {
        // Nothing to do here, but method must be implemented
    }
}