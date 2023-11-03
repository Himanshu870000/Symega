/*
* Author: Anjali Singh
*/
@RestResource(urlMapping='/application_update/*')
global without sharing class Optiva_ApplicationUpdate {
    
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Id applicationId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        Optiva_ApplicationWrapper appWrapper = (Optiva_ApplicationWrapper)JSON.deserialize(requestString, Optiva_ApplicationWrapper.class);
        String responseBody;
        if(appWrapper != null) {
            system.debug('appWrapper :: ' + appWrapper);
            if(updateApplication(appWrapper, appWrapper.product_outcome, applicationId)) {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Application updated successfully'));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/application_update/*', 'POST', 200, processingStartTime, System.now()); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
            else {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Something went wrong'));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/application_update/*', 'POST', 400, processingStartTime, System.now()); //Log this request
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
        }
    }
    
    private static Boolean updateApplication(Optiva_ApplicationWrapper applicationWrapper, List<Optiva_ApplicationWrapper.prod_outcome_cls> quotientList, string applicationId){
        try{
            if(!String.isBlank(applicationId)){
                
                List<Project__c> applicationList = [SELECT Id, Courier__c, Actual_date_of_dispatch__c, Dispatch_Details__c, Start_Date__c, Additional_Comments__c,
                                                    Sample_delivery_date__c, Application_Ready__c, Country_Regulation__c, Current_Shelf_life__c, Reason_for_rejection__c, Way_Bill_No__c
                                                    FROM Project__c WHERE Id =: applicationId LIMIT 1];
                
                if(!applicationList.isEmpty()){
                    applicationList[0].Way_Bill_No__c = !String.isBlank(applicationWrapper.way_bill_no) ? applicationWrapper.way_bill_no : applicationList[0].Way_Bill_No__c;
                    applicationList[0].Application_Ready__c = !String.isBlank(applicationWrapper.application_ready) && applicationWrapper.application_ready == 'true' ? true : false ;
                    applicationList[0].Courier__c = !String.isBlank(applicationWrapper.courier) ? applicationWrapper.courier : applicationList[0].Courier__c;
                    applicationList[0].Actual_Date_of_Dispatch__c = !String.isBlank(applicationWrapper.actual_dispatch_date) ? Utility.parseDate(applicationWrapper.actual_dispatch_date) : applicationList[0].Actual_Date_of_Dispatch__c;
                    applicationList[0].Country_Regulation__c = !String.isBlank(applicationWrapper.country_regulation) ? applicationWrapper.country_regulation : applicationList[0].Country_Regulation__c;
                    applicationList[0].Current_Shelf_life__c = !String.isBlank(applicationWrapper.current_shelf_life) ? applicationWrapper.current_shelf_life : applicationList[0].Current_Shelf_life__c;
                    applicationList[0].Dispatch_Details__c = !String.isBlank(applicationWrapper.dispatch_details) ? applicationWrapper.dispatch_details : applicationList[0].Dispatch_Details__c;
                    applicationList[0].Start_Date__c = !String.isBlank(applicationWrapper.start_date) ? Utility.parseDate(applicationWrapper.start_date) : applicationList[0].Start_Date__c;
                    applicationList[0].Sample_Delivery_Date__c = !String.isBlank(applicationWrapper.delivery_date) ? Utility.parseDate(applicationWrapper.delivery_date) : applicationList[0].Sample_Delivery_Date__c;
                    applicationList[0].Additional_Comments__c = !String.isBlank(applicationWrapper.comments) ? applicationWrapper.comments : applicationList[0].Additional_Comments__c;
                    applicationList[0].Reason_for_rejection__c = !String.isBlank(applicationWrapper.rejected_reason) ? applicationWrapper.rejected_reason : applicationList[0].Reason_for_rejection__c;
                    
                    Update applicationList;
                    system.debug('applicationList:: ' + applicationList);
                    
                    List<Project_Quotient__c> prQntlist = [SELECT Id, Product_Name__c, SSC_Code__c, Sample_Project_Application__c FROM Project_Quotient__c WHERE Sample_Project_Application__c =: applicationId];
                    Map<String, Project_Quotient__c> sscCodeToPRMap = new Map<String, Project_Quotient__c>();
                    
                    for(Project_Quotient__c pr : prQntlist){
                        sscCodeToPRMap.put(pr.SSC_Code__c, pr);
                    }
                    
                    system.debug('sscCodeToPRMap :: ' + sscCodeToPRMap);
                    system.debug('quotientList :: ' + quotientList);
                    
                    if(quotientList != null) {
                        for(Optiva_ApplicationWrapper.prod_outcome_cls optivaRec : quotientList) {
                            string sscCd = optivaRec.ssc_code;
                            string newCode = sscCd.replace('""', '"');
                            system.debug('sscCd ::' + sscCd);
                            system.debug('newCode ::' + newCode);
                            if(!String.isBlank(optivaRec.ssc_code)) {
                                string captialSSC = Utility.capitalizeString(optivaRec.ssc_code);
                                if(sscCodeToPRMap.containsKey(optivaRec.ssc_code)) {
                                    Project_Quotient__c extPR = sscCodeToPRMap.get(optivaRec.ssc_code);
                                    extPR.SSC_Code__c = !String.isBlank(captialSSC) ? captialSSC : Utility.capitalizeString(extPR.SSC_Code__c);
                                    extPR.Product_Name__c = !String.isBlank(optivaRec.prod_name) ? optivaRec.prod_name : extPR.Product_Name__c;
                                }
                                else{
                                    Project_Quotient__c newPR = new Project_Quotient__c();
                                    newPR.Sample_Project_Application__c = applicationId;
                                    newPR.SSC_Code__c = !String.isBlank(captialSSC) ? captialSSC : '';
                                    newPR.Product_Name__c = !String.isBlank(optivaRec.prod_name) ? optivaRec.prod_name : '';
                                    sscCodeToPRMap.put(optivaRec.ssc_code, newPR);
                                }
                            }
                            
                        }
                        if(!sscCodeToPRMap.isEmpty())
                            upsert sscCodeToPRMap.values();
                    }
                    
                    return true;
                }
            }
            return false;
        }catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('Optiva_ApplicationUpdate','updateApplication', e);
            return false;
        }
    }
}