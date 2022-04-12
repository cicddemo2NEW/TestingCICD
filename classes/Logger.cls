global class Logger {
    global static Callout_Logs__c log;
    global static list<Callout_Logs__c> logs;

    // First method called when a logging is requested
    global static void processStart(string process) {
        log = new Callout_Logs__c(
                            Process__c = process,
                            Process_Start__c = Datetime.now().getTime());
        system.debug('---Logging started: '+log);
    }

    // Called whenever a callout starts
    global static void calloutStart(HttpRequest req){
        if(log == null) return;
        log.Callout_URL__c         = req.getEndpoint(); 
        log.Callout_Start__c       = Datetime.now().getTime();
        log.Request_Body__c        = req.getBody();
        log.HeaderRequestedId__c	= req.getHeader('requestedId'); 
        system.debug('---Callout started: '+log);
    }

    // Called whenever a callout ends, here the response object can be empty
    global static void calloutEnd(HttpResponse res){
        system.debug('---Logging ending: '+log);
        if(log == null) return;
        log.Callout_End__c         = Datetime.now().getTime();
        log.Callout_Time_ms__c     = (log.Callout_End__c - log.Callout_Start__c);

        if(res != null){
            if(string.isNotEmpty(res.getBody()))
                log.Response_Body__c    = res.getBody().left(Schema.sObjectType.Callout_Logs__c.fields.Response_Body__c.getLength());
                
            log.Callout_Statuscode__c   = res.getStatusCode();
            
        } else {
            log.Callout_Statuscode__c   = 500;
        }
    }

    global static void calloutSetError(Exception e){
        if(log == null) return;
        log.Callout_Error__c = e.getMessage() + '\n' + e.getStackTraceString();
    }

    // method called when a logging is to end
    global static void processEnd() {
        system.debug('---Logging ended: '+log);
        if(log == null) return;
        log.Process_End__c = Datetime.now().getTime();

        // Calculate pre-processing and post-processing times
        log.Process_Time_ms__c          = (log.Process_End__c - log.Process_Start__c);
        // If there are no callouts
        if(log.Callout_Start__c != null)
            log.Pre_Processing_Time_ms__c   = (log.Callout_Start__c - log.Process_Start__c);

        // If there are no callouts
        if(log.Callout_End__c != null)
            log.Post_Processing_Time_ms__c  = (log.Process_End__c - log.Callout_End__c);

        if(logs == null) logs = new list<Callout_Logs__c>();
        logs.add(log);
    }

    global static void commitLogs(){
        system.debug('---inserting Log');
        if(logs == null || logs.size() == 0) return;
        try {
            insert logs;
            
        } catch(Exception e) {
            system.debug('----exception: '+e.getStackTraceString());
        }
    }
	
}