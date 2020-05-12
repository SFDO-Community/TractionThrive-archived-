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
 * @description Handler class for Group records
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-05-12
 */
public with sharing class GroupHandler {
    /**
      * @description Creates a new group for each new account created. Uses account record type name and account Id
      *              in the group api name
      * @param       accounts Set of accounts to create groups for
      */
    public static void createAccountGroups(Set<Account> accounts) {
        List<Group> newGroups = new List<Group>();

        for (Account account : accounts) {
            Group readGroup = new Group(
                    Name = generateGroupName(account, Constants.READ_ACCESS),
                    DeveloperName = generateGroupDeveloperName(account.Id, Constants.READ_ACCESS),
                    Type = Constants.GROUP_TYPE_REGULAR,
                    DoesIncludeBosses = FALSE
            );
            newGroups.add(readGroup);

            Group editGroup = new Group(
                    Name = generateGroupName(account, Constants.EDIT_ACCESS),
                    DeveloperName = generateGroupDeveloperName(account.Id, Constants.EDIT_ACCESS),
                    Type = Constants.GROUP_TYPE_REGULAR,
                    DoesIncludeBosses = FALSE
            );
            newGroups.add(editGroup);
        }

        Database.SaveResult[] saveResults = Database.insert(newGroups, false);
        for(Database.SaveResult result : saveResults) {
            if(!result.success) {
                System.debug(result);
            }
        }
    }

    /**
     * @description Deletes each group associated with the list of accounts provided
     * @param       accounts Set of accounts to delete groups for
     */
    public static void deleteAccountGroups(List<Account> accounts) {
        List<Group> groups = getAccountGroups(accounts, null);
        if (!groups.isEmpty()) {
            delete groups;
        }
    }

    /**
     * @description Get the sharing groups associated with the provided set of accounts
     * @param       accounts set of accounts
     * @param       accessLevel - READ = read groups, EDIT = edit groups, null = all groups
     * @return      List of groups
     */
    public static List<Group> getAccountGroups(List<Account> accounts, String accessLevel) {
        Set<String> groupNames = new Set<String>();

        for (Account account : accounts) {
            // Divisions don't have accounts
            if(account.RecordTypeId == Constants.DIVISION_RECORDTYPE_ID){
                continue;
            }
            if(accessLevel == null || accessLevel == Constants.READ_ACCESS) {
                groupNames.add(generateGroupDeveloperName(account.Id, Constants.READ_ACCESS));
            }
            if(accessLevel == null || accessLevel == Constants.EDIT_ACCESS) {
                groupNames.add(generateGroupDeveloperName(account.Id, Constants.EDIT_ACCESS));
            }
        }

        List<Group> groups = GroupsSelector.getAccountGroupsByDeveloperName(groupNames);
        return groups;
    }

    /**
     * @description Given a list of groups, returns the first one that matches the accessType (read, edit)
     * @param       groups
     * @param       accessLevel - read, edit
     * @return      Group
     */
    public static Group getGroupByAccess(List<Group> groups, String accessType){
        Group result;

        String readAccess = Constants.READ_ACCESS + Constants.GROUP_NAME_DELIMITER;
        String editAccess = Constants.EDIT_ACCESS + Constants.GROUP_NAME_DELIMITER;

        for(Group sharingGroup : groups) {
            if(accessType == Constants.READ_ACCESS
                    && sharingGroup.DeveloperName.contains(readAccess)) {
                result = sharingGroup;
                break;
            } else if(accessType == Constants.EDIT_ACCESS
                    && sharingGroup.DeveloperName.contains(editAccess)) {
                result = sharingGroup;
                break;
            }
        }

        return result;
    }

    /**
     * @description Gets the AccountId from the developer name for the group
     * @param       developerName - Group developer name
     * @return      Id - AccountId associated with group
     */
    public static Id getAccountIdFromGroupDeveloperName(String developerName) {
        List<String> parts = developerName.split(Constants.GROUP_NAME_DELIMITER);
        return Id.valueOf(parts[parts.size()-1]);
    }

    /**
     * @description Constructs the name for the group
     * @param       account - account associated with group
     * @param       accessType - read or edit
     * @return      String - Group name
     */
    @TestVisible
    private static String generateGroupName(Account account, String accessType) {
        String prefix = accessType + ': ';
        Integer remainingChars = 40 - prefix.length();
        Integer nameLength = account.Name.length();
        return  prefix + account.Name.substring(0, Math.min(nameLength, remainingChars));
    }

    /**
     * @description Constructs the developer name for the group
     * @param       accountId - account associated with group
     * @param       accessType - read or edit
     * @return      String - Group developer name
     */
    public static String generateGroupDeveloperName(Id accountId, String accessType) {
        return accessType + Constants.GROUP_NAME_DELIMITER + accountId;
    }
}