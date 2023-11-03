public with sharing class OptivaCreateNewProjectAPI {
    
    
    public static string createNPDProject(){
        try {
            String url = 'https://flavourstest.azurewebsites.net/api/CreateNewProject?code=Wu88xu7RQ3CuglqP5a8xKaabp6UEHi6Ib/nLRyM4ulfp02GgKjmYVw==';
            String body = '';

            HTTP http = new HTTP();
            HttpRequest req = new HttpRequest();

            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type','application/json');

            req.setMethod('POST');
            req.setEndpoint(url);
            req.setBody(body);

            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            return JSON.serialize(res.getBody());
        } catch (Exception e) {
            system.debug('Error==>'+e.getMessage());
            system.debug('Error>>><<'+e.getLineNumber());
            HandleBusinessException.captureError('OptivaCreateNewProjectAPI', 'initiateApprovalProcess', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}