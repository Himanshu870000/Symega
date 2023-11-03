/*
* Author: Anjali Singh
*/
public class SAP_PIRController {
    
    public List<PIR__c> selected {get;set;}
    public List<PIR__c> pirToSendToSAP {get;set;}
    public List<Account> selectedAccs {get;set;}
    public boolean noIds{get;set;}
    List<String> pirIdListToSendToSAP = new List<String>();
    List<Id> allPirIdList = new List<Id>();
    List<Id> accIdList = new List<Id>();
    List<Id> successAccIdList = new List<Id>();
    
    public SAP_PIRController(ApexPages.StandardSetController controller) {
        noIds = false;
        selected = (PIR__c[])controller.getSelected();
        if(selected.size() == 0){
            noIds = true;
        }
        
        for(PIR__c pItem : selected) {
            allPirIdList.add(pItem.id);
        } 
        
        List<PIR__c> pirList = [SELECT Id, Customer_Code__c, Customer_Name__c, Submit_To_SAP__c, Synced_to_SAP__c FROM PIR__c WHERE Id IN: allPirIdList];
        
        for(PIR__c pItem : pirList) {
            accIdList.add(pItem.Customer_Name__c);
        }    
        
        List<Account> accList = [SELECT Id, Name, Missing_Fields__c, Customer_Code_SAP__c, Customer_Type__c, BillingCountry, BillingPostalCode, BillingState, Delivery_Plant__c, Account_Segment__c, Transportation_Terms__c, PAN_Number__c, GST_number__c 
                                 FROM Account WHERE Id =: accIdList];
        
        selectedAccs = new list<Account>();
        for(Account acc : accList){
            String customerValidationRes = Utility.sapAccountMFieldsCheck(acc);
            system.debug('customerValidationRes -- ' + customerValidationRes);
            if(!String.isEmpty(acc.Customer_Code_SAP__c)){
                successAccIdList.add(acc.Id);
            }
            if(String.isEmpty(acc.Customer_Code_SAP__c) && customerValidationRes != 'Success'){
                acc.Missing_Fields__c = customerValidationRes;
                selectedAccs.add(acc);
            }
        }
                
        pirToSendToSAP = new list<PIR__c>();
        List<PIR__c> pirListToSendToSAP = [SELECT Id, Name, Product__c, Product_Code_HALB__c, Customer_Code__c, Customer_Name__c, Submit_To_SAP__c, Synced_to_SAP__c FROM PIR__c WHERE Customer_Name__c IN: successAccIdList AND Id IN: allPirIdList];
        for(PIR__c pir : pirListToSendToSAP){
            pirToSendToSAP.add(pir);
            pirIdListToSendToSAP.add(pir.Id);
        }
        
    }
    
    public Pagereference updatePIR(){
        String response = SAP_UpdatePIRCallout.updatePIR(pirIdListToSendToSAP);
        system.debug('response ' + response);
        if(!String.isBlank(response) && response.equalsIgnoreCase('Success')) {
            for(PIR__c pItem : pirToSendToSAP) {
                pItem.Synced_to_SAP__c = true;
                if(String.isEmpty(pItem.Customer_Name__r.Customer_Code_SAP__c)){
                    pItem.Submit_To_SAP__c = TRUE;
                }
                else{
                    pItem.Submit_To_SAP__c = FALSE;
                }
            }
            update selected;
        }
        return new ApexPages.Action('{!List}').invoke();
    }
}