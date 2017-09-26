({
	setCasesForAccount : function(component, event) {

		//getAccountCases
		        // Get the account id
        var actId = component.get("v.actId");

        console.log('CapacityManagementCasesRow.setCasesForAccount: ' + actId);

        // call the controller method that returns schedule__c records for this case
        var action = component.get("c.getAccountCases");

        action.setParams({
            actId : actId

        });
    
        // Add callback behavior when retrieving the records
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //console.log('CapacityManagement.doinit query state: ' + state);
                component.set("v.pastCases", response.getReturnValue());

                var sArray = response.getReturnValue(),
                    numOfCases, elem;

                // set hasPastCases to true if we have past cases
                numOfCases = sArray.length;

                var caseSpinner = component.find("caseSpinner");

                $A.util.removeClass(caseSpinner,"slds-show");
                $A.util.addClass(caseSpinner,"slds-hide");


                if (numOfCases > 0) {
                    elem = component.find("moreInfoCard");
                    $A.util.removeClass(elem,"slds-hide");
                    $A.util.addClass(elem,"slds-show");
                    //this.toggleElem(component, event, "moreInfoCard");
                    //this.toggleElem(component, event, "pastCasesTable");
                } else {
                    console.log('toggle noCasesToast');
                    elem = component.find("noCasesToast");
                    $A.util.removeClass(elem,"slds-hide");
                    $A.util.addClass(elem,"slds-show");
                    //this.toggleElem(component, event, "noCasesToast");
                }

            } else {
                console.log("CapacityManagementCasesRow.setCasesForAccount Failed with state: " + state);
            }
        });
    
        // Send action off to be executed
        $A.enqueueAction(action);
	},

	setCaseOwner : function(component, event, caseId, ownerId) {

		//getAccountCases
		        // Get the account id
        var caseId = component.get("v.caseId");

        console.log('CapacityManagementCasesRow.setCaseOwner: ' + ownerId);

        // call the controller method that returns schedule__c records for this case
        var action = component.get("c.reassignCase");

        action.setParams({
            caseId : caseId,
            ownerId : ownerId
        });
    
        // Add callback behavior when retrieving the records
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //console.log('CapacityManagement.doinit query state: ' + state);

                // hide this component
                var caseRow = component.find("caseRow");
                $A.util.removeClass(caseRow,"slds-show");
                $A.util.addClass(caseRow,"slds-hide");

                // show success toast
                var title = "Success!";
                var message = "Case successfully assigned.";
                var type = "success";
                this.showToast(component, event, title, message, type)

            } else {
                console.log("CapacityManagementCasesRow.setCaseOwner Failed with state: " + state);
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

    toggleElem : function(component, event, elemId) {

        var elem = component.find(elemId);

        if ( $A.util.hasClass(elem,"slds-hide") ) {
            $A.util.removeClass(elem,"slds-hide");
            $A.util.addClass(elem,"slds-show");
        } else {
            $A.util.removeClass(elem,"slds-show");
            $A.util.addClass(elem,"slds-hide");
        }
    }

})