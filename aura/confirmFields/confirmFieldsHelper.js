({
    getFieldsName: function(component, event) {
        console.log('fieldsListdefault: '+component.get("v.fieldsList"));
        var action = component.get("c.getFieldsList");
        action.setParams({ 'sObjName' : component.get("v.selectedObjectsAPIName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: '+result);
                var fieldsList = [];
                for(var key in result){
                    fieldsList.push({label: result[key], value: key});
                }
                component.set("v.fieldsList", fieldsList);   
                console.log('fieldsListAfterSet: '+JSON.stringify(component.get("v.fieldsList")));
            }
        });
        $A.enqueueAction(action);
    },
    
    getDefinedFieldsName: function(component, event) {
        var action = component.get("c.getdefinedFieldsList");
        action.setParams({ 'sObjName' : component.get("v.selectedObjectsAPIName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: '+result);
                var autoSelectedFieldsList = [];
				var fieldsList = component.get("v.fieldsList");
                for(var key in fieldsList){
                    console.log('In for ');
                    if (result[key]){
						console.log('In If ');
                        autoSelectedFieldsList.push(result[key]); 
                	}
                }
                component.set("v.autoSelectedFieldsList", autoSelectedFieldsList);
                component.set("v.selectedFields", autoSelectedFieldsList); 
                console.log('autoSelectedFieldsListAfterSet: '+component.get("v.autoSelectedFieldsList"));
                console.log('valueAfterSet: '+component.get("v.selectedFields"));
            }
        });
        $A.enqueueAction(action);
    }
})