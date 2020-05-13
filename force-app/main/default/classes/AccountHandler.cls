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
 * @description Handler class for account records
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-05-12
 */
public with sharing class AccountHandler {

    /**
     * @description Stamps Health Authority Name on insert of a facility to the Health Authority field
     * @param       newAccounts Newly inserted accounts
     */
    public void handleStampingHealthAuthorityOnFacility(List<Account> newAccounts) {
        Set<Id> parentAccountIds = new Set<Id>();

        for (Account account : newAccounts) {
            parentAccountIds.add(account.ParentId);
        }

        Map<Id, Account> parentAccountsByIds = new Map<Id, Account>(AccountsSelector.getAccountHierarchyAccounts(parentAccountIds));
        for (Account account : newAccounts) {
            if (account.RecordTypeId == Constants.HOSPITAL_RECORDTYPE_ID) {
                if (account.ParentId != null && parentAccountsByIds.containsKey(account.ParentId)) {
                    account.Health_Authority__c = parentAccountsByIds.get(account.ParentId).Name;
                }
            } else if (account.RecordTypeId == Constants.DIVISION_RECORDTYPE_ID) {
                if (account.ParentId != null
                        && parentAccountsByIds.containsKey(account.ParentId)
                        && parentAccountsByIds.get(account.ParentId).ParentId != null) {
                    account.Health_Authority__c = parentAccountsByIds.get(account.ParentId).Parent.Name;
                }
            } else {
                account.Health_Authority__c = account.Name;
            }
        }
    }

    /**
     * @description Handles sharing of child accounts to the group associated with the parent account
     * @param       newAccountMap Newly inserted accounts
     */
    public void handleAccountSharing(Map<Id, Account> newAccountMap) {
        Set<Account> parentAccounts = new Set<Account>();
        Set<Account> childFacilities = new Set<Account>();

        for (Account account : newAccountMap.values()) {
            if (account.RecordTypeId == Constants.HEALTH_AUTH_RECORDTYPE_ID) {
                parentAccounts.add(account);
            } else if (account.RecordTypeId == Constants.HOSPITAL_RECORDTYPE_ID) {
                parentAccounts.add(account);
                childFacilities.add(account);
            } else if (account.RecordTypeId == Constants.DIVISION_RECORDTYPE_ID) {
                childFacilities.add(account);
            }
        }

        if (!parentAccounts.isEmpty()) {
            GroupHandler.createAccountGroups(parentAccounts);
        }

        if (!childFacilities.isEmpty()) {
            createSharesWithParentAccountGroups(childFacilities);
        }
    }

    /**
     * @description Handles deletion of accounts and the related cleanup
     * @param       oldAccountMap list of accounts being deleted
     */
    public void handleAccountDeletion(Map<Id, Account> oldAccountMap) {
        List<Account> parentAccounts = new List<Account>();

        for (Account account : oldAccountMap.values()) {
            if (account.RecordTypeId == Constants.HOSPITAL_RECORDTYPE_ID
                    || account.RecordTypeId == Constants.HEALTH_AUTH_RECORDTYPE_ID) {
                parentAccounts.add(account);
            }
        }

        if (!parentAccounts.isEmpty()) {
            GroupHandler.deleteAccountGroups(parentAccounts);
        }
    }

    /**
     * @description Shares the given list of accounts with the group associated with their parent account
     * @param       accounts List of accounts to create shares for
     */
    private void createSharesWithParentAccountGroups(Set<Account> accounts) {
        List<Account> parentAccounts = AccountsSelector.getParentAccounts(accounts);

        if(!parentAccounts.isEmpty()){
            List<Group> groups = GroupHandler.getAccountGroups(parentAccounts, null);
            Map<Id, List<Group>> parentAccountGroupsMap = getAccountToGroupsMap(groups);

            // Generate a map of health authority names to Ids
            Map<String, Id> healthAuthNameIdMap = new Map<String, Id>();
            for(Account parentAccount : parentAccounts) {
                if(parentAccount.RecordTypeId == Constants.HEALTH_AUTH_RECORDTYPE_ID){
                    healthAuthNameIdMap.put(parentAccount.Name,parentAccount.Id);
                }
            }

            List<AccountShare> accShares = new List<AccountShare>();
            for (Account account : accounts) {

                // Share accounts to the group associated with their parent. I.e. share divisions to the hospital group and
                // hospitals to health authorities
                if (parentAccountGroupsMap.get(account.ParentId) != null) {
                    accShares.addAll(
                            AccountShareHandler.createAccountSharesWithGroup(account.Id, account.ParentId, parentAccountGroupsMap));
                }

                // Share divisions to the group associated with their health authority
                if(account.RecordTypeId == Constants.DIVISION_RECORDTYPE_ID) {
                    Id healthAuthId = healthAuthNameIdMap.get(account.Health_Authority__c);
                    if(healthAuthId != null) {
                        accShares.addAll(
                                AccountShareHandler.createAccountSharesWithGroup(account.Id, healthAuthId, parentAccountGroupsMap));
                    }
                }
            }
            if(!accShares.isEmpty()) {
                insert accShares;
            }
        }
    }

    /**
     * @description Creates a map of accounts ids to their respective sharing groups
     * @param       accounts set of accounts
     * @param       accessLevel accessLevel of group to get. READ, EDIT (NULL = all)
     * @return      Map of account id to list of groups
     */
    public static Map<Id, List<Group>> getAccountToGroupsMap(List<Group> groups ) {
        Map<Id, List<Group>> accountToGroupMap = new Map<Id, List<Group>>();

        for(Group accGroup : groups) {
            List<Group> accGroups = new List<Group>();

            Id accountId = GroupHandler.getAccountIdFromGroupDeveloperName(accGroup.DeveloperName);

            if(accountToGroupMap.get(accountId) != null) {
                accGroups.addAll(accountToGroupMap.get(accountId));
            }

            accGroups.add(accGroup);
            accountToGroupMap.put(accountId, accGroups);
        }

        return accountToGroupMap;
    }
}