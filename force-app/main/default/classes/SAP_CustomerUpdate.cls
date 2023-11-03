/**
 * Author: Anjali Singh
 */
@RestResource(urlMapping='/update_SapCode/*')
global without sharing class SAP_CustomerUpdate {
     
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Id accId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        try{
            if(String.isBlank(accId))
                throw new APIException('Invalid customer code');
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString'+ requestString);
            String responseBody;
            if(!String.isEmpty(requestString)) {
                Account newAccount = (Account)JSON.deserialize(requestString, Account.class);
                newAccount.Id = accId;
                if(newAccount != null) {
                    //system.debug('updateCustomer :: ' + updateCustomer(leadWrapper));
                    String accountId = updateCustomer(newAccount);
                    if(accountId != null) {
                        responseBody = JSON.serialize(new APIResponseWrapper('Success', 'Customer updated successfully:'+accountId));
                        HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_SapCode', 'POST', 200, processingStartTime, System.now()); //Log this request
                        RestContext.response.responseBody = Blob.valueOf(responseBody);
                    }
                    else {
                        responseBody = JSON.serialize(new APIResponseWrapper('Error', 'Something went wrong. couldn\'t update Customer'));
                        RestContext.response.responseBody = Blob.valueOf(responseBody);
                        HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_SapCode', 'POST', 400, processingStartTime, System.now()); //Log this request
                    }
                }
            }else {
                responseBody = JSON.serialize(new APIResponseWrapper('Error', 'Bad Request'));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_SapCode', 'POST', 400, processingStartTime, System.now()); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                RestContext.response.statusCode = 400;
            }
        }catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('SAP_CustomerUpdate','updateCustomer', e);
        }
    }
    

    
    
    class APIResponseWrapper {
        public String message;
        public String status;

        public APIResponseWrapper(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
    

    private static String updateCustomer(Account accRec){
        system.debug('--- accRec ' + accRec);
        update accRec;
        return accRec.Id;
    }

    class APIException extends Exception {}
}