({
	doInit : function(component, event, helper) {
		var deploymentId = component.get("v.recordId");
        component.set("v.showSpinner",true);//start showing spinner on initialization
	},
    getReleaseDetails : function(component, event, helper) {
		
        var releaseDetails = component.get("v.deploymentRecord");
        
        var action = component.get("c.getReleaseDeploymentDetails");
        action.setParams({ 'ReleaseId' : releaseDetails.CPQ_Release__c });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner",false);//stop showing sprinner once data is returned from the server.
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.objects",result);
            }
        });
        $A.enqueueAction(action);
	},
    handleVeiw : function(component, event, helper) {
        
         var ctarget = event.currentTarget;
        var objectName = ctarget.dataset.objectlabel;
        var IdsToMigrate = ctarget.dataset.ids;
        var ObjectAPIName = ctarget.dataset.objectapiname;
   
     
        $A.createComponent("c:DeploymentItemDetail", {  
            "selectedObjectsAPIName": ObjectAPIName,
            "filterValues": IdsToMigrate,
            "selectedObjectLabel": objectName,
                      
            }, function(newCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    var div = component.find("dynamicComponent");
                    component.set("v.showDeploymentStatusSection", false);
                    div.set("v.body", newCmp);
                }else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
                
            });
    },
    navigateToDeploy : function(component, event, helper) {
        
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__TestN'
            },
            state: {
                c__releaseId: component.get("v.recordId"),
            }
        };
        component.set("v.pageReference", pageReference);
        const navService = component.find('navService');
        const pageRef = component.get('v.pageReference');
        const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
        navService.generateUrl(pageRef).then(handleUrl, handleError);
    }
})