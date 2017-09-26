@isTest
public with sharing class ScheduleControllerTest {
	public class MyException extends Exception{}

	// used for createUsers to attempt a unique userName
    @isTest static String getUserNamePrefix(){

        return UserInfo.getOrganizationId() + System.now().millisecond();
    }

	@isTest static void getSrnUsers_Test() {

		// create user with srNetwork profile in my region
		List<User> u = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'srNetwork']; 
        String alias = 'tstUsr';
        String email = 'srNuser@testorg.com';
        String userName = 'srNuser@testorg.com';
        Integer numToInsert = 2;
        String lastName = 'testLastName';

        // get users geography
        String geo = CapacityManagementController.getUserGeo();

        for (Integer j = 0; j < numToInsert; j++) {
            userName = j + userName;
            //system.debug('new userName : ' + getUserNamePrefix() + 'standarduser@testorg.com');
            userName = getUserNamePrefix() + j;

            u.add(new User(Alias = alias, 
                    Email = email,
                    UserName = userName + 'srNuser@testorg.com',
                    LastName = lastName + j,
                    EmailEncodingKey = 'UTF-8', 
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    srNetwork_Team__c = 'Graphic Design',
                    Sales_Geography__c = geo,
                    ProfileId = p.Id
                    )
            );
        }

        List<User> users = [SELECT Id, Name, srNetwork_Team__c
                    FROM User
                    WHERE srNetwork_Team__c != null
                    AND Sales_Geography__c = :geo
                    AND IsActive = true
                    ORDER BY srNetwork_Team__c, Name
                    ];

		// retrieve this user in a list
		List<User> srnUser = ScheduleController.getSrnUsers();

		system.assertEquals(users.size(), srnUser.size());
	}

	@isTest static void getUserSchedules_Test() {

		Date startDate = System.today();
		Integer daysToDisplay = 14;
		Date endDate = System.today().addDays(daysToDisplay);

		// create a schedule record
		Id sOwnerId = UserInfo.getUserId();
		Integer sHours = 8;
		Date sDate = System.today().addDays(2);

		// create case
		List<Case> cases = new List<Case>();
		Integer numToInsert = 1;
		String caseOrigin = 'Email';
        String caseStatus = 'New';
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
            					RecordTypeId = caseRcrdTyp,
            					OwnerId = sOwnerId)
            );
        }

        insert cases;
        Case caseForSchedule = cases[0];

		List<Schedule__c> schedule = new List<Schedule__c>();

		schedule.add(new Schedule__c(OwnerId__c = sOwnerId,
					Hours__c = sHours,
					Date__c = sDate,
					Case__c = caseForSchedule.Id
			)
		);

		insert schedule;

		// retrieve schedule record
		List<Schedule__c> testSchl = [SELECT Id FROM Schedule__c 
								WHERE Date__c >= :startDate
								And Date__c <= :endDate
								//AND Case__r.Administrative_for_CM__c != true
								];

		Integer month = startDate.month();
		Integer day = startDate.day();
		String sMonth = String.valueOf(month);
		String sDay = String.valueOf(day);
		if (sMonth.length() == 1) {
			sMonth = '0' + sMonth;
		}
		if (sDay.length() == 1) {
			sDay = '0' + sDay;
		}
		String sStartDate = startDate.year() + '-' + sMonth + '-' + sDay;

		List<Schedule__c> schedules = ScheduleController.getUserSchedules(sStartDate, daysToDisplay);

		system.assertEquals(testSchl.size(), schedules.size());
	}

	@isTest static void getUserSchedulesForUnownedCases_Test() {

		Date startDate = System.today();
		Integer daysToDisplay = 14;
		Date endDate = System.today().addDays(daysToDisplay);

		// create a schedule record
		Id sOwnerId = UserInfo.getUserId();
		Integer sHours = 8;
		Date sDate = System.today().addDays(2);

		// create case
		List<Case> cases = new List<Case>();
		Integer numToInsert = 1;
		String caseOrigin = 'Email';
        String caseStatus = 'New';
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
            					RecordTypeId = caseRcrdTyp,
            					OwnerId = sOwnerId)
            );
        }

        insert cases;
        Case caseForSchedule = cases[0];

		List<Schedule__c> schedule = new List<Schedule__c>();

		schedule.add(new Schedule__c(OwnerId__c = sOwnerId,
					Hours__c = sHours,
					Date__c = sDate,
					Case__c = caseForSchedule.Id
			)
		);

		insert schedule;

		// retrieve schedule record
		List<Schedule__c> testSchl = [SELECT Id FROM Schedule__c 
									WHERE Case__r.OwnerId <> :UserInfo.getUserId()
									AND Schedule__c.OwnerId__c = :UserInfo.getUserId()
									AND Case__r.Administrative_for_CM__c != true
									AND Case__r.Status IN ('New','On Schedule','Behind Schedule')];

		Integer month = startDate.month();
		String sMonth = String.valueOf(month);
		if (sMonth.length() == 1) {
			sMonth = '0' + sMonth;
		} 

		String sStartDate = startDate.year() + '-' + sMonth + '-' + startDate.day();
		system.debug('sStartDate: ' + sStartDate);

		List<Schedule__c> schedules = ScheduleController.getUserSchedulesForUnownedCases();

		system.assertEquals(testSchl.size(), schedules.size());
	}

	@isTest static void getAllUserSchedules_Test() {

		Date startDate = System.today();
		Integer daysToDisplay = 14;
		Date endDate = System.today().addDays(daysToDisplay+1);

		// create a schedule record
		Id sOwnerId = UserInfo.getUserId();
		Integer sHours = 8;
		Date sDate = System.today().addDays(2);

		// create case
		List<Case> cases = new List<Case>();
		Integer numToInsert = 1;
		String caseOrigin = 'Email';
        String caseStatus = 'New';
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, Status = caseStatus, RecordTypeId = caseRcrdTyp));
        }

        insert cases;

        // create schedule
		List<Schedule__c> schedule = new List<Schedule__c>();
		Case caseForSchedule = cases[0];
		schedule.add(new Schedule__c(OwnerId__c = sOwnerId,
					Hours__c = sHours,
					Date__c = sDate,
					Case__c = caseForSchedule.Id
			)
		);

		insert schedule;

		// retrieve schedule record
		List<Schedule__c> testSchl = [SELECT Id FROM Schedule__c 
									WHERE Schedule__c.OwnerId__c = :UserInfo.getUserId()
									AND Case__r.Status IN ('New','On Schedule','Behind Schedule')
									AND Date__c >= :startDate
									AND Date__c <= :endDate
									ORDER BY Date__c DESC];

		Integer month = startDate.month();
		Integer day = startDate.day();
		String sMonth = String.valueOf(month);
		String sDay = String.valueOf(day);
		if (sMonth.length() == 1) {
			sMonth = '0' + sMonth;
		}
		if (sDay.length() == 1) {
			sDay = '0' + sDay;
		}
			
		String sStartDate = startDate.year() + '-' + sMonth + '-' + sDay;
		system.debug('sStartDate: ' + sStartDate);

		List<Schedule__c> schedules = ScheduleController.getAllUserSchedules(sStartDate, daysToDisplay);

		system.assertEquals(testSchl.size(), schedules.size());
	}

	@isTest static void getUserOpenCases_Test() {

		Integer numToInsert = 200;
		String caseOrigin = 'Email';
        String caseStatus = 'New';
        Id caseOwner = UserInfo.getUserId();

		// create case
		List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
        						RecordTypeId = caseRcrdTyp,
        						OwnerId = caseOwner));
        }

        insert cases;

        List<Case> userCases = ScheduleController.getUserOpenCases();

        system.assertEquals(numToInsert,userCases.size());
	}

	@isTest static void getUserAllCases_Test() {

		Integer numToInsert = 200;
		String caseOrigin = 'Email';
        String caseStatus = 'Closed';
        Id caseOwner = UserInfo.getUserId();

		// create case
		List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
        						RecordTypeId = caseRcrdTyp,
        						OwnerId = caseOwner));
        }

        insert cases;

        List<Case> userCases = ScheduleController.getUserAllCases();

        system.assertEquals(50,userCases.size());
	}

	@isTest static void getAdminCases_Test() {

		Integer numToInsert = 10;
		String caseOrigin = 'Email';
        String caseStatus = 'New';

		// create case
		List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
        						RecordTypeId = caseRcrdTyp,
        						Administrative_for_CM__c = true));
        }

        insert cases;

        List<Case> adminCases = ScheduleController.getAdminCases();

        system.assertEquals(numToInsert,adminCases.size());
	}

	@isTest static void getAdminSchedules_Test() {

		Integer numToInsert = 10;
		String caseOrigin = 'Email';
        String caseStatus = 'New';
        Date startDate = System.today();
		Integer daysToDisplay = 14;
		Date endDate = System.today().addDays(daysToDisplay);

		// create case
		List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
        						RecordTypeId = caseRcrdTyp,
        						Administrative_for_CM__c = true));
        }

        insert cases;

        // create schedule__c records
		Case caseForSchedule = cases[0];
		Decimal hours = 8;
		List<Schedule__c> schedules = new List<Schedule__c>();
		for (Integer j = 0; j < numToInsert; j++) {
			schedules.add(new Schedule__c(Case__c = caseForSchedule.Id, 
					Date__c = startDate.addDays(j),
					Hours__c = hours,
					OwnerId__c = UserInfo.getUserId())
			);
		}

		insert schedules;

		startDate = System.today();

		List<Schedule__c> newSchedules = [SELECT Id, Name, OwnerId__c, Date__c, Hours__c, Case__c, Case__r.CaseNumber, Case__r.Administrative_for_CM__c,
                        Case__r.Type, Case__r.Requested_Service__c, Case__r.Opportunity_Name__c, Case__r.Account_Name_Text__c, 
                        Case__r.Service_Requested_By_Name__c, Case__r.Days__c, Case__r.Requested_Completion_Date__c
                       FROM Schedule__c  
                       WHERE OwnerId__c = :UserInfo.getUserId()
                       AND Case__c = :caseForSchedule.Id
                       AND Date__c >= :startDate
                       And Date__c <= :endDate
                       AND Case__r.Administrative_for_CM__c = true
                       ];

		// find admin schedules
		Integer month = startDate.month();
		Integer day = startDate.day();
		String sMonth = String.valueOf(month);
		String sDay = String.valueOf(day);
		if (sMonth.length() == 1) {
			sMonth = '0' + sMonth;
		}
		if (sDay.length() == 1) {
			sDay = '0' + sDay;
		}
		String sStartDate = startDate.year() + '-' + sMonth + '-' + sDay;
        List<Schedule__c> adminSchedules = ScheduleController.getAdminSchedules(caseForSchedule.Id, sStartDate, daysToDisplay);

        system.assertEquals(newSchedules.size(),adminSchedules.size());
	}

	@isTest static void saveSchedule_Test() {

		String scheduleId;
		Decimal hours = 8;
		Date today = System.today();
		Integer numToInsert = 1;
		String caseOrigin = 'Email';
        String caseStatus = 'New';

		// create case
		List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, Status = caseStatus, RecordTypeId = caseRcrdTyp));
        }

        insert cases;

		// create schedule__c record
		Case caseForSchedule = cases[0];
		List<Schedule__c> schedules = new List<Schedule__c>();
		for (Integer j = 0; j < numToInsert; j++) {
			schedules.add(new Schedule__c(Case__c = caseForSchedule.Id, 
					Date__c = today,
					Hours__c = hours)
			);
		}

		insert schedules;

		// update hours for the schedule__c record
		scheduleId = schedules[0].Id;
		Decimal updatedHours = hours / 2;
		Schedule__c updatedSchedule = ScheduleController.saveSchedule(scheduleId, updatedHours);


		// verify the updated schedule__c record has correct hours
		system.assertEquals(updatedHours,updatedSchedule.Hours__c);
	}

	@isTest static void insertSchedule_Test() {

		Date dateForHours = System.today();
		Decimal hours = 8;
		Integer numToInsert = 1;
		String caseOrigin = 'Email';
        String caseStatus = 'New';

		// create case
		List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, Status = caseStatus, RecordTypeId = caseRcrdTyp));
        }

        insert cases;

        String caseId = cases[0].Id;
        Integer month = dateForHours.month();
		String sMonth = String.valueOf(month);
		if (sMonth.length() == 1) {
			sMonth = '0' + sMonth;
		} 

		String today = dateForHours.year() + '-' + sMonth + '-' + dateForHours.day();


		Schedule__c insertedSchedule = ScheduleController.insertSchedule(caseId, today, hours);

		// verify the updated schedule__c record has correct hours
		system.assertEquals(hours, insertedSchedule.Hours__c);
	}

	@isTest static void getCaseInfo_Test() {

		Integer numToInsert = 200;
		String caseOrigin = 'Email';
        String caseStatus = 'New';
        Id caseOwner = UserInfo.getUserId();

		// create case
		List<Case> cases = new List<Case>();
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
        						RecordTypeId = caseRcrdTyp,
        						OwnerId = caseOwner));
        }

        insert cases;

        Id caseId = cases[0].Id;

        List<Case> newCases = [SELECT Id, CaseNumber
        						FROM Case
        						WHERE Id = :caseId];

        List<Case> userCases = ScheduleController.getCaseInfo(caseId);

        system.assertEquals(newCases[0].CaseNumber,userCases[0].CaseNumber);
	}

	@isTest static void getUserCaseSchedules_Test() {

		Date startDate = System.today();
		Integer daysToDisplay = 14;
		Date endDate = System.today().addDays(daysToDisplay+1);

		// create a schedule record
		Id sOwnerId = UserInfo.getUserId();
		Integer sHours = 8;
		Date sDate = System.today().addDays(2);

		// create case
		List<Case> cases = new List<Case>();
		Integer numToInsert = 1;
		String caseOrigin = 'Email';
        String caseStatus = 'New';
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
            					RecordTypeId = caseRcrdTyp,
            					OwnerId = sOwnerId)
            );
        }

        insert cases;

        // create schedule
		List<Schedule__c> schedule = new List<Schedule__c>();
		Case caseForSchedule = cases[0];
		schedule.add(new Schedule__c(OwnerId__c = sOwnerId,
					Hours__c = sHours,
					Date__c = sDate,
					Case__c = caseForSchedule.Id
			)
		);

		insert schedule;

		// retrieve schedule record
		List<Schedule__c> testSchl = [SELECT Id FROM Schedule__c 
									WHERE Schedule__c.OwnerId__c = :sOwnerId
									AND Case__c = :caseForSchedule.Id
									AND Case__r.Status IN ('New','On Schedule','Behind Schedule')
									AND Date__c >= :startDate
									AND Date__c <= :endDate
									ORDER BY Date__c DESC];

		Integer month = startDate.month();
		Integer day = startDate.day();
		String sMonth = String.valueOf(month);
		String sDay = String.valueOf(day);
		if (sMonth.length() == 1) {
			sMonth = '0' + sMonth;
		}
		if (sDay.length() == 1) {
			sDay = '0' + sDay;
		}
		String sStartDate = startDate.year() + '-' + sMonth + '-' + sDay;

		List<Schedule__c> schedules = ScheduleController.getUserCaseSchedules(caseForSchedule.Id, sStartDate, daysToDisplay);

		system.assertEquals(testSchl.size(), schedules.size());
	}

	@isTest static void getTeamSchedules_Test() {

		Date startDate = System.today();
		Integer daysToDisplay = 14;
		Date endDate = System.today().addDays(daysToDisplay+1);

		// create a schedule record
		Id sOwnerId = UserInfo.getUserId();
		Integer sHours = 8;
		Date sDate = System.today().addDays(2);

		// create user to own the case
		List<User> newUsers = TestDataFactory.createUsers(1, 'zylinksi');
		User userJoe = newUsers[0];

		// create case
		List<Case> cases = new List<Case>();
		Integer numToInsert = 1;
		String caseOrigin = 'Email';
        String caseStatus = 'New';
        Id caseRcrdTyp = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SrN').getRecordTypeId();

        for (Integer j = 0; j < numToInsert; j++) {
            cases.add(new Case(Origin = caseOrigin + j, 
            					Status = caseStatus, 
            					RecordTypeId = caseRcrdTyp,
            					OwnerId = sOwnerId)
            );
        }

        insert cases;

        // create schedule
		List<Schedule__c> schedule = new List<Schedule__c>();
		Case caseForSchedule = cases[0];
		schedule.add(new Schedule__c(OwnerId__c = userJoe.Id,
					Hours__c = sHours,
					Date__c = sDate,
					Case__c = caseForSchedule.Id
			)
		);

		insert schedule;

		// retrieve schedule record
		List<Schedule__c> testSchl = [SELECT Id FROM Schedule__c 
									WHERE Schedule__c.OwnerId__c != :UserInfo.getUserId()
									AND Case__c = :caseForSchedule.Id
									AND Case__r.Status IN ('New','On Schedule','Behind Schedule')
									AND Date__c >= :startDate
									AND Date__c <= :endDate
									ORDER BY Date__c DESC];

		Integer month = startDate.month();
		String sMonth = String.valueOf(month);
		if (sMonth.length() == 1) {
			sMonth = '0' + sMonth;
		} 

		String sStartDate = startDate.year() + '-' + sMonth + '-' + startDate.day();
		system.debug('sStartDate: ' + sStartDate);

		List<Schedule__c> schedules = ScheduleController.getTeamSchedules(caseForSchedule.Id, sStartDate, daysToDisplay);

		system.assertEquals(testSchl.size(), schedules.size());
	}
}