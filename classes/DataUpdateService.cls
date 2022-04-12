@RestResource(urlMapping='/DataUpdateService/*')

global  class DataUpdateService {
    

    @HttpPatch
    global static  finalResponse updatePARRecord() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response; 
        finalResponse objResponseWrapper = new finalResponse();
        
        try{ 
           
            String conversionRefID = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
           
            
            Apttus_Config2__ProductAttributeRule__c recordToUpdate = [SELECT Id, Name FROM Apttus_Config2__ProductAttributeRule__c WHERE Conversion_Ref_ID__c = :conversionRefID];
            
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
            
            for(String fieldName : params.keySet()) {
                
                recordToUpdate.put(fieldName, params.get(fieldName));
            }
            update recordToUpdate;
            objResponseWrapper.ParID=recordToUpdate.Id;
        }
        
       
        catch(Exception ex){
            objResponseWrapper.attributes = new ResponseAttribute(400, 'Not able to process Request. ' + ex.getmessage());
        }
        
        return objResponseWrapper;
    }
    
    global class finalResponse{
        public ResponseAttribute attributes = new ResponseAttribute(200, 'OK ');
        public string parid;
        
       
        public finalResponse() {}
    }
    
    global class ResponseAttribute{
        public Integer returnCode;
        public String message;
        public ResponseAttribute(Integer returnCode, String message) {
            this.returnCode = returnCode;
            this.message = message;
        }
    }
    
    
    
    
}