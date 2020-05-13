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
 * @date    2020-05-12
 */
public with sharing class AccountService {

    private final static Traction_Thrive_Setting__mdt setting = Constants.getTractionThriveSettingByName(Constants.COMMUNITY_SETTINGS);

    /**
     * @description Before insert trigger logic
     * @param       newAccountList newly inserted accounts
     */
    public static void onBeforeInsertUpdate(List<Account> newAccountList) {
        AccountHandler accountHandler = new AccountHandler();
        accountHandler.handleStampingHealthAuthorityOnFacility(newAccountList);
    }

    /**
     * @description After insert trigger logic
     * @param       newAccountMap newly inserted accounts
     */
    public static void onAfterInsert(Map<Id, Account> newAccountMap) {
        AccountHandler accountHandler = new AccountHandler();
        if(setting.Private_Security_Enabled__c) {
            accountHandler.handleAccountSharing(newAccountMap);
        }
    }

    /**
     * @description After delete trigger logic
     * @param       oldAccountMap newly deleted accounts
     */
    public static void onAfterDelete(Map<Id, Account> oldAccountMap) {
        AccountHandler accountHandler = new AccountHandler();
        if(setting.Private_Security_Enabled__c) {
            accountHandler.handleAccountDeletion(oldAccountMap);
        }
    }
}