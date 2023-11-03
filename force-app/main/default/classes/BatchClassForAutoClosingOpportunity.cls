Global  class BatchClassForAutoClosingOpportunity implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id,Remainder_Sent_Date__c,StageName FROM Opportunity Where Remainder_Sent_Date__c != null and StageName !='Closed Lost' and StageName !='Closed Won' and RecordType.name = 'Parent']); 
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> OppList){   
        
        List<Opportunity> updateOpp = new List<Opportunity>();
        for(Opportunity oppRec : OppList){
            Date d = oppRec.Remainder_Sent_Date__c.addDays(10);
            System.debug('d----->'+d); 
            if(d == System.today()){
                oppRec.StageName = 'Closed Lost';
                updateOpp.add(oppRec);
            }       
        }
        update updateOpp;
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug(' batch to close all the opportunities after 10 days of Reminder sent');        
    }   
}