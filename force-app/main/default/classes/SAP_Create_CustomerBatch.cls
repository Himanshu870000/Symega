public without sharing class SAP_Create_CustomerBatch Implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    Set<Id> setOfCustomer;
    public SAP_Create_CustomerBatch(Set<Id> setOfCustomer){
        this.setOfCustomer = setOfCustomer;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator([Select Id from Contact limit 1]); 
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){ 

        set<Id> successfulAccIdSet = new set<Id>();
        for(String id : setOfCustomer){
            String response = SAP_CreateCustomerCallout.createCustomer(id, true);
            if(response.equalsIgnoreCase('Success')){
                successfulAccIdSet.add(id);
            }
        }
        if(successfulAccIdSet.size()>0){
            List<Account> accRecListToUpdate = new List<Account>();
            List<Account> accRecList = [SELECT Id, Submitted_to_SAP__c FROM Account WHERE Id IN: successfulAccIdSet];
            for(Account accRec : accRecList){
                if(accRec.Submitted_to_SAP__c != true){
                    accRec.Submitted_to_SAP__c = true;
                    accRecListToUpdate.add(accRec);
                }
            }
            update accRecListToUpdate;
        }
         
    } 
    
    public void finish(Database.BatchableContext BC){ 
        System.debug('finishing SMS Batch');
    }
}