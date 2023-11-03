public class ShowAndUpdateProjectQuotients {
    @AuraEnabled
    public static List<Project_Quotient__c> showProjectQuotientRec(string proRecId){
        List<Project_Quotient__c> prolist;
        if(proRecId != null){
            prolist   = [Select Id, Name, Stage__c, Lost_Reason__c from Project_Quotient__c where Sample_Project_Application__c =: proRecId];
            if(prolist.size()>0){
                return prolist;
            }  
            
        }
        return null;
    }
    @AuraEnabled
    public static List<String> getStagePicklistValues() {
        Schema.DescribeFieldResult fieldResult = Project_Quotient__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<String> StageValues = new List<String>();
        
        for (Schema.PicklistEntry entry : picklistValues) {
            StageValues.add(entry.getValue());
        }
        
        return StageValues;
    }
    
    @AuraEnabled
    public static string updateProjectQuotientValues( List<Project_Quotient__c> projectlist){
        try{
            update projectlist;
            return 'success';
        }
        catch(exception e){
            system.debug('Error Msg :: ' + e.getMessage());
            system.debug('Error Line No :: ' + e.getLineNumber());
            return e.getMessage();
        }
    }
    
     @AuraEnabled
    public static List<String> getSampleStatusPicklistValues() {
        Schema.DescribeFieldResult fieldResult = Sample_Line_Item__c.Sample_Request_Status__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<String> StageValues = new List<String>();
        
        for (Schema.PicklistEntry entry : picklistValues) {
            StageValues.add(entry.getValue());
        }
        
        return StageValues;
    }
     @AuraEnabled
    public static List<Sample_Line_Item__c> showSamplelineRec(string proRecId){
        List<Sample_Line_Item__c> samplelist;
        if(proRecId != null){
            samplelist   = [Select id, Product_Name__c,Sample_Request_Status__c  from Sample_Line_Item__c where Sample__c =: proRecId];
            if(samplelist.size()>0){
                return samplelist;
            }  
            
        }
        return null;
    }
    @AuraEnabled
    public static string updateSamplelineItemValues( List<Sample_Line_Item__c> samplelineIemlist){
        try{
            update samplelineIemlist;
            return 'success';
        }
        catch(exception e){
            system.debug('Error Msg :: ' + e.getMessage());
            system.debug('Error Line No :: ' + e.getLineNumber());
            return e.getMessage();
        }
    }
}