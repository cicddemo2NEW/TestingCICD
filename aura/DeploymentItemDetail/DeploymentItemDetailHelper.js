({
	getFilterValues: function(component, event) {
        
        var apiname = component.get("v.selectedObjectsAPIName");
        var action = component.get("c.getFilterFields");
        action.setParams({ 'parentObjectAPIName' : apiname });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var filterMap = [];
                for(var key in result){
                    filterMap.push({key: key, value: result[key]});
                    
                    
                }
                component.set("v.filterMap", filterMap);
            }
        });
        $A.enqueueAction(action);
    },
    getRelatedObjects: function(component, event) {        
        let selectedName  = component.get("v.selectedObjectLabel");
        let realatedObjectNameMap = [];
        realatedObjectNameMap.push({label: selectedName, value: component.get("v.selectedObjectsAPIName")});        
        
        component.set("v.relatedObjectMapList",realatedObjectNameMap);
    },
})