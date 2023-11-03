/*
 *    Author: Anjali Singh
 */

Public class DeleteExceptionBatch Implements Database.batchable<sobject>{
     public Date deleteTo;
     public DeleteExceptionBatch (Integer Year, Integer Month, Integer myDate){
          deleteTo=date.newinstance(Year, Month, myDate);
     }
   
     public Database.QueryLocator Start(Database.BatchableContext bc){    
        system.debug('Date::'+deleteTo );
        return Database.getQueryLocator('SELECT Id, CreatedDate FROM Exceptions__c WHERE CreatedDate <: deleteTo');
    }
     public  void execute(Database.BatchableContext BC, List<Exceptions__c> excpetionListToBeDeleted){
         system.debug('ExcpetionListToBeDeleted:: '+excpetionListToBeDeleted);
         try{
             if(!excpetionListToBeDeleted.isEmpty()){
                 delete excpetionListToBeDeleted;
             }
         }
         catch(Exception e){
             system.debug('Error>> '+e.getMessage() + 'at Line Number>> ' + e.getLineNumber());
         }
    }
    
    public void finish(Database.BatchableContext BC){
    }

 }