public class SampleRevertDateNotificationBatch implements Database.Batchable <Sobject> {
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        //date dateBefore=dt.addMonths(-12);
        //date dateAfter=dt.addMonths(-6);
        return Database.getQueryLocator('SELECT Id, CreatedDate, Sample_Revert_Date__c, Account__r.RecordType.Name, Status__c, OwnerId, Owner.FirstName, Owner.Email, Sample_Name__c FROM Project__c WHERE ' + 
                                        'RecordType.Name = \'Sample\' AND Status__c != \'Sample Accepted\' AND Status__c != \'Sample Lost\' AND Sample_Revert_Date__c != NULL');
    }
    
    public void Execute(Database.BatchableContext bc, List<Project__c> sampleList){
        try{            
            system.debug('sampleList :: ' + sampleList);     
            date past6monthsDate = system.today().addMonths(-6);
            system.debug('past6monthsDate :: ' + past6monthsDate);
            
            date past1yrDate = system.today().addMonths(-12);
            system.debug('past1yrDate :: ' + past1yrDate);
            
            List<Project__c> smplListToBeUpdated = new List<Project__c>();
            Map <Id,User> userMap = new Map <Id, User>([SELECT FirstName, Email FROM User]);        
            Map <ID, List<Project__c>> smplOwnerMap = new Map <Id, List<Project__c>>();        
            
            for (Project__c smpl : sampleList) {
                date dt = smpl.Sample_Revert_Date__c.addDays(-1);
                system.debug('date :: ' + dt);                
                if(System.today() == dt){
                    if (smplOwnerMap.containsKey(smpl.OwnerId)) {
                        smplOwnerMap.get(smpl.OwnerId).add(smpl); 
                    }
                    else{
                        smplOwnerMap.put(smpl.OwnerId, new List<Project__c> {smpl});
                    }   
                    
                } 
                if( (smpl.CreatedDate <= past6monthsDate && smpl.Account__r.RecordType.Name == 'Direct Customer') || (smpl.CreatedDate <= past1yrDate && smpl.Account__r.RecordType.Name == 'Channel and Food Service')){
                    smpl.Status__c = 'Sample Lost';
                    smplListToBeUpdated.add(smpl);                    
                }
            }
            
            List <Messaging.SingleEmailMessage> allEmailMessages = new List <Messaging.SingleEmailMessage>();
            
            for (ID oneOwn : smplOwnerMap.keyset()) {
                Messaging.SingleEmailMessage smplEmail = new Messaging.SingleEmailMessage();
                List <String> emailRecipients = new List <String>{userMap.get(oneOwn).Email};
                    
                    smplEmail.setToAddresses(emailRecipients);
                smplEmail.setSubject('Revert on Sample');
                smplEmail.setReplyTo(emailRecipients[0]);
                
                String emailBody = 'Dear ' + userMap.get(oneOwn).FirstName + ',';
                emailBody += ' <br> <br> Tomorrow is the revert sample date. Please look into the following record.<br><br>';
                
                List <Project__c> relatedOwnerRec = smplOwnerMap.get(oneOwn);
                
                for (Integer i = 0; i < relatedOwnerRec.size(); i++) {
                    emailBody += ' <a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+relatedOwnerRec[i].Id+'">'+ relatedOwnerRec[i].Sample_Name__c +'</a><br>' ;    
                }
                
                emailBody += '<br> Thanks and Regards';
                emailBody += '<br> Symega Foods';
                smplEmail.setHtmlBody(emailBody);
                allEmailMessages.add(smplEmail);
            } 
            if(!allEmailMessages.isEmpty()) {
                Messaging.sendEmail(allEmailMessages);     
                Update smplListToBeUpdated;
            }    
        }
        catch(Exception e){
            System.debug('---> Message: '+e.getMessage());
            System.debug('---> Line No: '+e.getLineNumber());
            HandleBusinessException.captureError('SampleRevertDateNotificationBatch', 'execute', e);
        }
    }
    
    public void Finish(Database.BatchableContext bc){
        System.debug('The Batch Run Successfully');
    }
    
}