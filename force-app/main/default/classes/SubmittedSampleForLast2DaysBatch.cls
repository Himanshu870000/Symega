public class SubmittedSampleForLast2DaysBatch implements Database.Batchable <Sobject>{
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        return Database.getQueryLocator( 'SELECT Id, Name, Account__c, Lead__c, Account__r.Owner.Email, Lead__r.Owner.Email, Account__r.Owner.Name, Lead__r.Owner.Name FROM Project__c WHERE ' + 
                                        'Id IN (SELECT Sample__c FROM Sample_History__c WHERE Modified_Date__c = TODAY AND Sample_Status_Value__c = \'Submitted for Sampling\' ) ' );
    }
    
    public void Execute(Database.BatchableContext bc, List<Project__c> sampleList){
        try{  
            if(sampleList.size()>0){
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                List<String> recipients = new List<String>();
                system.debug('sampleList::'+sampleList);
                
                for(Project__c prj : sampleList){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    string accLeadOwnerName;
                    
                    if( ( !string.isEmpty(prj.Account__c) && !string.isEmpty(prj.Lead__c) ) || ( !string.isEmpty(prj.Account__c) && string.isEmpty(prj.Lead__c) )  ){
                        recipients.add(prj.Account__r.Owner.Email);
                        accLeadOwnerName = prj.Account__r.Owner.Name;
                    }
                    else if (!string.isEmpty(prj.Lead__r.Email) ){
                        recipients.add(prj.Lead__r.Owner.Email);
                        accLeadOwnerName = prj.Lead__r.Owner.Name;
                    }
                    
                    String emailBody = 'Dear ' + accLeadOwnerName + ',';
                    emailBody += ' <br> <br> No activity on the following sample is found. ';
                    emailBody += ' Click here : <br>';
                    emailBody += ' <a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+prj.Id+'">'+ prj.Name +'</a><br>' ;
                    emailBody += ' <br> Thanks and Regards,' ;
                    emailBody += ' <br> Symega Foods' ;
                    
                    mail.setToAddresses(recipients);
                    mail.setReplyTo(UserInfo.getUserEmail());
                    mail.setSenderDisplayName('Symega Foods');
                    mail.setHtmlBody(emailBody);
                    mails.add(mail);
                }
                System.debug('Mails----'+mails);
                if(!mails.isEmpty()){
                    system.debug('Sending Email');
                    Messaging.sendEmail(mails);
                }
            }
        }
        catch(Exception e){
            HandleBusinessException.captureError('SubmittedSampleForLast2DaysBatch', 'Execute', e);
        }
    }
    
    public void Finish(Database.BatchableContext bc){
        System.debug('The Batch Run Successfully');
    }
}