public class TreeGridGenerator {
 /*@AuraEnabled
    public static String getTreeGridData(){
        List<Account> accs = [Select Id , Name,(Select Id , Name from Contacts) from Account limit 10];
        Map<Id , Contact> opps =new Map<Id , Contact>( [Select Id , Name,(Select Id ,Name From Opportunities) from Contact limit 10]);
        
        List<DataWrapper> aooo = new List<DataWrapper>();
        for(sObject a : accs){
            DataWrapper aWraper = new DataWrapper() ; 
            aWraper.name =a.Name ;
            List<Items> co = new List<Items>();
            for(sObject c : a.Contacts){
                Items conWrapp = new Items();
                conWrapp.name =c.Name ;
                
                List<Items> wrapperOooo = new List<Items>();
               /* for(Opportunity o : opps.get(a.Id).Opportunities){
                    Items ooo = new Items(); 
                    ooo.name = o.Name ;
                    ooo.label = o.Name ;
                    wrapperOooo.add(ooo);
                }*/
                
                /*conWrapp.items =wrapperOooo ;
                co.add(conWrapp);
            }
            aWraper.items = co;
            aooo.add(aWraper);
            
        }
        return JSON.serializePretty(aooo) ;
    } 
    public Class DataWrapper{
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }
    public Class Items{
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }*/
    @AuraEnabled
    public static List<Data_Migration_Details__c> findHierarchyData(string recId){
        recId = getId(recId);
        List<Data_Migration_Details__c> accList = new List<Data_Migration_Details__c>();
        string queryString = 'select Id,Name,ParentObject__c from Data_Migration_Details__c '; 
        //Section to get all child account details from ultimate parent starts-------------------------
        List<String> currentParent = new List<String>{};
        Integer level               = 0;
        Boolean endOfStructure      = false;
        //method to find ultimate parent of account
        string topMostparent = GetUltimateParentId(recId );
        system.debug('*******topMostparent:'+topMostparent);
        currentParent.add(topMostparent);
        system.debug('**********topMostparent:'+ currentParent);
        //Loop though all children
        string finalQueryString = '';
        List<Data_Migration_Details__c>  queryOutput = new List<Data_Migration_Details__c> ();
        while ( !endOfStructure ){  
            if( level == 0 ){
                finalQueryString = queryString + ' where Id IN : CurrentParent ORDER BY ParentObject__c  Limit 1000';
            } 
            else {
                finalQueryString = queryString + ' where ParentObject__c IN : CurrentParent ORDER BY ParentObject__c Limit 1000';
            }
            system.debug('********finalQueryString:'+finalQueryString);
            if(finalQueryString != null && finalQueryString !=''){
                try{
                    if(Limits.getLimitQueries()-Limits.getQueries()>0){
                        queryOutput = database.query(finalQueryString);
                        system.debug('***hierarchy level:'+level);
                    }else{
                        system.debug('****endOfStructure is true as SOQL limit reaches:');
                        endOfStructure = true;
                    }
                }catch(exception ex){ 
                    endOfStructure = true;
                }
            }
            system.debug('**queryOutput size:'+queryOutput);
            if( queryOutput.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParent.clear();
                //iterating through query output
                for ( Integer i = 0 ; i < queryOutput.size(); i++ ){
                    currentParent.add(queryOutput[i].Id);
                    accList.add(queryOutput[i]);
                 }
            }
            level++;
        }
        system.debug('**********accList:'+accList);
        return accList;
    }
    public static string getId(string recName){
        List<Data_Migration_Details__c> accList = new List<Data_Migration_Details__c>();
        accList = [select Id ,Name, ParentObject__c from Data_Migration_Details__c where Name =:recName LIMIT 1];
            return accList[0].id;
    }
	// Find the tom most element in Heirarchy  
    // @return objId
    public static String GetUltimateParentId( string recId ){
        Boolean top = false;
        while ( !top ) {
            string queryString = 'select Id ,Name, ParentObject__c from Data_Migration_Details__c where Id =:recId LIMIT 1';
            Data_Migration_Details__c acc = database.query(queryString);
            if ( acc.ParentObject__c != null ) {
                recId = acc.ParentObject__c;
            }else {
                top = true;
            }
        }
        return recId ;
    }
    
    /*@AuraEnabled
      public static List<Account> findHierarchyData(string recId){
        List<Account> accList = new List<Account>();
        string queryString = 'select id,name,parentId from Account ';
        //Section to get all child account details from ultimate parent starts-------------------------
        List<String> currentParent      = new List<String>{};
        Integer level               = 0;
        Boolean endOfStructure      = false;
        //method to find ultimate parent of account
        string topMostparent = GetUltimateParentId(recId );
        system.debug('*******topMostparent:'+topMostparent);
        currentParent.add(topMostparent);
        system.debug('**********topMostparent:'+ currentParent);
        //Loop though all children
        string finalQueryString = '';
        List<Account>  queryOutput = new List<Account> ();
        while ( !endOfStructure ){  
            if( level == 0 ){
                finalQueryString = queryString + ' where id IN : CurrentParent ORDER BY ParentId  Limit 1000';
            } 
            else {
                finalQueryString = queryString + ' where ParentID IN : CurrentParent ORDER BY ParentId Limit 1000';
            }
            system.debug('********finalQueryString:'+finalQueryString);
            if(finalQueryString != null && finalQueryString !=''){
                try{
                    if(Limits.getLimitQueries()-Limits.getQueries()>0){
                        queryOutput = database.query(finalQueryString);
                        system.debug('***hierarchy level:'+level);
                    }else{
                        system.debug('****endOfStructure is true as SOQL limit reaches:');
                        endOfStructure = true;
                    }
                }catch(exception ex){ 
                    endOfStructure = true;
                }
            }
            system.debug('**queryOutput size:'+queryOutput);
            if( queryOutput.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParent.clear();
                //iterating through query output
                for ( Integer i = 0 ; i < queryOutput.size(); i++ ){
                    currentParent.add(queryOutput[i].Id);
                    accList.add(queryOutput[i]);
                 }
            }
            level++;
        }
        system.debug('**********accList:'+accList);
        return accList;
    }
     
	// Find the tom most element in Heirarchy  
    // @return objId
    public static String GetUltimateParentId( string recId ){
        Boolean top = false;
        while ( !top ) {
            string queryString = 'select id ,name, ParentId from Account where Id =:recId LIMIT 1';
            Account acc = database.query(queryString);
            if ( acc.parentId != null ) {
                recId = acc.parentId;
            }else {
                top = true;
            }
        }
        return recId ;
    }*/
}