global without sharing class LeadOnboardingEmailServiceHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('--- email'+email);
        System.debug('--- envelope'+envelope);

        String myPlainText= '';
        // Add the email plain text into the local variable 
        myPlainText = email.plainTextBody;

        try {
            List<Lead> vLeadList = [SELECT Id, Name, Email FROM Lead WHERE Email = :email.fromAddress LIMIT 1];
            if(!vLeadList.isEmpty()) {
                System.debug('--- existing Lead');
                return result;
            }
            //Otherwise
            Lead newCandidate = new Lead(LastName = email.fromName != null ? email.fromName : 'NO_NAME', Email = email.fromAddress, LeadSource = 'Email');
            insert newCandidate;
            System.debug('--- text attach'+ email.textAttachments);
            
            
        }catch(Exception e) {
            HandleBusinessException.captureError('LeadOnboardingEmailServiceHandler', 'handleInboundEmail', e);
        }
        return result;
    }
}