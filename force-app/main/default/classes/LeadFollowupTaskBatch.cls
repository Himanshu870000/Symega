/**
 * Author: DeaGle
 */
public without sharing class LeadFollowupTaskBatch implements Database.Batchable<sObject> {
    
    String followupQuery;
    public LeadFollowupTaskBatch() {
        this.followupQuery = 'SELECT Id, Name, OwnerId, Next_Followup_Date__c FROM Lead WHERE Next_Followup_Date__c = TODAY';
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(followupQuery);
    }

    public void execute(Database.BatchableContext BC, List<Lead> followupLeadList){
        List<Task> followupTaskList = new List<Task>();
        Task followupTask;
        for(Lead lRec : followupLeadList){
            followupTask = new Task();
            followupTask.WhoId = lRec.Id;
            followupTask.Status = 'Open';
            followupTask.Type = 'Call';
            followupTask.Priority = 'High';
            followupTask.ActivityDate = lRec.Next_Followup_Date__c != null ? lRec.Next_Followup_Date__c : System.today();
            followupTask.Subject = 'Follow up with ' + lRec.Name;
            followupTask.OwnerId = lRec.OwnerId;
            followupTaskList.add(followupTask);
        }
        if(!followupTaskList.isEmpty()) {
            try {
                insert followupTaskList;
            }catch(Exception e){
                HandleBusinessException.captureError('LeadFollowupTaskBatch', 'BATCH:Execute', e);
            }

        }
    }

   public void finish(Database.BatchableContext BC) {
   }
}