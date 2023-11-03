/**
* Author: Anjali Singh
*/
@RestResource(urlMapping='/sync_invoice')
global without sharing class SAP_InvoiceSyncRestService {
    
    /**
* {
"BILLING": [
{
"EMPLOYEE": "EPPAKGHOTTL",
"SOLD_TOPARTY": "ANUPAM S",
"SONO": "67891",
"BILLINGNO": "4768789",
"MATERIAL": "H00028287",
"CANC_INV": "",
"VALUE_DOCCUR": "5.00",
"EXPORT_CUR": "INR",
"QTY_UOM": "KG",
"SALE_UNIT": "CAR",
"QTY_KG": "5",
"BILLING_DATE": "2022-09-07",
"NET_VALUE": "50.00",
"TAXBALE_VALUE": "50.00",
"TOTAL_BILL": "10.00",
"FREIGHT": "100.00",
"MATERIL_DISC": "0.00",
"EXPORT_VALUE": "1000.00",
"CUSTOMER_DIS": "00.00",
"CASH_DIS": "0.00",
"INSURANCE": "00.00",
"TOTAL_GST": "18",
"TRASACTION_TYPE": "CREDIT_NOTE",
"INVOICE_DATE": "2022-09-07"
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
        //System.debug('--- rquestString'+ requestString);
        SAP_InvoiceSyncRestServiceWrapper iWrapper = (SAP_InvoiceSyncRestServiceWrapper)JSON.deserialize(requestString, SAP_InvoiceSyncRestServiceWrapper.class);
        String responseBody;
        if(iWrapper != null) {
            string getResponse = updateInvoice(iWrapper.BILLING);
            if(getResponse == 'success'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Invoice synced successfully'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sync_invoice/', 'POST', 200, processingStartTime, System.now()); //Log this request
            }
            else if(getResponse == 'so not found'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Sale Order Number does not exist'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sync_invoice/', 'POST', 400, processingStartTime, System.now()); //Log this request
            }
            else if(getResponse == 'failed'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Internal Server Error in creating Line Item'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sync_invoice/', 'POST', 400, processingStartTime, System.now()); //Log this request
            }
            else{
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', getResponse));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sync_invoice/', 'POST', 400, processingStartTime, System.now()); //Log this request
            }
        }
    }
    
    private static string updateInvoice(List<SAP_InvoiceSyncRestServiceWrapper.cls_BILLING> SAP_invWrapperList){
        try{
            Map<String, SAP_InvoiceSyncRestServiceWrapper.cls_BILLING> billingDetailsBySO_NoMap = new Map<String, SAP_InvoiceSyncRestServiceWrapper.cls_BILLING>();
            Map<String, SAP_InvoiceSyncRestServiceWrapper.cls_BILLING> billingDetailsByBillNoMap = new Map<String, SAP_InvoiceSyncRestServiceWrapper.cls_BILLING>();
            Map<String, SAP_InvoiceSyncRestServiceWrapper.cls_BILLING> billingDetailsByMaterailMap = new Map<String, SAP_InvoiceSyncRestServiceWrapper.cls_BILLING>();
            
            for(SAP_InvoiceSyncRestServiceWrapper.cls_BILLING billing : SAP_invWrapperList){
                billingDetailsBySO_NoMap.put(billing.SONO, billing);
                billingDetailsByBillNoMap.put(billing.BILLINGNO, billing);
                billingDetailsByMaterailMap.put(billing.MATERIAL, billing);
            }
            
            List<Sales_Order__c> soList = [SELECT Id, SAP_Reference_Code__c, Account__c 
                                           FROM Sales_Order__c WHERE Id IN: billingDetailsBySO_NoMap.keySet() OR SAP_Reference_Code__c IN: billingDetailsBySO_NoMap.keySet()];
            Map<String, Sales_Order__c> soBySONoMap = new Map<String, Sales_Order__c>();            
            for(Sales_Order__c so : soList){
                if(billingDetailsBySO_NoMap.containsKey(so.SAP_Reference_Code__c)){
                    soBySONoMap.put(so.SAP_Reference_Code__c, so);                   
                }
                else if(billingDetailsBySO_NoMap.containsKey(so.Id)){
                    soBySONoMap.put(so.Id, so);                   
                }
            }
            system.debug('soList' + soList);
            
            if(!soList.isEmpty()){
                List<Invoice__c> invList = [SELECT Id, Sales_Order__c, Sales_Order__r.SAP_Reference_Code__c, Invoice_Number__c FROM Invoice__c 
                                            WHERE (Sales_Order__c IN: billingDetailsBySO_NoMap.keySet() OR Sales_Order__r.SAP_Reference_Code__c IN: billingDetailsBySO_NoMap.keySet() ) AND Invoice_Number__c IN: billingDetailsByBillNoMap.keySet()];
                
                Map<String, Invoice__c> invByBillingNoSONoMap = new Map<String, Invoice__c>();                
                for(Invoice__c inv : invList){
                    if(billingDetailsBySO_NoMap.containsKey(inv.Sales_Order__r.SAP_Reference_Code__c)){
                        invByBillingNoSONoMap.put(inv.Invoice_Number__c + inv.Sales_Order__r.SAP_Reference_Code__c, inv);
                    }
                    else if(billingDetailsBySO_NoMap.containsKey(inv.Sales_Order__c)){
                        invByBillingNoSONoMap.put(inv.Invoice_Number__c + inv.Sales_Order__c, inv);
                    }
                }
                
                List<OpportunityLineItem> oppLineItemList = [SELECT Id, ProductCode, Sales_Order__r.SAP_Reference_Code__c FROM OpportunityLineItem 
                                                             WHERE ProductCode IN: billingDetailsByMaterailMap.keySet() AND (Sales_Order__r.SAP_Reference_Code__c IN: billingDetailsBySO_NoMap.keySet() OR Sales_Order__c IN: billingDetailsBySO_NoMap.keySet() )];
                
                Map<String, OpportunityLineItem> itemByCode_SONoMap = new Map<String, OpportunityLineItem>();                
                for(OpportunityLineItem item : oppLineItemList){
                    if(billingDetailsBySO_NoMap.containsKey(item.Sales_Order__r.SAP_Reference_Code__c)){
                        itemByCode_SONoMap.put(item.ProductCode + item.Sales_Order__r.SAP_Reference_Code__c, item);                 
                    }
                    else if(billingDetailsBySO_NoMap.containsKey(item.Sales_Order__c)){
                        itemByCode_SONoMap.put(item.ProductCode + item.Sales_Order__c, item);                 
                    }                    
                }
                system.debug('itemByCode_SONoMap -- ' + itemByCode_SONoMap);
                
                Map<String, Invoice__c> invoiceToBeInsertedMap = new Map<String, Invoice__c>();    
                List<Invoice_Line_Item__c> lineItemListToBeInserted = new List<Invoice_Line_Item__c>();   
                Map<String, Invoice_Line_Item__c> itemListByBillingSONoMap = new Map<String, Invoice_Line_Item__c> ();                
                
                for(SAP_InvoiceSyncRestServiceWrapper.cls_BILLING invWrapper : SAP_invWrapperList){
                    if(!invByBillingNoSONoMap.containsKey(invWrapper.BILLINGNO + invWrapper.SONO) ){     
                        Invoice__c newInvoice = new Invoice__c();
                        newInvoice.Invoice_Number__c = invWrapper.BILLINGNO ;
                        newInvoice.Sales_Order__c = soBySONoMap.get(invWrapper.SONO).Id;
                        newInvoice.Account__c = soBySONoMap.get(invWrapper.SONO).Account__c;
                        invoiceToBeInsertedMap.put(invWrapper.BILLINGNO + invWrapper.SONO, newInvoice);
                    }
                }
                system.debug('invoiceToBeInsertedMap -- ' + invoiceToBeInsertedMap);
                if(!invoiceToBeInsertedMap.values().isEmpty()){
                    insert invoiceToBeInsertedMap.values();
                    for(Invoice__c inv : invoiceToBeInsertedMap.values()){
                        String sono = [SELECT Id, SAP_Reference_Code__c FROM Sales_Order__c WHERE Id =: inv.Sales_Order__c].SAP_Reference_Code__c;
                        system.debug('sono ' + sono);
                        if(billingDetailsBySO_NoMap.containsKey(sono)){
                            invByBillingNoSONoMap.put(inv.Invoice_Number__c + sono, inv);
                        }
                        else if(billingDetailsBySO_NoMap.containsKey(inv.Sales_Order__c)){
                            invByBillingNoSONoMap.put(inv.Invoice_Number__c + inv.Sales_Order__c, inv);
                        }
                    }
                }      
                
                system.debug('invByBillingNoSONoMap' + invByBillingNoSONoMap);
                for(SAP_InvoiceSyncRestServiceWrapper.cls_BILLING invWrapper : SAP_invWrapperList){
                    Invoice_Line_Item__c newILI = doMapping(invWrapper);
                    if( itemByCode_SONoMap.containsKey(invWrapper.MATERIAL + invWrapper.SONO) ){
                        newILI.Opportunity_Product__c = itemByCode_SONoMap.get(invWrapper.MATERIAL + invWrapper.SONO).Id;
                    }
                    if(invByBillingNoSONoMap.containsKey(invWrapper.BILLINGNO + invWrapper.SONO)){
                        newILI.Invoice__c = invByBillingNoSONoMap.get(invWrapper.BILLINGNO + invWrapper.SONO).Id;
                        lineItemListToBeInserted.add(newILI);
                    }
                }
                system.debug('lineItemListToBeInserted' + lineItemListToBeInserted);
                
                if(!lineItemListToBeInserted.isEmpty()){
                    insert lineItemListToBeInserted;
                    return 'success';
                }
                else{
                    return 'failed';
                }
            }
            else{
                return 'so not found';
            }
        }
        catch (Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('SAP_InvoiceSyncRestService','updateInvoice', e);
            return e.getMessage();
        }
    }
    
    private static Invoice_Line_Item__c doMapping(SAP_InvoiceSyncRestServiceWrapper.cls_BILLING invWrapper){
        Invoice_Line_Item__c newILI = new Invoice_Line_Item__c();
        newILI.Cancel_Invoice__c = invWrapper.CANC_INV;
        newILI.Value_in_Document_Currency__c = !String.isBlank(invWrapper.VALUE_DOCCUR) ? decimal.valueof(invWrapper.VALUE_DOCCUR) : null;
        newILI.CurrencyIsoCode = invWrapper.EXPORT_CUR;
        newILI.UOM__c = invWrapper.QTY_UOM;
        newILI.Sales_Unit__c = invWrapper.SALE_UNIT;
        newILI.Quantity_in_KG__c = !String.isBlank(invWrapper.QTY_KG) ? integer.valueof(invWrapper.QTY_KG) : null;
        newILI.Billing_Date__c = !String.isBlank(invWrapper.BILLING_DATE) ? Date.ValueOf(invWrapper.BILLING_DATE) : null;
        newILI.Net_Value__c = !String.isBlank(invWrapper.NET_VALUE) ? decimal.valueof(invWrapper.NET_VALUE) : null;
        newILI.Taxable_value__c = !String.isBlank(invWrapper.TAXBALE_VALUE) ? decimal.valueof(invWrapper.TAXBALE_VALUE) : null;
        newILI.Total_Bill__c = !String.isBlank(invWrapper.TOTAL_BILL) ? decimal.valueof(invWrapper.TOTAL_BILL) : null;
        newILI.Freight_Charges__c = !String.isBlank(invWrapper.FREIGHT) ? decimal.valueof(invWrapper.FREIGHT) : null;
        newILI.Material_Disc__c = !String.isBlank(invWrapper.MATERIL_DISC) ? decimal.valueof(invWrapper.MATERIL_DISC) : null;
        newILI.Export_Value__c = !String.isBlank(invWrapper.EXPORT_VALUE) ? decimal.valueof(invWrapper.EXPORT_VALUE) : null;
        newILI.Customer_Disc__c = !String.isBlank(invWrapper.CUSTOMER_DIS) ? decimal.valueof(invWrapper.CUSTOMER_DIS) : null;
        newILI.Cash_Disc__c = !String.isBlank(invWrapper.CASH_DIS) ? decimal.valueof(invWrapper.CASH_DIS) : null;
        newILI.Insurance__c = !String.isBlank(invWrapper.INSURANCE) ? decimal.valueof(invWrapper.INSURANCE) : null;
        newILI.Total_GST__c = !String.isBlank(invWrapper.TOTAL_GST) ? decimal.valueof(invWrapper.TOTAL_GST) : null;
        newILI.Invoice_Type__c = invWrapper.TRASACTION_TYPE;
        newILI.Invoice_Date__c = !String.isBlank(invWrapper.INVOICE_DATE) ? Date.ValueOf(invWrapper.INVOICE_DATE) : null;
        return newILI;
    }
}