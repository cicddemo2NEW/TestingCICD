({
    doInit: function (component, event, helper) { 
        console.log('doInit of component called');
        var columns = [
            {
                fieldName: 'Name',
                label: 'Object relationship details',
                typeAttributes: {
                    label: { fieldName: 'Name' }
                }
            }
            
        ];
        component.set('v.gridColumns', columns);
        
        
        var trecid = component.get('v.ltngcurrentRecId');
        //var tsObjectName= component.get('v.ltngSobjectname');
        //var tparentFieldAPIname= component.get('v.ltngParentFieldAPIName');
        //var tlabelFieldAPIName= component.get('v.ltngLabelFieldAPIName');
        if(trecid){
            helper.callToServer(
                component,
                "c.findHierarchyData",
                function(response) {
                    var expandedRows = [];
                    var apexResponse = response;
                    var roles = {};
                    console.log('*******apexResponse:'+JSON.stringify(apexResponse));
                    var results = apexResponse;
                    roles[undefined] = { Name: "Root", _children: [] };
                    apexResponse.forEach(function(v) {
                        expandedRows.push(v.Id);
                        roles[v.Id] = { 
                            Name: v.Name ,
                            name: v.Id,
                            _children: [] };
                    });
                    apexResponse.forEach(function(v) {
                        roles[v.ParentObject__c]._children.push(roles[v.Id]);   
                    });                
                    component.set("v.gridData", roles[undefined]._children);
                    console.log('*******treegrid data:'+JSON.stringify(roles[undefined]._children));
                    
                    component.set('v.gridExpandedRows', expandedRows);
                }, 
                {
                    recId: component.get('v.ltngcurrentRecId')
                }
            );    
        }
        
        
        
        
    }
})