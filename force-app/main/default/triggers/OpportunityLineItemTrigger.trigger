/**
 * Author: DeaGle
 */
trigger OpportunityLineItemTrigger on OpportunityLineItem (before update, before insert, after insert) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('OpportunityLineItem');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        OpportunityLineItemTriggerHandler handlerInstance = OpportunityLineItemTriggerHandler.getInstance();
        if(Trigger.isBefore && Trigger.isUpdate) {
            handlerInstance.onBeforeUpdate(Trigger.New, Trigger.OldMap);
        }
        
        if(Trigger.isBefore && Trigger.isInsert) {
            handlerInstance.onBeforeInsert(Trigger.New);
        }

        if(Trigger.isAfter && Trigger.isInsert) {
            handlerInstance.onAfterInsert(Trigger.New);
        }
    }
}