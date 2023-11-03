/**
* Author: Anjali Singh
*/
@RestResource(urlMapping='/pro_quotient_update/*')
global without sharing class SAP_UpdateProjectQuotient {
    
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Id projectId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        SAP_ProjectQuotientWrapper prjWrapper = (SAP_ProjectQuotientWrapper)JSON.deserialize(requestString, SAP_ProjectQuotientWrapper.class);
        String responseBody;
        if(prjWrapper != null) {
            system.debug('prjWrapper :: ' + prjWrapper);
            String getResponse = updateProject_Quotient(prjWrapper.product_outcome, projectId);
            if(getResponse == 'Success'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Quotients created'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/pro_quotient_update', 'POST', 200, processingStartTime, System.now()); //Log 
            }
            else{
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Something went wrong'));
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/pro_quotient_update', 'POST', 200, processingStartTime, System.now()); //Log 
            }
        }
    }
    private static String updateProject_Quotient(List<SAP_ProjectQuotientWrapper.cls_PRODUCT_OUTCOME> quotientList, string projectId){
        try{
            if(!String.isBlank(projectId)){
                
                List<Project_Quotient__c> prQntlist = [SELECT Id, Product_Name__c, SSC_Code__c, Sample_Project_Application__c, 
                                                       Current_Shelf_Life__c, Usage_Level__c, Comments__c
                                                       FROM Project_Quotient__c WHERE Sample_Project_Application__c =: projectId];
                
                Map<String, Project_Quotient__c> sscCodeToPRMap = new Map<String, Project_Quotient__c>();
                
                for(Project_Quotient__c pr : prQntlist){
                    sscCodeToPRMap.put(pr.SSC_Code__c, pr);
                }
                
                system.debug('sscCodeToPRMap :: ' + sscCodeToPRMap);
                system.debug('quotientList :: ' + quotientList);
                
                if(quotientList != null) {
                    for(SAP_ProjectQuotientWrapper.cls_PRODUCT_OUTCOME prRec : quotientList) {
                        if(!String.isBlank(prRec.HALB_CODE)) {
                            string capitalHALB = Utility.capitalizeString(prRec.HALB_CODE);
                            if(sscCodeToPRMap.containsKey(prRec.HALB_CODE)) {
                                Project_Quotient__c extPR = sscCodeToPRMap.get(prRec.HALB_CODE);
                                extPR.SSC_Code__c = !String.isBlank(capitalHALB) ? capitalHALB : Utility.capitalizeString(extPR.SSC_Code__c);
                                extPR.Product_Name__c = !String.isBlank(prRec.PROD_NAME) ? prRec.PROD_NAME : extPR.Product_Name__c;
                                extPR.Current_Shelf_Life__c = !String.isBlank(prRec.CURRENT_SHELF_LIFE) ? prRec.CURRENT_SHELF_LIFE : extPR.Current_Shelf_Life__c;
                                extPR.Usage_Level__c = !String.isBlank(prRec.USAGE_LEVEL) ? prRec.USAGE_LEVEL : extPR.Usage_Level__c;
                                extPR.Comments__c = !String.isBlank(prRec.COMMENTS) ? prRec.COMMENTS : extPR.Comments__c;
                            }
                            else{
                                Project_Quotient__c newPR = new Project_Quotient__c();
                                newPR.Sample_Project_Application__c = projectId;
                                newPR.SSC_Code__c = !String.isBlank(capitalHALB) ? capitalHALB : '';
                                newPR.Product_Name__c = !String.isBlank(prRec.PROD_NAME) ? prRec.PROD_NAME : '';
                                newPR.Current_Shelf_Life__c = !String.isBlank(prRec.CURRENT_SHELF_LIFE) ? prRec.CURRENT_SHELF_LIFE : '';
                                newPR.Usage_Level__c = !String.isBlank(prRec.USAGE_LEVEL) ? prRec.USAGE_LEVEL : '';
                                newPR.Comments__c = !String.isBlank(prRec.COMMENTS) ? prRec.COMMENTS : '';
                                sscCodeToPRMap.put(prRec.HALB_CODE, newPR);
                            }
                        }
                        
                    }
                    if(!sscCodeToPRMap.isEmpty())
                        upsert sscCodeToPRMap.values();
                }
                
                return 'Success';
            }
            return 'err';
        }
        catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('Optiva_ApplicationUpdate','updateApplication', e);
            return e.getMessage();
        }
    }
}