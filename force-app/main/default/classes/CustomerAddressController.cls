public without sharing class CustomerAddressController {

    @AuraEnabled
    public static Dispatch_Address__c getCustomerRecord(String dipRecId){
       
       Dispatch_Address__c dispAdd;
        try{
            dispAdd = [SELECT ID,Contact__c FROM Dispatch_Address__c WHERE ID =:dipRecId];

       
        }catch(Exception e){
            System.debug('Exception Line Number--->'+e.getLineNumber());
            System.debug('Exception Message--->'+e.getMessage());
        }
         return dispAdd ;
    }

}