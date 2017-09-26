({
	findUsers : function(component, event) {

		var searchText = component.get("v.searchText");

		// set search string for apex search
		if ( searchText.length > 0) {
			searchText = '%'+searchText+'%';
		} else {
			searchText = '';
		}


        console.log('CapacityManagementCasesUserLookup.findUsers: ' + searchText);

        // call the controller method that returns schedule__c records for this case
        var action = component.get("c.getSrnUsers");

        action.setParams({
            name : searchText

        });
    
        // Add callback behavior when retrieving the records
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //console.log('CapacityManagement.doinit query state: ' + state);
                //component.set("v.users", response.getReturnValue());

                var sArray = response.getReturnValue(),
                    elem = component.find("searchResults"),
                    numOfUsers;

                // set hasPastCases to true if we have past cases
                numOfUsers = sArray.length;

                component.set("v.users",sArray);
                if (numOfUsers > 0) {
                    //component.set("v.users",sArray);
                    $A.util.removeClass(elem,"slds-hide");
                    $A.util.addClass(elem,"slds-show");
                } else {
                    console.log('CapacityManagementCasesUserLookup.findUsers No search results');
                    $A.util.removeClass(elem,"slds-show");
                    $A.util.addClass(elem,"slds-hide");
                }


            } else if (component.isValid() && state === "INCOMPLETE") {
                console.log("CapacityManagementCasesUserLookup.findUsers Failed with Incomplete state: " + state);

            } else if (component.isValid() && state === "ERROR") {
                
                var errSchAry = [],
                    errors = response.getError();
                                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("CapacityManagementCasesUserLookup.findUsers * Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("CapacityManagementCasesUserLookup.findUsers * Unknown error");
                }
            }
        });
    
        // Send action off to be executed
        $A.enqueueAction(action);
	},

	helpAssignCase : function(component, event) {

		var caseId = component.get("v.caseId"),
			userId = component.get("v.userId");

        // call the controller method that returns schedule__c records for this case
        var action = component.get("c.reassignCase");

        console.log('caseId: ' + caseId + ' - userId: ' + userId);

        action.setParams({
            caseId : caseId,
            ownerId : userId
        });
    
        // Add callback behavior when retrieving the records
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //console.log('CapacityManagement.doinit query state: ' + state);
                //component.set("v.users", response.getReturnValue());

                var sArray = response.getReturnValue();

                console.log("CapacityManagementCasesUserLookup.helpAssignCase state: " + state);

                // hide this case row
                var asgnCaseEvnt = component.getEvent("CapacityManagementCaseAssigned");
                asgnCaseEvnt.fire();

                // show success toast
                var title = "Success!";
                var message = "Case successfully assigned.";
                var type = "success";
                this.showToast(component, event, title, message, type);

            } else if (component.isValid() && state === "INCOMPLETE") {
                console.log("CapacityManagementCasesUserLookup.helpAssignCase Failed with Incomplete state: " + state);

                // show error toast
                var title = "Incomplete!";
                var message = "Assignment attempt went sideways with an Incomplete state. :(";
                var type = "error";
                this.showToast(component, event, title, message, type);

            } else if (component.isValid() && state === "ERROR") {
                
                var errSchAry = [],
                    errors = response.getError();
                
                component.set("v.errorMsg","Could not assign case. Please try again later.");
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("CapacityManagementCasesUserLookup.helpAssignCase * Error message: " + 
                                 errors[0].message);

                        // show error toast
		                var title = "Error!";
		                var message = "Assignment attempt went sideways with an error message: " + errors[0].message;
		                var type = "error";
		                this.showToast(component, event, title, message, type);

                    }
                } else {
                    console.log("CapacityManagementCasesUserLookup.helpAssignCase * Unknown error");
                }
            }
        });
    
        // Send action off to be executed
        $A.enqueueAction(action);
	},

    showToast : function(component, event, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
})