trigger TriggerOnAccount on Account (after update, before update, before insert) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Account');
    System.debug('Trigger Config Started');

    if(triggerConfig != null && triggerConfig.Trigger_Status__c){
        AccountTriggerHandler handlerInstance = AccountTriggerHandler.getInstance();
        System.debug('Trigger Started');
        if(Trigger.isUpdate && Trigger.isAfter){
            handlerInstance.afterUpdate(Trigger.oldMap,Trigger.newMap);
        }

        if(Trigger.isBefore && Trigger.isInsert){
            handlerInstance.onBeforeInsert(Trigger.New);
        }

        if(Trigger.isBefore && Trigger.isUpdate){
            handlerInstance.onBeforeUpdate(Trigger.New, Trigger.OldMap);
        }
    }
}