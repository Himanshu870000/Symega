Global class BatchClassForOpportunityOwner implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id, Name, CloseDate, StageName, OwnerId,CreatedDate,AccountId,Account.Name FROM Opportunity Where AccountId != null and CloseDate = YESTERDAY and StageName != 'Closed Won' and StageName != 'Closed Lost' and RecordType.name = 'Parent']); 
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> OppList){   
        try{

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
                taskRec.ActivityDate = System.today().addDays(5); 
                taskRec.Status = 'Open';
                taskRec.WhatId = oppRec.Id;
                tskList.add(taskRec);
            }
            insert tskList;
            Update OppList;
            sendEmailToOwnersAccount(oppMapList);

        }catch(Exception e){
            System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
        }
        
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
           // mymail.setSubject('Close opportunities, if potential');
            
            //added 51,52,56,57,58,67,68  lines BY GC
            // if (oppMap !=null){
            //     if( oppMap.get(keyS).Name != null &&  oppMap.get(keyS).Account.Name != null && oppMap.get(keyS).Name != null){
            //       mymail.setSubject('Opportunity closure date lapse' + oppMap.get(keyS).Name +  oppMap.get(keyS).Account.Name);
            // }else{
            //        mymail.setSubject('Opportunity closure date lapse');
            // }

            // }
            
             mymail.setSubject('Opportunity closure date lapse');
            mymail.setSaveAsActivity(false);
            
            String emailBody = 'Hi ' + userMap.get(keyS).FirstName + ',';
              emailBody += ' <br> <br> We observe that below Opportunities close date is lapsed.<br> <br>';
           // emailBody += ' <br> <br> The Following Opportunities close date is Today. Please change the date if they are potential.<br>';
            // emailBody += ' <br> <br> The proposed closure date for opportunity created on'+oppMap.get(keyS).CreatedDate + 'for' + oppMap.get(keyS).Account.Name + 'with' + oppMap.get(keyS).Name + 'is' +oppMap.get(keyS).CloseDate + ' we observe that is lapsed.<br>';
            // emailBody += ' <br> <br> Please re-visit the opportunity and update the opportunity close date, if this is still active. .';
            // emailBody += ' <br> <br> Note : If this opportunity is not active update stage as  Closed lost.';

            List<Opportunity> relatedOwnerRec = oppMapList.get(keyS);
            emailBody += '<br><br> <table border="2" style="border-collapse: collapse"><tr><th>Opportunity Name</th><th>Created Date</th><th>Proposed Closed Date</th><th>Account Name</th></tr>';  // <td>' + gdResult + '</td><td>' + piResult + '</td></tr>';
            for(opportunity oppRec:relatedOwnerRec){
                 String oppName = ' <br><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+oppRec.Id+'">'+ oppRec.Name +'</a><br>' ;  
                  emailBody += '<tr><td Style="padding-left: 10px;  padding-bottom: 10px;">' + oppName  + '</td><td Style="padding-left: 10px;">' + oppRec.CreatedDate + '</td><td Style="padding-left: 10px;">' + oppRec.CloseDate + '</td><td Style="padding-left: 10px;">' +  oppRec.Account.Name + '</td></tr>'; 

            }
            // for (Integer i = 0; i < relatedOwnerRec.size(); i++) {
            //    //oppMap.get(keyS).Name
            //     String oppName = ' <br><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+relatedOwnerRec[i].Id+'">'+ relatedOwnerRec[i].Name +'</a><br>' ;  
            //      emailBody += '<tr><td>' + oppName  + '</td><td>' + oppMap.get(keyS).CreatedDate + '</td><td>' + oppMap.get(keyS).CloseDate + '</td><td>' +  oppMap.get(keyS).Account.Name + '</td></tr>';    //<td>' + passingYear + '</td><td>' + aptiMarks + '</td><td>' + aptiResult + '</td></tr>' ;
            //    // emailBody += ' <br><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+relatedOwnerRec[i].Id+'">'+ relatedOwnerRec[i].Name +'</a><br>' ;    
            // }
            emailBody += '</table>';
            emailBody += ' <br> <br> Please re-visit the opportunity and update the opportunity close date, if this is still active. .';
            emailBody += ' <br> <br> Note : If this opportunity is not active update stage as  Closed lost.';
            emailBody += '<br> <br>  Regards';
            emailBody += '<br> Symega';
            // emailBody += '<br> Thanks and Regards';
           // emailBody += '<br> Symega Foods';
            mymail.setHtmlBody(emailBody);
            //mymail.setPlainTextBody('Hello '+userMap.get(keyS).LastName +',' +'\n'+'\n' + 'The Following Opportunities close date is Today. Please change the date if they are potential.'+oppNames+'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
            semList.add(mymail);
        }
        Messaging.sendEmail(semList);

        }catch(Exception e){
             System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());

        }
        
         
    } 
    
}