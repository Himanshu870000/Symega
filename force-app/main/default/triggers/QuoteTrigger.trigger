/*
 * Author: Anjali Singh
 */

trigger QuoteTrigger on Quote (before insert) {  
    
        if(Trigger.isBefore && Trigger.isInsert) {
            QuoteTriggerHandler.onBeforeInsert(Trigger.New);
        }
}