({
    getResponse: function(component, id , objectName) {      
        
        var serviceUrl = '/services/data/v53.0/sobjects/'+objectName+'/Conversion_Ref_ID__c/'+id;
        var action = component.get("c.getRecord");        
        action.setParams({
            "serviceURL": serviceUrl
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var record = component.get("v.recordDetails");
            if (component.isValid() && state === "SUCCESS") { 
                var remoteData = [];
                var result = response.getReturnValue();
                for (var key in record) {                    
                    remoteData.push({key:key, sourcevalue:record[key], targetvalue:result[key]});            
                }                
                component.set("v.finaldata", remoteData);
                //component.set("v.ShowTable", true);               
            }
        });        
        $A.enqueueAction(action);
    },    
    
    getCurrentOrgDomain : function(component,event,helper) {     
        
        var action = component.get("c.getCurrentInstance");          
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                var result = response.getReturnValue();
                component.set("v.instanceDomain", result);    
            }
        });        
        $A.enqueueAction(action);   
    },
})