/**
* Author : Anjali Singh
*/

@RestResource(urlMapping='/update_invoice_amount')
global without sharing class UpdateInvoiceOutstandingRestService {
    
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        UpdateInvOutstandingRestWrapper iWrapper = (UpdateInvOutstandingRestWrapper)JSON.deserialize(requestString, UpdateInvOutstandingRestWrapper.class);
        String responseBody;
        if(iWrapper != null) {
            string getResponse = updateInvoice(iWrapper.INVOICES);
            system.debug('getResponse :: ' + getResponse);
            if(getResponse == 'success'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Invoice synced successfully'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_invoice_amount', 'POST', 200, processingStartTime, System.now()); //Log 
            }
            else if(getResponse == 'not found'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Invoice number does not exist'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_invoice_amount', 'POST', 400, processingStartTime, System.now()); //Log 
            }
            else{
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Something went wrong'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_invoice_amount', 'POST', 400, processingStartTime, System.now()); //Log 
            }
        }
    }
    
    private static string updateInvoice(List<UpdateInvOutstandingRestWrapper.cls_INVOICES> invWrapperList){
        try{
            Map<String, UpdateInvOutstandingRestWrapper.cls_INVOICES> getWrapperInstByInvNo = new Map<String, UpdateInvOutstandingRestWrapper.cls_INVOICES>();
            for(UpdateInvOutstandingRestWrapper.cls_INVOICES inv : invWrapperList){
                getWrapperInstByInvNo.put(inv.INVOICE_NO, inv);
            }
            
            List<Invoice__c> invList = [SELECT Id, Invoice_Number__c, Payment_Received__c FROM Invoice__c WHERE Invoice_Number__c IN: getWrapperInstByInvNo.KeySet()];
            system.debug('invList :: ' + invList);
            if(invList.size()>0){
                for(Invoice__c inv : invList){
                    if(getWrapperInstByInvNo.containsKey(inv.Invoice_Number__c)){
                        if(inv.Payment_Received__c == null){
                            system.debug('in1 :: ');
                            inv.Payment_Received__c = getWrapperInstByInvNo.get(inv.Invoice_Number__c).AMOUNT;
                        }
                        else{
                            system.debug('in2 :: ');
                            inv.Payment_Received__c = inv.Payment_Received__c + getWrapperInstByInvNo.get(inv.Invoice_Number__c).AMOUNT;
                        }
                        inv.Due_Date__c = !String.isBlank(getWrapperInstByInvNo.get(inv.Invoice_Number__c).RECEIVED_DATE) ? Date.valueOf(getWrapperInstByInvNo.get(inv.Invoice_Number__c).RECEIVED_DATE) : inv.Due_Date__c;
                    }
                }              
                update invList;
                return 'success';
            }
            else{
                return 'not found';
            }
        }
        catch (Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('UpdateInvoiceOutstandingRestService','updateInvoice', e);
            return 'error';
        }
    }
}