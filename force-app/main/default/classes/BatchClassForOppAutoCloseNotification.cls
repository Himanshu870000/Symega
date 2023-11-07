global class BatchClassForOppAutoCloseNotification implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id, Name, CloseDate, StageName,Remainder_Sent_Date__c,OwnerId,CreatedDate,AccountId,Account.Name FROM Opportunity Where Remainder_Sent_Date__c != null and StageName !='Closed Lost' and StageName !='Closed Won' and RecordType.name = 'Parent']); 
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> OppList){   
        System.debug('OppList---->'+OppList);
        Map<Id,List<Opportunity>> oppMapList = new Map<ID,List<Opportunity>>();
        Boolean sendNotification = false;
        
        for(Opportunity oppRec: OppList){
            Date d = oppRec.Remainder_Sent_Date__c.addDays(5);
            if(d == System.today()){
                sendNotification = true;
                if(!oppMapList.containsKey(oppRec.OwnerId)){
                    oppMapList.put(oppRec.OwnerId,new List<Opportunity>{oppRec});
                }
                else{
                    oppMapList.get(oppRec.OwnerId).add(oppRec);
                }
            }
        }
        
        if(sendNotification)
            sendEmailToOwnersAccount(oppMapList);
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('Sending Email Message to opportunity Owner');   
    } 


     public static void sendEmailToOwnersAccount(Map<Id,List<Opportunity>> oppMapList){

        try{
            Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>([SELECT ID,Name,AccountId,Account.Name,CloseDate,CreatedDate FROM Opportunity]);

        Map<ID, User> userMap = new Map<ID, User>([SELECT ID,LastName,FirstName,Email FROM User]);
        List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>(); 
        
        for(ID keyS: oppMapList.keySet()){            
            Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
            mymail.setToAddresses(new string[]  {userMap.get(keyS).Email} );  
            mymail.setSenderDisplayName('Excelr'); 
            mymail.setSubject('Opportunity closure date lapse');
            mymail.setSaveAsActivity(false);
            
            String emailBody = 'Hi ' + userMap.get(keyS).FirstName + ',';
             emailBody += ' <br> <br>We observe that below Opportunities Close Date is lapsed and are not updated post our last notification.';
           List<Opportunity> relatedOwnerRec = oppMapList.get(keyS);
            emailBody += '<br><br> <table border="2" style="border-collapse: collapse"><tr><th>Opportunity Name</th><th>Created Date</th><th>Proposed Closed Date</th><th>Account Name</th></tr>';  // <td>' + gdResult + '</td><td>' + piResult + '</td></tr>';
            for(opportunity oppRec:relatedOwnerRec){
                 String oppName = ' <br><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+oppRec.Id+'">'+ oppRec.Name +'</a><br>' ;  
                  emailBody += '<tr><td Style="padding-left: 10px;  padding-bottom: 20px;">' + oppName  + '</td><td Style="padding-left: 10px;">' + oppRec.CreatedDate + '</td><td Style="padding-left: 10px;">' + oppRec.CloseDate + '</td><td Style="padding-left: 10px;">' +  oppRec.Account.Name + '</td></tr>'; 

            }
            
            emailBody += '</table>';
            emailBody += ' <br> <br> Please re-visit the opportunity and update the opportunity close date, if this is still active, Else we will auto close this opportunity on <calculated date 10 days from opportunity close date';
            emailBody += ' <br> <br> Note : If this opportunity is not active update stage as  Closed lost.';
            emailBody += '<br> <br>  Regards';
            emailBody += '<br> Symega';
            
            mymail.setHtmlBody(emailBody);
            semList.add(mymail);
        }
        Messaging.sendEmail(semList);

        }catch(Exception e){
             System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());

        }
        
         
    } 
    
    // public static void sendEmailToOwnersAccount(Map<Id,List<Opportunity>> oppMapList){
        
    //     Map<ID, User> userMap = new Map<ID, User>([SELECT ID,LastName,FirstName,Email FROM User]);

    //     List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>(); 
        
    //     for(ID keyS: oppMapList.keySet()){            
    //         Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
    //         mymail.setToAddresses(new string[]  {userMap.get(keyS).Email} );  
    //         mymail.setSenderDisplayName('Excelr');
    //         mymail.setSubject('Opportunity closure date lapse');
    //         mymail.setSaveAsActivity(false);
            
    //         String emailBody = 'Hi ' + userMap.get(keyS).FirstName + ',';
    //        // emailBody += ' <br> <br> The Following Opportunities will be auto closed by the system, if not actioned within 5 days.<br>';
    //           emailBody += ' <br> <br> we observe that below opps are lapsed and are not updated post our last notification.';
            
    //         List<Opportunity> relatedOwnerRec = oppMapList.get(keyS);   
              
    //           emailBody += '<br><br> <table border="2" style="border-collapse: collapse"><tr><th>Opportunity Name</th><th>Created Date</th><th>Closed Date</th><th>Account Name</th></tr>';  

    //           for(opportunity oppRec:relatedOwnerRec){
    //              String oppName = ' <br><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+oppRec.Id+'">'+ oppRec.Name +'</a><br>' ;  
    //               emailBody += '<tr><td Style="padding-left: 10px;  padding-bottom: 10px;">' + oppName  + '</td><td Style="padding-left: 10px;">' + oppRec.CreatedDate + '</td><td Style="padding-left: 10px;">' + oppRec.CloseDate + '</td><td Style="padding-left: 10px;">' +  oppRec.Account.Name + '</td></tr>'; 

    //         }       
            
    //         // for (Integer i = 0; i < relatedOwnerRec.size(); i++) {
    //         //     emailBody += ' <br><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+relatedOwnerRec[i].Id+'">'+ relatedOwnerRec[i].Name +'</a><br>' ;    
    //         // }

    //          emailBody += '</table>';
    //         emailBody += ' <br> <br> Please re-visit the opportunity and update the opportunity close date, if this is still active. .';
    //         emailBody += ' <br> <br> Note : If this opportunity is not active update stage as  Closed lost.';
    //         emailBody += '<br> <br>  Regards';
    //         emailBody += '<br> Symega';
            
    //         // emailBody += '<br> Thanks and Regards';
    //         // emailBody += '<br> Symega Foods';
    //         mymail.setHtmlBody(emailBody);
    //         //mymail.setPlainTextBody('Hello '+userMap.get(keyS).LastName +',' +'\n'+'\n' + 'The Following Opportunities close date is Today. Please change the date if they are potential.'+oppNames+'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
    //         semList.add(mymail);
    //     }
    //     Messaging.sendEmail(semList);
    // } 
    
}