/*
* Author : Anjali
*/
public without sharing class AccountConvertionUpdate {
    
    @InvocableMethod
    public static void invocableMethod(List<ID> accIdList){
        enableAccountValidation(accIdList);
    }
    
    @future
    public static void enableAccountValidation(List<Id> accIdList)
    {   
        if(accIdList != null && !accIdList.isEmpty()) {
        	list<Account> accList = [SELECT Id, Run_Validation_Rule__c FROM Account WHERE Id IN : accIdList AND Run_Validation_Rule__c = false];    
        	for(Account acc : accList){
                acc.Run_Validation_Rule__c = TRUE;
            }
            if(!accList.isEmpty())
            	update accList;
        }
    }

}