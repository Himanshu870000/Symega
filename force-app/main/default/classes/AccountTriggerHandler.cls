public without sharing class AccountTriggerHandler {
    static AccountTriggerHandler accTriggerInstance;
    
    public static AccountTriggerHandler getInstance(){
        if(accTriggerInstance==null)
            accTriggerInstance = new AccountTriggerHandler();
        return accTriggerInstance;     
    }
    
    //Deagle~ : v1.1 added to calculate parent account roll-ups
    public void onBeforeUpdate(List<Account> accList, Map<Id, Account> oldAccMap) {
        
        Set<Id> parentAccountIdSet = new Set<Id>();
        for(Account a : accList) {
            if(a.ParentId != oldAccMap.get(a.Id).ParentId || a.Number_of_closed_opportunity__c != oldAccMap.get(a.Id).Number_of_closed_opportunity__c || a.Number_of_open_opportunity__c != oldAccMap.get(a.Id).Number_of_open_opportunity__c || a.Number_of_Total_Opportunity__c != oldAccMap.get(a.Id).Number_of_Total_Opportunity__c || a.Number_Of_Won_Opportunity__c != oldAccMap.get(a.Id).Number_Of_Won_Opportunity__c || a.Number_of_won_opportunity_partially_exec__c != oldAccMap.get(a.Id).Number_of_won_opportunity_partially_exec__c || a.Closed_Opportunity_Value__c != oldAccMap.get(a.Id).Closed_Opportunity_Value__c || a.COLOR_Opportunity_Closed_Value__c != oldAccMap.get(a.Id).COLOR_Opportunity_Closed_Value__c || a.CPD_Opportunity_Closed_Value__c != oldAccMap.get(a.Id).CPD_Opportunity_Closed_Value__c || a.FLAVOR_Opportunity_Closed_Value__c != oldAccMap.get(a.Id).FLAVOR_Opportunity_Closed_Value__c || a.PLANT_BASED_Opportunity_Closed_Value__c != oldAccMap.get(a.Id).PLANT_BASED_Opportunity_Closed_Value__c || a.SPD_Opportunity_Closed_Value__c != oldAccMap.get(a.Id).SPD_Opportunity_Closed_Value__c) {
                parentAccountIdSet.add(a.ParentId);
            }
        }
        
        if(!parentAccountIdSet.isEmpty())
            ParentAccountRollupUtility.processSummaryCalculationFuture(parentAccountIdSet);
    }
    
    //Deagle~ : v1.1 added to calculate parent account roll-ups
    public void onBeforeInsert(List<Account> accountList) {
        Set<Id> parentAccountIdSet = new Set<Id>();
        for(Account a : accountList) {
            if(a.ParentId != null) {
                parentAccountIdSet.add(a.ParentId);
            }
        }
        
        if(!parentAccountIdSet.isEmpty())
            ParentAccountRollupUtility.processSummaryCalculationFuture(parentAccountIdSet);
    }
    
    public void afterUpdate(Map<Id,Account> oldMap,Map<Id,Account> newMap){
        System.debug('CALLLEEDDDD');
        List<Id> accIds = new List<Id>();
        Set<Id> setOfAccountToUpdate = new Set<Id>();
        Set<Id> registeredAccIds = new Set<Id>();
        for(Account acc : newMap.values()){
            if(oldMap.get(acc.Id).Customer_Code_SAP__c==null && acc.Customer_Code_SAP__c!=null){
                accIds.add(acc.Id);
            }
            
            if((oldMap.get(acc.Id).Customer_Code_SAP__c==null && acc.Customer_Code_SAP__c!=null) || (oldMap.get(acc.Id).Customer_Code_OPTIVA__c==null && acc.Customer_Code_OPTIVA__c!=null)) {
                registeredAccIds.add(acc.Id);
            }
            if(isAccChange(oldMap,acc) && acc.SAP_Update_Customer__c){
                setOfAccountToUpdate.add(acc.Id);
            }
        }
        
        System.debug('AcccSet'+accIds);
        
        if(!accIds.isEmpty()){
            System.debug('hiii');
            GetFERTCodeController.sendFertCodeEmailBulk(accIds); 
            OpportunityCreateSaleOrderController.updateOppInBulk(accIds);  
            SAP_UpdatePIRCallout.updateOnPIR(accIds);
        }
        
        if(!registeredAccIds.isEmpty()) {
            Map<Id,Project__c> allProjectToSMap = new Map<Id,Project__c>([SELECT Id FROM Project__c WHERE Opportunity__r.AccountId IN :registeredAccIds AND Submit_Sample_To_Optiva__c = true]);
            
            if(!allProjectToSMap.isEmpty()) {
                Database.executeBatch(new AutoSyncBatchSampleToOptiva(allProjectToSMap.keySet()), 1);
            }
        }
        
        if(!setOfAccountToUpdate.isEmpty()){
            //Database.executeBatch(new SAP_Update_CustomerBatch(setOfAccountToUpdate));
        }
    }
    
    
    private static boolean isAccChange(Map<Id,Account> oldMap, Account acc){
        if(oldMap.get(acc.Id).Name != null && acc.Name!=null && oldMap.get(acc.Id).Name!=acc.Name && acc.Customer_Code_SAP__c == null
           || oldMap.get(acc.Id).BillingStreet != null && acc.BillingStreet!=null && oldMap.get(acc.Id).BillingStreet!=acc.BillingStreet 
           || oldMap.get(acc.Id).BillingPostalCode != null && acc.BillingPostalCode !=null && oldMap.get(acc.Id).BillingPostalCode!=acc.BillingPostalCode
           || oldMap.get(acc.Id).BillingCity != null && acc.BillingCity !=null && oldMap.get(acc.Id).BillingCity!=acc.BillingCity
           || oldMap.get(acc.Id).BillingCountry != null && acc.BillingCountry!=null && oldMap.get(acc.Id).BillingCountry!=acc.BillingCountry 
           || oldMap.get(acc.Id).BillingState != null && acc.BillingState!=null && oldMap.get(acc.Id).BillingState!=acc.BillingState && acc.Customer_Type__c!='Export'
           || oldMap.get(acc.Id).GST_number__c != null && acc.GST_number__c !=null && oldMap.get(acc.Id).GST_number__c!=acc.GST_number__c && !String.isBlank(acc.BillingCountry) && acc.BillingCountry.equalsIgnoreCase('India')
           || oldMap.get(acc.Id).PAN_Number__c != null && acc.PAN_Number__c !=null && oldMap.get(acc.Id).PAN_Number__c!=acc.PAN_Number__c && !String.isBlank(acc.BillingCountry) && acc.BillingCountry.equalsIgnoreCase('India')
           || oldMap.get(acc.Id).Account_Segment__c != null && acc.Account_Segment__c !=null && oldMap.get(acc.Id).Account_Segment__c!=acc.Account_Segment__c
           || oldMap.get(acc.Id).Delivery_Plant__c != null && acc.Delivery_Plant__c !=null && oldMap.get(acc.Id).Delivery_Plant__c!=acc.Delivery_Plant__c
           || oldMap.get(acc.Id).Customer_Type__c != null && acc.Customer_Type__c !=null && oldMap.get(acc.Id).Customer_Type__c!=acc.Customer_Type__c
           || oldMap.get(acc.Id).Payment_terms__c != null && acc.Payment_terms__c !=null && oldMap.get(acc.Id).Payment_terms__c!=acc.Payment_terms__c
           || oldMap.get(acc.Id).FSSAI__c != null && acc.FSSAI__c !=null && oldMap.get(acc.Id).FSSAI__c!=acc.FSSAI__c
           || oldMap.get(acc.Id).Transportation_Terms__c != null && acc.Transportation_Terms__c !=null && oldMap.get(acc.Id).Transportation_Terms__c!=acc.Transportation_Terms__c
           || oldMap.get(acc.Id).Tax_Collected_At_Source__c != null && acc.Tax_Collected_At_Source__c !=null && oldMap.get(acc.Id).Tax_Collected_At_Source__c!=acc.Tax_Collected_At_Source__c
           || oldMap.get(acc.Id).CurrencyIsoCode != null && acc.CurrencyIsoCode !=null && oldMap.get(acc.Id).CurrencyIsoCode!=acc.CurrencyIsoCode
           || oldMap.get(acc.Id).RecordTypeId != null && acc.RecordTypeId !=null && oldMap.get(acc.Id).RecordTypeId!=acc.RecordTypeId           
          ){
              return true;
          }
        return false;
    }
    
    
}