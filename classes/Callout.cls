global class Callout {
    
	global static string SYSTEM_APIGATEWAY_ENDPOINT = (String)System__c.getOrgDefaults().AWS_ApiGateway_URL__c;
	global static boolean SET_OVERRIDE_TIMEOUT =  (boolean)System__c.getOrgDefaults().Override_Timeout_Threshold_Flag__c;
    global static final integer SYSTEM_OVERRIDE_TIMEOUT_THRESHOLD = (Integer)System__c.getOrgDefaults().Override_Timeout_Threshold__c;
    global static final boolean SYSTEM_OVERRIDE_TIMEOUT_THRESHOLD_FLAG = (boolean)System__c.getOrgDefaults().Override_Timeout_Threshold_Flag__c;
    
    global static integer SYSTEM_TIMEOUT_THRESHOLD {
        get{
            SYSTEM_TIMEOUT_THRESHOLD = (Integer)System__c.getOrgDefaults().Timeout_Threshold__c;
            
            if(SET_OVERRIDE_TIMEOUT && SYSTEM_OVERRIDE_TIMEOUT_THRESHOLD_FLAG){
              SYSTEM_TIMEOUT_THRESHOLD = SYSTEM_OVERRIDE_TIMEOUT_THRESHOLD;
            }
            if(System.isFuture()){    // Separate Callout for Async Calls
              SYSTEM_TIMEOUT_THRESHOLD = (Integer)System__c.getOrgDefaults().Async_Timeout_Threshold__c;
            }
    
            return SYSTEM_TIMEOUT_THRESHOLD;
      }set;}
	
    global static HttpResponse doGet(String url){
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(SYSTEM_APIGATEWAY_ENDPOINT + url);

        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        system.debug('---system time-out threshold is: '+SYSTEM_TIMEOUT_THRESHOLD);
        req.setTimeout(SYSTEM_TIMEOUT_THRESHOLD);
        
        Long start = Datetime.now().getTime();
        HttpResponse res;
        
        try {
            Logger.calloutStart(req);
            res = h.send(req);
        } catch(Exception e) {
            Logger.calloutSetError(e);
        } finally {
            Logger.calloutEnd(res);
        }
        
        // Send the request, and return a response
        return res;
    }
}