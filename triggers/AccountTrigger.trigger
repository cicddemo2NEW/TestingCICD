trigger AccountTrigger on Account (after insert) {
if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            // Process before insert
        } else if (Trigger.isAfter) {
            // Process after insert
        }        
    }
    else if (Trigger.isDelete) {
        // Process after delete
    }
    else if (Trigger.isUpdate) {
        // Process after delete
    }
    //testing conflick 1
    //TTT
    //Testing commit2
}