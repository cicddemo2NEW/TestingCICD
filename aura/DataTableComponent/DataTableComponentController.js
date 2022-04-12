({

    init: function(component, event, helper) {
        
        var object = component.get("v.objectName");        
        if (typeof object !== 'undefined'){
        	helper.initialize(component, event);
        }
    },
    reIntit: function(component, event, helper) {
        var message = event.getParam("statusValue");
        var status = event.getParam("statusType");
        var type = 'error';
        let title = 'Error';
        if(status == 'OK'){
            type = 'success';
            title = 'Success';
        }            
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message,
            "duration": 10000
        });
        toastEvent.fire();
        helper.initialize(component, event);        
    },

    handleSort: function(component, event, helper) {
        helper.handleSort(component, event);
    },
    refreshGrid: function(component, event, helper) {
        console.log('---refreshGrid has been requested.');
    },
    handleRetrieveFromOther: function ( component, event, helper ) {
        
       
        var metadata = component.get("v.objectMetadata");
        
        //var fieldsToExport = metadata.Fields_to_export__c;
        var fieldsToExport = component.get("v.fieldsToExport")
		
        var dynamicFields = metadata.Dynamic_Fields__c;        
        
        var objectName = component.get("v.objectName");
        var filterField = component.get("v.filterField");
        var filterValues = component.get("v.filterValues");
        var lookupFieldName = component.get("v.lookupFieldName");
        var lookupRelationshipName = component.get("v.lookupRelationshipName");
        
        $A.createComponent("c:ImportComponent", {  
            "objectName": objectName,
            "objectData": component.get("v.objectData"),
            "filterField": filterField,
            "filterValues": filterValues,
            "fieldsToExport": fieldsToExport,
            "dynamicFields": dynamicFields,
            "lookupFieldName": lookupFieldName,
            "lookupRelationshipName":lookupRelationshipName,            
            }, function(newCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    var div = component.find("dynamicComponent");
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
    handleRowAction: function ( component, event, helper ) {
      	var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
        var recId = row.Id;                
        var object = component.get("v.objectName");
        var label = component.get("v.objectLabel");


        var externalId;
        var externalIdField = component.get("v.filterField");
        for(var key in row){
            if(key.toLowerCase() == externalIdField.toLowerCase()){
                externalId = row[key];
                break;
            }
        }
        $A.createComponent("c:CompareRecord", {  
            "recordId": recId,
            "ObjectName": object,
            "objectLabel": label,
            "externalIdField": externalIdField,
            "externalId": externalId,
            "recordDetails": row
            }, function(newCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    var div = component.find("dynamicComponent");
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
    btnToggleButton:function(component,event,helper){
        var checkCmp = component.find("tglbtn").get("v.checked");
        component.set("v.exportWithId",checkCmp);
    },
    downloadRecords :function(component, event, helper){
        var recordsList=component.get("v.objectData");
        var object = component.get("v.objectName");
        var csv = helper.convertListToCSV(component, recordsList);
        if (csv == null){return;}
        // Create a temporal <a> html tag to download the CSV file
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self';
        hiddenElement.download = object+'_DataExport.csv';;
        document.body.appendChild(hiddenElement);
        // using click() js function to download csv file
        hiddenElement.click();
    },
    
     handleRetrieveFromOtherparentsdetails: function ( component, event, helper ) {
       
        var metadata = component.get("v.objectMetadata");
        
        //var fieldsToExport = metadata.Fields_to_export__c;
        var fieldsToExport = component.get("v.fieldsToExport")
		
        var dynamicFields = metadata.Dynamic_Fields__c;        
        
        var objectName = component.get("v.objectName");
        var filterField = component.get("v.filterField");
        var filterValues = component.get("v.filterValues");
        var lookupFieldName = component.get("v.lookupFieldName");
        var lookupRelationshipName = component.get("v.lookupRelationshipName");
        
        $A.createComponent("c:ImportComponentDemo", {  
            "objectName": objectName,
            "objectData": component.get("v.objectData"),
            "filterField": filterField,
            "filterValues": filterValues,
            "fieldsToExport": fieldsToExport,
            "dynamicFields": dynamicFields,
            "lookupFieldName": lookupFieldName,
            "lookupRelationshipName":lookupRelationshipName,            
            }, function(newCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    var div = component.find("dynamicComponent");
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
    
    callconfirmFieldsComp:function(component,event,helper){
        
        var objectName = component.get("v.objectName");
        var fieldsToExport = component.get("v.fieldsToExport");
        var modalBody;
        var modalFooter;
        
        $A.createComponents([
            ["c:confirmFields", { 
                "fieldsList": fieldsToExport,
                "autoSelectedFieldsList": fieldsToExport,
                "selectedObjectsAPIName": objectName,
                "selectedFields": fieldsToExport}],
            ["c:confirmFieldsModal",{}]
            ], function(content, status, errorMessage) {
                	modalBody = content;
            		if (status === "SUCCESS") {
                        modalBody = content[0];
                        modalFooter = content[1];
                    	component.find('confirmFieldsAuraId').showCustomModal({
                    		body: modalBody,
                            footer: modalFooter,
                    		showCloseButton: true,
                		})
                        console.log("fieldsToExport"+fieldsToExport);
                        console.log("fieldsToExportComp"+component.get("v.fieldsToExport"));
                    }
           	});
    },
    
});