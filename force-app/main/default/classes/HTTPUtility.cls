public with sharing class HTTPUtility {
    
    static final String NO_RESPONSE = 'NO_RESPONSE';
    static final String HTTP_ERROR = 'ERROR WHILE MAKING REQUEST';
    static HTTPUtility httpUtilityInstance;
    static Symega_Configuration__c symegaConfig;
    
    private HTTPUtility(){}

    public static HTTPUtility getInstance(){
        if(httpUtilityInstance==null){
            httpUtilityInstance = new HTTPUtility();
            symegaConfig = Symega_Configuration__c.getAll()?.get('Symega Configuration');
        }
        return httpUtilityInstance;    
    }

    public Map<String,String> httpReqHelper(Map<String,String> headerMap, String method, String jsonBody, String endPoint) {
        
        System.debug('ReqJsonBody----'+jsonBody);

        DateTime sDate = System.now();
        Map<String,String> respMap = new Map<String,String>();

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(method);
        httpRequest.setBody(jsonBody);
        httpRequest.setTimeout(600);
        
        system.debug('headerMap -- ' + headerMap);

        if(!headerMap.isEmpty()){
            for(String key : headerMap.keySet()){
                httpRequest.setHeader(key,headerMap.get(key)); 
            }
        }
        System.debug('METHOD---'+method); 
        System.debug('EndPoint-- '+endPoint);
        System.debug('X-CSRF-Token- '+httpRequest.getHeader('X-CSRF-Token'));
        System.debug('Authorization- '+httpRequest.getHeader('Authorization'));
        System.debug('Cookies- '+httpRequest.getHeader('Cookie'));


        try {
            Http http = new Http();
            HTTPResponse response = http.send(httpRequest);

            DateTime eDate = System.now();



            System.debug('RESPONSE BODY----'+response.getBody());

            System.debug('AUTHHEADER-----'+httpRequest);

            respMap.put('code',String.valueOf(response.getStatusCode()));
            respMap.put('status',response.getStatusCode() == 200 || response.getStatusCode() == 201?'Success':'Failure');

            createLog(httpRequest,response,sDate,eDate);

            if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                respMap.put('message',response.getBody());
                return respMap;
            }
            respMap.put('message',response.getBody());

            return respMap;
        }catch (Exception e) {
            System.debug('--- e-message '+ e.getMessage() + 'at line no -- ' + e.getLineNumber());
            HandleBusinessException.captureError('HttpUtility', 'httpReqHelper', e);

            respMap.put('code','404');
            respMap.put('status','Failure');
            respMap.put('message',HTTP_ERROR);
            return respMap;
        }
    }


    public static void createLog(HttpRequest httpReq, HttpResponse httpRes,DateTime sTime, DateTime eTime) {
        Integration_Log__c logger = new Integration_Log__c();

        logger.Integration_Type__c = 'CALLOUT';
        logger.Start_Date_And_Time__c = sTime;
        logger.End_Date_And_Time__c = eTime;

        if(httpReq != null) {
            logger.HTTP_Method__c = httpReq.getMethod();
            logger.Request_Body__c = httpReq.getBody();
            logger.EndPoint__c = httpReq.getEndPoint();
        }
        if(httpRes != null) {
            logger.Response_Body__c = httpRes.getBody();
            logger.Response_Status_Code__c = httpRes.getStatusCode();
        }
        insert logger;
    }

    public void createServiceLogger(String reqBody, String resBody, String endPoint, String method, Integer statusCode, DateTime startDatetime, DateTime endDateTime) {
        try {
            if(symegaConfig != null && symegaConfig.Enable_Apex_Service_Logger__c) {
                Integration_Log__c logger = new Integration_Log__c();
                logger.HTTP_Method__c = method;
                logger.Integration_Type__c = 'SERVICE';
                logger.Request_Body__c = reqBody;
                logger.Response_Body__c = resBody;
                logger.EndPoint__c = endPoint;
                logger.Response_Status_Code__c = statusCode;
                logger.Start_Date_And_Time__c = startDatetime;
                logger.End_Date_And_Time__c = endDatetime;
                insert logger;
            }
        }catch(DMLException e){
            System.debug('--- e-message '+ e.getMessage());
            System.debug('--- e-line-no '+ e.getLineNumber());
            HandleBusinessException.captureError('HttpUtility', 'httpReqHelper', e);
        }
    }

    public static String getAuthHeader(){

        //sandbox
        String username = 'clss';
        String password = 'clss@1234';

        //prod
        // String username = 'Basis';
        // String password = 'Integration@4321';
        

        Blob headerValue = Blob.valueOf(username + ':' + password);
        return 'Basic ' +EncodingUtil.base64Encode(headerValue);
    }

    public static String getSAPCalloutHeader(String calloutName){
        SAP_API_Config__c config = SAP_API_Config__c.getValues(calloutName);

        String username = config.Username__c;
        String password = config.Password__c;

        Blob headerValue = Blob.valueOf(username + ':' + password);
        return 'Basic ' +EncodingUtil.base64Encode(headerValue);
    }
}