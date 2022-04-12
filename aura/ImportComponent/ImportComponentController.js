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
})