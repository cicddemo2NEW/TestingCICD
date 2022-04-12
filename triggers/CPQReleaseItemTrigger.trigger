trigger CPQReleaseItemTrigger on CPQ_Release_Item__c (before insert,before update, after insert,after update) {
    if(Trigger.isBefore){
        for(CPQ_Release_Item__c  CPQReleaseItemObj : Trigger.new){ 
           CPQReleaseItemObj.UniqueId__c = CPQReleaseItemObj.CPQ_Release__c+CPQReleaseItemObj.Name+CPQReleaseItemObj.Operation__c+CPQReleaseItemObj.Sequence__c;
        }
    }
    
}