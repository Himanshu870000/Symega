/**
 * Author: DeaGle
 */
@RESTResource(urlMapping='/sap_project_update/*')
global without sharing class SAP_ProjectUpdateRestService {

    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        String responseBody;
        if(!String.isEmpty(requestString)) {
            Project__c newProject = (Project__c)JSON.deserialize(requestString, Project__c.class);
            if(newProject != null) {
                //system.debug('insertLead :: ' + insertLead(leadWrapper));
                String projectId = updateProject(newProject);
                if(projectId != null) {
                    responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Project updated succesfully:'+projectId));
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                    HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sap_project_update', 'POST', 200, processingStartTime, System.now()); //Log 
                }
                else {
                    responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Could not update Project'));
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                    RestContext.response.statusCode = 400;
                    HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sap_project_update', 'POST', 400, processingStartTime, System.now()); //Log 
                }
            }
        }else {
            responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Bad Request'));
            RestContext.response.responseBody = Blob.valueOf(responseBody);
            RestContext.response.statusCode = 400;
            HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sap_project_update', 'POST', 400, processingStartTime, System.now()); //Log 
        }
    }

    private static String updateProject(Project__c projectRec){
        try {
            system.debug('--- leadRec ' + projectRec);
            update projectRec;
            return projectRec.Id;
        }catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('SAP_ProjectUpdateRestService','updateProject', e);
            return null;
        }
    }
}