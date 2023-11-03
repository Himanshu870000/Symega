global class BatchCommentsDelete implements Database.Batchable<SObject> {
    //constructor
    global BatchCommentsDelete(){
        
    }
    
    //start Method
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        List<Symega_Configuration__c> syConfig = Symega_Configuration__c.getAll().values();
        Integer noOfDays = integer.valueOf(syConfig[0].Delete_Comment_Before__c);
        
        string dateCondtion = 'LAST_N_DAYS:' + noOfDays;
        system.debug('dateCondtion::::'+dateCondtion);
        
        string query = 'select id,name from Comment__c Where CreatedDate < '+ dateCondtion +' LIMIT 1';
        return Database.getQueryLocator(query);  
    }
    
    //execute Method
    global void execute(Database.BatchableContext bc,List<Comment__c> scope){
        system.debug('SCOPE -- ' + scope);
        if(scope.size() > 0)
            delete scope;
    }
    
    //finish Method
    global void finish(Database.BatchableContext bc){
        
        
    }
}