/*
* Author: Anjali Singh
*/
@RestResource(urlMapping='/project_update/*')
global without sharing class Optiva_ProjectUpdate {
    
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Id projectId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        Optiva_ProjectWrapper projectWrapper = (Optiva_ProjectWrapper)JSON.deserialize(requestString, Optiva_ProjectWrapper.class);
        if(projectWrapper != null) {
            
            // if(projectWrapper.product_outcome_obj != null){
            
            //projectWrapper.product_outcome_obj = (List<Optiva_ProjectWrapper.prod_outcome_cls>)JSON.deserialize(requestString, List<Optiva_ProjectWrapper.prod_outcome_cls>.class); 
            //   }
            system.debug('calling with wrapper --- '+projectWrapper.product_outcome);
            String getResponse = updateProject(projectWrapper, projectWrapper.product_outcome, projectId);
            String responseBody;
            if(getResponse == 'Success'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Project updated successfully'));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/project_update/*', 'POST', 200, processingStartTime, System.now()); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
            else if(getResponse == 'err'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Project Id is blank'));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/project_update/*', 'POST', 400, processingStartTime, System.now()); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
            else{
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/project_update/*', 'POST', 400, processingStartTime, System.now()); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
        }
    }
    
    private static String updateProject(Optiva_ProjectWrapper projectData, List<Optiva_ProjectWrapper.prod_outcome_cls> OPTIVA_ProjectQuotientList, string projectId){
        try{
            if(!String.isBlank(projectId)){
                
                List<Project__c> projectList = [SELECT Id, Way_Bill_No__c, Courier__c, Actual_date_of_dispatch__c, Dispatch_Details__c, Start_Date__c,
                                                Sample_delivery_date__c, Application_Ready__c, Status__c, Current_Shelf_life__c, 
                                                R_D_Approval_Status__c, Usage_Levels_in_Recipes_Average__c, Project_Completion_Date__c, Reason_for_rejection__c, Additional_Comments__c
                                                FROM Project__c WHERE Id =: projectId LIMIT 1];
                
                if(!projectList.isEmpty()){
                    
                    projectList[0].Start_Date__c = !String.isBlank(projectData.start_date) ? Utility.parseDate(projectData.start_date) : projectList[0].Start_Date__c;
                    projectList[0].Status__c = !String.isBlank(projectData.project_request_status) ? projectData.project_request_status : projectList[0].Status__c;
                    projectList[0].Actual_Date_of_Dispatch__c = !String.isBlank(projectData.actual_dispatch_date) ? Utility.parseDate(projectData.actual_dispatch_date) : projectList[0].Actual_Date_of_Dispatch__c;
                    projectList[0].Way_Bill_No__c =!String.isBlank(projectData.way_bill_no) ? projectData.way_bill_no : projectList[0].Way_Bill_No__c;
                    projectList[0].Courier__c = !String.isBlank(projectData.courier) ? projectData.courier : projectList[0].Courier__c;
                    projectList[0].Sample_Delivery_Date__c = !String.isBlank(projectData.delivery_date) ? Utility.parseDate(projectData.delivery_date) : projectList[0].Sample_Delivery_Date__c;
                    projectList[0].Dispatch_Details__c = !String.isBlank(projectData.dispatch_details) ? projectData.dispatch_details : projectList[0].Dispatch_Details__c;
                    projectList[0].R_D_Approval_Status__c = !String.isBlank(projectData.rd_approval_status) ? projectData.rd_approval_status : projectList[0].R_D_Approval_Status__c;
                    projectList[0].Usage_Levels_in_Recipes_Average__c = !String.isBlank(projectData.usage_level) ? projectData.usage_level : projectList[0].Usage_Levels_in_Recipes_Average__c;
                    projectList[0].Current_Shelf_life__c = !String.isBlank(projectData.current_shelf_life) ? projectData.current_shelf_life : projectList[0].Current_Shelf_life__c;
                    projectList[0].Project_Completion_Date__c = !String.isBlank(projectData.completion_date) ? Utility.parseDate(projectData.completion_date) : projectList[0].Project_Completion_Date__c;
                    projectList[0].Reason_for_rejection__c = !String.isBlank(projectData.rejected_reason) ? projectData.rejected_reason : projectList[0].Reason_for_rejection__c;
                    projectList[0].Additional_Comments__c = !String.isBlank(projectData.comments) ? projectData.comments : projectList[0].Additional_Comments__c;                  
                    
                    Update projectList;
                    
                    List<Project_Quotient__c> prQntlist = [SELECT Id, Product_Name__c, SSC_Code__c, Sample_Project_Application__c FROM Project_Quotient__c WHERE Sample_Project_Application__c =: projectId];
                    Map<String, Project_Quotient__c> sscCodeToPRMap = new Map<String, Project_Quotient__c>();
                    
                    for(Project_Quotient__c pr : prQntlist){
                        sscCodeToPRMap.put(pr.SSC_Code__c, pr);
                    }
                    
                    system.debug('sscCodeToPRMap :: ' + sscCodeToPRMap);
                    system.debug('OPTIVA_ProjectQuotientList :: ' + OPTIVA_ProjectQuotientList);
                    
                    if(OPTIVA_ProjectQuotientList != null) {
                        for(Optiva_ProjectWrapper.prod_outcome_cls optivaRec : OPTIVA_ProjectQuotientList) {
                            if(!String.isBlank(optivaRec.ssc_code)) {
                                string captialSSC = Utility.capitalizeString(optivaRec.ssc_code);
                                if(sscCodeToPRMap.containsKey(optivaRec.ssc_code)) {
                                    Project_Quotient__c extPR = sscCodeToPRMap.get(optivaRec.ssc_code);
                                    extPR.SSC_Code__c = !String.isBlank(captialSSC) ? captialSSC : Utility.capitalizeString(extPR.SSC_Code__c);
                                    extPR.Product_Name__c = !String.isBlank(optivaRec.prod_name) ? optivaRec.prod_name : extPR.Product_Name__c;
                                }
                                else{
                                    Project_Quotient__c newPR = new Project_Quotient__c();
                                    newPR.Sample_Project_Application__c = projectId;
                                    newPR.SSC_Code__c = !String.isBlank(captialSSC) ? captialSSC : '';
                                    newPR.Product_Name__c = !String.isBlank(optivaRec.prod_name) ? optivaRec.prod_name : '';
                                    sscCodeToPRMap.put(optivaRec.ssc_code, newPR);
                                }
                            }
                        }
                        if(!sscCodeToPRMap.isEmpty())
                            upsert sscCodeToPRMap.values();
                    }
                    return 'Success';
                }
            }
            return 'err';
        }catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('Optiva_ProjectUpdate','updateProject', e);
            return e.getMessage();
        }
    }
}