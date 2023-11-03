public without sharing class SAP_Update_CustomerAddressBatch Implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    Set<Id> setOfCustomerAddress;
    public SAP_Update_CustomerAddressBatch(Set<Id> setOfCustomerAddress) {
        this.setOfCustomerAddress = setOfCustomerAddress;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator([Select Id from Contact limit 1]); 
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){ 
        for(String id : setOfCustomerAddress){
            String response = SAP_ADDRESS_UPDATE_CALLOUT.syncAddressCustomersWithSAP(id);
        }
    } 
    
    public void finish(Database.BatchableContext BC){ 
        System.debug('finishing SMS Batch');
    }
}