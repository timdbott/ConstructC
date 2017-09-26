({
	retrieveCurrentUser : function(component, event) {
		
		var action = component.get("c.currentUserId");
		
		// Add callback behavior when retrieving the records
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				//component.set("v.teams", response.getReturnValue());
				console.log('CapacitySchedulesUsers.retrieveCurrentUser query state: ' + state);

				var user = response.getReturnValue(), 
					name, team;

				component.set("v.currentUserId",user[0].Id);
				component.set("v.defaultTeam",user[0].srNetwork_Team__c);
				console.log('team: ' + srNetwork_Team__c);

			} else {
				console.log("CapacitySchedulesUsers.retrieveCurrentUser Failed with state: " + state);
			}
		});
	
		// Send action off to be executed
		$A.enqueueAction(action);
	}
})