({
    initialize: function(component, event) {
        
        var action = component.get("c.getMigrationObjectMetadata");
        var object = component.get("v.objectName");
        action.setParams({ 'crrentObject' :  object});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();    
                component.set("v.objectMetadata", result);                
                this.getData(component, event);            
            }else if (state === "ERROR") {   
                console.log('--no metadata entry found.');
                component.set("v.objectMetadata", null);                
            }
        });
        $A.enqueueAction(action);
    },
    getData: function(component, event) {
        var metadata = component.get("v.objectMetadata");
        var fieldsToExport = metadata.Fields_to_export__c;
        var RelationshipField = metadata.Parent_relationship_field__c;
        
        var RelationshipName = metadata.Parent_relationship_name__c;
        component.set("v.relationshipName",RelationshipName);
        
        var filterField = component.get("v.filterField");
        var filterValues = component.get("v.filterValues");
        var objectName = component.get("v.objectName");
        var parentObjectName = component.get("v.parentObjectName");
        
        component.set("v.showSpinner",true);//set loader to false
        component.set("v.showObject",true);
        
        var action = component.get("c.getChildRecords");
        action.setParams({ 'fieldsToExport' :  fieldsToExport,
                           'RelationshipField' :  RelationshipField,
                           'RelationshipName' :  RelationshipName,
                           'filterName' :  filterField,
                           'filterValues' :  filterValues,
                           'objectName' :  objectName,
                           'parentObjectName' :  parentObjectName,
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length>0){
                    component.set("v.objectData",result);
                    //console.log('---ObjectData: '+JSON.stringify(result));
                    this.setColumns(component, event);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    setColumns: function(component, event) {
        var metadata = component.get("v.objectMetadata");
        var fieldList = metadata.Fields_to_display__c.split(',');
        
        var action = component.get("c.getFieldLabels");
        var object = component.get("v.objectName");
        action.setParams({ 'objName' :  object, 'fieldList' :  fieldList});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();  
                component.set("v.objectHeadersMap",result);
                
                //default compare icon.
                var headerList = [{label: 'Compare', type: 'button-icon', initialWidth: 75, typeAttributes: {iconName: 'action:preview', title: 'Preview', variant: 'border-filled', alternativeText: 'View'}}];
                
                for(var key in result){
                    if(JSON.stringify(key).includes("CreatedDate")){
                        headerList.push({fieldName: key, label: result[key], type: 'datetime', sortable: true, defaultSortDirection: 'desc'});
                    }else{
                        headerList.push({fieldName: key, label: result[key]});    
                    }                      
                }                   
                component.set('v.columns', headerList);
        		component.set("v.showSpinner",false);//set loader to false
                this.setData(component, event);
            }
        });
        $A.enqueueAction(action);    
    },

    setData: function(component, event) {        
        component.set('v.data', component.get("v.objectData"));
    },

    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function(component, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        
        var cloneData = component.get("v.objectData").slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        component.set('v.data', cloneData);
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', sortedBy);
    },
    convertListToCSV : function(component, sObjectList){
        if (sObjectList == null || sObjectList.length == 0) {
            return null;  
        }        
        var columnEnd = ',';
        var lineEnd =  '\n';
        // Get the CSV header from the list.
        var keys = new Set();
        sObjectList.forEach(function(record){
            Object.keys(record).forEach(function(key){
                if(component.get("v.exportWithId")){                    
                    keys.add(key);
                }
                else{
                    if(key!="Id")
                        keys.add(key);
                }
            });
        });        
        keys = Array.from(keys);
        var csvString = '';
        csvString += keys.join(columnEnd);
        csvString += lineEnd;
        for(var i=0; i < sObjectList.length; i++){
            var counter = 0;
            for(var sTempkey in keys) {
                var skey = keys[sTempkey];
                // add , after every value except the first.
                if(counter > 0){
                    csvString += columnEnd;
                }
                // If the column is undefined, leave it as blank in the CSV file.
                var value = sObjectList[i][skey] === undefined ? '' : sObjectList[i][skey];
                csvString += '"'+ value +'"';
                counter++;
            }
            csvString += lineEnd;
        }
        return csvString;
    },
})