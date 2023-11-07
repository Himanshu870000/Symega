/**
* Author: Anjali Singh
*/
@RestResource(urlMapping='/update_fert')
global without sharing class SAP_UpdateFertRestService {
    
    /**
* {
"PRODUCT_DATA": [
{
"ACTIVE": "NO",
"PRODUCTCODE": "206636_P2",
"PRODUCT_DESCRIPTION": "TOMATO KETCHUP SACHETS-25169-8g P2.",
"PRODUCTFAMILY": "",
"PRODUCTTYPE": "FERT",
"UNITOFMEASURE": "KAR",
"PRODUCT_USED_BY": "",
"LEGACYCODE": "",
"HSN_TAX": "0",
"SALES_CODE": "",
"ALLERGEN_STATUS": "TRUE",
"DIETARYINFO": "",
"MOQ": "0.000 ",
"PRODUCTSUBCATEGORY": "",
"CUSTOMER_NUMBER": ""
}
]
}
*/
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        //Now as you have the request string You can parse it in APex
        System.debug('--- rquestString'+ requestString);
        SAP_UpdateFertRestServiceWrapper rw = (SAP_UpdateFertRestServiceWrapper)JSON.deserialize(requestString,SAP_UpdateFertRestServiceWrapper.class);
        String responseBody;
        if(rw != null) {
            string response = updateFERT(rw.PRODUCT_DATA);
            if(response == 'success') {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'FERT updated Successfully'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_fert', 'POST', 200, processingStartTime, System.now()); //Log 
            }
            else if(response == 'not existing'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Opportunity Product doesn\'t exist.'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_fert', 'POST', 400, processingStartTime, System.now()); //Log 
            }
            else if(response == 'false'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'PRODUCTCODE or CUSTOMER_NUMBER is empty!!'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_fert', 'POST', 400, processingStartTime, System.now()); //Log 
            }
            else {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', response));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_fert', 'POST', 400, processingStartTime, System.now()); //Log 
            }
        }
    }
    
    //Quert opp products with customer sap code and product code and update FERT_CODE @ opp product level with 
    private static string updateFERT(List<SAP_UpdateFertRestServiceWrapper.cls_PRODUCT_DATA> wrapperList) {
        try{
            Map<String, SAP_UpdateFertRestServiceWrapper.cls_PRODUCT_DATA> sapOppProdMap = new Map<String, SAP_UpdateFertRestServiceWrapper.cls_PRODUCT_DATA>();
            Map<String, SAP_UpdateFertRestServiceWrapper.cls_PRODUCT_DATA> sapOppProdByCstmCodeMap = new Map<String, SAP_UpdateFertRestServiceWrapper.cls_PRODUCT_DATA>();
            Map<String, String> fertCodeByProdCodeMap = new Map<String, String>();
            
            for(SAP_UpdateFertRestServiceWrapper.cls_PRODUCT_DATA oppProduct : wrapperList) {
                if(!String.isBlank(oppProduct.PRODUCTCODE))
                    sapOppProdMap.put(oppProduct.PRODUCTCODE, oppProduct);
                sapOppProdByCstmCodeMap.put(oppProduct.CUSTOMER_NUMBER, oppProduct);
                fertCodeByProdCodeMap.put(oppProduct.PRODUCTCODE, oppProduct.FERT_CODE);
                
            }                
            
            System.debug('sapOppProdMap '+ sapOppProdMap);
            System.debug('sapOppProdByCstmCodeMap '+ sapOppProdByCstmCodeMap);
            
            if(!sapOppProdMap.isEmpty() && !sapOppProdByCstmCodeMap.isEmpty()) {
                List<OpportunityLineItem> existingProductList = [SELECT Id, Name, FERT_Code__c, ProductCode, Opportunity.Account.Customer_Code_SAP__c, Opportunity.Account_Billing_Address__c, Opportunity.Customer_Billing_Address__c, Opportunity.Customer_Billing_Address__r.Customer_Code_SAP__c
                                                                 FROM OpportunityLineItem WHERE FERT_Code__c = null AND ProductCode IN: sapOppProdMap.keySet() AND (Opportunity.Account.Customer_Code_SAP__c IN: sapOppProdByCstmCodeMap.keySet() OR Opportunity.Customer_Billing_Address__r.Customer_Code_SAP__c IN: sapOppProdByCstmCodeMap.keySet() ) AND Quantity_Unit__c != null AND Packaging_Type__c != null /* AND Opportunity.RecordType.Name = 'Parent' */ ];
                if(!existingProductList.isEmpty()){
                    for(OpportunityLineItem lineItem : existingProductList) {

                        String customerCodeSAP = '';

                        if(lineItem.Opportunity.Account_Billing_Address__c){
                            customerCodeSAP = lineItem.Opportunity.Account.Customer_Code_SAP__c;
                        }
                        else if(lineItem.Opportunity.Customer_Billing_Address__c != null){
                            customerCodeSAP = lineItem.Opportunity.Customer_Billing_Address__r.Customer_Code_SAP__c;
                        }

                        if(sapOppProdMap.containsKey(lineItem.ProductCode) && sapOppProdByCstmCodeMap.containsKey(customerCodeSAP)) {
                            lineItem.FERT_Code__c = !String.isBlank(fertCodeByProdCodeMap.get(lineItem.ProductCode)) ? fertCodeByProdCodeMap.get(lineItem.ProductCode) : lineItem.FERT_Code__c;
                        }
                    }
                    upsert existingProductList;
                    return 'success';   
                }
                return 'not existing';
            }
            return 'false';
        }
        catch (Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('SAP_UpdateFertRestService','updateFERT', e);
            return e.getMessage();
        }
    }
}