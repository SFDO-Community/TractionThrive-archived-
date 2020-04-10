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
 * @date    2020-03-24
 */
public with sharing class AccountPickerCtrl {

    @AuraEnabled
    public static List<Account> getChildAccounts(Id parentId){
        List<Account> accounts =  AccountsSelector.getChildAccountsByParent(parentId);
        return accounts;
    }

    @AuraEnabled
    public static List<Account> getChildHospitals(String authorityName){
        List<Account> accounts =  AccountsSelector.getHospitalsByAuthorityName(authorityName);
        return accounts;
    }

    @AuraEnabled
    public static AccountData getAccountSelections(){
        AccountData usersAccountData = new AccountData();
        try {
            User currentUser = ContactsSelector.getCurrentUser();
            List<Contact> contacts = ContactsSelector.getCurrentContact(currentUser);

            if (!contacts.isEmpty()) {
                usersAccountData = getValidAccounts();

                if (contacts[0].Account.RecordTypeId == Constants.DIVISION_RECORDTYPE_ID) {
                    usersAccountData.currentDivision = contacts[0].Account;
                    usersAccountData.currentHospital = contacts[0].Account.Parent;
                    usersAccountData.currentHealthAuthority = contacts[0].Account.Health_Authority__c;
                } else if (contacts[0].Account.RecordTypeId == Constants.HOSPITAL_RECORDTYPE_ID) {
                    usersAccountData.currentHospital = contacts[0].Account;
                    usersAccountData.currentHealthAuthority = contacts[0].Account.Health_Authority__c;
                } else if (contacts[0].Account.RecordTypeId == Constants.HEALTH_AUTH_RECORDTYPE_ID) {
                    usersAccountData.currentHealthAuthority = contacts[0].Account.Name;
                }
            } else {
                List<Account> healthAuthorities = AccountsSelector.getAccountByRecordType(Constants.HEALTH_AUTH_RECORDTYPE_ID);
                usersAccountData.healthAuthorities = new List<String>();
                for (Account ha : healthAuthorities) {
                    usersAccountData.healthAuthorities.add(ha.Name);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(JSON.serialize(e.getTypeName() + ': ' + e.getMessage() + ' - ' + e.getStackTraceString()));
        }

        return usersAccountData;
    }

    private static AccountData getValidAccounts(){
        List<Account> divisions =  AccountsSelector.getDivisionTree();

        Map<Id, List<Account>> hospitalDivisionMap = new Map<Id, List<Account>>();
        Map<String, List<Account>> authorityHospitalMap = new Map<String, List<Account>>();
        Set<String> healthAuthorities = new Set<String>();

        for(Account division : divisions) {
            Set<Account> hospitalsInAuthority;
            Set<Account> divisionsInHospital;

            // Create a map of divisions in a given hospital
            if(hospitalDivisionMap.get(division.ParentId) != null) {
                divisionsInHospital = new Set<Account>(hospitalDivisionMap.get(division.ParentId));
            } else {
                divisionsInHospital = new Set<Account>();
            }
            divisionsInHospital.add(division);

            // Create a map of hospitals in a given health authority
            if(authorityHospitalMap.get(division.Health_Authority__c) != null) {
                hospitalsInAuthority = new Set<Account>(authorityHospitalMap.get(division.Health_Authority__c));
            } else {
                hospitalsInAuthority = new Set<Account>();
            }
            hospitalsInAuthority.add(division.parent);

            hospitalDivisionMap.put(division.ParentId, new List<Account>(divisionsInHospital));
            authorityHospitalMap.put(division.Health_Authority__c, new List<Account>(hospitalsInAuthority));
            healthAuthorities.add(division.Health_Authority__c);
        }

        AccountData userAccountData = new AccountData();
        userAccountData.hospitalDivisionMap = hospitalDivisionMap;
        userAccountData.authorityHospitalMap = authorityHospitalMap;
        userAccountData.healthAuthorities = new List<String>(healthAuthorities);

        return userAccountData;
    }

    public class AccountData {

        @AuraEnabled
        public Account currentDivision {get;set;}

        @AuraEnabled
        public Account currentHospital {get;set;}

        @AuraEnabled
        public String currentHealthAuthority {get;set;}

        @AuraEnabled
        public Map<Id, List<Account>> hospitalDivisionMap {get;set;}

        @AuraEnabled
        public Map<String, List<Account>> authorityHospitalMap {get;set;}

        @AuraEnabled
        public List<String> healthAuthorities {get;set;}
    }
}