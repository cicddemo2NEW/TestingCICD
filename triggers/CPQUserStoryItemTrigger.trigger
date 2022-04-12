trigger CPQUserStoryItemTrigger on CPQ_User_Story_Item__c (before insert,before update, after insert,after update) {
    if(Trigger.isBefore){
        CPQUserStoryItemTriggerHandler.updateUniqueId(Trigger.new);
    }
    
    if(Trigger.isAfter){
        
        // Call After Insert methods.
        if(Trigger.isInsert){
           CPQUserStoryItemTriggerHandler.UpdateCPQReleaseItemObject(Trigger.new);
        }
         
        // Call After Update methods.
        if(Trigger.isUpdate){
            CPQUserStoryItemTriggerHandler.UpdateCPQReleaseItemObject(Trigger.new);
        }
    }
}