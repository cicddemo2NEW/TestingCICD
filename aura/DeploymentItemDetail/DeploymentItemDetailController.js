({
	doInit : function(component, event, helper) {
		
       helper.getRelatedObjects(component, event);
        helper.getFilterValues(component, event);
	},
    handleNext : function(component,event,helper){
    
  
     var filter  = component.get("v.filter");
            var filterValues  = component.get("v.filterValues");
            var filterValuesWhere  = component.get("v.filterValuesWhere");
            if((filter=="" || filterValues=="" ) && (filterValuesWhere=="" || filterValuesWhere==" where ")){
                component.set("v.showErrorMessage_step2",true);
            }else{
                component.set("v.showErrorMessage_step2",false);
                component.set("v.selectedStep", "2");
            }
    
    },
    navigateToDeploy: function(component,event,helper){
    	    var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": "a8a5c00000001shAAA"
            });
            navEvt.fire();
    }
})