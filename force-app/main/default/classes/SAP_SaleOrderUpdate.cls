/**
* Author: Anjali Singh
*/
@RestResource(urlMapping='/sale_order_update')
global without sharing class SAP_SaleOrderUpdate {
    
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        SAP_SaleOrderUpdateWrapper saleOrderWrapper = (SAP_SaleOrderUpdateWrapper)JSON.deserialize(requestString, SAP_SaleOrderUpdateWrapper.class);
        String responseBody;
        if(saleOrderWrapper != null) {
            String getResponse = updateSaleOrder(saleOrderWrapper.SALE_ORDERS);
            if(getResponse == 'Success') {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Sale Order Updated Successfully'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sale_order_update', 'POST', 200, processingStartTime, System.now()); //Log 
            }
            else if(getResponse == 'err') {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Something went wrong'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sale_order_update', 'POST', 400, processingStartTime, System.now()); //Log 
            }
            else if(getResponse == 'unequal') {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'We couldn\'t find the requested products details in our system'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sale_order_update', 'POST', 400, processingStartTime, System.now()); //Log 
            }
            else {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', getResponse));
                RestContext.response.responseBody = Blob.valueOf(responseBody); 
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sale_order_update', 'POST', 400, processingStartTime, System.now()); //Log 
                
            }
        }
    }
    
    private static String updateSaleOrder(List<SAP_SaleOrderUpdateWrapper.SALE_ORDER> saleOrderDataList){
        try{
            Boolean performUpdation = false;
            if(saleOrderDataList.size() > 0){
                Map<String, SAP_SaleOrderUpdateWrapper.SALE_ORDER> soByRefCodeMap = new Map<String, SAP_SaleOrderUpdateWrapper.SALE_ORDER>();
                Map<String, SAP_SaleOrderUpdateWrapper.SALE_ORDER> soByCstmrCodeMap = new Map<String, SAP_SaleOrderUpdateWrapper.SALE_ORDER>();
                Map<String, List<SAP_SaleOrderUpdateWrapper.prod_outcome_cls>> SAP_ProductList = new Map<String, List<SAP_SaleOrderUpdateWrapper.prod_outcome_cls>>();
                Map<String, SAP_SaleOrderUpdateWrapper.ship_add_cls> SAP_shipAdrList = new Map<String, SAP_SaleOrderUpdateWrapper.ship_add_cls>();
                
                for(SAP_SaleOrderUpdateWrapper.SALE_ORDER soData : saleOrderDataList){
                    soByRefCodeMap.put(soData.REF_CODE, soData);
                    soByCstmrCodeMap.put(soData.CUSTOMER_CODE, soData);
                    SAP_ProductList.put(soData.REF_CODE, soData.PRODUCTS);
                    SAP_shipAdrList.put(soData.REF_CODE, soData.SHIPPING_ADDRESS);
                }
                
                system.debug('SAP_ProductList ---- ' + SAP_ProductList);
                
                /*******************    SALE ORDER START   ************************/
                
                List<Sales_Order__c> existingSaleOrderList = [SELECT Id, Name, Opportunity__r.Account_Billing_Address__c, Opportunity__r.Account.Customer_Code_SAP__c, Opportunity__r.Customer_Billing_Address__c, Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c,
                                                              SAP_Reference_Code__c, Remarks__c, Account__c, Service_Rendering_date__c, Submitted_Date__c, Payment_Received__c, Change_in_Dispatch_Date_Reason__c  
                                                              FROM Sales_Order__c WHERE (Id IN: soByRefCodeMap.keySet() OR SAP_Reference_Code__c IN: soByRefCodeMap.keySet()) AND ( Opportunity__r.Account.Customer_Code_SAP__c IN: soByCstmrCodeMap.keySet() OR Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c IN: soByCstmrCodeMap.keySet()) ];
                system.debug('existingSaleOrderList -- ' + existingSaleOrderList);
                
                Map<String, String> accountIdByRefId = new Map<String, String>();
                
                List<Id> extSOId = new List<Id>();
                if(existingSaleOrderList.size()>0){
                    for(Sales_Order__c soRec : existingSaleOrderList){

                        String customerCodeSAP = '';

                        if(soRec.Opportunity__r.Account_Billing_Address__c){
                            customerCodeSAP = soRec.Opportunity__r.Account.Customer_Code_SAP__c;
                        }
                        else if(soRec.Opportunity__r.Customer_Billing_Address__c != null){
                            customerCodeSAP = soRec.Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c;
                        }

                        if( (soByRefCodeMap.containsKey(soRec.Id) || soByRefCodeMap.containsKey(soRec.SAP_Reference_Code__c)) && soByCstmrCodeMap.containsKey(customerCodeSAP) ) {
                            String so = '';
                            if(soByRefCodeMap.containsKey(soRec.Id)){
                                so = soRec.Id;
                            }
                            else if(soByRefCodeMap.containsKey(soRec.SAP_Reference_Code__c)){
                                so = soRec.SAP_Reference_Code__c;
                            }
                            
                            extSOId.add(soRec.Id);
                            accountIdByRefId.put(so, soRec.Account__c);
                            soRec.Remarks__c = !String.isBlank(soByRefCodeMap.get(so).REMARKS) ? soByRefCodeMap.get(so).REMARKS : soRec.Remarks__c;
                            soRec.Submitted_Date__c = !String.isBlank(soByRefCodeMap.get(so).SUBMITTED_DATE) ? Date.ValueOf(soByRefCodeMap.get(so).SUBMITTED_DATE) : soRec.Submitted_Date__c;
                        }                        
                    }
                    
                    /***********************     SALE ORDER END     ************************/
                    
                    /************************    PRODUCTS START     ************************/
                    Map<String, SAP_SaleOrderUpdateWrapper.prod_outcome_cls> mp = new Map<String, SAP_SaleOrderUpdateWrapper.prod_outcome_cls>();
                    //Incase of multiple same product codes under single sale order then below logic will pick one op.
                    for(String SAP_refId : SAP_ProductList.keySet()) {       
                        List<SAP_SaleOrderUpdateWrapper.prod_outcome_cls> prodList = SAP_ProductList.get(SAP_refId);
                        for(SAP_SaleOrderUpdateWrapper.prod_outcome_cls reqProds : prodList){
                            mp.put(SAP_refId + reqProds.PRODUCT_CODE, reqProds);
                        }                        
                    }
                                        
                    List<OpportunityLineItem> extOppProds = [SELECT Id, ProductCode, Quantity_In_KG__c, Quantity, Sales_Order__c, Sales_Order__r.SAP_Reference_Code__c
                                                             FROM OpportunityLineItem WHERE Sales_Order__c IN: extSOId /*AND ProductCode IN: prodsCode*/ ];
                    
                    Map<String, List<OpportunityLineItem>> lineItemListByRefCode = new Map<String, List<OpportunityLineItem>>();
                    List<OpportunityLineItem> listToBeUpdated = new List<OpportunityLineItem>();
                    
                    for(OpportunityLineItem lineItem : extOppProds){
                        String li = '';
                        if(soByRefCodeMap.containsKey(lineItem.Sales_Order__c)){
                            li = lineItem.Sales_Order__c;
                        }
                        else if(soByRefCodeMap.containsKey(lineItem.Sales_Order__r.SAP_Reference_Code__c)){
                            li = lineItem.Sales_Order__r.SAP_Reference_Code__c;
                        }
                        
                        if (lineItemListByRefCode.containsKey(li)) {
                            lineItemListByRefCode.get(li).add(lineItem); 
                        }
                        else{
                            lineItemListByRefCode.put(li, new List<OpportunityLineItem> {lineItem});
                        }
                    }
                    
                    Integer totalExtOppProds = 0;
                    
                    for(String SAP_refId : SAP_ProductList.keySet()){
                        List<SAP_SaleOrderUpdateWrapper.prod_outcome_cls> prodList = SAP_ProductList.get(SAP_refId);
                        List<OpportunityLineItem> oppLineItemList = lineItemListByRefCode.get(SAP_refId);
                        system.debug('oppLineItemList ---- ' + oppLineItemList);
                        
                        Integer totalRequestedOppProds = prodList.size();
                        
                        if(oppLineItemList == null){
                            totalExtOppProds = 0;
                        }
                        else{
                            totalExtOppProds = oppLineItemList.size();
                        }                        
                        
                        system.debug('totalExtOppProds :: ' + totalExtOppProds);
                        system.debug('totalRequestedOppProds :: ' + totalRequestedOppProds);
                        
                        if(totalExtOppProds == totalRequestedOppProds) {
                            for(OpportunityLineItem item : oppLineItemList){
                                String refNo = '';
                                if(mp.containsKey(item.Sales_Order__c + item.ProductCode)){
                                    refNo = item.Sales_Order__c + item.ProductCode;
                                }
                                else if(mp.containsKey(item.Sales_Order__r.SAP_Reference_Code__c + item.ProductCode)){
                                    refNo = item.Sales_Order__r.SAP_Reference_Code__c + item.ProductCode;
                                }
                                if(mp.containsKey(refNo)){
                                    item.Service_Rendering_Date__c = !String.isBlank(mp.get(refNo).SERVICE_RENDERING_DATE) ? Date.valueOf(mp.get(refNo).SERVICE_RENDERING_DATE) : item.Service_Rendering_Date__c;
                                    item.Change_in_Dispatch_Date__c = !String.isBlank(mp.get(refNo).CHANGE_IN_DISPATCH_DATE) ? mp.get(refNo).CHANGE_IN_DISPATCH_DATE : item.Change_in_Dispatch_Date__c;                                
                                    listToBeUpdated.add(item);
                                    performUpdation = true;
                                    system.debug('hi2');
                                }
                            }
                        }
                        else{
                            system.debug('hi1');
                            performUpdation = false;
                            return 'unequal';
                        }                        
                    }   
                    /*************************   PRODUCTS END ************************/
                    
                    
                    /*************************   SHIP_ADDRS START  ************************/
                    list<Dispatch_Address__c> addressList = new List<Dispatch_Address__c>();
                    
                    for(SAP_SaleOrderUpdateWrapper.SALE_ORDER soData : saleOrderDataList){
                        if(accountIdByRefId.containsKey(soData.REF_CODE)){
                            Dispatch_Address__c newAdrs = new Dispatch_Address__c();
                            newAdrs.Address__City__s = !String.isBlank(soData.SHIPPING_ADDRESS.CITY) ? soData.SHIPPING_ADDRESS.CITY : '';
                            newAdrs.Address__StateCode__s = !String.isBlank(soData.SHIPPING_ADDRESS.STATE) ? soData.SHIPPING_ADDRESS.STATE : '';
                            newAdrs.Address__CountryCode__s = !String.isBlank(soData.SHIPPING_ADDRESS.COUNTRY) ? soData.SHIPPING_ADDRESS.COUNTRY : '';
                            newAdrs.Address__PostalCode__s = !String.isBlank(soData.SHIPPING_ADDRESS.POSTAL_CODE) ? soData.SHIPPING_ADDRESS.POSTAL_CODE : '';
                            newAdrs.Address__Street__s = !String.isBlank(soData.SHIPPING_ADDRESS.STREET) ? soData.SHIPPING_ADDRESS.STREET : '';
                            newAdrs.Account__c = accountIdByRefId.get(soData.REF_CODE);
                            addressList.add(newAdrs);
                        }
                    }      
                    
                    if(performUpdation){
                        system.debug('hi');
                        update existingSaleOrderList;
                        update listToBeUpdated;
                        Database.insert(addressList, false); 
                    }                    
                    return 'Success';        
                    
                    /*************************   SHIP_ADDRS END  ************************/
                }
            }  
            return 'err';
        }catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('SAP_SaleOrderUpdate','updateSaleOrder', e);
            return e.getMessage();
        }
    }    
}