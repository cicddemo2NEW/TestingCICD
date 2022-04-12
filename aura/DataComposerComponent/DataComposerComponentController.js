({
    
    doInit: function(component, event, helper) {        
        helper.getObjectName(component, event);
    },
    handleNext : function(component,event,helper){
        var getselectedStep = component.get("v.selectedStep");
        if(getselectedStep == "1"){            
            var selectedName  = component.get("v.selectedValue");
            if(selectedName==""){
                var allValid = component.find('ObjectName').showHelpMessageIfInvalid('Error');                
            }else{
                var objectNameMap = component.get("v.objectNameMap");            
                for (var m in objectNameMap){                
                    if(objectNameMap[m].key == selectedName)//select selected object's API Name if condition matches
                        component.set("v.selectedObjectsAPIName", objectNameMap[m].value);
                }
                
                helper.getRelatedObjects(component, event);
                helper.getFilterValues(component, event);
                component.set("v.selectedStep", "2");
            }
        }
        else if(getselectedStep == "2"){
            //helper.getRelatedChildObjects(component, event);//Uncomment to find child objects dynamically.
            var filter  = component.get("v.filter");
            var filterValues  = component.get("v.filterValues");
            var filterValuesWhere  = component.get("v.filterValuesWhere");
            if((filter=="" || filterValues=="" ) && (filterValuesWhere=="" || filterValuesWhere==" where ")){
                component.set("v.showErrorMessage_step2",true);
            }else{
                component.set("v.showErrorMessage_step2",false);
                component.set("v.selectedStep", "3");
            }
        }
        /*else if(getselectedStep == "3"){
                component.set("v.selectedStep", "4");
            }*/
    },
    
    handlePrev : function(component,event,helper){
        var getselectedStep = component.get("v.selectedStep");
        if(getselectedStep == "2"){
            component.set("v.selectedStep", "1");
            helper.clearScreen1(component,event);
            helper.clearScreen2(component,event);
            
        }
        else if(getselectedStep == "3"){
            component.set("v.selectedStep", "2");
            //  helper.clearScreen2(component,event);
        }
            else if(getselectedStep == "4"){
                component.set("v.selectedStep", "3");
                
            }
    },
    
    handleFinish : function(component,event,helper){
        alert('Finished...');
        component.set("v.selectedStep", "1");
        helper.clearScreen1(component,event);
        helper.clearScreen2(component,event);
        
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