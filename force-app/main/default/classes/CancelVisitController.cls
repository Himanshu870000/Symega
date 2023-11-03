public class CancelVisitController {
    
    public CancelVisitController(ApexPages.StandardSetController stdController){
        Database.executeBatch(new sendInvoiceToCustomersBatch());
    }
    
    @AuraEnabled
    public static void cancelVisit(Id visitId) {
        Visit__c visit = [SELECT Id, Opportunity__c,Job_Status__c,School__c FROM Visit__c WHERE Id = :visitId];        
        //Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :visit.Opportunity__c];
        Opportunity opp = new Opportunity();
        opp.Id = visit.Opportunity__c;
        opp.StageName = 'School Selected';
        opp.Finalized_School__c = visit.School__c;
        update opp;
    }
    
    @AuraEnabled
    public static void sendApplication(Id schoolId) {
        School__c schl = [SELECT Id, Name, Email__c, School_Coordinator__c FROM School__c WHERE Id =: schoolId];
        List <Messaging.SingleEmailMessage> emails = new List <Messaging.SingleEmailMessage> ();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {schl.Email__c});
        email.setSubject('Edustoke - Onboarding Form'); 
        string formLink = 'https://sales-production--fsldemo--c.sandbox.vf.force.com/apex/ApplicationFormPage?id=' + schoolId;
        string emailBody = 'Hi ' + schl.School_Coordinator__c + ', \n\nGreetings. Kindly find the registration link pasted below in this email. You are requested to fill this registration form to complete the onboarding process with Edustoke.\n' + formLink + '\n\nThanks & Regards,\nEduStoke';
        email.setPlainTextBody(emailBody);
        emails.add(email);   
        Messaging.sendEmail(emails);
        schl.Status__c = 'Registration Completed';
        update schl;
    }
}