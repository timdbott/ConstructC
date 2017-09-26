public with sharing class ScheduleController {

    @AuraEnabled
    public static User currentUserId() {
        Id userId = UserInfo.getUserId();
        return [SELECT Id, srNetwork_Team__c FROM User WHERE Id = :userId];
    }

	@AuraEnabled
	// * used to display list of srNetwork users, by team, in the current user's geo
	public static List<User> getSrnUsers() {

        List<User> users;
        String geo = CapacityManagementController.getUserGeo();

        users = [SELECT Id, Name, srNetwork_Team__c
                    FROM User
                    WHERE srNetwork_Team__c != null
                    AND Sales_Geography__c = :geo
                    AND IsActive = true
                    ORDER BY srNetwork_Team__c, Name
                    ];

        //system.debug('geo: ' + geo + ' - getSrnUsers #: ' + users.size());

		return users;
	}
	
	@AuraEnabled
    // * used in CapacityManagementSchedules.cmp to display all schedule hours for the given time frame
    public static List<Schedule__c > getUserSchedules(String startDate, Integer daysToDisplay) {

        system.debug('ScheduleController.getUserSchedules * startDate: ' + startDate);

        List<Schedule__c> scheduleList;
        Integer year, month, day;
        Date beginDate, endDate;
        String geo = CapacityManagementController.getUserGeo();

        if (startDate == null) {
            return scheduleList;
        } else if (startDate.length() != 24) {
            // probably format like 2017-03-17T00:06:30.951Z
            startDate = startDate.left(10);

            try {
                year = integer.valueOf(startDate.left(4));
                month = integer.valueOf(startDate.mid(5,2));
                day = integer.valueOf(startDate.right(2));
                beginDate = date.newInstance(year,month,day);
                //system.debug('getUserSchedules converted date in try: ' + beginDate);
            } catch (System.CalloutException e) {
                //system.debug('getUserSchedules convert date error: ' + e);
                beginDate = date.valueOf(startDate);
                //system.debug('getUserSchedules converted date in catch: ' + beginDate);
            }
        } else {
            try {
                beginDate = date.valueOf(startDate);
                //system.debug('getUserSchedules converted date in else...try: ' + beginDate);
            } catch (System.CalloutException e) {
                system.debug('getUserSchedules convert date error in else...catch: ' + e);
            }
        }
        
        endDate = beginDate.addDays(integer.valueOf(daysToDisplay)+1);
        beginDate = beginDate.addDays(-1);
        scheduleList = new List<Schedule__c >();
        Schedule__c[] schedules = [SELECT Id, Name, OwnerId__c, Date__c, Hours__c, Case__c, Case__r.CaseNumber, Case__r.Administrative_for_CM__c,
                               	Case__r.Type, Case__r.Requested_Service__c, Case__r.Opportunity_Name__c, Case__r.Account_Name_Text__c, 
                               	Case__r.Service_Requested_By_Name__c, Case__r.Days__c, Case__r.Requested_Completion_Date__c,
                                Case__r.Account_Classification__c, Case__r.Opportunity_Est_Disc_Sales__c
                               FROM Schedule__c  
                               WHERE Date__c >= :beginDate
                               And Date__c <= :endDate
                               //AND Case__r.Administrative_for_CM__c != true
                               ];
        system.debug('getUserSchedules #: ' + schedules.size());

        for (Schedule__c  s : schedules) {

            scheduleList.add(s);
            //system.debug('getUserSchedules schedule Id: ' + s.Id);
        }
        
        return scheduleList;
    }

    @AuraEnabled
    // * used in MyScheduleUnownedCases.cmp to display unowned cases user is working on
    public static List<Schedule__c > getUserSchedulesForUnownedCases() {
        
        List<Schedule__c> scheduleList = new List<Schedule__c >();
        List<Schedule__c> schedules = [SELECT Id, Name, OwnerId__c, Date__c, Hours__c, Case__c, Case__r.CaseNumber,
                                        Case__r.Administrative_for_CM__c, Case__r.Type, Case__r.Opportunity_Name__c, 
                                        Case__r.Account_Name_Text__c, Case__r.Service_Requested_By_Name__c, Case__r.Days__c, 
                                        Case__r.Requested_Completion_Date__c, Case__r.Account_Classification__c, 
                                        Case__r.Opportunity_Est_Disc_Sales__c
                                       FROM Schedule__c 
                                       WHERE Case__r.OwnerId <> :UserInfo.getUserId()
                                       AND Schedule__c.OwnerId__c = :UserInfo.getUserId()
                                       AND Case__r.Administrative_for_CM__c != true
                                       AND Case__r.Status IN ('New','On Schedule','Behind Schedule')];
        
        for (Schedule__c  s : schedules) {

            scheduleList.add(s);
            //system.debug('getUserSchedulesForUnownedCases.schedule Id: ' + s.Id);
        }
        
        return scheduleList;
    }
    
    @AuraEnabled
    // * used in CapacityScheduleAllRow.cmp to display all of a users schedule records
    public static List<Schedule__c > getAllUserSchedules(String startDate, Integer daysToDisplay) {

        Integer year = integer.valueOf(startDate.left(4));
        Integer month = integer.valueOf(startDate.mid(5,2));
        Integer day = integer.valueOf(startDate.right(2));
        Date beginDate = date.newInstance(year,month,day);
        Date endDate = beginDate.addDays(integer.valueOf(daysToDisplay)+1);
        beginDate = beginDate.addDays(-1);
        //system.debug('getAllUserSchedules* beginDate: ' + beginDate + ' - daysToDisplay: ' + daysToDisplay + ' - endDate: ' + endDate);
        List<Schedule__c> scheduleList = new List<Schedule__c >();
        List<Schedule__c> schedules = [SELECT Id, Name, OwnerId__c, Date__c, Hours__c, Case__c, Case__r.Administrative_for_CM__c,
                                        Case__r.Type, Case__r.Opportunity_Name__c, Case__r.Account_Name_Text__c, 
                                        Case__r.Service_Requested_By_Name__c, Case__r.Days__c, Case__r.Requested_Completion_Date__c,
                                        Case__r.Account_Classification__c, Case__r.Opportunity_Est_Disc_Sales__c
                                       FROM Schedule__c 
                                       WHERE Schedule__c.OwnerId__c = :UserInfo.getUserId()
                                       //AND Case__r.Status IN ('New','On Schedule','Behind Schedule')
                                       AND Date__c >= :beginDate
                                       AND Date__c <= :endDate
                                       //AND Case__r.Administrative_for_CM__c != true
                                       ORDER BY Date__c DESC];
        
        for (Schedule__c  s : schedules) {

            scheduleList.add(s);
            system.debug('getAllUserSchedules* schedule Id: ' + s.Id + ' - Date: ' + s.Date__c + ' - owner: ' + s.OwnerId__c + ' - # of schedule records: ' + schedules.size());
        }
                
        if (schedules.size() <= 0) {
            throw new AuraHandledException('Could not find Schedules');
        }

        return scheduleList;
    }
    
    @AuraEnabled
    // * used in MyScheduleOwnedCases.cmp
    public static List<Case> getUserOpenCases() {
        
        List<Case> caseList = new List<Case>();
        List<Case> cases = [SELECT Id, CaseNumber, Type, Opportunity_Name__c, Account_Name_Text__c, 
                                Requested_Service__c, Service_Requested_By_Name__c, Requested_Completion_Date__c,
                                Days__c, Account_Classification__c, Opportunity_Est_Disc_Sales__c
                            FROM Case 
                            WHERE OwnerId = :UserInfo.getUserId()
                            AND Status IN ('New','On Schedule','Behind Schedule')
                            AND Administrative_for_CM__c != true
                            ORDER BY Days__c ASC];
        for (Case c : cases) {
            
            caseList.add(c);
            system.debug('getUserOpenCases.case id: ' + c.Id);
        }
        return caseList;
    }

    @AuraEnabled
    // * used in MyScheduleOwnedCases.cmp
    public static List<Case> getUserAllCases() {
        
        List<Case> caseList = new List<Case>();
        List<Case> cases = [SELECT Id, CaseNumber, Type, Opportunity_Name__c, Account_Name_Text__c, 
                                Requested_Service__c, Service_Requested_By_Name__c, Requested_Completion_Date__c,
                                Days__c, Account_Classification__c, Opportunity_Est_Disc_Sales__c
                            FROM Case 
                            WHERE OwnerId = :UserInfo.getUserId()
                            AND Status != 'Cancelled'
                            AND Administrative_for_CM__c != true
                            ORDER BY Days__c ASC LIMIT 50];
        for (Case c : cases) {
            
            caseList.add(c);
            //system.debug('getUserOpenCases.case id: ' + c.Id);
        }
        return caseList;
    }

    @AuraEnabled
    // * used in MyScheduleAdminCases.cmp
    public static List<Case> getAdminCases() {

        List<Case> caseList = new List<Case>();
        List<Case> cases = [SELECT Id, Type, Opportunity_Name__c, Account_Name_Text__c, 
                                Requested_Service__c, Service_Requested_By_Name__c, Requested_Completion_Date__c,
                                Days__c
                            FROM Case 
                            WHERE Administrative_for_CM__c = true
                            ORDER BY Requested_Service__c DESC];
        for (Case c : cases) {
            
            caseList.add(c);
            //system.debug('getAdminCases.case id: ' + c.Id);
        }
        return caseList;
    }

    @AuraEnabled
    // * used in MyScheduleAdminCases.cmp to display the user's schedule hours for the specific case
    public static List<Schedule__c > getAdminSchedules(String caseId, String startDate, Integer daysToDisplay) {

        //system.debug('getAdminSchedules * startDate: ' + startDate);

        List<Schedule__c> scheduleList, schedules;
        Integer year, month, day;
        Date beginDate, endDate;

        if (startDate == null) {
            return scheduleList;
        } else if (startDate.length() != 24) {
            // probably format like 2017-03-17T00:06:30.951Z
            startDate = startDate.left(10);

            try {
                year = integer.valueOf(startDate.left(4));
                month = integer.valueOf(startDate.mid(5,2));
                day = integer.valueOf(startDate.right(2));
                beginDate = date.newInstance(year,month,day);
                //system.debug('getAdminSchedules converted date in try: ' + beginDate);
            } catch (System.CalloutException e) {
                //system.debug('getAdminSchedules convert date error: ' + e);
                beginDate = date.valueOf(startDate);
                //system.debug('getAdminSchedules converted date in catch: ' + beginDate);
            }
        } else {
            try {
                beginDate = date.valueOf(startDate);
                //system.debug('getAdminSchedules converted date in else...try: ' + beginDate);
            } catch (System.CalloutException e) {
                system.debug('getAdminSchedules convert date error in else...catch: ' + e);
            }
        }

        endDate = beginDate.addDays(integer.valueOf(daysToDisplay)+1);
        beginDate = beginDate.addDays(-1);
        scheduleList = new List<Schedule__c >();
        schedules = [SELECT Id, Name, OwnerId__c, Date__c, Hours__c, Case__c, Case__r.CaseNumber, Case__r.Administrative_for_CM__c,
                        Case__r.Type, Case__r.Requested_Service__c, Case__r.Opportunity_Name__c, Case__r.Account_Name_Text__c, 
                        Case__r.Service_Requested_By_Name__c, Case__r.Days__c, Case__r.Requested_Completion_Date__c
                       FROM Schedule__c  
                       WHERE OwnerId__c = :UserInfo.getUserId()
                       AND Case__c = :caseId
                       AND Date__c >= :beginDate
                       And Date__c <= :endDate
                       AND Case__r.Administrative_for_CM__c = true
                       ];
        // saving for later - 1.10.17 tb
        Date Date_today = Date.today();
        String weekStart = Date_today.toStartofWeek().format();
        // end
        
        for (Schedule__c  s : schedules) {

            scheduleList.add(s);
            //system.debug('getUserSchedules schedule Id: ' + s.Id);
        }
        
        return scheduleList;
    }

    @AuraEnabled
    // * used in CapacityHours.cmp
    public static Schedule__c saveSchedule(String Id, Decimal hours) {

        List<Schedule__c> schedule = [SELECT Id, Hours__c 
                                FROM Schedule__c 
                                WHERE Id = :Id];
        Schedule__c updatedSchedule;
                
        for (Schedule__c s : schedule) {
            //system.debug('saveSchedule: ' + hours);
            s.Hours__c = hours;
            updatedSchedule = s;
        }

        system.debug('Case__c: ' + updatedSchedule.Case__c + ' - Date__c: ' + updatedSchedule.Date__c + ' - Hours__c: ' + updatedSchedule.Hours__c + ' - OwnerId__c: ' + UserInfo.getUserId() );
        
        try {
            update schedule;
        } catch(DmlException e) {
            system.debug('error saving this Schedule record: ' + e);
        }
        
        return updatedSchedule;
    }

    @AuraEnabled
    public static Schedule__c insertSchedule(String caseId, String dateForHours, Decimal hours) {
        
        String year = dateForHours.left(4);
        String month = dateForHours.mid(4,2);
        String day = dateForHours.right(2);
        Date dateForHrs;

        system.debug('ScheduleControlloer.insertSchedule yr: ' + year + ' - mo: ' + month + ' - dt: ' + day);

        Integer yr = integer.valueof(year);
        Integer mo = integer.valueof(month);
        Integer dt = integer.valueof(day);

        try {
            dateForHrs = Date.newInstance(yr,mo,dt);
        } catch(System.CalloutException e) {
            system.debug('ScheduleControlloer.insertSchedule could not create date');
        }

        system.debug('ScheduleControlloer.insertSchedule date converted: ' + dateForHrs + ' - dateForHours: ' + dateForHours);

        Schedule__c schedule = new Schedule__c(Case__c = caseId,
                                           Date__c = dateForHrs,
                                           Hours__c = hours,
                                           OwnerId__c = UserInfo.getUserId());

        try {
            insert schedule;
        } catch(DmlException e) {
            system.debug('ScheduleControlloer.insertSchedule error inserting new Schedule record: ' + e);
        }
        
        return schedule;
    }

    // ----  for CaseSchedule.cmp  ------

    @AuraEnabled
    // * used in CaseMySchedule.cmp to show Case info - even if there are no schedule records
    public static List<Case > getCaseInfo(String caseId) {

        List<Case> caseList = new List<Case>();
        List<Case> cases = [SELECT Id, CaseNumber, Type, Opportunity_Name__c, Account_Name_Text__c, 
                                Requested_Service__c, Service_Requested_By_Name__c, Requested_Completion_Date__c,
                                Days__c, Account_Classification__c, Opportunity_Est_Disc_Sales__c
                            FROM Case 
                            WHERE Id = :caseId];
        for (Case c : cases) {
            
            caseList.add(c);
        }
        return caseList;
    }

    @AuraEnabled
    // * used in CapacityScheduleRow.cmp to display the user's schedule hours for the specific case
    public static List<Schedule__c > getUserCaseSchedules(String caseId, String startDate, Integer daysToDisplay) {

        List<Schedule__c> scheduleList, schedules;
        Integer year, month, day;
        Date beginDate, endDate;

        // format the string date from the LE
        if (startDate == null) {
            return scheduleList;
        } else if (startDate.length() != 24) {
            // probably format like 2017-03-17T00:06:30.951Z
            startDate = startDate.left(10);

            try {
                year = integer.valueOf(startDate.left(4));
                month = integer.valueOf(startDate.mid(5,2));
                day = integer.valueOf(startDate.right(2));
                beginDate = date.newInstance(year,month,day);
                //system.debug('getUserCaseSchedules converted date in try: ' + beginDate);
            } catch (System.CalloutException e) {
                //system.debug('getUserCaseSchedules convert date error: ' + e);
                beginDate = date.valueOf(startDate);
                //system.debug('getUserCaseSchedules converted date in catch: ' + beginDate);
            }
        } else {
            try {
                beginDate = date.valueOf(startDate);
                //system.debug('getUserCaseSchedules converted date in else...try: ' + beginDate);
            } catch (System.CalloutException e) {
                system.debug('getUserCaseSchedules convert date error in else...catch: ' + e);
            }
        }
        
        endDate = beginDate.addDays(integer.valueOf(daysToDisplay)+1);
        beginDate = beginDate.addDays(-1);
        scheduleList = new List<Schedule__c >();

        // find the user's schedules for this case
        schedules = [SELECT Id, Name, OwnerId__c, Date__c, Hours__c, Case__c, Case__r.CaseNumber, Case__r.Administrative_for_CM__c,
                        Case__r.Type, Case__r.Requested_Service__c, Case__r.Opportunity_Name__c, Case__r.Account_Name_Text__c, 
                        Case__r.Service_Requested_By_Name__c, Case__r.Days__c, Case__r.Requested_Completion_Date__c,
                        Case__r.Account_Classification__c, Case__r.Opportunity_Est_Disc_Sales__c
                       FROM Schedule__c  
                       WHERE OwnerId__c = :UserInfo.getUserId()
                       AND Case__c = :caseId
                       AND Date__c >= :beginDate
                       And Date__c <= :endDate
                       AND Case__r.Administrative_for_CM__c != true
                       ];
        
        for (Schedule__c  s : schedules) {

            scheduleList.add(s);
            //system.debug('getUserSchedules schedule Id: ' + s.Id);
        }
        
        return scheduleList;
    }

    @AuraEnabled
    // * used in CapacityScheduleCaseTeamHrs.cmp to display all users' schedule hours for the specific case
    public static List<Schedule__c > getTeamSchedules(String caseId, String startDate, Integer daysToDisplay) {

        // format the string date from the LE        
        List<Schedule__c> scheduleList, schedules;
        Integer year, month, day;
        Date beginDate, endDate;

        if (startDate == null) {
            return scheduleList;
        } else if (startDate.length() != 24) {
            // probably format like 2017-03-17T00:06:30.951Z
            startDate = startDate.left(10);

            try {
                year = integer.valueOf(startDate.left(4));
                month = integer.valueOf(startDate.mid(5,2));
                day = integer.valueOf(startDate.right(2));
                beginDate = date.newInstance(year,month,day);
                //system.debug('getTeamSchedules converted date in try: ' + beginDate);
            } catch (System.CalloutException e) {
                system.debug('getTeamSchedules convert date error: ' + e);
                beginDate = date.valueOf(startDate);
                //system.debug('getTeamSchedules converted date in catch: ' + beginDate);
            }
        } else {
            try {
                beginDate = date.valueOf(startDate);
                //system.debug('getTeamSchedules converted date in else...try: ' + beginDate);
            } catch (System.CalloutException e) {
                system.debug('getTeamSchedules convert date error in else...catch: ' + e);
            }
        }

        scheduleList = new List<Schedule__c >();

        // find the others' schedules for this case
        schedules = [SELECT Id, Name, OwnerId__c, OwnerId__r.Name, Date__c, Hours__c, Case__c,  Case__r.Administrative_for_CM__c,
                            Case__r.Type, Case__r.Opportunity_Name__c, Case__r.Account_Name_Text__c, 
                            Case__r.Service_Requested_By_Name__c, Case__r.Days__c, Case__r.Requested_Completion_Date__c,
                            Case__r.Account_Classification__c, Case__r.Opportunity_Est_Disc_Sales__c
                           FROM Schedule__c  
                           WHERE OwnerId__c != :UserInfo.getUserId()
                           AND Case__c = :caseId
                           AND Date__c >= :beginDate
                           And Date__c <= :endDate
                           AND Case__r.Administrative_for_CM__c != true
                           ORDER BY OwnerId__r.Name ASC, Date__c ASC
                           ];
        
        for (Schedule__c  s : schedules) {

            scheduleList.add(s);
            //system.debug('getTeamSchedules schedule Id: ' + s.Id + ' - owner: ' + s.Owner.Name);
        }

        if (schedules.size() <= 0) {
            throw new AuraHandledException('Could not find Schedules');
        }
        
        return scheduleList;
    }


    //  -----------------------------------

}