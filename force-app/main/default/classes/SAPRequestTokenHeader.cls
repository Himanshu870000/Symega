public without sharing class SAPRequestTokenHeader {
    
    static SAPRequestTokenHeader tokenHeaderInstance;
    public static SAPRequestTokenHeader getInstance(){
        if(tokenHeaderInstance==null)
            tokenHeaderInstance = new SAPRequestTokenHeader();
        return tokenHeaderInstance;     
    }

    public Map<String,String> requestToken(String tokenEndPoint){
        Map<String,String> respMap = new Map<String,String>();

        String endpoint = 'callout:SAP'+tokenEndPoint;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('X-CSRF-Token', 'Fetch');

        req.setHeader('Authorization', getAuthHeader());

        HttpResponse resp = http.send(req);

        String cookies = resp.getHeader('Set-Cookie');
        System.debug('Cookies----'+cookies);

        if(resp.getStatusCode()!=200 && resp.getStatusCode()!=201){
            respMap.put('token','Failed');
            respMap.put('cookies',null);

            return respMap;
        }

        
        respMap.put('token',resp.getHeader('x-csrf-token'));
        respMap.put('cookies',cookies);
        return respMap;
    }

    public Map<String,String> requestAuthToken(String endPoint){
        Map<String,String> respMap = new Map<String,String>();

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endPoint);
        req.setHeader('X-CSRF-Token', 'Fetch');

        req.setHeader('Authorization', requestAuthHeader());

        HttpResponse resp = http.send(req);

        String cookies = resp.getHeader('Set-Cookie');
        System.debug('Cookies----'+cookies);

        if(resp.getStatusCode()!=200 && resp.getStatusCode()!=201){
            respMap.put('token','Failed');
            respMap.put('cookies',null);

            return respMap;
        }

        
        respMap.put('token',resp.getHeader('x-csrf-token'));
        respMap.put('cookies',cookies);
        return respMap;
    }

    public Map<String,String> customerAuthToken(String endPoint){
        Map<String,String> respMap = new Map<String,String>();

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endPoint);
        req.setHeader('X-CSRF-Token', 'Fetch');

        req.setHeader('Authorization', getAuthHeader());

        HttpResponse resp = http.send(req);

        String cookies = resp.getHeader('Set-Cookie');
        System.debug('Cookies----'+cookies);

        if(resp.getStatusCode()!=200 && resp.getStatusCode()!=201){
            respMap.put('token','Failed');
            respMap.put('cookies',null);

            return respMap;
        }

        
        respMap.put('token',resp.getHeader('x-csrf-token'));
        respMap.put('cookies',cookies);
        return respMap;
    }


    public static String getAuthHeader(){
       // sandbox
        String username = 'clss';
        String password = 'clss@1234';

        //pord
        // String username = 'Basis';
        // String password = 'Integration@4321';

        Blob headerValue = Blob.valueOf(username + ':' + password);
        return 'Basic ' +EncodingUtil.base64Encode(headerValue);
    }

    public static String requestAuthHeader(){
        //sandbox
        String username = 'clss';
        String password = 'clssqas';

        //prod
        // String username = 'Basis';
        // String password = 'Integration@4321';

        Blob headerValue = Blob.valueOf(username + ':' + password);
        return 'Basic ' +EncodingUtil.base64Encode(headerValue);
    }

    public  Map<String,String> getCSRFToken(String endpoint, String credsName){
        Map<String,String> respMap = new Map<String,String>();
        DateTime sDate = System.now();
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endPoint);
        req.setHeader('X-CSRF-Token', 'Fetch');

        req.setHeader('Authorization', getAuthrizationHeader(credsName));

        HttpResponse resp = http.send(req);
        DateTime eDate = System.now();
        //HTTPUtility.createLog(req,resp,sDate,eDate);

        String cookies = resp.getHeader('Set-Cookie');
        System.debug('Cookies----'+cookies);

        if(resp.getStatusCode()!=200 && resp.getStatusCode()!=201){
            respMap.put('token','Failed');
            respMap.put('cookies',null);

            return respMap;
        }

        
        respMap.put('token',resp.getHeader('x-csrf-token'));
        respMap.put('cookies',cookies);
        return respMap;
    }

    public static String getAuthrizationHeader(String credsName){
        SAP_API_Config__c config = SAP_API_Config__c.getValues(credsName);

        String username = config.Username__c;
        String password = config.Password__c;

        Blob headerValue = Blob.valueOf(username + ':' + password);
        return 'Basic ' +EncodingUtil.base64Encode(headerValue);
    }
}