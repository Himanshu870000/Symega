public without sharing class Optiva_NPDCreationCallout {

    static Optiva_NPDCreationCallout OptiovaNPDObj;

    public static Optiva_NPDCreationCallout getInstance(){
        if(OptiovaNPDObj==null)
            OptiovaNPDObj = new Optiva_NPDCreationCallout();
        return OptiovaNPDObj;
    }

    
    public Map<String,String> createProject(String body){
        Map<String,String> responseMap = new Map<String,String>();
        System.debug('Body------'+body);
        try{
            if(Utility.isOptivaSyncingEnable()){

                String endPoint = 'callout:Optiva'+Constants.OPTIVA_CREATE_PROJECT_ENDPOINT;

                DateTime startDate = System.now();

                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');

                req.setEndpoint(endPoint);
                req.setHeader('content-type', 'application/json');
                req.setHeader('x-functions-key', Constants.OPTIVA_AUTH_HEADER);
                req.setBody(body);
                req.setHeader('Content-length', String.valueOf(body.length()));
                req.setTimeout(60 * 1000);
                HttpResponse resp = http.send(req);

                DateTime endDate = System.now();
                
                HttpUtility.createLog(req,resp,startDate,endDate);
                
                if(resp.getStatusCode()==200 || resp.getStatusCode()==201){
                    responseMap.put('status','Success');
                    responseMap.put('code',String.valueOf(resp.getStatusCode()));
                    responseMap.put('message',resp.getBody());
                    return responseMap;
                }else{
                    HandleBusinessException.captureCalloutError('Optiva_NPDCreationCallout','createProject',body,resp.getStatusCode(),resp.getBody());    
                }

             

                responseMap.put('status','Failure');
                responseMap.put('code',String.valueOf(resp.getStatusCode()));
                responseMap.put('message',resp.getBody());
                
                System.debug('Response-----' + resp.getBody());
                return responseMap;
            }else{
                responseMap.put('status','Failure');
                responseMap.put('code','404');
                responseMap.put('message',Constants.OPTIVA_SYNCING_ENABLE_MSG);
                return responseMap;
            }
        }catch(Exception e){
            HandleBusinessException.captureError('Optiva_NPDCreationCallout','createProject',e);
            responseMap.put('status','Failure');
            responseMap.put('code','404');
            responseMap.put('message',Constants.OPTIVA_NO_RESPONSE_MSG);
            return responseMap;
        }
    }
}