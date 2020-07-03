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
 * @description Selector class for account records
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-03-24
 */
public with sharing class AccountsSelector {

    /**
     * @description Gets accounts with a specific record type
     * @param       recordTypeId
     * @return      List of accounts
     */
    public static List<Account> getAccountByRecordType(Id recordTypeId) {
        List<Account> accounts = [
                SELECT  Id,
                        Name
                FROM    Account
                WHERE   RecordTypeId = :recordTypeId
        ];
        accounts.sort();
        return accounts;
    }

    /**
     * @description Gets an accounts child accounts
     * @param       parentId Id of parent account
     * @return      List of accounts
     */
    public static List<Account> getChildAccountsByParent(Id parentId) {
        List<Account> accounts = [
                SELECT  Id,
                        Name
                FROM    Account
                WHERE   ParentId = :parentId
        ];
        accounts.sort();
        return accounts;
    }

    /**
     * @description Gets all child hospitals for the given authority name
     * @param       authorityName Health Authority's name
     * @return      List of accounts
     */
    public static List<Account> getHospitalsByAuthorityName(String authorityName) {
        List<Account> accounts = [
                SELECT  Id,
                        Name
                FROM    Account
                WHERE   Parent.Name = :authorityName
                AND     RecordTypeId = :Constants.HOSPITAL_RECORDTYPE_ID
        ];
        accounts.sort();
        return accounts;
    }

    /**
     * @description Gets all divisions and their parent hospitals and health authority names
     * @return      List of accounts
     */
    public static List<Account> getDivisionTree() {
        List<Account> accounts = [
                SELECT  Id,
                        Name,
                        Health_Authority__c,
                        ParentId,
                        Parent.Name,
                        Parent.Health_Authority__c,
                        Parent.ParentId,
                        Parent.Parent.Name,
                        Parent.Parent.Health_Authority__c,
                        RecordTypeId
                FROM    Account
                WHERE   RecordTypeId = :Constants.DIVISION_RECORDTYPE_ID
        ];
        accounts.sort();
        return accounts;
    }
    
    /**
     * @description Gets a list of accounts and their names
     * @param       accountIds
     * @return      List of accounts
     */
    public static List<Account> getAccount(Set<Id> accountIds) {
        List<Account> accounts = [
                SELECT  Id,
                        Name
                FROM    Account
                WHERE   ID IN :accountIds
        ];
        return accounts;
    }

    /**
     * @description Gets a list of accounts and their names
     * @param       accountIds
     * @return      List of accounts
     */
    public static List<Account> getAccountsForExternalId(Set<Id> accountIds) {
        List<Account> accounts = [
                SELECT  Id,
                        Name,
                        ShippingLatitude,
                        ShippingLongitude,
                        RecordTypeId,
                        External_ID__c
                FROM    Account
                WHERE   ID IN :accountIds AND External_ID__c = NULL AND ShippingLongitude != NULL AND ShippingLatitude != NULL
        ];
        return accounts;
    }
}
