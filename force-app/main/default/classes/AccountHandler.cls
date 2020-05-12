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
}