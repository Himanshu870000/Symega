/*
* Author: Anjali Singh
*/
@RestResource(urlMapping='/sample_product_update/*')
global without sharing class Optiva_SampleProductUpdate {
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Id sampleId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        Optiva_SampleProductWrapper lineItemWrapper = (Optiva_SampleProductWrapper)JSON.deserialize(requestString, Optiva_SampleProductWrapper.class);
        String responseBody;
        if(lineItemWrapper != null) {
            system.debug('updateLineItem :: '+ lineItemWrapper);
            if(String.isBlank(lineItemWrapper.product_code) || String.isBlank(sampleId)) {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Product SSC Code is mandatory'));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sample_product_update/*', 'POST', 200, processingStartTime, System.now()); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                RestContext.response.statusCode = 400;
                return;
            }
            if(updateLineItem(lineItemWrapper, sampleId)) {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Sample updated successfully'));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sample_product_update/*', 'POST', 200, processingStartTime, System.now()); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
            else {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Something went wrong'));
                RestContext.response.statusCode = 400;
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sample_product_update/*', 'POST', 400, processingStartTime, System.now()); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
        }
    }

    private static Boolean updateLineItem(Optiva_SampleProductWrapper SLI_Wrapper, string sampleID){
        try{
            if(!String.isBlank(sampleID)){
                List<Sample_Line_Item__c> existingLineItemList = [SELECT Id, Name, Product__r.ProductCode, Exclusive_customer_product_code__c, Way_Bill_No__c, Courier__c, OPTIVA_Recipe__r.SSC_Code__c,Actual_date_of_dispatch__c, Dispatch_Details__c, Sample_Request_Status__c, Start_Date__c, Sample_delivery_date__c, Reason_for_rejection__c, Additional_Comments__c, Project_Quotient__r.SSC_Code__c
                FROM Sample_Line_Item__c WHERE Sample__c =: sampleID AND (OPTIVA_Recipe__r.SSC_Code__c =: SLI_Wrapper.Product_Code OR Project_Quotient__r.SSC_Code__c =: SLI_Wrapper.Product_Code OR Product__r.ProductCode =: SLI_Wrapper.Product_Code) LIMIT 1];

                if(!existingLineItemList.isEmpty()){
                    existingLineItemList[0].Exclusive_customer_product_code__c = !String.isBlank(SLI_Wrapper.exclusive_product_code) ? SLI_Wrapper.exclusive_product_code : existingLineItemList[0].Exclusive_customer_product_code__c;
                    existingLineItemList[0].Way_Bill_No__c = !String.isBlank(SLI_Wrapper.way_bill_no) ? SLI_Wrapper.way_bill_no : existingLineItemList[0].Way_Bill_No__c;
                    existingLineItemList[0].Courier__c = !String.isBlank(SLI_Wrapper.courier) ? SLI_Wrapper.courier : existingLineItemList[0].Courier__c;
                    existingLineItemList[0].Actual_date_of_dispatch__c = !String.isBlank(SLI_Wrapper.actual_dispatch_date) ? Utility.parseDate(SLI_Wrapper.actual_dispatch_date) : existingLineItemList[0].Actual_date_of_dispatch__c;
                    existingLineItemList[0].Dispatch_Details__c = !String.isBlank(SLI_Wrapper.dispatch_details) ? SLI_Wrapper.dispatch_details : existingLineItemList[0].Dispatch_Details__c;
                    existingLineItemList[0].Sample_Request_Status__c = !String.isBlank(SLI_Wrapper.request_status) ? SLI_Wrapper.request_status : existingLineItemList[0].Sample_Request_Status__c;
                    existingLineItemList[0].Start_Date__c = !String.isBlank(SLI_Wrapper.start_date) ? Utility.parseDate(SLI_Wrapper.start_date) : existingLineItemList[0].Start_Date__c;
                    existingLineItemList[0].Sample_delivery_date__c = !String.isBlank(SLI_Wrapper.delivery_date) ? Utility.parseDate(SLI_Wrapper.delivery_date) : existingLineItemList[0].Sample_delivery_date__c;
                    existingLineItemList[0].Reason_for_rejection__c = !String.isBlank(SLI_Wrapper.rejected_reason) ? SLI_Wrapper.rejected_reason : existingLineItemList[0].Reason_for_rejection__c;
                    existingLineItemList[0].Additional_Comments__c = !String.isBlank(SLI_Wrapper.comments) ? SLI_Wrapper.comments : existingLineItemList[0].Additional_Comments__c; 

                    Update existingLineItemList;
                    return true;
                }
            }
            return false;
        }catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('Optiva_SampleProductUpdate','updateLineItem', e);
            return false;
        }
    }
}