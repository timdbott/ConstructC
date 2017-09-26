@isTest

public with sharing class AccountTeamMemberCTriggerTest {

    @isTest static void createActTeamMembers() {

        AccountTeamMemberCTriggerHandler obj = new AccountTeamMemberCTriggerHandler();
        List<Account_Team_Member__c> actTeamMbrs = new List<Account_Team_Member__c>();  // custom ATM object
        Set<Id> accountIds = new Set<Id>();
        Id actId;

        // create test accounts
        List<Account> testActs = TestDataFactory.createActs(20, 'test account', 'Customer');

        // create test users
        List<User> testUsrs = TestDataFactory.createUsers(20, 'testing');

        // create Account_Team_Member__c records for each account and all team members (20 max)
        for (Account act : testActs) {
            accountIds.add(act.Id);
            actId = act.Id;
            for (User team : testUsrs) {
                actTeamMbrs.add(new Account_Team_Member__c(Account__c = act.Id,
                    Role__c = 'Specialist',
                    Team_Member__c = team.Id
                    )

                );
            }  // finished adding team members
        }  // finished with all accounts

        insert actTeamMbrs;

        // query Account_Team_Member__c> to determine if the team members were added
        List<Account_Team_Member__c> addedAtmList = [SELECT Id
                                            FROM Account_Team_Member__c
                                            WHERE Account__c IN :accountIds];

        // query AccountTeamMember to determine if the team members were added
        List<AccountTeamMember> addedMemberList = [SELECT Id, UserId, TeamMemberRole, AccountId 
                                            FROM AccountTeamMember
                                            WHERE AccountId IN :accountIds];
        
        system.assertEquals(addedAtmList.size(), addedMemberList.size());
    }

    // when a record is deleted from Account_Team_Member__c then also delete from AccountTeamMember
    @isTest static void deleteActTeamMembers() {
        
        AccountTeamMemberCTriggerHandler obj = new AccountTeamMemberCTriggerHandler();
        List<Account_Team_Member__c> actTeamMbrs = new List<Account_Team_Member__c>();  // custom ATM object
        Set<Id> accountIds = new Set<Id>();
        Id actId;

        // create test accounts
        List<Account> testActs = TestDataFactory.createActs(5, 'test account for del actTeamMbrs', 'Customer');

        // create test users
        List<User> testUsrs = TestDataFactory.createUsers(20, 'testing');

        // create Account_Team_Member__c records for each account and all team members (20 max)
        for (Account act : testActs) {
            accountIds.add(act.Id);
            actId = act.Id;
            for (User team : testUsrs) {
                actTeamMbrs.add(new Account_Team_Member__c(Account__c = act.Id,
                    Role__c = 'Specialist',
                    Team_Member__c = team.Id
                    )

                );
            }  // finished adding team members
        }  // finished with all accounts

        insert actTeamMbrs;

        // delete a team member from the first account
        system.debug('delUserId : ' + testUsrs[0].Id + ' __ delActId : ' + testActs[0].Id);
        Id delUserId = testUsrs[0].Id;
        Id delActId = testActs[0].Id;

        List<Account_Team_Member__c> deletedList = [SELECT ID, Team_Member__c, Account__c 
                                                    FROM Account_Team_Member__c
                                                    WHERE Account__c = :delActId AND Team_Member__c = :delUserId];

        delete deletedList;

        // query Account_Team_Member__c> to determine if the team members were deleted
        List<Account_Team_Member__c> atmList = [SELECT Id
                                                FROM Account_Team_Member__c
                                                WHERE Account__c IN :accountIds AND Team_Member__c = :delUserId];

        // query AccountTeamMember to determine if the team members were deleted
        List<AccountTeamMember> updatedMemberList = [SELECT Id, UserId, TeamMemberRole, AccountId 
                                                        FROM AccountTeamMember
                                                        WHERE AccountId IN :accountIds AND UserId = :delUserId];
        
        system.assertEquals(atmList.size(), updatedMemberList.size());
    }
}