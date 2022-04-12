({
	
    getObjectName: function(component, event) {
        var action = component.get("c.getObjectName_API");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var objectNameMap = [];
                for(var key in result){
                    objectNameMap.push({key: key, value: result[key]});
                }
                component.set("v.objectNameMap", objectNameMap);
            }
        });
        $A.enqueueAction(action);
    },
    getFilterValues: function(component, event) {
        var action = component.get("c.getFilterFields");
        action.setParams({ 'parentObjectAPIName' : component.get("v.selectedObjectsAPIName") });
        
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
        var action = component.get("c.getRelatedObjectsName");
        var selectedName  = component.get("v.selectedValue");
        action.setParams({ parentObjectName : selectedName });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var realatedObjectNameMap = [];
                for(var key in result){
                    realatedObjectNameMap.push({label: result[key], value: result[key]});
                }
				component.set("v.objectLists", realatedObjectNameMap);
                console.dir(component.get("v.objectLists"));
            }
        });
        $A.enqueueAction(action);
    },
    getRelatedChildObjects: function(component, event) {
        var action = component.get("c.getChildObjects");
        action.setParams({ 'selObject' : component.get("v.selectedObjectsAPIName") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                       
                
                component.set("v.relatedObjectLists", [component.get("v.selectedObjectsAPIName")].concat(result));
                //component.set("v.relatedObjectLists", component.get("v.relatedObjectLists"));
                /*
                console.log('--child Objects: ');
                for (var m in result){
                    console.log(result[m]);
                }
                console.log('--------------- ');
                */
            }
        });
        $A.enqueueAction(action);
    },
    
})