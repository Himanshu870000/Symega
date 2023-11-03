public class SAP_UpdateFERTCallout {
    
    public static String updateFERT(List<String> recIds){
        
        String endpoint = 'callout:SAP'+System.Label.SAP_PR_TOKEN;
        
        Map<String,String> tokenMap = SAPRequestTokenHeader.getInstance().requestToken(System.Label.SAP_TOKEN);//'VwjYxecZl9_yUv2pLtoLHA==';
        String cookies = tokenMap.get('cookies');//'SAP_SESSIONID_SMD_200=21m-9n9qrNMY4XJn-zCnZIt2ArVljhHtrSkADTo-F08%3d; sap-usercontext=sap-client=200';
        String token = tokenMap.get('token');

        //String token = SAPRequestTokenHeader.getInstance().requestToken(System.Label.SAP_TOKEN);

        if(token=='Failed')
            return 'Failed to reach target system';

        List<PIR__c> pirList = getPIRList(recIds);
        String body = updatePIRWrapper(pirList);

        System.debug('AUTH TOKEN ------ '+token);
        System.debug('BODY-----'+body);

        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Content-Type','application/json');
        headerMap.put('X-CSRF-Token',token);
        headerMap.put('Authorization',HTTPUtility.getAuthHeader());

        Map<String,String> respMap = HTTPUtility.getInstance().httpReqHelper(headerMap, 'POST', body, endPoint);

        if(respMap.get('code')!='200' || respMap.get('code')!='201'){
            return 'Failed - API STATUS CODE - '+respMap.get('code')+respMap.get('message');
        }

        return 'Success';
    }
    
    public static List<PIR__c> getPIRList(List<String> recIds){
        return [Select Id, Customer_Code__c, Product_Code_HALB__c, Quantity_in_KG__c, Dispatch_Plan__c From PIR__c Where Id IN: recIds];
    }

    public static string updatePIRWrapper(List<PIR__c> pirList){
        
        List<PIRWrapper> pirWrapperList = new List<PIRWrapper>();
        
        for(PIR__c pir : pirList ){
            PIRWrapper pWrapper = new PIRWrapper();
            pWrapper.CUSTOMER_CODE = pir.Customer_Code__c;
            pWrapper.MATERIAL_CODE = pir.Product_Code_HALB__c;
            pWrapper.QUANTITY = pir.Quantity_in_KG__c;
            pWrapper.DISPATCH_PLAN = pir.Dispatch_Plan__c; 
            pirWrapperList.add(pWrapper);
        }
        String jsonBody = JSON.serialize(pirWrapperList);
        
        return jsonBody;
    }
    
    public class PIRWrapper{
        public String CUSTOMER_CODE;
        public String MATERIAL_CODE;
        public Decimal QUANTITY;
        public Date DISPATCH_PLAN;
    }

}