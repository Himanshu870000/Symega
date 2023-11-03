public class QuoteTriggerHandler {   
    
    public static void onBeforeInsert(List<Quote> quoteList) {
        Set<Id> parentOppIdToRestrict = new Set<Id>();
        Set<Id> parentOppIdSet = new Set<Id>(); 
        
        for(Quote quoteRec: quoteList){
            parentOppIdSet.add(quoteRec.OpportunityId);           
        }
        List<Opportunity> childOppList = [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c IN:parentOppIdSet AND Parent_Opportunity__r.RecordType.DeveloperName = :Constants.OPP_PARENT_RECORD_TYPE];
        for(Opportunity opp: childOppList) {
            parentOppIdToRestrict.add(opp.Parent_Opportunity__c);
        }
        
        for(Quote quoteRec: quoteList) {
            if(parentOppIdToRestrict.contains(quoteRec.OpportunityId))
                quoteRec.addError(Constants.QuoteCreationErrorMsg);
        }
    }
}