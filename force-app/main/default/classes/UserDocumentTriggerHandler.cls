/**
 * Author : DeaGle
 */

public without sharing class UserDocumentTriggerHandler {
    
    static UserDocumentTriggerHandler handlerInstance;
    private UserDocumentTriggerHandler() {}

    public static UserDocumentTriggerHandler getInstance() {
        if(handlerInstance == null)
            handlerInstance = new UserDocumentTriggerHandler();
        return handlerInstance;
    }


    public void onBeforeUpdate(List<User_Document__c> userDocumentList) {
        Set<Id> userDocIdSet = new Set<Id>();
        Set<Id> distributerIdSet = new Set<Id>();
        for(User_Document__c userDoc: userDocumentList) {
            if(userDoc.Required__c && userDoc.Required__c && userDoc.Account__c != null) {
                userDocIdSet.add(userDoc.Id);
                distributerIdSet.add(userDoc.Account__c);
            }
        }

        if(!distributerIdSet.isEmpty()) {
            validateDocumentApproval(userDocIdSet, distributerIdSet);
        }
    }

    private void validateDocumentApproval(Set<Id> userDocIdSet, Set<Id> distributerIdSet) {
        List<User_Document__c> distributorDocsList = [SELECT Id, Account__c FROM User_Document__c WHERE Id NOT IN :userDocIdSet AND Account__c IN :distributerIdSet AND Status__c IN ('Pending', 'Rejected', 'Uploaded') AND Required__c = true AND Account__r.Status__c = 'Document Submission' AND Account__r.RecordType.Name = 'Distributor'];
        Map<Id, Account> currentDistributorMap = new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN :distributerIdSet AND RecordType.Name = 'Distributor' AND Status__c = 'Document Submission']);
        if(!currentDistributorMap.isEmpty()) {
            for(User_Document__c uDoc: distributorDocsList) {
                currentDistributorMap.remove(uDoc.Account__c);
            }
            List<Account> distributorsToActivate = new List<Account>();
            if(!currentDistributorMap.isEmpty()) {
                for(Id candidateId : currentDistributorMap.keySet()) {
                    distributorsToActivate.add(new Account(Id = candidateId, Status__c = 'Active'));
                }
    
                if(!distributorsToActivate.isEmpty()) {
                    try{
                        update distributorsToActivate;
                    }catch(DmlException ex) {
                        HandleBusinessException.captureError('UserDocumentTriggerHandler', 'validateDocumentApproval', ex);
                    }
                }
            }
        }


    }
}