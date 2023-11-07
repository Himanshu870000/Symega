/*
* Author: Anjali Singh
*/
public class SAP_UpdatePIRCallout {
    
    public static String updatePIR(List<String> recIds){
        
        Set<Id> setOfAccId = new Set<Id>();
        List<PIR__c> pirWithoutSAPCODE = new List<PIR__c>();
        List<PIR__c> pirListWithCustomerSAPCODE = new List<PIR__c>();
        List<PIR__c> pirList = getPIRList(recIds);
        
        for(PIR__c pir : pirList){
            if(String.isBlank(pir.Customer_Name__r.Customer_Code_SAP__c) && !pir.Customer_Name__r.Submitted_to_SAP__c){
                setOfAccId.add(pir.Customer_Name__c);
                pirWithoutSAPCODE.add(pir);
            }else{
                pirListWithCustomerSAPCODE.add(pir);
            }
        }
        
        if(pirListWithCustomerSAPCODE.isEmpty() && !setOfAccId.isEmpty()){
            System.debug('Calling batch');
            Database.executeBatch(new SAP_Create_CustomerBatch(setOfAccId));
            updatePIRToPending(pirWithoutSAPCODE);
            return 'Customer code submitted';
        }else{
            if(!setOfAccId.isEmpty()){
                Database.executeBatch(new SAP_Create_CustomerBatch(setOfAccId));
            }
            return updatePIRCallout(pirListWithCustomerSAPCODE);
        }
    }
    
    public static String updatePIRCallout(List<PIR__c> pirList){
        String endpoint = 'callout:SAP'+System.Label.SAP_PR_TOKEN;
        Map<String,String> tokenMap = SAPRequestTokenHeader.getInstance().getCSRFToken(System.Label.SAP_PR_TOKEN, Constants.SAP_PIR_AUTH_HEADER);//'VwjYxecZl9_yUv2pLtoLHA==';
        String cookies = tokenMap.get('cookies');//'SAP_SESSIONID_SMD_200=21m-9n9qrNMY4XJn-zCnZIt2ArVljhHtrSkADTo-F08%3d; sap-usercontext=sap-client=200';
        String token = tokenMap.get('token');
        
        if(token=='Failed')
            return 'Failed to reach target system';
        
        String body = updatePIRWrapper(pirList);
        System.debug('AUTH TOKEN ------ '+token);
        System.debug('BODY-----'+body);
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Content-Type','application/json');
        headerMap.put('X-CSRF-Token',token);
        headerMap.put('Cookie',cookies);
        headerMap.put('Authorization',HTTPUtility.getSAPCalloutHeader(Constants.SAP_PIR_AUTH_HEADER));
        
        Map<String,String> respMap = HTTPUtility.getInstance().httpReqHelper(headerMap, 'POST', body, endPoint);
        
        if(respMap.get('code') =='200' || respMap.get('code')=='201'){
            return 'Success';
        }
        return 'Failure';
    }
    
    
    public static void updatePIRToPending(List<PIR__c> pirWithoutSAPCODE){
        for(PIR__c pir : pirWithoutSAPCODE){
            pir.Submit_To_SAP__c = true;
        }
        update pirWithoutSAPCODE;
    }
    
    public static List<PIR__c> getPIRList(List<String> recIds){
        return [Select Id, Customer_Name__r.Submitted_to_SAP__c, Customer_Code__c, Product_Code_HALB__c, Quantity_in_KG__c, Dispatch_Plan__c, Submit_To_SAP__c, OwnerId, Customer_Name__r.Customer_Code_SAP__c From PIR__c Where Id IN: recIds];
    }
    
    public static string updatePIRWrapper(List<PIR__c> pirList){
        Set<Id> setOfOwnerId = new Set<Id>();
        for(PIR__c pir:pirList){setOfOwnerId.add(pir.OwnerId);}
        Map<Id,User> userMap = new Map<Id,User>([Select Id,SAP_USER_CODE__c From User Where Id IN :setOfOwnerId]);
        List<PIRWrapper> pirWrapperList = new List<PIRWrapper>();
        
        for(PIR__c pir : pirList ){
            PIRWrapper pWrapper = new PIRWrapper();           
            if(!String.isEmpty(pir.Customer_Code__c) && !String.isEmpty(pir.Product_Code_HALB__c)){
                pWrapper.CUSTOMER_CODE = pir.Customer_Code__c;
                pWrapper.MATERIAL_CODE = pir.Product_Code_HALB__c;
                pWrapper.QUANTITY = pir.Quantity_in_KG__c;
                pWrapper.DISPATCH_PLAN = pir.Dispatch_Plan__c; 
                pWrapper.SALES_CODE = userMap.get(pir.OwnerId).SAP_USER_CODE__c;
                pirWrapperList.add(pWrapper);
            }
        }
        String jsonBody = JSON.serialize(pirWrapperList);
        return jsonBody;
    }
    
    public class PIRWrapper{
        public String SALES_CODE;
        public String CUSTOMER_CODE;
        public String MATERIAL_CODE;
        public Decimal QUANTITY;
        public Date DISPATCH_PLAN;
    }
    
    @future(callout=true)
    public static void updateOnPIR(list<Id> accIdsList){
        List<PIR__c> pirList = [Select Id, Customer_Code__c, Product_Code_HALB__c, Quantity_in_KG__c, Dispatch_Plan__c, Submit_To_SAP__c, OwnerId, Customer_Name__r.Customer_Code_SAP__c FROM PIR__c WHERE Customer_Name__c IN: accIdsList AND Submit_To_SAP__c = TRUE AND Customer_Name__r.Customer_Code_SAP__c!=null AND Synced_To_SAP__c=false];
        if(!pirList.isEmpty()){
            String response = updatePIRCallout(pirList);
            if(response.equalsIgnoreCase('Success')){
                for(PIR__c pir : pirList){
                    pir.Submit_To_SAP__c = false;
                    pir.Synced_To_SAP__c = true;
                }   
                update pirList;
            }
        }    
    }
}