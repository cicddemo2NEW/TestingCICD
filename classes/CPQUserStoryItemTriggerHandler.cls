public class CPQUserStoryItemTriggerHandler {
    public static void updateUniqueId(List<CPQ_User_Story_Item__c> CPQUserStoryList){
        for(CPQ_User_Story_Item__c CPQUserStoryItemObj : CPQUserStoryList){ 
           CPQUserStoryItemObj.UniqueId__c = CPQUserStoryItemObj.CPQ_User_Story__c+''+CPQUserStoryItemObj.Sequence__c;
        }
    }
    public static void UpdateCPQReleaseItemObject(List<CPQ_User_Story_Item__c> CPQUserStoryList){
        List<Id> CPQReleaseIds = new List<Id>();
        for(CPQ_User_Story_Item__c CPQUserStoryItemObj : CPQUserStoryList){ 
            CPQReleaseIds.add(CPQUserStoryItemObj.CPQ_Release__c);
        }
        Map<string,CPQ_Release_Item__c> cpqRILObj = new Map<string,CPQ_Release_Item__c>();
        Map<string,decimal> cpqReleaseVSObjectCount = new Map<string,decimal>();
        for(CPQ_Release_Item__c cpqRIObj : [select id,CPQ_Release__c,CPQ_Release__r.Objects_count__c,Name,Operation__c,Sequence__c,uniqueId__c,Ids__c,External_Id_API_Field__c from CPQ_Release_Item__c where CPQ_Release__c IN :CPQReleaseIds]){
            string uniqueId = cpqRIObj.CPQ_Release__c+cpqRIObj.Name+cpqRIObj.Operation__c+cpqRIObj.Sequence__c;
            cpqRILObj.put(uniqueId, cpqRIObj);
            cpqReleaseVSObjectCount.put(cpqRIObj.CPQ_Release__c, cpqRIObj.CPQ_Release__r.Objects_count__c);
        }
        List<CPQ_Release_Item__c> cpqRIList = new List<CPQ_Release_Item__c>();
        
         for(CPQ_User_Story_Item__c CPQUSItemObj : CPQUserStoryList){
             
             string uniqueId = CPQUSItemObj.CPQ_Release__c+CPQUSItemObj.Name+CPQUSItemObj.Operation__c+CPQUSItemObj.Sequence__c;
             Decimal sequence = cpqReleaseVSObjectCount.get(CPQUSItemObj.CPQ_Release__c);
             if(cpqRILObj.containsKey(uniqueId)){
                 CPQ_Release_Item__c cpqRIUPdate = new  CPQ_Release_Item__c();
                 cpqRIUPdate.Ids__c = processIds(cpqRILObj.get(uniqueId).Ids__c, CPQUSItemObj.Ids_to_deploy__c);
                 cpqRIUPdate.UniqueId__c = uniqueId;
                 cpqRIList.add(cpqRIUPdate);
             }else{
               CPQ_Release_Item__c cpqRI = new  CPQ_Release_Item__c();
                 cpqRI.Name = CPQUSItemObj.Name;
                 cpqRI.Operation__c = CPQUSItemObj.Operation__c;
                 cpqRI.Sequence__c = sequence+1;
                 cpqRI.Ids__c = CPQUSItemObj.Ids_to_deploy__c;
                 cpqRI.External_Id_API_Field__c = CPQUSItemObj.External_Id_field_API_name__c;
                 cpqRI.UniqueId__c = uniqueId;
                 cpqRI.CPQ_Release__c = CPQUSItemObj.CPQ_Release__c;
                 cpqRIList.add(cpqRI);
             }
         }
        system.debug('cpqRIList-->'+cpqRIList);
        if(cpqRIList.size()>0){
            database.upsert(cpqRIList,CPQ_Release_Item__c.UniqueId__c, false);
        }
        
    }
    public static string processIds(string releaseIds,string userStoryIds){
        string fullIds = releaseIds+','+userStoryIds;
        Set<String> uniqueList = new Set<String>();
		uniqueList.addAll(fullIds.split(','));
        string combinedIds = string.join(new List<String>(uniqueList), ','); 
        return combinedIds;
    }
}