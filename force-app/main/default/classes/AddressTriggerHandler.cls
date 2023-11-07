public without sharing class AddressTriggerHandler {
    static AddressTriggerHandler accTriggerInstance;
    
    public static AddressTriggerHandler getInstance(){
        if(accTriggerInstance==null)
            accTriggerInstance = new AddressTriggerHandler();
        return accTriggerInstance;     
    }
    
    public void afterUpdate(Map<Id,Dispatch_Address__c> oldMap,Map<Id,Dispatch_Address__c> newMap){
        System.debug('CALLLEEDDDD');
        List<Id> addressIds = new List<Id>();
        Set<Id> setOfAddressToUpdate = new Set<Id>();
        Set<Id> registeredAddressIds = new Set<Id>();
        for(Dispatch_Address__c addr : newMap.values()){
            if(oldMap.get(addr.Id).Customer_Code_SAP__c==null && addr.Customer_Code_SAP__c!=null){
                addressIds.add(addr.Id);
            }
            
            if((oldMap.get(addr.Id).Customer_Code_SAP__c==null && addr.Customer_Code_SAP__c!=null) || (oldMap.get(addr.Id).OPTIVA_Customer_Code__c==null && addr.OPTIVA_Customer_Code__c!=null)) {
                registeredAddressIds.add(addr.Id);
            }
            if(isAddressChange(oldMap,addr) && addr.SAP_Update_Customer__c){
                setOfAddressToUpdate.add(addr.Id);
            }
        }
        
        System.debug('AcccSet'+addressIds);
        
        if(!addressIds.isEmpty()){
            System.debug('hiii');
            GetFERTCodeController.sendFertCodeEmailBulkAddress(addressIds); 
            OpportunityCreateSaleOrderController.updateOppInBulkAddress(addressIds);  
            //SAP_UpdatePIRCallout.updateOnPIR(addressIds);
        }
        
        if(!registeredAddressIds.isEmpty()) {
            Map<Id,Project__c> allProjectToSMap = new Map<Id,Project__c>([SELECT Id FROM Project__c WHERE Opportunity__r.Customer_Billing_Address__c IN :registeredAddressIds AND Submit_Sample_To_Optiva__c = true]);
            
            if(!allProjectToSMap.isEmpty()) {
                Database.executeBatch(new AutoSyncBatchSampleToOptiva(allProjectToSMap.keySet()), 1);
            }
        }
        
        if(!setOfAddressToUpdate.isEmpty()){
            Database.executeBatch(new SAP_Update_CustomerAddressBatch(setOfAddressToUpdate));
        }
    }
    
    
    private static boolean isAddressChange(Map<Id,Dispatch_Address__c> oldMap, Dispatch_Address__c acc){
        if(oldMap.get(acc.Id).Name != null && acc.Name!=null && oldMap.get(acc.Id).Name!=acc.Name && acc.Customer_Code_SAP__c == null
           || oldMap.get(acc.Id).Address__Street__s != null && acc.Address__Street__s!=null && oldMap.get(acc.Id).Address__Street__s!=acc.Address__Street__s 
           || oldMap.get(acc.Id).Address__PostalCode__s != null && acc.Address__PostalCode__s !=null && oldMap.get(acc.Id).Address__PostalCode__s!=acc.Address__PostalCode__s
           || oldMap.get(acc.Id).Address__City__s != null && acc.Address__City__s !=null && oldMap.get(acc.Id).Address__City__s!=acc.Address__City__s
           || oldMap.get(acc.Id).Address__CountryCode__s  != null && acc.Address__CountryCode__s !=null && oldMap.get(acc.Id).Address__CountryCode__s !=acc.Address__CountryCode__s  
           || oldMap.get(acc.Id).Address__StateCode__s != null && acc.Address__StateCode__s!=null && oldMap.get(acc.Id).Address__StateCode__s!=acc.Address__StateCode__s && acc.Account__r.Customer_Type__c!='Export'
           || oldMap.get(acc.Id).GST_number__c != null && acc.GST_number__c !=null && oldMap.get(acc.Id).GST_number__c!=acc.GST_number__c && !String.isBlank(acc.Address__CountryCode__s) && acc.Address__CountryCode__s.equalsIgnoreCase('India')
           || oldMap.get(acc.Id).CurrencyIsoCode != null && acc.CurrencyIsoCode !=null && oldMap.get(acc.Id).CurrencyIsoCode!=acc.CurrencyIsoCode
           || oldMap.get(acc.Id).Contact__c != null && acc.Contact__c !=null && oldMap.get(acc.Id).Contact__c!=acc.Contact__c
          ){
              return true;
          }
        return false;
    }
    
}