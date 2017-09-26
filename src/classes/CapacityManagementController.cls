public with sharing class CapacityManagementController {

    
    // * used to determine GEO for current user
    public static String getUserGeo() {

        String geo;

        List<User> users = [SELECT Sales_Geography__c FROM User WHERE Id = :UserInfo.getUserId()];

        geo = users[0].Sales_Geography__c;

        return geo;
    }

	@AuraEnabled
    // * used in CapacityManagementCases.cmp
    public static List<Case> getUnassignedCases(String caseRqstType) {
        
        List<Case> caseList = new List<Case>();
        List<Case> cases;
        String usersGeo = getUserGeo();

        system.debug('getUnassignedCases.caseRqstType: ' + caseRqstType);

        // find all open cases
        if (String.isBlank(caseRqstType) || caseRqstType == 'All') {

            cases = [SELECT Id, CaseNumber, Type, OwnerId, Region__c, Days__c, Status,
                            Requested_Service__c, Service_Requested_By_Name__c, Requested_Completion_Date__c,
                            AccountId, Account_Name_Text__c, Account_Classification__c,
                            Opportunity_Est_Disc_Sales__c, Opportunity_Name__c
                            FROM Case 
                            WHERE Administrative_for_CM__c != true
                            AND Status IN ('New','On Schedule','Behind Schedule')
                            AND Region__c = :usersGeo
                            ORDER BY Requested_Completion_Date__c ASC];
        } else {

            cases = [SELECT Id, CaseNumber, Type, OwnerId, Region__c, Days__c, Status,
                            Requested_Service__c, Service_Requested_By_Name__c, Requested_Completion_Date__c,
                            AccountId, Account_Name_Text__c, Account_Classification__c,
                            Opportunity_Est_Disc_Sales__c, Opportunity_Name__c
                            FROM Case 
                            WHERE Type = :caseRqstType
                            //WHERE Case.Owner.Type = 'Queue'
                            AND Status IN ('New','On Schedule','Behind Schedule')
                            AND Region__c = :usersGeo
                            AND Administrative_for_CM__c != true
                            ORDER BY Requested_Completion_Date__c ASC];
        }

        // find the ones still in a queue
        for (Case c : cases) {
            //system.debug('c.OwnerId.getSObjectType(): ' + c.OwnerId.getSObjectType());
            if (c.OwnerId.getSObjectType() == Group.SObjectType) {

                caseList.add(c);
            }
        }
        return caseList;
    }

    @AuraEnabled
    // * used in CapacityManagementCasesRow.cmp
    public static List<Case> getAccountCases(String actId) {

        List<Case> caseList = new List<Case>();

        // find all cases for this account
        List<Case> cases = [SELECT Id, Type, OwnerId, Owner.Name, Opportunity_Name__c, Account_Name_Text__c, 
                                Requested_Service__c, Service_Requested_By_Name__c, Requested_Completion_Date__c,
                                Days__c, Status
                            FROM Case 
                            WHERE AccountId = :actId
                            //AND Case.Owner.Type != 'Queue'
                            ORDER BY Requested_Completion_Date__c DESC
                            LIMIT 10];

        // find the ones that are not in a queue
        for (Case c : cases) {
            
            if (c.OwnerId.getSObjectType() != Group.SObjectType) {

                caseList.add(c);
            }
        }
        return caseList;
    }

    @AuraEnabled
    // * used in CapacityManagementCasesUserLookup.cmp
    public static List<User> getSrnUsers(String name) {

        List<User> users = [SELECT Id, Name, SmallPhotoUrl
                            FROM User 
                            WHERE Name LIKE :name
                            AND IsActive = true
                            AND ProfileId = '00e37000000MmErAAK'
                            ORDER BY Name DESC];

        return users;
    }

    @AuraEnabled
    // * used in CapacityManagement.cmp
    public static List<String> getRequestTypes() {

        List<String> options = new List<String>();

        Schema.DescribeFieldResult fieldResult = Case.Type.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.add(f.getValue());
        }

        return options;
    }

    @AuraEnabled
    // * used in CapacityManagementCasesRow.cmp, CapacityManagementCasesUserLookup.cmp
    public static Case reassignCase(String caseId, String ownerId) {

        system.debug('reassignCase caseId: ' + caseId + ' - ownerId: ' + ownerId);

        Case updatedCase;
        List<Case> casesToUpdate = new List<Case>{};
        List<Case> cases = [SELECT Id FROM Case WHERE Id = :caseId];

        for (Case c : cases) {

            Database.DMLOptions dmo = new Database.DMLOptions();

            // set asssignment to use the default rule
            dmo.EmailHeader.triggerAutoResponseEmail = true;
            dmo.EmailHeader.triggerUserEmail = true;
            c.setOptions(dmo);

            c.OwnerId = ownerId;

            casesToUpdate.add(c);

            updatedCase = c;
        }

        try {
            //update cases;
            Database.update(casesToUpdate);
        } catch(DmlException e) {
            system.debug('error reassigning this case: ' + e);
            throw new AuraHandledException('error reassigning this case: ' + e);
        }

        return updatedCase;
    }
}