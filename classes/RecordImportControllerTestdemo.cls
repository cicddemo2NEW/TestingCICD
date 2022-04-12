public class RecordImportControllerTestdemo {
    
    @AuraEnabled
    public static String ImportAllRecords (String serviceURL,String objectName, String filterField)
    {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldNameMap = objType.getDescribe().fields.getMap();
        
        List<SObject> recList = (List<SObject>)getRecord(serviceURL);
        
        for(SObject obj: recList){
            obj.put('Id', null);   
        }
        
        try{
            
            List<Database.upsertResult> results = Database.upsert(recList, fieldNameMap.get('Conversion_Ref_ID__c'), true);
            
            system.debug('--upsert size: '+results.size());
            for (Database.UpsertResult ur : results) {
                
                // If Some error happens in upsert 
                for(Database.Error err : ur.getErrors()) {
                    System.debug('---The following error has occurred.');                    
                    System.debug('--'+err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('---SObject fields that affected this error: ' + err.getFields());
                }
            }
        }catch(Exception e){
            System.debug('--Error Message: ' +e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        return 'OK';
    }
    
    @AuraEnabled
    public static List<Sobject> getRecord (String serviceURL)
    {
        Logger.processStart('GetRecords');        
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DataComposerCPQDev1/'+serviceURL);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        
        Http h = new Http();
        HttpResponse res;
        
        Long start = Datetime.now().getTime(); 
        
        try {
            Logger.calloutStart(req);
            res = h.send(req);
            system.debug('---Body:'+res.getBody());
        } catch(Exception e) {
            Logger.calloutSetError(e);
        } finally {
            Logger.calloutEnd(res);
        }
        
        string response = res.getBody(); 
        
        system.debug('--errorCode: '+res.getStatusCode());
        if(res.getStatusCode() ==  404){
            return null;
        }else{            
            
            QueryResponseJSON qr = (QueryResponseJSON)JSON.deserialize(res.getBody(),QueryResponseJSON.class);    
            
            Logger.processEnd();
            Logger.commitLogs();
            
            return qr.records;
        }
    }
    
    @AuraEnabled
    public static List<Sobject> getParentConfRefId (String serviceURL)
    {
         Logger.processStart('GetRecords');        
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DataComposerCPQDev1/'+serviceURL);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        
        Http h = new Http();
        HttpResponse res;
        
        Long start = Datetime.now().getTime();
        
        try {
            Logger.calloutStart(req);
            system.debug('req:'+ req);
            
            res = h.send(req);
            
            system.debug('res:'+ res);
            system.debug('---Body:'+res.getBody());
        } catch(Exception e) {
            Logger.calloutSetError(e);
        } finally {
            Logger.calloutEnd(res);
        }
        
        string response = res.getBody(); 
        
        system.debug('--errorCode: '+res.getStatusCode());
        if(res.getStatusCode() ==  404){
            return null;
        }else{            
            
            QueryResponseJSON qr = (QueryResponseJSON)JSON.deserialize(res.getBody(),QueryResponseJSON.class);    
            
            Logger.processEnd();
            Logger.commitLogs();
            
            return qr.records;
    }
    }
    
     @AuraEnabled
    public static boolean checkPermission(){
        Enable_Record_Import__c obj = Enable_Record_Import__c.getInstance();
        return  obj.Import_Allowed__c;
    }    
    
}