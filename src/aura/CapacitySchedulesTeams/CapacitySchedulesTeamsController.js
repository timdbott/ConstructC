({
	doInit : function(component, event, helper) {
        

        var spinner = component.find('rowSpinner');

        //helper.retrieveCurrentUser(component, event);
        console.log('CapacitySchedulesUsers.doInit defaultTeam: ' + component.get("v.defaultTeam"));
        console.log('CapacitySchedulesUsers.doInit selectedTeam: ' + component.get("v.selectedTeam"));
        
        if (component.get("v.selectedTeam") === "undefined") {
            // go with defaultTeam...
        }
        
        $A.util.toggleClass(spinner, "slds-show");

        // call the controller method that returns schedule__c records for this case
        var action = component.get("c.getSrnUsers");
    
        // Add callback behavior when retrieving the records
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //component.set("v.teams", response.getReturnValue());
                console.log('CapacitySchedulesUsers.getSrnUsers query state: ' + state + ' - users#: ' + response.getReturnValue().length);

				var allUsers = response.getReturnValue(), 
                    teams = [], 
                    users = [],
                    results = [],
                    i, j, name, team, defaultTeam;

                component.set("v.srnUsers", allUsers);
                defaultTeam = component.get("v.defaultTeam");

                console.log('defaultTeam: ' + defaultTeam);

                // put teams into an array of strings
                if (allUsers === null || allUsers === "" || allUsers === 'null') {
                    console.log('allUsers list is null');
                } else if (defaultTeam !== "" || defaultTeam !== "All") {
                    for (i = 0, j = allUsers.length; i < j; i++) {
                        name = allUsers[i].Name;
                        team = allUsers[i].srNetwork_Team__c;

                        // if the current user's default team equals this then show it else show all teams
                        if (defaultTeam === team) {
                            users.push(team);
                        }

                    }
                } else {
                    for (i = 0, j = allUsers.length; i < j; i++) {
                        name = allUsers[i].Name;
                        team = allUsers[i].srNetwork_Team__c;
                        users.push(team);

                        //console.log('name: ' + name + ' - team: ' + team);
                    }
                }

                // create a unique array of teams
                teams = users.slice().sort(); // You can define the comparing function here. 
                                                     // JS by default uses a crappy string compare.
                                                     // (we use slice to clone the array so the
                                                     // original array won't be modified)
                for (i = 0; i < users.length; i++) {
                    if (teams[i + 1] != teams[i]) {
                        console.log('team: ' + teams[i]);
                        results.push(teams[i]);
                    }
                }

                component.set("v.teams",results);

                //$A.util.toggleClass(spinner, "slds-show");
                $A.util.removeClass(spinner,"slds-show");
                $A.util.addClass(spinner,"slds-hide");
            } else {
                console.log("CapacitySchedulesUsers.getSrnUsers Failed with state: " + state);
            }
        });
    
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})