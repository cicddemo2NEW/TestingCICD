({
    
    doInit: function(component, event, helper) {        
        helper.getObjectName(component, event);
    },
    handleNext : function(component,event,helper){
        var getselectedStep = component.get("v.selectedStep");
        if(getselectedStep == "1"){
            helper.getRelatedObjects(component, event);
            
            //new
            var selectedName  = component.get("v.selectedValue");
            var objectNameMap = component.get("v.objectNameMap");            
            for (var m in objectNameMap){                
                if(objectNameMap[m].key == selectedName)
                    component.set("v.selectedObjectsAPIName", objectNameMap[m].value);
            }
            //end new
            
            helper.getFilterValues(component, event);
            component.set("v.selectedStep", "2");
			            
        }
        else if(getselectedStep == "2"){
            helper.getRelatedChildObjects(component, event);
            component.set("v.selectedStep", "3");
        }
         else if(getselectedStep == "3"){
            component.set("v.selectedStep", "4");
        }
    },
     
    handlePrev : function(component,event,helper){
        var getselectedStep = component.get("v.selectedStep");
        if(getselectedStep == "2"){
            component.set("v.selectedStep", "1");
        }
        else if(getselectedStep == "3"){
            component.set("v.selectedStep", "2");
        }
        else if(getselectedStep == "4"){
            component.set("v.selectedStep", "3");
        }
    },
     
    handleFinish : function(component,event,helper){
        alert('Finished...');
        component.set("v.selectedStep", "1");
    },
     
    selectStep1 : function(component,event,helper){
        component.set("v.selectedStep", "1");
    },
    selectStep2 : function(component,event,helper){
        component.set("v.selectedStep", "2");
    },
    selectStep3 : function(component,event,helper){
        component.set("v.selectedStep", "3");
    },
    selectStep4 : function(component,event,helper){
        component.set("v.selectedStep", "4");
    },
    handleOnChange : function(component, event, helper) {
        var filter = component.get("v.filter");
    },
})