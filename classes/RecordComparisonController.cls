public class RecordComparisonController {
    
    @AuraEnabled
    public static Map<string,Object> getRecord (String serviceURL)
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
    
    @AuraEnabled
    public static string getCurrentInstance()
    {
        String OrgDomainUrl = URL.getOrgDomainUrl().toString(); 
        String[] temp =OrgDomainUrl.split('//');
        String[] temp2 = temp[1].split('.my');
        string finaldomain = temp2[0];
        return finaldomain;
    }
    
    
}