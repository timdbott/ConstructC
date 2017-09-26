({
	doInit : function(component, event, helper) {
        
        var userId = component.get("v.userId");

        //console.log('CapacitySchedulesUsersHrs.doInit * userId: ' + userId + ' - schedules#: ' + component.get("v.scheduleRcds").length);

        
        helper.getSchedules(component, event);
    }
})