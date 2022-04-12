public class DataComposerController {
    
    @AuraEnabled(cacheable=true) 
    public static Map<String, String> getObjectName_API(){
        Map<String, String> options = new Map<String, String>();
        List<Data_Migration_Details__c> dataMigrationList = new List<Data_Migration_Details__c>();
        dataMigrationList = [select id,Name,Object_API_Name__c from Data_Migration_Details__c order by 	Sequence__c ASC NULLS LAST];
        for (Data_Migration_Details__c DMD: dataMigrationList) {
            options.put(DMD.Name, DMD.Object_API_Name__c);
            //options.put(DMD.Object_API_Name__c,DMD.Name);
        }
        return options;
    }
    @AuraEnabled(cacheable=true) 
    public static List<Data_Migration_Details__c> getRelatedObjectsName(string parentObjectName){
        List<Data_Migration_Details__c> dataMigrationList = new List<Data_Migration_Details__c>();
        dataMigrationList = [select id,Name,Object_API_Name__c,ParentObject__r.Object_API_Name__c from Data_Migration_Details__c where ParentObject__r.Name = :parentObjectName  ];// To do: Have to populated API name        
        for(Data_Migration_Details__c dmt: dataMigrationList){
            Map<String, String> abc = getParentRelationshipName(dmt.Object_API_Name__c, dmt.ParentObject__r.Object_API_Name__c);
            for(String key: abc.keySet()){
                dmt.Parent_relationship_field__c = key;
                dmt.Parent_relationship_name__c = abc.get(key);   
            }
        }        
        return dataMigrationList;
    }
    public static Map<String,String> getParentRelationshipName(String objectName, String parentObjectName){
        
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        for (SObjectField f : t.getDescribe().fields.getMap().values()) {
            if (f.getDescribe().getType() == DisplayType.Reference) {
                List<Schema.sObjectType> parentLookupList =  f.getDescribe().getReferenceTo();
                String parentLookup = String.valueOf(parentLookupList.get(0));
                if(parentLookup.equalsIgnoreCase(parentObjectName)){
                    Map<String,String> lookupDetails = new Map<String,String>();
                    String rname = f.getDescribe().getRelationshipName();                     
                    String lookupField = f.getDescribe().getName();
                    lookupDetails.put(lookupField,rname);
                    return lookupDetails;
                }   
            }                
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true) 
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
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getFieldLabels(String objName, List<String> fieldList) { //it returns translated labels in users local language
        
        system.debug('---objectName: '+objName);
        system.debug('---fieldList: '+fieldList);
        
        Map<String, String> translationMap = new Map<String, String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
        
        Map<String, Schema.SObjectField> fieldNameMap = objType.getDescribe().fields.getMap();
        
        for(String fieldAPIName: fieldList) {
            
            fieldAPIName = fieldAPIName.trim(); //remove leading or trailing white space characters.
            
            system.debug('--field APIName: '+fieldAPIName);
            if(fieldNameMap.get(fieldAPIName.toLowerCase()) != null){
                translationMap.put(fieldAPIName, fieldNameMap.get(fieldAPIName.toLowerCase()).getDescribe().getLabel());    
            }else if(fieldAPIName.split(' ').size() == 1){ //check there are no spaces in the given field name(coming from metadata records).
                String[] obj_fld = fieldAPIName.split('\\.');
                if(obj_fld[0].endsWith('__r'))
                    obj_fld[0] = obj_fld[0].replace('__r','__c');
                string RelationName = fieldNameMap.get(obj_fld[0]).getDescribe().getLabel();
                translationMap.put(fieldAPIName, RelationName);
            }    
        }
        
        return translationMap;
    }
    @AuraEnabled
    public static List<SObject> getChildRecords(string fieldsToExport, String filterName, String filterValues, 
                                                String objectName, String parentObjectName){
                                                    
                                                    String Query='SELECT '+fieldsToExport+' FROM '+objectName;
                                                    List<String> filterValuesList;
                                                    
                                                    
                                                    if(filterValues != null)
                                                        filterValuesList = filterValues.trim().split(',');
                                                    
                                                    if(objectName != NULL && objectName.equalsIgnoreCase(parentObjectName) && filterValuesList != null){
                                                        Query = Query +' where '+filterName+' IN :filterValuesList Order by CreatedDate DESC';
                                                        system.debug('---Query: '+Query);
                                                        system.debug('---filterValuesList: '+filterValuesList);
                                                        
                                                    }else if(objectName != NULL && !objectName.equalsIgnoreCase(parentObjectName) && filterValuesList != null){
                                                        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
                                                        for (SObjectField f : t.getDescribe().fields.getMap().values()) {
                                                            if (f.getDescribe().getType() == DisplayType.Reference) {
                                                                List<Schema.sObjectType> parentLookupList =  f.getDescribe().getReferenceTo();
                                                                String parentLookup = String.valueOf(parentLookupList.get(0));
                                                                if(parentLookup.equalsIgnoreCase(parentObjectName)){
                                                                    
                                                                    String rname = f.getDescribe().getRelationshipName();
                                                                    Query = Query +' where '+rname+'.'+filterName+' IN :filterValuesList Order by CreatedDate DESC';    
                                                                }   
                                                            }                
                                                        }
                                                        system.debug('---Query: '+Query);
                                                    }else{
                                                        
                                                        Query = Query +' Order by CreatedDate DESC LIMIT 500 ';
                                                    }
                                                    List<SObject> recordList;
                                                  
                                                        recordList = database.query(Query);
                                                    
                                                   

                                                    return recordList;
                                                    
                                                }
    @AuraEnabled(cacheable=true)
    public static list<string> getChildObjects(string selObject){
        list<string> relatedObject =  new list<String>();
        
        set<string> allowedObjForMigration =  new set<string>{
            'Product2',
                'Apttus_Config2__PriceList__c',
                'Apttus_Config2__PriceListItem__c',
                'Apttus_Config2__ClassificationName__c',
                'Apttus_Config2__ClassificationHierarchy__c',
                'Apttus_Config2__ProductClassification__c',
                'Apttus_Config2__PriceListCategory__c',
                'Apttus_Config2__ProductGroup__c',
                'Apttus_Config2__ProductGroupMember__c',
                'Apttus_Config2__RelatedPriceListItem__c',
                'Apttus_Config2__FieldExpression__c',
                'Apttus_Config2__ConstraintRule__c',
                'Apttus_Config2__ConstraintRuleAction__c',
                'Apttus_Config2__ConstraintRuleCondition__c',
                'Apttus_Config2__AttributeValueMatrix__c',
                'Apttus_Config2__AttributeValueMatrixEntry__c',
                'Apttus_Config2__ProductAttributeGroup__c',
                'Apttus_Config2__ProductAttribute__c',
                'Apttus_Config2__ProductAttributeGroupMember__c',
                'Apttus_Config2__PriceDimension__c',
                'Apttus_Config2__PriceRuleset__c',
                'Apttus_Config2__PriceRule__c',
                'Apttus_Config2__PriceRuleEntry__c',
                'Apttus_Config2__PriceMatrix__c',
                'Apttus_Config2__PriceMatrixEntry__c',
                'Apttus_Config2__ProductAttributeRule__c',
                'Apttus_Config2__ProductAttributeRuleAction__c',
                'Apttus_Config2__SearchFilter__c', 
                'Apttus_Config2__ConfigFlow__c',
                'Apttus_Config2__ConfigCustomDisplayColumns__c',
                'Apttus_Config2__ConfigCustomDisplayActions__c',
                'Apttus_Config2__ConfigSystemProperties__c',
                'Apttus_Approval__FormulaField__c',
                'Apttus_Approval__SearchFilter__c',
                'Apttus_Approval__ApprovalRule__c',
                'Apttus_Approval__ApprovalRuleEntry__c',
                'Apttus_Approval__ApprovalRuleAssignee__c',
                'Apttus_Config2__FormulaField__c'
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
    @AuraEnabled(cacheable=true)
    public static Data_Migration_Details__c getMigrationObjectMetadata(String crrentObject){
        
        system.debug('---crrentObject: '+crrentObject);
        Data_Migration_Details__c dataMigDelList = [select Id, ParentObject__c, Parent_relationship_field__c,
                                                    Parent_relationship_name__c, Fields_to_display__c, Fields_to_export__c, 
                                                    Dynamic_Fields__c from  Data_Migration_Details__c 
                                                    where Object_API_Name__c =: crrentObject];
        system.debug('---dataMigDelList: '+dataMigDelList);
        string fieldTodisplay = dataMigDelList.Fields_to_display__c;
        return dataMigDelList;
    }
    
    @InvocableMethod()
    public static List <Result> execute (List<Request> requestList) {
        Result response = new Result();
        List<Result> responseWrapper= new List<Result>();
        response = new DataComposerController().processRequest(requestList[0]);
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