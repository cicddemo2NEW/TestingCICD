public class RecordImportController {
    
    @AuraEnabled
    public static String ImportAllRecords (String serviceURL,String objectName, String filterField, String dynamicFields)
    {
        
        Map<String, List<String>> dynamicIds = new Map<String, List<String>>();//Map<dynamic_fied_name, Id_values_from_source
        Map<String, String> dynamicFieldMap = new Map<String,String>();//Map<dynamic_field_api_name,objectName>
        Map<String, String> IdExternalIdMap = new Map<String,String>();// Map<OldSystemId, OldSystemExternalId> 
        Map<String, String> ExternalIdAndInternalIdMap = new Map<String,String>(); //Map<CurrentSystemExternalId, CurrentSystemId>
        Map<String, String> IdIdMap = new Map<String,String>(); // Map<OldSystemId, CurrentSystemId>
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldNameMap = objType.getDescribe().fields.getMap();        		       
        
        List<SObject> recList = (List<SObject>)getRecord(serviceURL);        
        
        if(dynamicFields != null){      
            String[] df = dynamicFields.split(',');
            for(String s: df){
                String[] obj_fld = s.split('\\.');
                dynamicFieldMap.put(obj_fld[1],obj_fld[0]);
            }
        }        
        
        for(SObject obj: recList){
            obj.put('Id', null);
            for(String s : dynamicFieldMap.keySet()){                
                String parentIds = (String)obj.get(s);
                if(parentIds != null){
                    
                    List<String> sfIds;
                    if(parentIds.startsWith('[') && parentIds.endsWith(']')){
                        parentIds =parentIds.replaceAll('\"', '');
                        parentIds =parentIds.replaceAll('\\[', '');
                        parentIds =parentIds.replaceAll('\\]', '');
                        
                        sfIds = parentIds.trim().split(','); 
                        
                    }else if(!parentIds.equals('All') ){                                        
                        sfIds = parentIds.split(';');                    
                    }
                    if(dynamicIds.get(s) != null){
                        List<String> temp = dynamicIds.get(s);
                        temp.addAll(sfIds);
                        dynamicIds.put(s,temp);                        
                    }else{
                        dynamicIds.put(s,sfIds);    
                    }
                }
            }
        }
        
        if(dynamicIds.size() > 0){
            for(String fname: dynamicIds.keySet()){
                String objName = dynamicFieldMap.get(fname);
                List<String> Ids = dynamicIds.get(fname);
                Set<String> tempSet = new Set<String>();
                tempSet.addAll(Ids);
                String IdString = quoteKeySet(tempSet);
                
                /* The below code can be put inside a method. START */
                String subURL = '/services/data/v54.0/query?q=Select Id, '+filterField+' from '+objName+' WHERE Id IN '+IdString;                
                system.debug('---dynamic Id query: '+subURL);
                subURL =subURL.replaceAll('\\s+', '+');
                List<SObject> parentList = (List<SObject>)getRecord(subURL);
                for(SObject obj: parentList){
                    IdExternalIdMap.put((String)obj.get('Id'), (String)obj.get(filterField));
                }
                system.debug('---IdExternalIdMap: '+IdExternalIdMap);
                String objN = dynamicFieldMap.get(fname);
                List<String> extIdFilter = IdExternalIdMap.values();
                String qstr = 'SELECT Id, '+filterField+' FROM '+objN+' where '+filterField+' IN: extIdFilter';                
                List<SObject> ol = Database.query(qstr);
                
                for(SObject objx: ol){
                    String a = (String)objx.get('Id');
                    String b = (String)objx.get(filterField);
                    ExternalIdAndInternalIdMap.put(b,a);
                }
                for(String oid: IdExternalIdMap.keySet()){
                    IdIdMap.put(oid,ExternalIdAndInternalIdMap.get(IdExternalIdMap.get(oid)));    
                }
                system.debug('---IdIdMap: '+IdIdMap);
                /* The below code can be put inside a method. END */
            }
            
            for(SObject obj: recList){
                for(String s : dynamicFieldMap.keySet()){                
                    String parentIds = (String)obj.get(s);
                    
                    if(parentIds != null){
                        String newStr = '';
                        List<String> sfIds;
                        if(parentIds.startsWith('[') && parentIds.endsWith(']')){
                            parentIds =parentIds.replaceAll('\"', '');
                            parentIds =parentIds.replaceAll('\\[', '');
                            parentIds =parentIds.replaceAll('\\]', '');
                            
                            sfIds = parentIds.trim().split(',');                             
                            
                            for(String sid: sfIds){
                                sid = sid.trim();
                                
                                if(IdIdMap.get(sid) != null){
                                    newStr = newStr +'\"'+IdIdMap.get(sid.trim())+'\",';  
                                }else{
                                    //perhaps thow error of associated Product Scope or, Product Group Scope not found.
                                    String message = 'Corresponding '+dynamicFieldMap.get(s)+' not found in this org. for source '+s+' Id '+sid;
                                    throw new AuraHandledException(message);
                                }                                
                            }
                            system.debug('--last character: '+newStr.substring(newStr.length()-1));
                            if(newStr.substring(newStr.length()-1).equals(','))
                                newStr.removeEnd(',');
								newStr = newStr.substring(0,newStr.length()-1);                            
                            
                            newStr = '['+newStr+']';
                            system.debug('---newStr: '+newStr);
                            
                        }else if(!parentIds.equals('All') ){
                            sfIds = parentIds.split(';');                                                    
                            for(String sid: sfIds){
                                if(IdIdMap.get(sid) != null){
                                    newStr = newStr + IdIdMap.get(sid)+';';  
                                }else{
                                    //perhaps thow error of associated Product Scope or, Product Group Scope not found.
                                    String message = 'Corresponding '+dynamicFieldMap.get(s)+' not found in this org. for source '+s+' Id '+sid;
                                    throw new AuraHandledException(message);
                                }                                
                            }
                        }
                        obj.put(s,newStr);
                    }
                }
            }			
        }
        
        try{                    
            
            List<Database.upsertResult> results = Database.upsert(recList, fieldNameMap.get(filterField), true);
            
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
    public static ImportRecordDetail getConsolidatedRecordInformation(String serviceURL){                
        List<SObject> recList = (List<SObject>)getRecord(serviceURL);
        Map<String,Boolean> parentDetailsMap = new Map<String,Boolean>();
        
        ImportRecordDetail ird = new ImportRecordDetail();
        ird.parents = parentDetailsMap;
        ird.records = recList;		 
        return ird;        
    }
    
    public class ImportRecordDetail{
        @AuraEnabled public Map<String,Boolean> parents;
        @AuraEnabled public List<Sobject> records;
    }
    
    @AuraEnabled
    public static List<Sobject> getRecord (String serviceURL)
    {
        //Logger.processStart('GetRecords');        
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DataComposerCPQDev1/'+serviceURL);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        
        Http h = new Http();
        HttpResponse res;
        
        Long start = Datetime.now().getTime();
        
        try {
            //Logger.calloutStart(req);
            res = h.send(req);
            system.debug('---Body:'+res.getBody());
        } catch(Exception e) {
            //Logger.calloutSetError(e);
        } finally {
            //Logger.calloutEnd(res);
        }
        
        string response = res.getBody(); 
        
        system.debug('--errorCode: '+res.getStatusCode());
        if(res.getStatusCode() ==  404){
            return null;
        }else{            
            
            QueryResponseJSON qr = (QueryResponseJSON)JSON.deserialize(res.getBody(),QueryResponseJSON.class);    
            
            //Logger.processEnd();
            //Logger.commitLogs();
            
            return qr.records;
        }
    }
    private static String quoteKeySet(Set<String> mapKeySet)
    {
        String newSetStr = '' ;
        for(String str : mapKeySet)
            newSetStr += '\'' + str.trim() + '\',';
        
        newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0,newSetStr.lastIndexOf(',')) + ')' : newSetStr ;
        return newSetStr;
        
    }
    
    
    @AuraEnabled
    public static boolean checkPermission(){
        Enable_Record_Import__c obj = Enable_Record_Import__c.getInstance();
        return  obj.Import_Allowed__c;
    }    
    
    
    @AuraEnabled
    public static Map<string,Object> getRecordParent (String serviceURL)
    {
        Map<string,Object> objMap = new Map<string,Object>();
        Logger.processStart('GetRecords');
        
        System.debug('---url: '+serviceURL);
        
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
        
        system.debug('body response '+response);
        system.debug('--errorCode: '+res.getStatusCode());
        if(res.getStatusCode() ==  404){
            return objMap;
        }else{
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            for(String fieldName : params.keySet()) {
                
                System.debug('key-- '+ fieldName +' value---- ' + params.get(fieldName));
                
                if (params.get(fieldName)!='attributes')
                {  
                    objMap.put(fieldName,params.get(fieldName));
                }
            }
            objmap.remove('attributes');
            
            Logger.processEnd();
            Logger.commitLogs();
            
            return objMap;
        }
    }
    
    
}