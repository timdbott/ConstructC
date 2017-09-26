({
    getWeekDates : function(component, startDate) {
        
        var numOfDays = component.get("v.daysToDisplay"), 
            datesInWeek = [],
            d, day, diff, monday, nextDay, newDate, i, j;
        
        d = new Date(startDate);
        
        if (startDate === null) {
            startDate = new Date();
        }
            
        // find day # of the week ('0' = sunday)
        day = d.getDay();
        
        // find day # of month
        diff = d.getDate() - day + (day == 0 ? -7 : 0); // adjust when day is sunday
        
            	// find sunday
            	//sunday = new Date(d.setDate(diff)),
            	
        //find monday
        monday = new Date(d.setDate(diff + 1));
                
        // loop through numofdays and push dates in array
        for (i = 0, j = numOfDays; i < j; i = i + 1) {
			
            nextDay = new Date(monday.valueOf());
            nextDay = nextDay.setDate(nextDay.getDate() + i);
            newDate = new Date(nextDay);

            newDate = this.getFormattedDate(newDate);

            datesInWeek.push(newDate);
        }

        return datesInWeek;
    },

    getFormattedDate : function(dateToFormat) {
        
        var d = new Date(dateToFormat),
            monthTxt = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],
            year, month, day, formattedDate;
        
        //console.log('ScheduleCalDateHlpr * getFormattedDate * dateToFormat: ' + dateToFormat + ' d: ' + d);;
        	
        year = d.getFullYear();
        month = d.getMonth();
        //month = d.getMonth() + 1;
        day = d.getDate();
        
        console.log('CapacitySchedulesHeader.getFormattedDate * date: ' + d + ' day: ' + day);
        
        //month = month.toString().length === 2 ? month : 0 + month.toString();
        if (day === undefined || day === "") {
            console.log('CapacitySchedulesHeader.getFormattedDate is undefined or null');
        } else {
            day = day.toString().length === 2 ? day : 0 + day.toString();
        }
        
        formattedDate = monthTxt[month] + " " + day;
        //formattedDate = year + "-" + month + "-" + day;
               
        return formattedDate;
	}
})