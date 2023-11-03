trigger TriggerOnReturn on Return__c (after insert, after update) {
    
SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Return');
    
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        
        ReturnTriggerHandler handlerInstance = ReturnTriggerHandler.getInstance();
        
        if(Trigger.isAfter && Trigger.isInsert ) {
            System.debug('On Before Insert Trigger fired');
            handlerInstance.onBeforeInsert(Trigger.New);
        }
        
        if(Trigger.isAfter && Trigger.isUpdate ) {
            System.debug('On After Update Trigger fired');
            handlerInstance.onAfterUpdate(Trigger.New, Trigger.OldMap);
        }
    }
}