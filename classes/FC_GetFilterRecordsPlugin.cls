public class FC_GetFilterRecordsPlugin {
    
    @AuraEnabled 
    public static Map<String, String> getObjectName_API(){
        Map<String, String> options = new Map<String, String>();
        List<Data_Migration_Details__c> dataMigrationList = new List<Data_Migration_Details__c>();
        dataMigrationList = [select id,Name,Object_API_Name__c from Data_Migration_Details__c ];
        for (Data_Migration_Details__c DMD: dataMigrationList) {
            options.put(DMD.Name, DMD.Object_API_Name__c);
            //options.put(DMD.Object_API_Name__c,DMD.Name);
        }
        return options;
    }
    @AuraEnabled 
    public static List<string> getRelatedObjectsName(string parentObjectName){
        List<string> ObjectName = new List<string>();
        List<Data_Migration_Details__c> dataMigrationList = new List<Data_Migration_Details__c>();
        dataMigrationList = [select id,Name,Object_API_Name__c from Data_Migration_Details__c where ParentObject__r.Name = :parentObjectName  ];// To do: Have to populated API name
        for (Data_Migration_Details__c DMD: dataMigrationList) {
            ObjectName.add(DMD.Name);
        }
        return ObjectName;
    }
    
    @AuraEnabled 
    public static Map<String, String> getFilterFields(string parentObjectAPIName){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(parentObjectAPIName);
        Map<String, Schema.SObjectField> M = targetType.getDescribe().fields.getMap();
        List<String> externalIdFields = new List<String>();
        Map<String, String> translationMap = new Map<String, String>{'Id' => 'Id'};
        
        for (String fieldAPIName : M.keySet()) {
            if(M.get(fieldAPIName).getDescribe().isExternalID()) {
                externalIdFields.add(fieldAPIName);
                translationMap.put(fieldAPIName, M.get(fieldAPIName.toLowerCase()).getDescribe().getLabel());
            }
        }
        return translationMap;
    }

    @AuraEnabled
    public static Map<String, String> getFieldLabels(String objName, List<String> fieldList) { //it returns translated labels in users local language
        
        Map<String, String> translationMap = new Map<String, String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
        
        Map<String, Schema.SObjectField> fieldNameMap = objType.getDescribe().fields.getMap();
        
        for(String fieldAPIName: fieldList) {
            
            if(fieldNameMap.get(fieldAPIName.toLowerCase()) != null){
                translationMap.put(fieldAPIName, fieldNameMap.get(fieldAPIName.toLowerCase()).getDescribe().getLabel());    
            }else{
                String[] obj_fld = fieldAPIName.split('\\.');
                if(obj_fld[0].endsWith('__r'))
                obj_fld[0] = obj_fld[0].replace('__r','__c');
                string RelationName = fieldNameMap.get(obj_fld[0]).getDescribe().getLabel();
                
                /*
                Schema.SObjectType targetType = Schema.getGlobalDescribe().get(RelationName);
                String lbl = targetType.getDescribe().fields.getMap().get(obj_fld[1]).getDescribe().getLabel();
                translationMap.put(fieldAPIName, lbl);
				*/
                translationMap.put(fieldAPIName, RelationName);
            }    
        }
        
        return translationMap;
    }
    @AuraEnabled
    public static List<SObject> getChildRecords(string fieldsToExport, String RelationshipField, String RelationshipName, 
                                               			String filterName, String filterValues, String objectName, 
                                               			String parentObjectName){
        String Query=fieldsToExport;
		List<String> filterValuesList = filterValues.trim().split(',');
                                                            
        if(RelationshipName != null && !objectName.equalsIgnoreCase(parentObjectName)){
            Query = Query +' where '+RelationshipName+'.'+filterName+' IN :filterValuesList';
            system.debug('---Query: '+Query);
            /*
        	SObjectField parentField;            
            Schema.SObjectType childSobjtType = Schema.getGlobalDescribe().get(objectName);
            Schema.SObjectType parentSobjtType = Schema.getGlobalDescribe().get(parentObjectName);
            for(ChildRelationship rel: parentSobjtType.getDescribe().getChildRelationships()) {
                if(rel.getChildSObject() == childSobjtType) {
                    parentField = rel.getField();
                    system.debug('----parentFied: '+parentField);
                    break;
                }
            }*/
        }else{
            Query = Query +' where '+filterName+' IN :filterValuesList';
            system.debug('---Query: '+Query);
            
        }
        List<SObject> recordList;
        recordList = database.query(Query);
        return recordList;
    }
    @AuraEnabled
    public static list<string> getChildObjects(string selObject){
        list<string> relatedObject =  new list<String>();
        
        set<string> allowedObjForMigration =  new set<string>{
               	'Product2',
                'Apttus_Config2__ClassificationHierarchy__c',
                'Apttus_Config2__ProductOptionGroup__c',
                'Apttus_Config2__ProductOptionComponent__c',
                'Apttus_Config2__PriceListItem__c',
                'Apttus_Config2__ProductClassification__c',
                'Apttus_Config2__ProductGroup__c',
                'Apttus_Config2__ProductGroupMember__c',
                'Apttus_Config2__FieldExpression__c',
                'Apttus_Config2__ProductAttributeGroup__c',
                'Apttus_Config2__ProductAttribute__c',
                'Apttus_Config2__ProductAttributeGroupMember__c',
                'Apttus_Config2__PriceMatrix__c',
                'Apttus_Config2__PriceMatrixEntry__c',
                'Apttus_Config2__ProductAttributeRule__c',
                'Apttus_Config2__ProductAttributeRuleAction__c',
                'Delivery_Mapping__c',
                'PortalProduct__c'
                };      
                    
        Schema.SObjectType gd = Schema.getGlobalDescribe().get(selObject);
        Schema.DescribeSobjectResult a11=gd.getDescribe();
        for (Schema.ChildRelationship cr: a11.getChildRelationships()) 
        {
            Schema.SObjectType str = Cr.getChildSObject();   
            if(allowedObjForMigration.contains(str.getDescribe().getName())){
                 relatedObject.add(str.getDescribe().getName());
            }         
        }
        return relatedObject;        
    }
    @AuraEnabled
    public static Data_Migration_Details__c getMigrationObjectMetadata(String crrentObject){
        
        Data_Migration_Details__c dataMigDelList = [select Id, ParentObject__c, Parent_relationship_field__c,
                                                    Parent_relationship_name__c, Fields_to_display__c, Fields_to_export__c 
                                                    from  Data_Migration_Details__c 
                                                    where Object_API_Name__c =: crrentObject];
        system.debug('---dataMigDelList: '+dataMigDelList);
        string fieldTodisplay = dataMigDelList.Fields_to_display__c;
        return dataMigDelList;
    }
    
    @InvocableMethod()
    public static List <Result> execute (List<Request> requestList) {
        Result response = new Result();
        List<Result> responseWrapper= new List<Result>();
        response = new FC_GetFilterRecordsPlugin().processRequest(requestList[0]);
        responseWrapper.add(response);
        return responseWrapper;
    }
    private Result processRequest(Request plugInRequest){
        Result response = new Result();
        List<SObject> recordList;
        try{            
            
            List<String> crefIds = plugInRequest.queryFilterValues.trim().split(',');
            recordList = database.query(plugInRequest.queryString +' :crefIds');
            response.records = recordList;
        }catch(Exception ex){
            response.records = null;
            response.message = ex.getMessage() + ex.getStackTraceString();
            response.errorCode = 'dml_error';
        }
        return response;
    }
   
    public class Request {        
        @InvocableVariable(label='queryString' description='query' required=true)
        public string queryString = '';
        @InvocableVariable(label='queryFilterValues' description='queryfilter' required=true)
        public string queryFilterValues = '';
    }
    public class Result{
        @InvocableVariable(label='record List' description='Queue name from pie' required=true)
        public List<Sobject> records;
        @InvocableVariable(label='error code' description='error code' required=true)
        public string errorCode = '';
        @InvocableVariable(label='Message' description='error code' required=true)
        public string Message = '';
    }

}