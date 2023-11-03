public without sharing class sendInvoiceToCustomersBatch implements Database.Batchable<Sobject>{
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Name, Finalized_School__c, Finalized_School__r.Email__c, Finalized_School__r.Name FROM Opportunity WHERE Finalized_School__c != null and Finalized_School__r.Email__c != null and stagename = \'Closed Won\' ');
    }
    
    public void Execute(Database.BatchableContext bc, List<Opportunity> oppList){
        try{
            System.debug('oppList :: ' + oppList);
            List <Messaging.SingleEmailMessage> emails = new List <Messaging.SingleEmailMessage> ();
            List<ContentVersion> cvList = [SELECT Id, Title, VersionData FROM ContentVersion where Title = 'EduStokeInvoice'];
            for(Opportunity opp : oppList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {opp.Finalized_School__r.Email__c});
                email.setSubject('Invoice'); 
                string emailBody = opp.Finalized_School__r.Name + ', \n\nPlease find the attached invoice for the obtained service.\n\nThanks & Regards,\nEduStoke';
                email.setPlainTextBody(emailBody);
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('Invoice.pdf');
                efa.setBody(cvList[0].VersionData);
                efa.setContentType('application/pdf');
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
                emails.add(email);   
            }
            Messaging.sendEmail(emails);
        }
        catch(Exception e){
            
        }
    }
    
    public void Finish(Database.BatchableContext bc){
        System.debug('The Batch Run Successfully');
    }
}