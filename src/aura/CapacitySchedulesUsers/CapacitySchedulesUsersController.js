({
	doInit : function(component, event, helper) {
        
        var team = component.get("v.team"),
            users = component.get("v.srnUsers"),
            teamMembers = [],
            usersTeam, i, j, userId;

            //console.log('CapacitySchedulesUsers.doInit looking for team: ' + team);


        for (i = 0, j = users.length; i < j; i = i + 1) {
            usersTeam = users[i].srNetwork_Team__c;

            //console.log('CapacitySchedulesUsers.doInit user: ' + users[i].Name + '\'s team: ' + usersTeam);

            if ( usersTeam === team ) {
                caseOwnerId = users[i].Id;
                caseOwnerId = caseOwnerId.slice(0,15);

                // add 15 character user id length so it will work with the report parameter
                users[i].caseOwnerId = caseOwnerId;

                // add report url
                users[i].reportUrl = 'https://steelcase.lightning.force.com/one/one.app#/sObject/00O37000001pDxsEAE/view?a:t=1493136505426&fv0='+caseOwnerId;

                // push to array the final changes to user value
                teamMembers.push(users[i]);
                //console.log('CapacitySchedulesUsers.doInit add user: ' + users[i].Name + ' too team: ' + team);
            }
        }

        component.set("v.teamMembers", teamMembers);
        
        helper.getSchedules(component, event);
    }
})