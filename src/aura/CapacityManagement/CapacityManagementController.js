({
    doInit : function(component, event, helper) {
        
        // call the controller method that returns picklist values for case type
        var action = component.get("c.getRequestTypes");
    
        // Add callback behavior when retrieving the records
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('CapacityManagement.doinit query state: ' + state);
                component.set("v.caseRqstTypes", response.getReturnValue());
            } else {
                console.log("CapacityManagement.doinit Failed with state: " + state);
            }
        });
    
        // Send action off to be executed
        $A.enqueueAction(action);
    },

    selectRqstType : function(component, event, helper) { 

        var selectedRqstType = component.get("v.selectedRqstType");

        console.log('CapacityManagement.selectRqstType: ' + selectedRqstType);

        
    }
})