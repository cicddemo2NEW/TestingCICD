({

    init: function(component, event, helper) {
        
        var object = component.get("v.objectName");
        
        if (typeof object !== 'undefined'){
        	helper.initialize(component, event);
        }
    },

    handleSort: function(component, event, helper) {
        helper.handleSort(component, event);
    },
    handleRowAction: function ( component, event, helper ) {
      	var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
        var recId = row.Id;
                
        var object = component.get("v.objectName");
        var relationshipName = component.get("v.relationshipName");
        var filterField = component.get("v.filterField");
        var externalIdField = 'Conversion_Ref_ID__c';
        var externalId;
        
        if(externalIdField == 'Conversion_Ref_ID__c')
            externalId = row.Conversion_Ref_ID__c;
        
		console.log('--recordId: '+recId);        
        console.log('--object: '+object);
        console.log('--filterField: '+filterField);
        console.log('--relationshipName: '+relationshipName);
        console.log('--ExternalId: '+externalId);
        
        $A.createComponent("c:CompareRecord", {  
            "recordId": recId,
            "recordDetails": row
            }, function(newCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    var div = component.find("dynamicCompare");
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
});