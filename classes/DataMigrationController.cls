public class DataMigrationController {
    /*@AuraEnabled
public static List getDataMigrationStages(String stageName , String recordId){
Opportunity opp = [Select Id ,StageName from Opportunity where Id=:recordId] ; 
opp.StageName =stageName ; 
update opp ;

}*/
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
        system.debug('---translationMap: '+translationMap);
        return translationMap;
    }
    @AuraEnabled 
    public static Blob createCSVContent(Id configurationRecordId,List<string> selectedRecordIds){//   List<String> fieldAPIList,SObject[] lstRecords){
        system.debug('selectedRecordIds-->'+selectedRecordIds);
         String csvStringContent;                
        try{  
            Data_Migration_Details__c dataMigrationRecord = [select id,Name,Object_API_Name__c,Fields_to_export__c from Data_Migration_Details__c where Id = :configurationRecordId ];
            if(dataMigrationRecord!=null){
                string fieldslist = 'NAME,PRODUCTCODE,DESCRIPTION,ISACTIVE,FAMILY,EXTERNALDATASOURCEID,EXTERNALID,DISPLAYURL,QUANTITYUNITOFMEASURE,STOCKKEEPINGUNIT,APTTUS_CONFIG2__BUNDLEINVOICELEVEL__C,APTTUS_CONFIG2__CONFIGURATIONTYPE__C,APTTUS_CONFIG2__CUSTOMIZABLE__C,APTTUS_CONFIG2__DISCONTINUEDDATE__C,APTTUS_CONFIG2__EFFECTIVEDATE__C,APTTUS_CONFIG2__EFFECTIVESTARTDATE__C,APTTUS_CONFIG2__EXCLUDEFROMSITEMAP__C,APTTUS_CONFIG2__EXPIRATIONDATE__C,APTTUS_CONFIG2__HASATTRIBUTES__C,APTTUS_CONFIG2__HASDEFAULTS__C,APTTUS_CONFIG2__HASOPTIONS__C,APTTUS_CONFIG2__HASSEARCHATTRIBUTES__C,APTTUS_CONFIG2__ICONID__C,APTTUS_CONFIG2__ICONSIZE__C,APTTUS_CONFIG2__LAUNCHDATE__C,APTTUS_CONFIG2__PRODUCTTYPE__C,APTTUS_CONFIG2__SHOWTABVIEW__C,APTTUS_CONFIG2__UOM__C,APTTUS_CONFIG2__VERSION__C,CONVERSION_REF_ID__C';
                string querystring = 'Select '+fieldslist+' from '+dataMigrationRecord.Object_API_Name__c+' where Id IN '+selectedRecordIds;
                system.debug('querystring-->'+querystring);
                List<sObject> lstRecords = Database.query(querystring);
                String csvHeader = fieldslist + '\n';
                csvStringContent = csvHeader;
                List<String> fieldAPINames = fieldslist.split(',');
                Integer recordListSize = lstRecords.size();
                Integer fieldListSize = fieldAPINames.size();
                for(Integer i=0;i<recordListSize;i++){
                    SObject sObj = lstRecords[i];
                    for(Integer j=0;j<fieldListSize;j++){
                        String fieldAPIName = fieldAPINames[j];
                        Object fieldValue = sObj.get(fieldAPIName);
                        if(fieldValue != null){
                            csvStringContent = csvStringContent + String.valueOf(fieldValue).escapeCsv();
                        }else{
                            csvStringContent = csvStringContent + '';  
                        }
                        csvStringContent += + ',';
                    }
                    csvStringContent += '\n';
                }
            }
        }catch(Exception e){
            System.debug(e.getMessage() + e.getLineNumber());
        }
         PageReference pageRef = new PageReference('/apex/GenerateExcelFile');
               return Blob.valueOf(csvStringContent);
    }
    
    
}