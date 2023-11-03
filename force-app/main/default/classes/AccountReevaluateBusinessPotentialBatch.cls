/**
 * Author: Deagle
 */
public without sharing class AccountReevaluateBusinessPotentialBatch implements Database.Batchable<SObject> {
    String followupQuery;
    public AccountReevaluateBusinessPotentialBatch() {
        this.followupQuery = 'SELECT Id, Name, Email__c, OwnerId FROM Account WHERE CreatedDate > LAST_90_DAYS';
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(followupQuery);
    }

    public void execute(Database.BatchableContext BC, List<Account> followupAccountList){
        System.debug('--- accList'+followupAccountList);
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        Symega_Configuration__c orgConfig = Symega_Configuration__c.getAll()?.get('Symega Configuration');
        List<String> marketingUsersEmailIdList = new List<String>();
        if(orgConfig != null && !String.isBlank(orgConfig.Lead_Approval_Marketing_Head_Group_Name__c)) {
            for(Group_Member__c gm : [SELECT Id,User__r.Email FROM Group_Member__c WHERE Assignment_Approval_Group__r.Name = :orgConfig.Lead_Approval_Marketing_Head_Group_Name__c AND Active__c = true AND User__r.Email != null]) {
                marketingUsersEmailIdList.add(gm.User__r.Email);
            }
        }
        System.debug('--- marketingUsersEmailIdList '+marketingUsersEmailIdList);
        List<Task> followupTaskList = new List<Task>();
        Task followupTask;
        for(Account acc : followupAccountList){
            followupTask = new Task();
            followupTask.WhatId = acc.Id;
            followupTask.Status = 'Open';
            followupTask.Type = 'Call';
            followupTask.Priority = 'High';
            followupTask.ActivityDate = System.today();
            followupTask.Subject = 'Re-evaluate business: ' + acc.Name;
            followupTask.OwnerId = acc.OwnerId;
            followupTaskList.add(followupTask);
            
            //Email notification.
            if(!marketingUsersEmailIdList.isEmpty()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(marketingUsersEmailIdList);
                email.setSubject('Followup:Re-Evaluate Business Potential');
                email.setHtmlBody('Hello Marketing Team, <br/><br/>This email is to notify you that the following account needs re-evaluation. <br/> Account Name: '+acc.Name+'<br/>Account Email: '+acc.Email__c);
                email.setPlainTextBody('Hello Marketing Team, \n This email is to notify you that the following account needs re-evaluation. Account Name: '+acc.Name+'\nAccount Email: '+acc.Email__c);
                emailsList.add(email);
            }
        }
        System.debug('--- followupTaskList'+followupTaskList);
        if(!followupTaskList.isEmpty()) {
            try {
                insert followupTaskList;
            }catch(Exception e){
                System.debug('---> Message: '+e.getMessage());
                System.debug('---> Line No: '+e.getLineNumber());
                HandleBusinessException.captureError('AccountReevaluateBusinessPotentialBatch', 'BATCH:Execute', e);
            }

        }
        if(!emailsList.isEmpty()) {
            try {
                Messaging.sendEmail(emailsList);
            }catch(exception e) {
                System.debug('---> Message: '+e.getMessage());
                System.debug('---> Line No: '+e.getLineNumber());
                HandleBusinessException.captureError('AccountReevaluateBusinessPotentialBatch', 'BATCH:Execute', e);
            }
        }
        
        
    }

   public void finish(Database.BatchableContext BC) {
   }
}