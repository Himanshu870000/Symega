trigger LeadTrigger on Lead (before update, before insert) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Lead');
    system.debug('triggerConfig----'+triggerConfig);
    system.debug('triggerConfig.Trigger_Status__c>>'+triggerConfig.Trigger_Status__c);
    
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        LeadTriggerHandler handlerInstance = LeadTriggerHandler.getInstance();
        
        if(Trigger.isBefore && Trigger.isInsert) {
            system.debug('Before Insert');
            handlerInstance.onBeforeInsert(Trigger.New);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate) {
            system.debug('Before Update');
            handlerInstance.onAfterUpdate(Trigger.OldMap, Trigger.NewMap);
            handlerInstance.updateApprovalMemberApprovedDate(Trigger.OldMap, Trigger.NewMap);
        }
    }
}