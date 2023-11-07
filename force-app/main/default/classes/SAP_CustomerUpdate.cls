/**
 * Author: Anjali Singh
 */
@RestResource(urlMapping='/update_SapCode/*')
global without sharing class SAP_CustomerUpdate {
     
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        String recId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);       
           
        try{
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString'+ requestString);
            String responseBody;

            if(String.isBlank(recId)){
                //throw new APIException('Invalid customer code');
                responseBody = JSON.serialize(new APIResponseWrapper('Error', 'Please provide a valid Id for the request'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_SapCode', 'POST', 400, processingStartTime, System.now()); //Log this request
                RestContext.response.statusCode = 400;
                return;
            }
               
            Boolean isAccount = false;
            if(recId.startsWith('001'))
                isAccount = true;

            if(!String.isEmpty(requestString)) {
                Account newAccount = new Account();
                Dispatch_Address__c newAddress = new Dispatch_Address__c();

                if(isAccount){
                    newAccount = (Account)JSON.deserialize(requestString, Account.class);
                    newAccount.Id = recId;
                }
                else{
                    newAddress = (Dispatch_Address__c)JSON.deserialize(requestString, Dispatch_Address__c.class);
                    newAddress.Id = recId;
                }
                
                if(newAccount != null || newAddress != NULL) {
                    //system.debug('updateCustomer :: ' + updateCustomer(leadWrapper));
                    String response = updateCustomer(newAccount, newAddress);
                    if(response.startsWith('001') || response.startsWith('a0G')){
                        responseBody = JSON.serialize(new APIResponseWrapper('Success', 'Customer updated successfully:'+response));
                        HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_SapCode', 'POST', 200, processingStartTime, System.now()); //Log this request
                        RestContext.response.responseBody = Blob.valueOf(responseBody);
                        RestContext.response.statusCode = 200;
                    }
                    else {
                        responseBody = JSON.serialize(new APIResponseWrapper('Error', 'Something went wrong. couldn\'t update Customer : ' + response));
                        RestContext.response.responseBody = Blob.valueOf(responseBody);
                        HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_SapCode', 'POST', 400, processingStartTime, System.now()); //Log this request
                        RestContext.response.statusCode = 400;
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
    

    private static String updateCustomer(Account accRec, Dispatch_Address__c addrRec){
        try{
            system.debug('--- accRec ' + accRec);
            system.debug('--- addrRec ' + addrRec);

            if(accRec.Id != null){
                update accRec;
                return accRec.Id;
            }
            if(addrRec.Id != null){
                update addrRec;
                return addrRec.Id;
            }
            return null;
        }
        catch(Exception e){
            system.debug('---' + e.getMessage() + ' : ' + e.getLineNumber());
            return e.getMessage();
        }
    }

    class APIException extends Exception {}
}