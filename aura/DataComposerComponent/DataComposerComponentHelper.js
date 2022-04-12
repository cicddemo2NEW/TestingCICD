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
                var relatedObjectAPIName = [];
                for(var key in result){
                    realatedObjectNameMap.push({label: result[key].Name, value: result[key].Object_API_Name__c, parent_field_name: result[key].Parent_relationship_field__c, parent_relationship_name: result[key].Parent_relationship_name__c});
                    relatedObjectAPIName.push(result[key].Object_API_Name__c);
                }                
                component.set("v.objectList", realatedObjectNameMap);                
                realatedObjectNameMap.unshift({label: selectedName, value: component.get("v.selectedObjectsAPIName")});
                //component.set("v.relatedObjectList", [component.get("v.selectedObjectsAPIName")].concat(relatedObjectAPIName));                
                component.set("v.relatedObjectMapList",realatedObjectNameMap);                
                console.dir(component.get("v.objectLists"));
            }
        });
        $A.enqueueAction(action);
    },
    /* The getRelatedChildObjects method is not in use right now. */
    getRelatedChildObjects: function(component, event) {
        var action = component.get("c.getChildObjects");
        action.setParams({ 'selObject' : component.get("v.selectedObjectsAPIName") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                              
                component.set("v.relatedObjectList", [component.get("v.selectedObjectsAPIName")].concat(result));
            }
        });
        $A.enqueueAction(action);
    },
    
    clearScreen2: function(component, event)
    {
        component.set("v.filter", "");
        component.set("v.filterValues", "");
        component.set("v.filterValuesWhere", " where ");
        
    },
    clearScreen1: function(component, event)
    {
        component.set("v.selectedObjectsAPIName", "");
        component.find("ObjectName").set("v.value", "");
        
    },
})