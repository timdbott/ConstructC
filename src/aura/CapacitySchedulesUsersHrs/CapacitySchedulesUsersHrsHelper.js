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
        
        //console.log('CapacitySchedulesUsersHrs.getWeekShortDates * startDate: ' + startDate);
        
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
            
            //console.log('CapacitySchedulesUsersHrs.getWeekShortDates startDate: ' + startDate + ' - short date: ' + shortDate + ' -d: ' + d);
			
            datesInWeek.push(shortDate);
            //datesInWeek.push(newDate);
        }

        return datesInWeek;
    },

    getSchedules : function(component, event) {
        
        var userId = component.get("v.userId"),
        	startDate = component.get("v.startDate"),
            daysToDisplay = component.get("v.daysToDisplay"),
        	datesInRange = this.getWeekShortDates(component,startDate),
        	sArray = [],
        	schedules = [],
        	schAry = [],
        	schedule, date, hour, i, j, m, o;

        //console.log('initializing CapacitySchedulesUsersHrs.getSchedules...from ' + event.getSource() + ' - startDate: ' + startDate);
        
                // get schedules array of objects
                sArray = component.get("v.scheduleRcds");

                // loop through days in week
                for (m = 0, o = datesInRange.length; m < o; m = m + 1) {
                    
                    //console.log('for date: ' + datesInRange[m]);
                    hour = 0;
                    schedule = {};

                    //console.log('owner: ' + userId + ' - date: ' + datesInRange[m] + ' - total: ' + hour);

                    if (sArray.length === 0) {
                    	schedule = {Date__c: datesInRange[m], Hours__c: hour, Class:"slds-input slds-text-align--center slds-theme--default"};
                    }

                    // set default schedule object
                    schedule = {Date__c: datesInRange[m], Hours__c: hour, Class:"slds-input slds-text-align--center slds-theme--default"};
                    
                    // loop through schedule__c records
                    for (i = 0, j = sArray.length; i < j; i = i + 1) {
                        
                        var sDate = sArray[i].Date__c;
                        
                        //console.log(i + ' hours: ' + hour + ' - sHour__c: ' + sArray[i].Hours__c + ' - sOwnerid: ' + sArray[i].OwnerId__c +  ' - rowOwnerId: ' + userId +' - datesInRange[m]: ' + datesInRange[m].toString() + ' - sDate.toString(): ' + sDate.toString() );
                          
                        if ( datesInRange[m].toString() === sDate.toString() && sArray[i].OwnerId__c === userId) {

                            console.log('MATCH FOUND ON --> date: ' + datesInRange[m].toString() + ' - sDate: ' + sDate.toString() + ' - sOwnerId: ' + sArray[i].OwnerId__c + ' - userId: ' + userId);
                            if (sArray[i].Hours__c > 0) {

                                hour = hour + sArray[i].Hours__c;
                                    
                                if (hour > 6) {
                                    schedule = {Date__c: datesInRange[m], Hours__c: hour, Class:"slds-input slds-text-align--center slds-theme--error"};
	                                   //console.log('sOwner: ' + sArray[i].OwnerId__c + ' - date: ' + datesInRange[m] + ' - sDATE: ' + sArray[i].Date__c + ' - HOURS: ' + sArray[i].Hours__c + ' - total: ' + hour);
                            	} else if (hour > 4) {
	                                //hour = hour + sArray[i].Hours__c;
	                                schedule = {Date__c: datesInRange[m], Hours__c: hour, Class:"slds-input slds-text-align--center slds-theme--warning"};
                                        //console.log('sOwner: ' + sArray[i].OwnerId__c + ' - date: ' + datesInRange[m] + ' - sDATE: ' + sArray[i].Date__c + ' - HOURS: ' + sArray[i].Hours__c + ' - total: ' + hour);
	                            } else if (hour > 0) {
                                    //hour = hour + sArray[i].Hours__c;
                                    schedule = {Date__c: datesInRange[m], Hours__c: hour, Class:"slds-input slds-text-align--center slds-theme--success"};
                                        //console.log('sOwner: ' + sArray[i].OwnerId__c + ' - date: ' + datesInRange[m] + ' - sDATE: ' + sArray[i].Date__c + ' - HOURS: ' + sArray[i].Hours__c + ' - total: ' + hour);
                                } else {
	                            	//hour = hour + sArray[i].Hours__c;
	                                schedule = {Date__c: datesInRange[m], Hours__c: hour, Class:"slds-input slds-text-align--center slds-theme--default"};
                                        //console.log('sOwner: ' + sArray[i].OwnerId__c + ' - date: ' + datesInRange[m] + ' - sDATE: ' + sArray[i].Date__c + ' - HOURS: ' + sArray[i].Hours__c + ' - total: ' + hour);
	                            }
                            }

                            //schAry.push(schedule);
    
                        } else {

                            //console.log('NO MATCH --> date: ' + datesInRange[m].toString() + ' - sDate: ' + sDate.toString() + ' - sOwnerId: ' + sArray[i].OwnerId__c + ' - userId: ' + userId);

                            //hour = 0;
                            //console.log('RESET total hours: ' + hour + ' - NEW schedule date: ' + datesInRange[m] + '--' + sArray[i].Date__c);
                        }
                    }

                    // push hours into an array
                    schAry.push(schedule);
                        //console.log('sHours: ' + schedule.Hours__c + ' - sDate: ' + schedule.Date__c + ' - sOwnerId: ' + schedule.OwnerId__c);
                    //schedules.push(hour);
                }
				//component.set("v.schedules", schedules);
                component.set("v.userHours", schAry);

                //console.log('schedule records #: ' + schAry.length);
    
    
    }	
})