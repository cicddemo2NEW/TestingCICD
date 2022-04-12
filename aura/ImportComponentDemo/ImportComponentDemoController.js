({
	doInit : function(component, event, helper) {        
        helper.getResponse(component,event);
        helper.checkImportPermission(component,event,helper);
	},
    handleCancel: function(component, event, helper) {
        var btnClicked = event.getSource();
        if (btnClicked.get("v.label") === "Cancel" || btnClicked.get("v.label") === "Close") {          
          component.destroy();
        }
    },
    handleImportAll: function(component, event, helper) {    
        helper.handleImport(component, event, component.get("v.query"));        
    },    
    ImportRecord: function(component, event, helper) {        
        var recordExtId = event.getSource().get("v.value");
        var fieldsToExport = component.get("v.fieldsToExport");
        var lookupRelationshipName = component.get("v.lookupRelationshipName");
        var externalId = component.get("v.filterField");
        let whereCriteria;
        
        let Query='SELECT '+fieldsToExport+' FROM '+component.get("v.objectName");
        
        var queryURL = '/services/data/v54.0/query?q=';        
        if (typeof lookupRelationshipName !== 'undefined'){
        	whereCriteria = ' WHERE '+lookupRelationshipName+'.'+externalId+' IN (\''+recordExtId+'\')';
        }else{
            whereCriteria = ' WHERE '+externalId+' IN (\''+recordExtId+'\')';
        }        
        var URI = queryURL + Query+whereCriteria;
        URI = URI.split(' ').join('+');
        helper.handleImport(component, event, URI);        
    },
    collapseAccordian: function(component, event, helper) {        
        var openSections = component.find("accordion").get("v.activeSectionName");
        //console.log('--Toggled Accordian: '+openSections);
    },
    
    checkParentConRefId: function(component, event, helper) {    
        component.set("v.showParent", false);
        var recordExtId = event.getSource().get("v.value");
        var objectName = component.get("v.objectName");
        
  
       
        var URI = '/services/apexrest/mycall/';        
              
        var URI = URI + objectName + '/'+ recordExtId;
        URI = URI.split(' ').join('+');
        
        console.log('URI::' +  URI);
        var action = component.get("c.getRecordParent");
        action.setParams({
            "serviceURL": URI
        });
        console.log('UR2I::' +  URI);

         action.setCallback(this, function(response) {
             
            var state = response.getState();
           console.log('state::' +  state);
            if (component.isValid() && state === "SUCCESS") { 
                var remoteData ;
                var result = response.getReturnValue();
                
                console.log('resultt:' +  JSON.stringify(result));
                for (var key in result) {     
                   
                    var temp2 = result[key];
                   
                    for(var key2  in  temp2){
                       
                         
                        if(key2 === 'Conversion_Ref_ID__c'){
 
                         //console.log('key2:' +  key2);
                         //console.log('key2target:' +  temp2[key2]);
                            //remoteData.push({targetvalue:temp2[key2]}); 
                            remoteData += ' ' + temp2[key2];   
                        }
                        
                        if(key2 === 'attributes'){
                            
                            var temp3 =  temp2[key2];
                            
                            for(var key3  in  temp3){
                                if( key3 === 'type'){
                                     //console.log('key3:' +  key3);
                                     //console.log('key3target:' +  temp3[key3]);
                                     //remoteData.push({targetvalue:temp3[key3]});  
                                     remoteData+= ' '+ temp3[key3];  
                                }
                                
                            }
 
                        
                        }
                        
 
                    }
                              
                }    
                
                console.log('remoteData1:' +  remoteData );
                var remoteData = remoteData.replace('undefined','');
                console.log('remoteData2:' +  remoteData );
                component.set("v.finaldataParent", remoteData);
                
                console.log('v.finaldataParent:' + component.get("finaldataParent") );
                            
            }
        });
        $A.enqueueAction(action);  
        
        component.set("v.showParent", true);
       
        
    },
    
    
})