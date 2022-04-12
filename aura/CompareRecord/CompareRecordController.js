({
	doInit: function(component, event, helper) {
        var record = component.get("v.recordDetails");        
        var id = component.get("v.externalId");        
        var objectName= component.get("v.ObjectName");
        helper.getCurrentOrgDomain(component,event,helper);
        helper.getResponse(component,id, objectName);
    },
    handleClose: function(component, event, helper) {
        console.log('--Cancel called');
        var btnClicked = event.getSource();
        if (btnClicked.get("v.label") === "Cancel" || btnClicked.get("v.label") === "Close") {          
          component.destroy();
        }
    },
})