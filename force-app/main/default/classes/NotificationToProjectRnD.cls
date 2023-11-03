public without sharing class NotificationToProjectRnD {
    
    public static void notifyRnD(Id projectId){
        Project__c projectRecord = [SELECT Id, Product_Family__c FROM Project__c WHERE Id =: projectId];
        list<Sample_Assignee__mdt> mdtList = Sample_Assignee__mdt.getAll().values();
        System.debug('--mdtList->'+mdtList);
        string recepient ;
        for (Sample_Assignee__mdt MDT : mdtList) {
            if(MDT.Label == projectRecord.Product_Family__c){
                recepient = MDT.Project_RnD_Email_Ids__c;
            }
        }
        
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage sliEmail = new Messaging.SingleEmailMessage();
        List <String> emailRecipients = new List <String>{recepient};
            system.debug('emailRecipients'+emailRecipients);
        
        sliEmail.setToAddresses(emailRecipients);
        sliEmail.setSubject('Project assigned');
        sliEmail.setReplyTo(UserInfo.getUserEmail());
        
        String emailBody = 'Dear User,';
        emailBody += ' <br> <br> One Project record is assigned to you. ';            
        emailBody += '<br> <br> Thank & Regards';
        emailBody += '<br> Symega Foods';
        sliEmail.setHtmlBody(emailBody);
        emailsList.add(sliEmail);
        if(!emailsList.isEmpty()) {
            Messaging.sendEmail(emailsList);     
        }
    }
    
}