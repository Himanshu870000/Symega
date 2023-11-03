public without sharing class DistributorInternalUtility {
    
    static final String DISTRIBUTOR_STATUS_DOCUMENT_SUBMISSION = 'Document Submission';

    @AuraEnabled
    public static void sendResetPasswordEmail(Id distributorId){
        try {
            Account candidate = new Account(id=distributorId, Login_Hash_Code__c=Utility.generateRandomString(), Status__c = DISTRIBUTOR_STATUS_DOCUMENT_SUBMISSION);
            update candidate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}