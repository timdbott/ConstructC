({
	handleClick : function(component, event, helper) {

		var caseId = component.get("v.caseId"),
			searchText = component.get("v.searchText"),
			selectedUserId, selectedUserName, elem;

		// get selected values
		selectedUserId = event.getSource().get("v.value");
		selectedUserName = event.getSource().get("v.label");

		// set component variables
		component.set("v.searchText",selectedUserName);
		component.set("v.userId",selectedUserId);

		// hide search pane
		elem = component.find("searchResults");
		$A.util.removeClass(elem,"slds-show");
        $A.util.addClass(elem,"slds-hide");
	},

	searchUsers : function(component, event, helper) {

		var caseId = component.get("v.caseId"),
			searchText = component.get("v.searchText"),
			elem;

		// query to find srNetwork user that match the search
		helper.findUsers(component, event);

		// display the results
		//elem = component.find("searchResults");
		//$A.util.removeClass(elem,"slds-hide");
        //$A.util.addClass(elem,"slds-show");
	},

	hideSearchResults : function(component, event, helper) {

		// hide the results
		var elem = component.find("searchResults");
		$A.util.removeClass(elem,"slds-show");
        $A.util.addClass(elem,"slds-hide");
	},

	assignCase : function(component, event, helper) {

		var caseId = component.get("v.caseId"),
			userId = component.get("v.userId");

		//console.log('caseId: ' + caseId + ' - userId: ' + userId);

		// check if values are not null
		if (caseId != 'undefined' && userId != 'undefined') {
			helper.helpAssignCase(component, event);
		} else {
			console.log('CapacityManagementCasesUserLookup.assignCase caseId or userId not found');
		}
		
	}
})