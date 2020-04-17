/**
* Copyright (c) 2012, FinancialForce.com, inc
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
*   are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice,
*      this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.
* - Neither the name of the FinancialForce.com, inc nor the names of its contributors
*      may be used to endorse or promote products derived from this software without
*      specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
*  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
*  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
*  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
*  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
* Base class aiding in the implementation of a Domain Model around SObject collections
*
* Domain (software engineering). “a set of common requirements, terminology, and functionality
* for any software program constructed to solve a problem in that field”,
* http://en.wikipedia.org/wiki/Domain_(software_engineering)
*
* Domain Model, “An object model of the domain that incorporates both behavior and data.”,
* “At its worst business logic can be very complex. Rules and logic describe many different "
* "cases and slants of behavior, and it's this complexity that objects were designed to work with...”
* Martin Fowler, EAA Patterns
* http://martinfowler.com/eaaCatalog/domainModel.html
*
**/
@isTest(isParallel=true)
public with sharing class SObjectDomainTest {

    @isTest 
    static void test() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today().addMonths(24),
            StageName = 'Prospecting',
            Type = 'New Customer'
        );
        insert opp;

        
        Map<Id, sObject> sObjectMap = new Map<Id, sObject> {
            opp.Id => opp
        };


        SObjectDomain.TestSObjectDomain sob = new SObjectDomain.TestSObjectDomain(new List<Opportunity>{opp});
        sob.handleBeforeDelete();
        sob.handleAfterUpdate(sObjectMap);
        sob.handleAfterUndelete();
        sob.onValidate(sObjectMap);
        sob.onBeforeDelete();
        sob.onBeforeInsert();
        sob.onBeforeUpdate(sObjectMap);
        sob.onAfterInsert();
        sob.onAfterUpdate(sObjectMap);
        sob.onAfterDelete();
        sob.onAfterUndelete();
        sob.handleBeforeInsert();
        sob.handleBeforeUpdate(sObjectMap);
        sob.handleAfterInsert();
        sob.onApplyDefaults();
        
        System.assertNotEquals(null, opp.Id);
    }
    
    @isTest
    static void testError() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity 2',
            CloseDate = Date.today().addMonths(24),
            StageName = 'Prospecting',
            Type = 'New Customer'
        );
        insert opp;

        
        SObjectDomain.TestSObjectDomain sob = new SObjectDomain.TestSObjectDomain(new List<Opportunity>{opp});

        SObjectDomain.Errors.error('Test Error 1', opp);
        SObjectDomain.Errors.error('Test Error 2', opp, Opportunity.Type);
        SObjectDomain.Errors.clearAll();

        System.assertNotEquals(null, SObjectDomain.Errors.getAll());
        System.assertNotEquals(null, sob.error('Test Error 3', opp));
        System.assertNotEquals(null, sob.error('Test Error 4', opp, Opportunity.Type));
    }

    @isTest
    static void test2() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity 3',
            CloseDate = Date.today().addMonths(24),
            StageName = 'Prospecting',
            Type = 'New Customer'
        );
        insert opp;
        
        Map<Id, sObject> sObjectMap = new Map<Id, sObject> {
            opp.Id => opp
        };

        List<sObject> records = new List<sObject> {
            opp
        };
        
        

        SObjectDomain.Test.Database.onInsert(records);
        SObjectDomain.Test.Database.onUpdate(records, sObjectMap);
        SObjectDomain.Test.Database.onDelete(sObjectMap);
        SObjectDomain.Test.Database.onUndelete(records);

        System.assertNotEquals(false, SObjectDomain.Test.Database.hasRecords());
        
    }
}

