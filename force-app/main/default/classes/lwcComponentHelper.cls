public with sharing class lwcComponentHelper {
    public lwcComponentHelper() {

    }

    @AuraEnabled
    public static list<Goal_Tracking__c> getAllProspectOpportunitites(string goalId){
        try {
            list<Goal_Tracking__c> goalTrackingRecordsWithProspectOpportunities = new list<Goal_Tracking__c> ();
            goalTrackingRecordsWithProspectOpportunities =  [SELECT Id,Goal__c,Opportunity__c,Opportunity__r.StageName,Opportunity__r.Amount,
                                                             Opportunity__r.Name,Opportunity__r.AccountId,Opportunity__r.Account.name 
                                                             FROM Goal_Tracking__c WHERE Goal__c =: goalId AND Opportunity__r.StageName != 'Closed Won' AND Opportunity__r.StageName != 'Closed Lost' ];
            return  goalTrackingRecordsWithProspectOpportunities;   
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list<Goal_Tracking__c> getAllClosedWonOpportunitites(string goalId){
        try {
            list<Goal_Tracking__c> goalTrackingRecordsWithClosedWonOpportunities = new list<Goal_Tracking__c> ();
            goalTrackingRecordsWithClosedWonOpportunities =  [SELECT Id,Goal__c,Opportunity__c,Opportunity__r.StageName,Opportunity__r.Amount,
                                                             Opportunity__r.Name,Opportunity__r.AccountId,Opportunity__r.Account.name 
                                                             FROM Goal_Tracking__c WHERE Goal__c =: goalId AND Opportunity__r.StageName = 'Closed Won' ];
            return  goalTrackingRecordsWithClosedWonOpportunities;   
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static goal__c getRevenueTrackFromGoal(string goalId){
        try {
            goal__c goalObj = new goal__c();
            goalObj = [select id,Target__c,Achieved_Target__c,Expected_Amount__c,Fiscal_Year__c,Fiscal_Year__r.Fiscal_Start_Date__c,Fiscal_Year__r.Fiscal_End_Date__c from goal__c WHERE id =: goalId];
            return goalObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static OpportunityLineItem getOppProductRecord(String lineItemId){
        try {
            if(String.isBlank(lineItemId))
                return null;
            return [Select Id, Name, OpportunityId, Sales_Order__c, TotalPrice, Quantity FROM OpportunityLineItem where Id =:lineItemId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}