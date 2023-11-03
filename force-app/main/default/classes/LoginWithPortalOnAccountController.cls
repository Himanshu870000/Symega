public without sharing class LoginWithPortalOnAccountController {
    
    @AuraEnabled
    public static string hashcodeCreationUpdation(String accId){
        try {
            Account acc = new Account(Id=accId,Login_Hash_Code__c=Utility.generateRandomString());
            update acc;
            return acc.Login_Hash_Code__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean pendingDocuments(String accId){
        try {
            List<User_Document__c> docList = [Select Id,Status__c,Name From User_Document__c Where Account__c=:accId];
            for(User_Document__c doc : docList){
                if(doc.Status__c=='Pending' && doc.Name!='Profile Picture'){
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}