({
    COLUMNS: [
        { label: 'Product', fieldName: 'name' },
        { label: 'ProductCode', fieldName: 'ProductCode'},
        { label: 'ISActive', fieldName: 'ISActive', type: 'boolean' },
    ],

    DATA: [
        { id: 1, name: 'HD Television Service',ProductCode: '456789', ISActive: true },
        { id: 2, name: 'Business Software Package', ProductCode: '345634', ISActive: true },
        { id: 3, name: 'Acme Cloud Storage', ProductCode: '354657', ISActive: true },
    ],
    
    
    initialize: function(cmp) {
        var action = cmp.get("c.getMigrationObjectMetadata");
        var object = cmp.get("v.objectName");
        action.setParams({ 'crrentObject' :  object});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();    
                cmp.set("v.objectMetadata", result);
                
                this.setColumns(cmp);
            
            }else if (state === "ERROR") {   
                console.log('--no metadata entry found.');
                cmp.set("v.objectMetadata", null);
            }
        });
        $A.enqueueAction(action);
    },
    
    setColumns: function(cmp) {
        var metadata = cmp.get("v.objectMetadata");
        var fieldList = metadata.Fields_to_display__c.split(',');
        
        var action = cmp.get("c.getFieldLabels");
        var object = cmp.get("v.objectName");
        //console.log('---object: '+object);
        action.setParams({ 'objName' :  object, 'fieldList' :  fieldList});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();  
                cmp.set("v.objectHeadersMap",result);
                
                var headerList = [];
                for(var key in result){
                    headerList.push({fieldName: key, label: result[key]});
                }
                console.log('---headers: '+JSON.stringify(headerList));
                cmp.set('v.columns', headerList);
                
                this.setData(cmp);
            }
        });
        $A.enqueueAction(action);    
    },

    setData: function(cmp) {
        var metadata = cmp.get("v.objectMetadata");
        var fieldsToExport = metadata.Fields_to_export__c;
        var RelationshipField = metadata.Parent_relationship_field__c;
        var RelationshipName = metadata.Parent_relationship_name__c;
        var filterField = cmp.get("v.filterField");
        var filterValues = cmp.get("v.filterValues");
        var objectName = cmp.get("v.objectName");
        var parentObjectName = cmp.get("v.parentObjectName");
        
        var action = cmp.get("c.getChildRecords");
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
                console.log('---response: '+JSON.stringify(result));
                cmp.set('v.data', result);
            }
        });
        $A.enqueueAction(action);
        
        //cmp.set('v.data', this.DATA);
    },

    // Used to sort the 'Age' column
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

    handleSort: function(cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        var cloneData = this.DATA.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        cmp.set('v.data', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    }
})