public with sharing class AccountHandler {
    public AccountHandler() {}

    @AuraEnabled
    public static List<Account> getRecord(String accId){
        try {
            System.debug('OppId'+accId);
            return [Select Id, Name from Account where Id=:accId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}