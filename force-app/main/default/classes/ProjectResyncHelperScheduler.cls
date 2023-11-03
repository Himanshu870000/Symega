/**
 * Author: Bhaskar
 */
global without sharing class ProjectResyncHelperScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        
        Map<Id,Project__c> checkIfPendingProjectToSMap = new Map<Id,Project__c>([SELECT Id FROM Project__c WHERE Submit_Sample_To_Optiva__c = true AND Error_Occured_On_Submitting_To_Optiva__c = true]);

        if(!checkIfPendingProjectToSMap.isEmpty())
            Database.executeBatch(new AutoSyncBatchSampleToOptiva(checkIfPendingProjectToSMap.keySet()),1);
        
    }
}