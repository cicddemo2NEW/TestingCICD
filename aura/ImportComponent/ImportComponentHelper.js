({
    getResponse : function(component, event) {
        
        var parentRelationshipName;
        var objectName = component.get("v.objectName");
        var filterField = component.get("v.filterField");
        var externalId = component.get("v.filterField");
        var filterValues = component.get("v.filterValues");
        var fieldsToExport = component.get("v.fieldsToExport");
        var lookupFieldName = component.get("v.lookupFieldName");
        var lookupRelationshipName = component.get("v.lookupRelationshipName");        
        
        var filterValuesList = filterValues.split(',');
        
        var recIds = filterValuesList.map(function(id) { return "'" + id.trim() + "'"; }).join(", ");
        
        component.set("v.FilterIdsCount", filterValuesList.length);
        
        let Query='SELECT '+fieldsToExport+' FROM '+objectName;
        
        let whereCriteria;
        
        var queryURL = '/services/data/v54.0/query?q=';
        
        if (typeof lookupRelationshipName !== 'undefined'){
            whereCriteria = ' WHERE '+lookupRelationshipName+'.'+externalId+' IN ('+recIds+')';
        }else{
            whereCriteria = ' WHERE '+externalId+' IN ('+recIds+')';
        }
        
        var URI = queryURL + Query+whereCriteria;
        URI = URI.split(' ').join('+');        
        
        component.set("v.query", URI);
        
        component.set("v.showSpinner",true);//set loader to false
        var action = component.get("c.getRecord");        
        action.setParams({
            "serviceURL": URI
        });
        action.setCallback(this, function(response) {
            var records = component.get("v.objectData");
            let sourcedata = [];
            for (var index in records) {                
                let odata = records[index];
                
                //change keys to lowecase
                let item, keys = Object.keys(odata);
                let n = keys.length;
                let newDataobj={}
                while (n--) {
                    item = keys[n];
                    newDataobj[item.toLowerCase()] = odata[item];
                }                    
                records[index] = newDataobj;
                sourcedata.push({key:records[index][externalId], detail:records[index]});
            }
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {              
                
                var result = response.getReturnValue();
                var extId = component.get("v.filterField");
                
                if(result.length < 1){
                    component.set("v.message", "No data found.")   
                }
                var allrecords = [];
                for (let temp in result) {
                    let remoteData = [];
                    let data = result[temp];
                    
                    //change keys to lowecase
                    let item, keys = Object.keys(data);
                    let n = keys.length;
                    let newDataobj={}
                    while (n--) {
                        item = keys[n];
                        newDataobj[item.toLowerCase()] = data[item];
                    }                    
                    data = newDataobj;
                    var extIdValue = data[extId];
                    
                    for (let key in data) {
                        
                        if(typeof(data[key]) == 'object' && key != 'attributes'){
                            for (var x in data[key]) {
                                if(x != 'attributes')
                                    if(sourcedata.find(x => x.key === extIdValue) != null)
                                        remoteData.push({key:key+'.'+x, sourcevalue:sourcedata.find(x => x.key === extIdValue).detail[key], targetvalue:data[key][x]});
                                    else
                                        remoteData.push({key:key+'.'+x, sourcevalue:null, targetvalue:data[key][x]});
                            }
                        }else{
                            if(sourcedata.find(x => x.key === extIdValue) != null)
                                remoteData.push({key:key, sourcevalue:sourcedata.find(x => x.key === extIdValue).detail[key], targetvalue:data[key]});                
                            else
                                remoteData.push({key:key, sourcevalue:null, targetvalue:data[key]});                
                        }                    	
                    }
                    allrecords.push({key: data[extId], name: data['name'], value: remoteData});                    
                }
                component.set("v.finaldata", allrecords);
                component.set("v.showSpinner",false);//set loader to false
            }else if (component.isValid() && state === "ERROR") {
                console.log('----error response: '+JSON.stringify(response.getError()));
                var cmpEvent = component.getEvent("refreshDataEvent");  
                cmpEvent.setParams({"statusType": "ERROR", "statusValue": response.getError()[0].message});
                cmpEvent.fire();
                component.destroy();
            }
        });        
        $A.enqueueAction(action);        
    },
    handleImport: function(component, event, serviceURL) {
        
        var action = component.get("c.ImportAllRecords");
        //var dynamicFields = component.get("v.dynamicFields");        
        
        action.setParams({
            "serviceURL": serviceURL,
            "objectName": component.get("v.objectName"),
            "filterField": component.get("v.filterField"),
            "dynamicFields": component.get("v.dynamicFields"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                              
                var result = response.getReturnValue();
                
                var cmpEvent = component.getEvent("refreshDataEvent");        	 	
                cmpEvent.setParams({"statusType": "OK", "statusValue": 'The records have been imported successfully'});
                cmpEvent.fire();
                component.destroy();
            }else if (component.isValid() && state === "ERROR") {
                var cmpEvent = component.getEvent("refreshDataEvent");  
                cmpEvent.setParams({"statusType": "ERROR", "statusValue": response.getError()[0].message});
                cmpEvent.fire();
                component.destroy();
            }
        });
        $A.enqueueAction(action);        
    },
    
    
    checkImportPermission : function(component, event, helper) {
        
        var action = component.get("c.checkPermission");
        
        action.setCallback(this, function(response){
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                component.set("v.isImportEnabled", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
})