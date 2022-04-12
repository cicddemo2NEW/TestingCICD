({
    callLoginMethod: function(component, event) {
        var action = component.get("c.callwebService");
        var selectedOrg = component.get("v.selectedValue");
        var userNameValue = component.get("v.userNameValue");
        var passwordInfo = component.get("v.passwordInfo");
        action.setParams({ 
            'userNameInfo' :  userNameValue,
            'passwordSecurityT' :  passwordInfo,
            'OrgInfo' :  selectedOrg
                         });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();    
                component.set("v.loginResponse", result); 
            }else if (state === "ERROR") {   
                component.set("v.loginResponse", null);                
            }
        });
        $A.enqueueAction(action);
    },
})