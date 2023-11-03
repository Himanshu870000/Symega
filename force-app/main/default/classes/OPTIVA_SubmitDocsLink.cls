/*
* Author: Anjali Singh
*/
@RestResource(urlMapping='/doc_linksync/*')
global without sharing class OPTIVA_SubmitDocsLink {
    
    @HttpPost
    global static void doPost() {
        try{
            DateTime processingStartTime = System.now();
            RestRequest req = RestContext.request;
            Id techDocId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            Blob body = req.requestBody;
            String requestString = body.toString().replaceAll('\\\\', ':');
            System.debug('--- rquestString'+ requestString);
            
            OPTIVA_SubmitDocLinkWrapper docLinkWrapper = (OPTIVA_SubmitDocLinkWrapper)JSON.deserialize(requestString, OPTIVA_SubmitDocLinkWrapper.class);
            System.debug('--- docLinkWrapper.document_linksync'+ docLinkWrapper.document_linksync);
            
            String responseBody;
            if(docLinkWrapper != null && !String.isBlank(techDocId)){
                String getResponse = processSubmitDocLinkRequest(docLinkWrapper, docLinkWrapper.document_linksync, techDocId);
                if(getResponse == 'Success') {
                    responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Document Synced Successfully'));
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                    HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/doc_linksync/*', 'POST', 200, processingStartTime, System.now()); //Log this request
                }
                else if(getResponse == 'nothing'){
                    responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Please provide all the data to be synced'));
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                    RestContext.response.statusCode = 400;
                    HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/doc_linksync/*', 'POST', 400, processingStartTime, System.now()); //Log this request
                }
                else if(getResponse == 'No Project'){
                    responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Project does not exist'));
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                    RestContext.response.statusCode = 400;
                    HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/doc_linksync/*', 'POST', 400, processingStartTime, System.now()); //Log this request
                }
                else{
                    responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', getResponse));
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                    RestContext.response.statusCode = 400;
                    HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/doc_linksync/*', 'POST', 400, processingStartTime, System.now()); //Log this request
                }
            }else {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'invalid body'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                RestContext.response.statusCode = 400;
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/doc_linksync/*', 'POST', 400, processingStartTime, System.now()); //Log this request
            }
        }
        catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            //return e.getMessage();
        }
    }
    
    private static string processSubmitDocLinkRequest(OPTIVA_SubmitDocLinkWrapper dlWrapper, List<OPTIVA_SubmitDocLinkWrapper.cls_document_link> dlWrapperList, String techDocId) {
        try{
            if(!String.isBlank(techDocId)){
                
                List<Project__c> prList = [SELECT Id FROM Project__c WHERE Id =: techDocId LIMIT 1];
                if(prList != null){
                    
                    list<User_Document__c> extDocList = [SELECT Id, Project__c, Document_Link__c FROM User_Document__c WHERE Project__c =: techDocId AND Document_Link__c != null];
                    Map<String, User_Document__c> docByLinkMap = new Map<String, User_Document__c>();
                    
                    for(User_Document__c doc : extDocList){
                        if(!String.isBlank(doc.Document_Link__c)){
                            docByLinkMap.put(doc.Document_Link__c, doc);
                        }
                    }
                    
                    list<User_Document__c> docListToBeInserted = new list<User_Document__c>();
                    
                    for(OPTIVA_SubmitDocLinkWrapper.cls_document_link prDocRec : dlWrapperList){
                        
                        if(!String.isBlank(prDocRec.document_link) && !String.isBlank(prDocRec.document_name)){
                            system.debug('prDocRec.document_link :: ' + prDocRec.document_link);
                            prDocRec.document_link = prDocRec.document_link.replaceAll(':', '\\\\');
                            system.debug('prDocRec.document_link :: ' + prDocRec.document_link);
                            
                            if(!docByLinkMap.containsKey(prDocRec.document_link)){
                                User_Document__c newDocRec = new User_Document__c();
                                newDocRec.Name = prDocRec.document_name;
                                newDocRec.Document_Link__c = 'file:'+prDocRec.document_link;
                                newDocRec.Project__c = prList[0].Id;
                                docByLinkMap.put(prDocRec.document_link, newDocRec);
                            }
                            else{
                                User_Document__c extDoc = docByLinkMap.get(prDocRec.document_link);
                                extDoc.Name = prDocRec.document_name;
                            }
                        }
                        else{
                            return 'nothing';
                        }
                    }
                    if(!docByLinkMap.IsEmpty()){
                        upsert docByLinkMap.values();
                        return 'Success';
                    }
                }
                else{
                    return 'No Project';
                }
            }           
            return 'no sf_id';
        }
        catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('OPTIVA_SubmitDocsLink','processSubmitDocLinkRequest', e);
            return e.getMessage();
        }
    }
    
}