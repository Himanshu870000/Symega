trigger UserTrigger on User (after update) {
    if(trigger.isAfter && trigger.isUpdate){
            UserTriggerHelper.checkingManagerandTranferAccount(trigger.new);
        }
}