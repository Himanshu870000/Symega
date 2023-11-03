/**
* Author: Anjali Singh
*/

@RestResource(urlMapping='/pro_status_update/*')
global without sharing class SAP_ProjectStatusUpdate {
    
    @httpPost
    global static void doPost(){
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Id projectId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Blob body = req.requestBody;
        String requestString = body.toString();
        SAP_ProjectStatusUpdateWrapper pWrapper = (SAP_ProjectStatusUpdateWrapper) JSON.deserialize(requestString, SAP_ProjectStatusUpdateWrapper.class);
        String responseBody;
        if(pWrapper != null){
            String getResponse = updateProjStatus(pWrapper, projectId);
            if(getResponse == 'Success'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Project updated successfully'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/pro_status_update', 'POST', 200, processingStartTime, System.now()); //Log 
            }
            else if(getResponse == 'error'){
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Please mention Rejection Reason'));
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/pro_status_update', 'POST', 200, processingStartTime, System.now()); //Log 
            }
            else{
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Something went wrong'));
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/pro_status_update', 'POST', 200, processingStartTime, System.now()); //Log 
            }
        }
    }
    
    private static string updateProjStatus(SAP_ProjectStatusUpdateWrapper projWrapper, String recId){
        try{
            if(!String.isBlank(recId)){
                
                List<Project__c> projList = [SELECT Id, Start_Date__c,Status__c, R_D_Approval_Status__c, Project_Completion_Date__c, 
                                             Reason_for_rejection__c, Additional_Comments__c FROM Project__c WHERE Id =: recId LIMIT 1];
                
                if(!projList.isEmpty()){
                    if(projWrapper.PROJECT_REQUEST_STATUS == 'Rejected by R&D' && String.isEmpty(projWrapper.REJECTED_REASON)){
                        return 'error';
                    }
                    else{
                        list<SAP_Project_Status__mdt> mdtList = SAP_Project_Status__mdt.getAll().values();
                        Map<string, SAP_Project_Status__mdt> getMDTBySAPValuesMap = new Map<string, SAP_Project_Status__mdt>();
                        System.debug('--mdtList->'+mdtList);
                        
                        for (SAP_Project_Status__mdt MDT : mdtList) {
                            getMDTBySAPValuesMap.put(MDT.SAP_Values__c, MDT);
                        }  
                        
                        projList[0].Start_Date__c = !String.isBlank(projWrapper.START_DATE) ? Date.valueOf(projWrapper.START_DATE) : projList[0].Start_Date__c;
                        projList[0].Status__c = !String.isBlank(projWrapper.PROJECT_REQUEST_STATUS) && getMDTBySAPValuesMap.containsKey(projWrapper.PROJECT_REQUEST_STATUS) ? getMDTBySAPValuesMap.get(projWrapper.PROJECT_REQUEST_STATUS).Label : projList[0].Status__c;
                        projList[0].Project_Completion_Date__c = !String.isBlank(projWrapper.COMPLETION_DATE) ? Date.valueOf(projWrapper.COMPLETION_DATE) : projList[0].Project_Completion_Date__c;
                        projList[0].Reason_for_rejection__c = !String.isBlank(projWrapper.REJECTED_REASON) ? projWrapper.REJECTED_REASON : projList[0].Reason_for_rejection__c;
                        projList[0].Additional_Comments__c = !String.isBlank(projWrapper.COMMENTS) ? projWrapper.COMMENTS : projList[0].Additional_Comments__c;
                        
                        Update projList;
                        system.debug('projList:: ' + projList);
                    }
                    return 'Success';
                }
            }
            return '';
        }
        catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('Optiva_ApplicationUpdate','updateApplication', e);
            return e.getMessage();
        }
    }
}