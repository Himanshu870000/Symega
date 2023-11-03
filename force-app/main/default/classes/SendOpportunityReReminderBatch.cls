public without sharing class SendOpportunityReReminderBatch implements Database.Batchable <Sobject>{
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        return Database.getQueryLocator ('SELECT Name, CloseDate, StageName, OwnerId FROM Opportunity WHERE StageName != \'Closed Won\' AND StageName != \'Closed Lost\' AND Last_Opp_Closure_Reminder_Date__c = LAST_N_DAYS:1 AND RecordType.Name = \'One Time\' ' );
    }
    
    public void Execute(Database.BatchableContext bc, List<Opportunity> oppList){
        Map <Id,User> userMap = new Map <Id, User>([SELECT FirstName, Email FROM User]);        
        Map <ID, List<Opportunity>> oppOwnerMap = new Map <Id, List<Opportunity>>();
        List<Opportunity> listOfOppToBeUpdated = new list<Opportunity> ();
        
        for (Opportunity opp : oppList) {
            if (oppOwnerMap.containsKey(opp.OwnerId)) {
                oppOwnerMap.get(opp.OwnerId).add(opp); 
            }
            else{
                oppOwnerMap.put(opp.OwnerId, new List<Opportunity> {opp});
            }   
            opp.StageName = 'Closed Won';
            listOfOppToBeUpdated.add(opp);
        }
        
        List <Messaging.SingleEmailMessage> allEmailMessages = new List <Messaging.SingleEmailMessage>();
        
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        for (ID oneOwn : oppOwnerMap.keyset()) {
            Messaging.SingleEmailMessage oppEmail = new Messaging.SingleEmailMessage();
            List <String> emailRecipients = new List <String>{userMap.get(oneOwn).Email};
                
            oppEmail.setToAddresses(emailRecipients);
            oppEmail.setSubject('Closing the opportunity records');
            oppEmail.setReplyTo(emailRecipients[0]);
            
            String emailBody = 'Hi ' + userMap.get(oneOwn).FirstName + ',';
            emailBody += ' <br> <br> We have closed the following opportunities as we found no response since the last reminder.<br>';
            String recordOwnerList = '';
            List <Opportunity> relatedOwnerRec = oppOwnerMap.get(oneOwn);
            
            for (Integer i = 0; i < relatedOwnerRec.size(); i++) {
                emailBody += ' <br><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+relatedOwnerRec[i].Id+'">'+ relatedOwnerRec[i].Name +'</a><br>' ;    
            }
            
            emailBody += '<br> Thanks and Regards';
            emailBody += '<br> Symega Foods';
            oppEmail.setHtmlBody(emailBody);
            emailsList.add(oppEmail);
        } 
        if(!emailsList.isEmpty()) {
            Messaging.sendEmail(emailsList);     
        }        
    }
    
    public void Finish(Database.BatchableContext bc){
        System.debug('The 2nd Reminder Batch Run Successfully');
    }
}