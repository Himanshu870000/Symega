public class PIRStdController {
    /*public List<PIR__c> pirList{get;private set;}
    public PIRStdController(ApexPages.StandardSetController stdSetController){
        pirList = (List<PIR__c>) stdSetController.getSelected();
    }
    
    public PageReference save(){
        try{
         update pirList;
        } catch(Exception e){
            System.debug('Exception: ' + e);
        }
        return null;
    }*/
    
    public PIRStdController(ApexPages.StandardSetController controller) {
        controller.setPageSize(10);
    }

}