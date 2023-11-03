public without sharing class Optiva_CustomerCreationCallout {
    
    static Optiva_CustomerCreationCallout OptiovaCustObj;
    public static Optiva_CustomerCreationCallout getInstance(){
        if(OptiovaCustObj==null)
            OptiovaCustObj = new Optiva_CustomerCreationCallout();
        return OptiovaCustObj;
    }

    public String createCustomer(String body){
        System.debug('Body------'+body);
        try{
            if(Utility.isOptivaSyncingEnable()){

                DateTime startDate = System.now();
                String endPoint = 'callout:Optiva'+Constants.OPTIVA_CREATE_CUSTOMER_ENDPOINT;

                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
        
                req.setEndpoint(endPoint);
                req.setHeader('content-type', 'application/json');
                req.setHeader('x-functions-key', Constants.OPTIVA_CUSTOMER_CREATION_AUTH_HEADER);
                req.setBody(body);
                req.setHeader('Content-length', String.valueOf(body.length()));
                req.setTimeout(60 * 1000);
                HttpResponse resp = http.send(req);

                DateTime endDate = System.now();

                HttpUtility.createLog(req,resp,startDate,endDate);

                if(resp.getStatusCode()==200 || resp.getStatusCode()==201){
                    return 'Success';
                }else{
                    HandleBusinessException.captureCalloutError('Optiva_CustomerCreationCallout','createCustomer',body,resp.getStatusCode(),resp.getBody());    
                }
                System.debug('Response-----' + resp.getBody());


                return 'Error code -'+resp.getStatusCode(); 
            }else{
                return Constants.OPTIVA_SYNCING_ENABLE_MSG;
            }  
        }catch(Exception e){
            HandleBusinessException.captureError('Optiva_CustomerCreationCallout','createCustomer',e);
            throw new AuraHandledException(e.getMessage());
        }
    }



}