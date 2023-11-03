@RESTResource(urlMapping='/updatecustomercode/*')
global without sharing class Optiva_CustomerCreationService {
    @HttpPost
    global static String updateCustomerCode(){
        try{
            DateTime processingStartTime = System.now();
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            
            Id reqId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            String body = req.requestBody.toString();
            System.debug('REQUEST----'+body);
            System.debug('Req Id----'+reqId);

            if(String.isBlank(body))
                return 'Failed, Please provide optiva code';

            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(body);
            String optivaCode = (String) m.get('CUSTOMER_CODE_OPTIVA__C');

            if(String.isBlank(reqId)) {
                RestContext.response.statusCode = 400;
                return 'Failed, recordId not found';
            }
                
            if(String.isBlank(optivaCode)) {
                RestContext.response.statusCode = 400;
                return 'Failed, Please provide optiva code';
            }
            String result = updateOptivaCode(reqId,optivaCode);
            if(result == 'Failed, recordId not found')
                RestContext.response.statusCode = 400;
            HttpUtility.getInstance().createServiceLogger(body, result, '/updatecustomercode/*', 'POST', 200, processingStartTime, System.now()); //Log this request
            return result;
        }catch(Exception e){
            HandleBusinessException.captureError('Optiva_CustomerCreationService','updateCustomerCode', e);
            return 'Failed, '+e.getMessage();
        }
    }

    private static String updateOptivaCode(Id recordId, String optivaCode){
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        if(sobjectType=='Account'){
            List<Account> accList = [Select Id, Customer_Code_OPTIVA__c From Account Where Id=:recordId];

            if(accList.isEmpty())
                return 'Failed, recordId not found';

            accList[0].Customer_Code_OPTIVA__c = optivaCode;
            update accList;
        }/*else if(sobjectType=='Lead'){
            List<Lead> leadList = [Select Id, Customer_Code_OPTIVA__c,IsConverted From Lead Where Id=:recordId];

            if(leadList.isEmpty())
                return 'Failed, recordId not found';
            
            if(leadList[0].IsConverted){
                Account acc = new Account(Id=leadList[0].ConvertedAccountId,Customer_Code_OPTIVA__c=optivaCode);
                update acc;
            }

            leadList[0].Customer_Code_OPTIVA__c = optivaCode;
            update leadList;
        }*/ 
        else{
            return 'Failed, Invalid recordId';
        }

        return 'Success';
    }
}