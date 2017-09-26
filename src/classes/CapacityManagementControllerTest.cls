@isTest
public with sharing class CapacityManagementControllerTest {
	public class MyException extends Exception{}
    
    @isTest static void testAddCase() {
        
        String caseOrigin = 'Email';
        String caseStatus = 'New';
        String caseType = 'Applications';
        String caseGeo = 'AMER';
        Integer numCasesToCreate = 20;
        Boolean globalCase = false;
        List<Id> caseIds;
        List<Case> unassignedCases;
        List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        //Fetching the assignment rules on case
		AssignmentRule AR = new AssignmentRule();
		AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true];

		//Creating the DMLOptions for "Assign using active assignment rules" checkbox
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;

        // add cases
        for (Integer j = 0; j < numCasesToCreate; j++) {
            Case newCase = new Case(Origin = caseOrigin, 
            					Status = caseStatus, 
            					RecordTypeId = caseRcrdTyp,
            					Type = caseType,
            					Region__c = caseGeo);

			//Setting the DMLOption on Case instance
			newCase.setOptions(dmlOpts);
			cases.add(newCase);
        }
        
        //insert cases;
        Database.insert(cases);

        List<Case> insertedCases = [SELECT Id, OwnerId, Owner.Type, Type, Status 
        							FROM Case 
        							WHERE Id in :cases];

        unassignedCases = CapacityManagementController.getUnassignedCases(caseType);

        // Case.Owner.Type is null when creating cases that are assigned to a queue in a test class
        // so this SELECT removes that criteria and allows this test to pass
        /*
        unassignedCases = [SELECT Id, OwnerId, CaseNumber, Type, Region__c, Days__c, Status, Owner.Type,
                            Requested_Service__c, Service_Requested_By_Name__c, Requested_Completion_Date__c,
                            AccountId, Account_Name_Text__c, Account_Classification__c,
                            Opportunity_Est_Disc_Sales__c, Opportunity_Name__c
                            FROM Case 
                            WHERE Status IN ('New','On Schedule','Behind Schedule')
                            AND Type = :caseType
                            AND Administrative_for_CM__c != true
                            ORDER BY Requested_Completion_Date__c ASC
                            LIMIT 20];
        */
        
        //system.debug('unassignedCases count: ' + unassignedCases.size());

        for ( Case c : unassignedCases ) {
        	system.debug('id: ' + c.Id + ' - type ' + c.OwnerId.getSObjectType() + ' - status: ' + c.Status);
        	Id testId = c.Id;
        	//String testUser = c.Owner.Type;
        	String testType = c.Type;
        	String testStatus = c.Status;
        }
        

        system.assertEquals(numCasesToCreate, unassignedCases.size());
    }

    @isTest static void testFindCustomerCases() {

		// * Create an account
		Integer numToInsert = 1;
		String accountName = 'test Act for testFindAccountCases';
		String accountType = 'Customer';
    	List<Account> acts = new List<Account>();
        Id actDlrRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(accountType).getRecordTypeId();
        Integer rand = Math.round(Math.random()*10000000);
        rand = Math.mod(rand, 99999999);
        String siteId = String.valueOf(rand);

        // add account
        for (Integer j = 0; j < numToInsert; j++) {
            system.debug('new act name: ' + accountName + j);
            acts.add(new Account(Name = accountName  + j,
                                Site_ID__c = siteId + j,
                                RecordTypeId = actDlrRecordType
                                )
            );
        }

        // insert the account
        insert acts;

        Id accountId = acts[0].Id;

        // * Create cases for this account
        String caseOrigin = 'Email';
        String caseStatus = 'Closed';
        String caseType = 'no type';
        //String caseGeo = 'AMER';
        Integer numCasesToCreate = 20;
        Boolean globalCase = false;
        List<Id> caseIds;
        List<Case> unassignedCases;
        List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        // add owned cases
        for (Integer j = 0; j < numCasesToCreate; j++) {
            Case newCase = new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
            					RecordTypeId = caseRcrdTyp,
            					AccountId = accountId,
            					OwnerId = UserInfo.getUserId(),
            					Type = caseType);

			//Setting the DMLOption on Case instance
			cases.add(newCase);
        }
        
        //insert owned cases;
        insert cases;

		List<Case> actCases = CapacityManagementController.getAccountCases(accountId);

		// Case.Owner.Type is null when creating cases that are assigned to a queue in a test class
        // so this SELECT removes that criteria and allows this test to pass
        /*
        actCases = [SELECT Id, AccountId, OwnerId, Owner.Type, Type, Status 
					FROM Case 
					WHERE AccountId = :accountId
					LIMIT 10];
		*/

		for ( Case c : actCases ) {
        	system.debug('id: ' + c.Id + ' - OwnerType ' + c.OwnerId.getSObjectType());
        	//system.debug('id: ' + c.Id + ' - OwnerId ' + c.Type + ' - Owner Type ' + c.Status);
        	Id testId = c.Id;
        	//String testUser = c.Owner.Type;
        	String testType = c.Type;
        	String testStatus = c.Status;
        }


		system.assertEquals(10, actCases.size());
    }

    @isTest static void testFindSrnUsers() {

    	// file srNetwork profile
    	List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'srNetwork'];

    	Id srnProfileId = profiles[0].Id;

    	// create new srNetwork user
    	List<User> newUsers = new List<User>();

    	newUsers.add(new User(Alias = 'testUser', 
                    Email = 'testUser@email.com',
                    UserName = 'testUser' + 'standarduser@testorg.com',
                    LastName = 'bott',
                    EmailEncodingKey = 'UTF-8', 
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    ProfileId = srnProfileId
                    )
            );

    	insert newUsers;

    	// find the new user
    	List<User> users = [SELECT Id, ProfileId FROM User WHERE ProfileId = :srnProfileId AND Name LIKE 'bott'];

    	// use CM controller to find the new user
    	List<User> cmUsers = CapacityManagementController.getSrnUsers('bott');

    	system.assertEquals(users.size(), cmUsers.size());
    }

    @isTest static void testFindRequestTypes() {

    	List<String> options = new List<String>();

        Schema.DescribeFieldResult fieldResult = Case.Type.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.add(f.getValue());
        }

        List<String> cmOptions = CapacityManagementController.getRequestTypes();

        system.assertEquals(options, cmOptions);
    }

    @isTest static void testReassignCase() {

    	String caseOrigin = 'Email';
        String caseStatus = 'New';
        String caseType = 'Applications';
        String caseGeo = 'AMER';
        Integer numCasesToCreate = 1;
        Boolean globalCase = false;
        List<Id> caseIds;
        List<Case> unassignedCases;
        List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        // add case
        for (Integer j = 0; j < numCasesToCreate; j++) {
            Case newCase = new Case(Origin = caseOrigin, 
            					Status = caseStatus, 
            					RecordTypeId = caseRcrdTyp,
            					Type = caseType,
            					Region__c = caseGeo);

			cases.add(newCase);
        }
        
        insert cases;

        // find case
        List<Case> insertedCases = [SELECT Id, OwnerId, Owner.Type, Type, Status 
        							FROM Case 
        							WHERE Id in :cases];

        String caseId = insertedCases[0].Id;
        String ownerId = insertedCases[0].OwnerId;

		// reassign case
        CapacityManagementController.reassignCase(caseId, UserInfo.getUserId());

        // find case
        List<Case> updatedCases = [SELECT Id, OwnerId, Owner.Type, Type, Status 
        							FROM Case 
        							WHERE Id = :caseId];

		system.assertEquals(UserInfo.getUserId(), updatedCases[0].OwnerId);
    }
}