({

    showMore : function (component, event, helper) {

        var infoCard = component.find("moreInfo"),
            caseType = component.get("v.caseType");

        console.log('caseType: ' + caseType);

        if ( $A.util.hasClass(infoCard,"slds-hide") ) {
        	console.log('showMore unhide moreInfoCard');

        	// find past cases for this account
        	helper.setCasesForAccount(component, event);

            $A.util.removeClass(infoCard,"slds-hide");
            $A.util.addClass(infoCard,"slds-show");

            var spinner = component.find('caseSpinner');
            $A.util.toggleClass(spinner, "slds-show");
        } else {
        	console.log('showMore hide moreInfoCard');
            $A.util.removeClass(infoCard,"slds-show");
            $A.util.addClass(infoCard,"slds-hide");
        }

    },

    assignCase : function (component, event, helper) {

    	var caseId = component.get("v.caseId"),
    		ownerId = event.getSource().get("v.value");

    	if (caseId != null && caseId != 'undefined' && caseId != "" && ownerId != null && ownerId != 'undefined' && ownerId != "") {

	    	helper.setCaseOwner(component, event, caseId, ownerId);
	    	
    	} else {
    		console.log('CapacityManagementCasesRow.assignCase: error - CaseId or OwnerId is null');
    	}

    },

    hideCmp : function (component, event, helper) {

        // hide this component
        var caseRow = component.find("caseRow");
        $A.util.removeClass(caseRow,"slds-show");
        $A.util.addClass(caseRow,"slds-hide");

        event.stopPropagation();

    }
})