({

    init: function(cmp, event, helper) {
        
        var object = cmp.get("v.objectName");
        
        if (typeof object !== 'undefined'){
        	helper.initialize(cmp);
        }
    },

    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    }
});