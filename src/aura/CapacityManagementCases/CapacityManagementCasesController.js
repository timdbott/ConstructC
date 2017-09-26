({
    doInit : function(component, event, helper) {
        var caseType = component.get("v.caseRqstType");
        
        if (caseType == "" || caseType == 'undefined' || caseType == null) {
            component.set("v.caseRqstType","All");
        }
    },

    changeType : function(component, event, helper) {
        
        // Get the case requested type
        var caseRqstType = component.get("v.caseRqstType");

        var spinner = component.find('rowSpinner');
        var msg = component.find('rowMsg');
        var divHeader = component.find('divHeader');

        $A.util.toggleClass(spinner, "slds-show");

        console.log('CapacityManagementCases.changeType: ' + caseRqstType);

        // call the controller method that returns schedule__c records for this case
        var action = component.get("c.getUnassignedCases");

        action.setParams({
            caseRqstType : caseRqstType

        });
    
        // Add callback behavior when retrieving the records
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //console.log('CapacityManagement.doinit query state: ' + state);
                
                component.set("v.unassignedCases", response.getReturnValue());

                // * show or hide spinner modal

                $A.util.removeClass(spinner,"slds-show");
                $A.util.addClass(spinner,"slds-hide");


                // * show or hide header and 'no results' message 

                if (response.getReturnValue().length > 0) {
                    // no results message
                    $A.util.removeClass(msg,"slds-show");
                    $A.util.addClass(msg,"slds-hide");

                    // header
                    $A.util.removeClass(divHeader,"slds-hide");
                    $A.util.addClass(divHeader,"slds-show");
                } else {
                    // no results message
                    $A.util.removeClass(msg,"slds-hide");
                    $A.util.addClass(msg,"slds-show");

                    // header
                    $A.util.removeClass(divHeader,"slds-show");
                    $A.util.addClass(divHeader,"slds-hide");
                }

            } else {
                console.log("CapacityManagement.doinit Failed with state: " + state);
            }
        });
    
        // Send action off to be executed
        $A.enqueueAction(action);
    },

    showMore : function (component, event, helper) {

        var target = event.getSource(),
	        cardElemId = target.get("v.name"),
            infoCard;

        infoCard = component.find(cardElemId);

        console.log('CapacityManagementCases.showMore: ' + cardElemId);

        if ( $A.util.hasClass(infoCard,"slds-hide") ) {
            $A.util.removeClass(infoCard,"slds-hide");
            $A.util.addClass(infoCard,"slds-show");
        } else {
            $A.util.removeClass(infoCard,"slds-show");
            $A.util.addClass(infoCard,"slds-hide");
        }


    }
})