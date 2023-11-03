Global class BatchClassForOpportunityOwner implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id, Name, CloseDate, StageName, OwnerId FROM Opportunity Where CloseDate = Today and StageName != 'Closed Won' and StageName != 'Closed Lost' and RecordType.name = 'Parent']); 
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> OppList){   
        System.debug('OppList---->'+OppList);
        Map<Id,List<Opportunity>> oppMapList = new Map<ID,List<Opportunity>>();
        List<Task> tskList = new list<Task>();
        for(Opportunity oppRec: OppList){
            oppRec.Remainder_Sent_Date__c = System.today();
            if(!oppMapList.containsKey(oppRec.OwnerId)){
                oppMapList.put(oppRec.OwnerId,new List<Opportunity>{oppRec});
            }
            else{
                oppMapList.get(oppRec.OwnerId).add(oppRec);
            }
            
            Task taskRec = new Task();
            taskRec.Subject = 'Close the opportunity, if potential';
            taskRec.OwnerId =  oppRec.OwnerId;
            taskRec.ActivityDate = System.today().addDays(10); 
            taskRec.Status = 'Open';
            taskRec.WhatId = oppRec.Id;
            tskList.add(taskRec);
        }
        insert tskList;
        Update OppList;
        sendEmailToOwnersAccount(oppMapList);
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('Sending Email Message to opportunity Owner');   
    } 
    
    public static void sendEmailToOwnersAccount(Map<Id,List<Opportunity>> oppMapList){
        
        Map<ID, User> userMap = new Map<ID, User>([SELECT ID,LastName,FirstName,Email FROM User]);
        List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>(); 
        
        for(ID keyS: oppMapList.keySet()){            
            Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
            mymail.setToAddresses(new string[]  {userMap.get(keyS).Email} );  
            mymail.setSenderDisplayName('Excelr');
            mymail.setSubject('Close opportunities, if potential');
            mymail.setSaveAsActivity(false);
            
            String emailBody = 'Hi ' + userMap.get(keyS).FirstName + ',';
            emailBody += ' <br> <br> The Following Opportunities close date is Today. Please change the date if they are potential.<br>';
            List<Opportunity> relatedOwnerRec = oppMapList.get(keyS);            
            for (Integer i = 0; i < relatedOwnerRec.size(); i++) {
                emailBody += ' <br><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+relatedOwnerRec[i].Id+'">'+ relatedOwnerRec[i].Name +'</a><br>' ;    
            }
            
            emailBody += '<br> Thanks and Regards';
            emailBody += '<br> Symega Foods';
            mymail.setHtmlBody(emailBody);
            //mymail.setPlainTextBody('Hello '+userMap.get(keyS).LastName +',' +'\n'+'\n' + 'The Following Opportunities close date is Today. Please change the date if they are potential.'+oppNames+'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
            semList.add(mymail);
        }
        Messaging.sendEmail(semList);
    } 
    
}