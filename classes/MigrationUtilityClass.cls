public class MigrationUtilityClass {
    
    public MigrationUtilityClass(){
        
        
    }
  
    /* Method to get child record dynamically for migration */
    @AuraEnabled
    public static list<string> getChildObjectsDynamicallyForMigration(string selObject, string conRefId, String filterField){
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
                    
                    for(string str : allowedObjForMigration ){
                        system.debug('allowed:' + str);
                    }      
                    
        Schema.SObjectType gd = Schema.getGlobalDescribe().get(selObject);
        Schema.DescribeSobjectResult a11=gd.getDescribe();
        for (Schema.ChildRelationship cr: a11.getChildRelationships()) 
        {
            //system.debug('Child Object Name:'+cr.getChildSObject());
            Schema.SObjectType str = Cr.getChildSObject();
            
            if(allowedObjForMigration.contains(str.getDescribe().getName())){
                 relatedObject.add(str.getDescribe().getName());
            }
         
        }
        
        system.debug('relatedObject:' +  relatedObject );
        system.debug('relatedObject size:' +  relatedObject.size() );
        
         for(string str : relatedObject ){
                        system.debug('After loop:' + str);
          } 

        return relatedObject;
        
    }
    
   /* public static void getRelatedRecords( List<string> selObject, string conRefId){
        //createing a map to store fieldtoDisplay corresponing to Sobject 
        Map<string,Data_Migration_Details__c > MapDataMigDel = new Map<string,Data_Migration_Details__c>(); 
        list<Data_Migration_Details__c> dataMigDelList = [select id ,  Object_API_Name__c, Child_relationship_field__c, Fields_to_display__c, Fields_to_export__c from  Data_Migration_Details__c ];
            for( Data_Migration_Details__c d :  dataMigDelList){
               MapDataMigDel.put(d.Object_API_Name__c, d); 
            }
        string query ;
        list<string> queryList = new list<string>();
        
        Generating a query string to fire a query dynamically 
        for(string rel : relatedObject){
            if(MapDataMigDel.containsKey(rel)){
                string fieldTodisplay = MapDataMigDel.get(rel).Fields_to_display__c;
                string ObjectAPIName =  MapDataMigDel.get(rel).Object_API_Name__c;
                 //query='select ' + fieldTodisplay +' '+ 'from ' +ObjectAPIName '+ 'where selObject.Conversion_Ref_ID__c = '+conRefId ;
                query ='select  id , Name ' + ' '+ 'from ' +ObjectAPIName ;
				system.debug('Generated query:' + query  );
                //queryList.add(query);
                //list<sObject> objList = database.query(query);
                
            }
        }
        
    } */
    
  
  
    
}