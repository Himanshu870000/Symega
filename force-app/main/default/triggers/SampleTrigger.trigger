/**
 * Author: DeaGle
 */
trigger SampleTrigger on Project__c (before insert, before update, after update) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Project__c');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        SampleTriggerHandler handlerInstance = SampleTriggerHandler.getInstance();
        if(Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate)) {
            handlerInstance.onBeforeInsert(Trigger.New);
        }

        if(Trigger.isBefore && Trigger.isUpdate){
            handlerInstance.onBeforeUpdate(Trigger.OldMap,Trigger.NewMap);
        }

        if(Trigger.isAfter && Trigger.isUpdate){
            handlerInstance.onAfterUpdate(Trigger.OldMap,Trigger.NewMap);
        }
    }
}