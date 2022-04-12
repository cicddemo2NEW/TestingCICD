({
	doInit: function(component, event, helper) {
        helper.getFieldsName(component, event);
		helper.getDefinedFieldsName(component, event);
    },
    
    handleChange: function (component, event, helper) {
        var changeValue = event.getParam("value");
        component.set("v.selectedFields", changeValue); 
        console.log('valueAfterChange: '+component.get("v.selectedFields"));
    },
    
    /*onSubmit : function(component, event, helper) {
        var checkboxValues = component.get("v.selectedFields");
        console.log('checkboxValues: ' + checkboxValues);
        alert(component.get("v.selectedFields"));
        var action = component.get("c.requestCheckedFields");
	},*/
    
    closeModal: function(component, event, helper) {
      component.set("v.isModalOpen", false);
   },
})