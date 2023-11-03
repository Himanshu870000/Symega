public without sharing class generateFuturisticPIRsBatch implements Database.Batchable<Sobject>{

    public Database.QueryLocator Start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Name, OpportunityId, Opportunity.AccountId, Product2Id,Quantity_In_KG__c, Is_PIR_Created__c, Opportunity.Proposed_Date_of_Dispatch__c FROM OpportunityLineItem WHERE ' +
                                        'Opportunity.StageName != \'Closed Won\' AND Opportunity.CloseDate <= TODAY AND Opportunity.RecordType.Name = \'One Time\' AND Is_PIR_Created__c = FALSE ');
    }
    public void Execute(Database.BatchableContext bc, List<OpportunityLineItem> lineItemList){
        try{
            System.debug('lineItemList :: ' + lineItemList);
            List<PIR__c> pirListToBeInserted = new List<PIR__c>();
            
            for(OpportunityLineItem lineItem : lineItemList){
                PIR__c newPIR = new PIR__c();
                newPIR.Customer_Name__c = lineItem.Opportunity.AccountId;
                newPIR.Product__c = lineItem.Product2Id;
                newPIR.Quantity_in_KG__c = lineItem.Quantity_In_KG__c;
                newPIR.Dispatch_Plan__c = lineItem.Opportunity.Proposed_Date_of_Dispatch__c;
                lineItem.Is_PIR_Created__c = TRUE;
                pirListToBeInserted.add(newPIR);
            }
            
            if(pirListToBeInserted != null){
                insert pirListToBeInserted;
                update lineItemList;
            }            
        }
        catch(Exception e){
            System.debug('Error :: ' + e.getMessage() + 'At Line No :: ' + e.getLineNumber());
        }
    }
    public void Finish(Database.BatchableContext bc){
        System.debug('The Batch Run Successfully');
    }
}