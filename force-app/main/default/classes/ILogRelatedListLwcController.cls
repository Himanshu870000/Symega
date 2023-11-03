public with sharing class ILogRelatedListLwcController
 {
    
    @AuraEnabled(Cacheable = true)
    public static  List<LoggerWrapper>  passRecordId(Id recId)
    {

       List<LoggerWrapper> loggersList = new List<LoggerWrapper>();

       List<Integration_Log__c> intRecs = [Select Id,Name,EndPoint__c,HTTP_Method__c,Integration_Type__c,Processing_Time_in_MilliSeconds__c,Reference_Id__c,Request_Body__c,Response_Body__c,Response_Status_Code__c,CreatedDate From Integration_Log__c Where Reference_Id__c =: recId];
      
         for(Integration_Log__c log : intRecs){
            LoggerWrapper wrapper = new LoggerWrapper();
            wrapper.id = log.Id;
            wrapper.name = log.Name;
            wrapper.endPoint = log.EndPoint__c;
            wrapper.methodType= log.HTTP_Method__c;
            wrapper.integrationType = log.Integration_Type__c;
            wrapper.processingTimeInMilliseconds = log.Processing_Time_in_MilliSeconds__c;
            wrapper.referenceId = log.Reference_Id__c;
            wrapper.requestBody = log.Request_Body__c;
            wrapper.responseBody = log.Response_Body__c;
            wrapper.responseStatusCode = log.Response_Status_Code__c;
            wrapper.createdDate = log.createdDate;
            wrapper.nameUrl = '/'+log.Id;

            loggersList.add(wrapper);
         }
           system.System.debug('wrapperrrrr Data'+loggersList);
       return loggersList;
    }

   public class LoggerWrapper
   {
      @AuraEnabled
      public String id; 
      @AuraEnabled
      public String name;
      @AuraEnabled
      public String endPoint;
      @AuraEnabled
      public String methodType;
      @AuraEnabled
      public String integrationType;
      @AuraEnabled
      public Decimal processingTimeInMilliseconds;  //Decimal
      @AuraEnabled
      public String referenceId;
      @AuraEnabled
      public String requestBody;
      @AuraEnabled
      public String responseBody;
      @AuraEnabled
      public Decimal  responseStatusCode; //Decimal
      @AuraEnabled
      public DateTime createdDate; //DateTime
      @AuraEnabled
      public String nameUrl;
      
   }


}