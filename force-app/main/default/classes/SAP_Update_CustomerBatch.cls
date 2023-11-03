public without sharing class SAP_Update_CustomerBatch Implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    Set<Id> setOfCustomer;
    public SAP_Update_CustomerBatch(Set<Id> setOfCustomer) {
        this.setOfCustomer = setOfCustomer;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator([Select Id from Contact limit 1]); 
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){ 
        for(String id : setOfCustomer){
            String response = SAP_CUSTOMER_UPDATE_CALLOUT.syncCustomersWithSAP(id);
        }
    } 
    
    public void finish(Database.BatchableContext BC){ 
        System.debug('finishing SMS Batch');
    }
}