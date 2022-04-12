public class getFieldListController {
    
    @AuraEnabled(cacheable=true) 
    public static Map<String, String> getFieldsList(String sObjName){
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjName);
        Map<String, Schema.SObjectField> fieldsNameMap = objType.getDescribe().fields.getMap();
        //Map<String, String> fieldsMap = new Map<String, String>{'Id' => 'Id'};
        Map<String, String> fieldsMap = new Map<String, String>();
        for (String fieldAPIName : fieldsNameMap.keySet()) {
                    fieldsMap.put(fieldAPIName, fieldsNameMap.get(fieldAPIName.toLowerCase()).getDescribe().getLabel());
        }
        system.debug('fieldsMap: '+fieldsMap);
        return fieldsMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getdefinedFieldsList(String sObjName){
        
        Data_Migration_Details__c dataMigrationObject = [select Id, Fields_to_display__c, Fields_to_export__c,Fields_for_Mapping__c
                                                    	from  Data_Migration_Details__c 
                                                    	where Object_API_Name__c =: sObjName];
        string fieldTodisplay = dataMigrationObject.Fields_to_export__c;        
        string fieldToPass = fieldTodisplay.toLowerCase();
        List<String> definedFieldsList = fieldToPass.split(',');
        system.debug('---definedFieldsList: '+definedFieldsList);
        return definedFieldsList;
    }
    
    /*@AuraEnabled(cacheable=true)
    public static requestCheckedFields(List<String> checkedFields){
        
        Data_Migration_Details__c dataMigrationObject = [select Id, Fields_to_display__c, Fields_to_export__c 
                                                    	from  Data_Migration_Details__c 
                                                    	where Object_API_Name__c =: sObjName];
        string fieldTodisplay = dataMigrationObject.Fields_to_display__c;
        string fieldToPass = fieldTodisplay.toLowerCase();
        List<String> definedFieldsList = fieldToPass.split(',');
        system.debug('---definedFieldsList: '+definedFieldsList);
        return definedFieldsList;
    }*/

}