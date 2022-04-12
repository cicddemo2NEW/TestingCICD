public class getParentClass {
    

public static void getParents(){
    
       string  objectName = 'Apttus_Config2__PriceListItem__c';
    
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        for (SObjectField f : t.getDescribe().fields.getMap().values()) {
            if (f.getDescribe().getType() == DisplayType.Reference) {
                List<Schema.sObjectType> parentLookupList =  f.getDescribe().getReferenceTo();
                String parentLookup = String.valueOf(parentLookupList.get(0));
             
                    Map<String,String> lookupDetails = new Map<String,String>();
                    String rname = f.getDescribe().getRelationshipName();                     
                   system.debug('rname:' +  rname);
               
            }                
        }
   


}

    

    
}