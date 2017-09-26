({

	// formats a js date to MMM dd
    dateFormatToMD : function(dateToFormat) {
        
        var m, d, fDate;
        	
        if (dateToFormat != undefined && dateToFormat != null) {
           
            m = dateToFormat.toString().slice(4,8);
            d = dateToFormat.getDate();
            
            fDate = m + " " + d;
        }
        
        return fDate;
	},

	getWeekShortDates : function(component, startDate) {
                
        var numOfDays = component.get("v.daysToDisplay"), 
            year, month, day, d, day, diff, monday, nextDay, 
            newDate, i, j, yr, mo, dy, shortDate, sunday, formattedDateHeader,
            datesInWeek = [];
        
        //console.log('capacityscheduleallrowhlpr * startDate: ' + startDate);
        
        //year = startDate.getFullYear();
        //month = startDate.getMonth() + 1;
        //day = startDate.getDay();
        
        // startDate is in '2017-03-07T05:00:00.000Z' format
        year = startDate.slice(0,4);
        month = startDate.slice(5,7) - 1;
        day = startDate.slice(8,10);
        
        d = new Date(year,month,day);
        // find day # of the week ('0' = sunday)
        day = d.getDay();
        // find day # of month
        diff = d.getDate() - day + (day == 0 ? -7 : 0);
        //find monday
        monday = new Date(d.setDate(diff + 1));
        sunday = new Date(monday);
        sunday.setDate(sunday.getDate() + 6);
        formattedDateHeader = this.dateFormatToMD(monday) + " - " + this.dateFormatToMD(sunday);
        
        //component.set("v.formattedDateHeader",formattedDateHeader);
                        
        // loop through numofdays and push dates in array
        for (i = 0, j = numOfDays; i < j; i = i + 1) {
			
            nextDay = new Date(monday.valueOf());
            nextDay = nextDay.setDate(nextDay.getDate() + i);
            newDate = new Date(nextDay);
            
            yr = newDate.getFullYear();
            mo = newDate.getMonth() + 1;
            dy = newDate.getDate();
            mo = mo.toString().length === 2 ? mo : 0 + mo.toString();
            dy = dy.toString().length === 2 ? dy : 0 + dy.toString();
            
            shortDate = yr + '-' + mo + '-' + dy;
            
            //console.log('CSAllRowHlpr * startDate: ' + startDate + ' - short date: ' + shortDate + ' -d: ' + d);
			
            datesInWeek.push(shortDate);
            //datesInWeek.push(newDate);
        }

        return datesInWeek;
    },

    getSchedules : function(component, event) {
        
    	// Get the record id
        //var caseId = component.get("v.caseId");
        var startDate = component.get("v.startDate"),
            daysToDisplay = component.get("v.daysToDisplay");

        //console.log('initializing CapacityScheduleUsers.getSchedules...from ' + event.getSource() + ' - startDate: ' + startDate);

        //  call the controller method that returns all the schedule__c records
        //  for this user on this date
        var action = component.get("c.getUserSchedules");
    
        action.setParams({
            startDate : startDate,
            daysToDisplay : daysToDisplay
        });
        
        var datesInRange = this.getWeekShortDates(component,startDate);
        
        // Add callback behavior when retrieving the records
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                console.log('CapacityScheduleUsers.getSchedules query state: ' + state);
                var sArray = [],
                	schedules = [],
                	schAry = [],
                	schedule, errSchedule, totalDateHours, date, hour, i, j, m, o, p, r, calDate, fDate, y, m, d;
                //console.log('datesInRange: ' + datesInRange.length);
                sArray = response.getReturnValue();

                component.set("v.scheduleRcds", sArray);

                console.log('CapacityScheduleUsers.getSchedules # of schedules: ' + sArray.length);
            /*
                // loop through days in week
                for (m = 0, o = datesInRange.length; m < o; m = m + 1) {
                    
                    //console.log('for date: ' + datesInRange[m]);
                    hour = 0;
                    schedule = {};
                    
                    // loop through schedule__c records
                    for (i = 0, j = sArray.length; i < j; i = i + 1) {
                        
                        var sDate = sArray[i].Date__c;
                        
                        //console.log(i + 'hours: ' + hour + ' - sdate: ' + sDate + ' - id: ' + sArray[i].Id + ' - datesInRange[m]: ' + datesInRange[m] );
                          
                        if ( datesInRange[m].toString() === sDate.toString() ) {
                            if (sArray[i].Hours__c > 0) {
                                hour = hour + sArray[i].Hours__c;
                                //console.log('date: ' + datesInRange[m] + ' - sDATE: ' + sArray[i].Date__c + ' - HOURS: ' + sArray[i].Hours__c + ' - total: ' + hour);
                                schedule = {Date__c: datesInRange[m], Hours__c: hour};
                            }
                            
                            //console.log('dates match for case: ' + sArray[i].Case__c + ' - schedule date: ' + sArray[i].Date__c + ' - hours: ' + sArray[i].Hours__c + ' - total hrs: ' + hour);
                            //console.log('hour: ' + sArray[i].Hours__c + ' - schedule date: ' + datesInRange[m] + '--' + sArray[i].Date__c);
                            //hour = hour + sArray[i].Hours__c;
                            //schedule = sArray[i];
                            //schAry.push(sArray[i]);
                        } else {
                            /*
                            console.log('ELSE * date: ' + datesInRange[m] + ' - sDATE: ' + sArray[i].Date__c + ' - HOURS: ' + sArray[i].Hours__c + ' - total: ' + hour);
                            if (hour > 0) {
                                //schedule = sArray[i];
                                schedule = {Date__c: datesInRange[m], Hours__c: hour};
                                console.log(' - total hours: ' + hour + ' - schedule date: ' + datesInRange[m]);
                            }
                            
                            
                            hour = 0;
                            //console.log('RESET total hours: ' + hour + ' - NEW schedule date: ' + datesInRange[m] + '--' + sArray[i].Date__c);
                        }
                    }

                    // push hours into an array
                    schAry.push(schedule);
                    //schedules.push(hour);
                }
				//component.set("v.schedules", schedules);
                component.set("v.scheduleRcds", schAry);

                console.log('schedule records #: ' + schAry.length);
        */
            } //else if (cmp.isValid() && state === "INCOMPLETE") {
            else if (state === "INCOMPLETE") {
                console.log("CapacityScheduleUsers.getSchedules * Failed with state: " + state);
            }
            //else if (cmp.isValid() && state === "ERROR") {
            else if (state === "ERROR") {
                
                var errSchAry = [],
                    errors = response.getError();
                
                component.set("v.errorMsg","CapacityScheduleUsers.getSchedules Could not retrieve total hours. Please try again later.");
                
                // loop through days in week
                for (m = 0, o = datesInRange.length; m < o; m = m + 1) {
                    errSchedule = {};
                    // set errSchedule for users without a schedule record yet
                    errSchedule = {Date__c: datesInRange[m], Hours__c: 0};
                    errSchAry.push(errSchedule);
                }
                component.set("v.scheduleRcds", errSchAry);
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("CapacityScheduleUsers.getSchedules * Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("CapacityScheduleUsers.getSchedules * Unknown error");
                }
            }
        });
    
        // Send action off to be executed
        $A.enqueueAction(action);
    
    
    }	
})