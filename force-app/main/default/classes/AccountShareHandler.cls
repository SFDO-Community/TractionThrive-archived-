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
 * @description Handler class for AccountShare records
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-05-12
 */
public with sharing class AccountShareHandler {

    /**
     * @description Creates and returns an accountshare record
     * @param       accId - account to share
     * @param       userOrGroupId - user/group shared to
     * @param       accessLevel - access given
     * @return      AccountShare record
     */
    public static AccountShare getAccountShare(Id accId, Id userOrGroupId, String accessLevel){
        AccountShare accShare = new AccountShare (
                AccountId = accId,
                UserOrGroupId = userOrGroupId,
                AccountAccessLevel = accessLevel,
                OpportunityAccessLevel = Constants.READ_ACCESS,
                RowCause = Constants.SHARING_REASON_MANUAL
        );

        // Needed for the open security model, cannot write to this field when contact is controlled by parent
        if(Schema.SObjectType.AccountShare.fields.ContactAccessLevel.isUpdateable() == TRUE) {
            accShare.ContactAccessLevel = accessLevel;
        }

        return accShare;
    }

    /**
     * @description Creates and returns the required account share records for the given account to the given group
     * @param       accountIdToShare Id of the account you are sharing. I.e. division Id
     * @param       groupAccountId Id of the account you are sharing to I.e. the divisions parent account id
     * @param       accountToGroupMap Map if account Ids to a list of their sharing groups
     * @return      List of account shares to insert
     */
    public static List<AccountShare> createAccountSharesWithGroup(Id accountIdToShare, Id groupAccountId, Map<Id, List<Group>> accountToGroupMap) {
        List<AccountShare> accountShares = new List<AccountShare>();
        Group readGroup = GroupHandler.getGroupByAccess(accountToGroupMap.get(groupAccountId), Constants.READ_ACCESS);
        Group editGroup = GroupHandler.getGroupByAccess(accountToGroupMap.get(groupAccountId), Constants.EDIT_ACCESS);

        AccountShare readShare = AccountShareHandler.getAccountShare(accountIdToShare, readGroup.Id, Constants.READ_ACCESS);
        accountShares.add(readShare);
        AccountShare editShare = AccountShareHandler.getAccountShare(accountIdToShare, editGroup.Id, Constants.EDIT_ACCESS);
        accountShares.add(editShare);

        return accountShares;
    }
}