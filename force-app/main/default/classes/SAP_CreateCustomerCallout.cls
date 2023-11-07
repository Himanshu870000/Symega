public without sharing class SAP_CreateCustomerCallout {
    @AuraEnabled
    public static String createCustomer(String recId, Boolean initialSubmission){
        String endpoint      = 'callout:Customer_Creation_SAP'+Constants.SAP_CREATE_CUSTOMER_ENDPOINT;
        String tokenEndPoint = 'callout:Customer_Creation_SAP'+Constants.SAP_CREATE_CUSTOMER_REQ_TOKEN;
        
        Map<String,String> tokenMap = SAPRequestTokenHeader.getInstance().getCSRFToken(tokenEndPoint, Constants.SAP_CUSTOMER_AUTH_HEADER);
        String cookies = tokenMap.get('cookies');
        String token = tokenMap.get('token');
        
        if(token=='Failed')
            return 'Failed to reach target system';
        
        String body = '';
        Account acc = getCustomer(recId);
        body = getCustomerWrapper(acc, initialSubmission);
        
        
        System.debug('AUTH TOKEN ------ '+token);
        System.debug('BODY-----'+body);
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Content-Type','application/json');
        headerMap.put('X-CSRF-Token',token);
        headerMap.put('Cookie',cookies);
        headerMap.put('Authorization',HTTPUtility.getSAPCalloutHeader(Constants.SAP_CUSTOMER_AUTH_HEADER));
        
        Map<String,String> respMap = HTTPUtility.getInstance().httpReqHelper(headerMap,'POST',body,endpoint);
        
        System.debug('ResponseMapXXX----'+respMap);
        
        if(respMap.get('code')!='200' && respMap.get('code')!='201'){
            return 'Failed - API STATUS CODE - '+respMap.get('code')+respMap.get('message');
        }
        
        return 'Success';
    }
    
    public static Account getCustomer(String recId){
        return [Select Id,Name,RecordType.Name,BillingStreet,BillingPostalCode,BillingCity,BillingCountry,BillingState,Owner.Name,Owner.Email,Owner.SAP_USER_CODE__c,
                Tax_Type__c,GST_number__c,PAN_Number__c,Account_Segment__c,CurrencyIsoCode,Delivery_Plant__c,Customer_Type__c,Payment_terms__c,(Select Id,Name,Email,Phone From Contacts),
                Tax_Collected_At_Source__c,FSSAI__c,User__r.Name,User__r.SAP_USER_CODE__c,Transportation_Terms__c, Customer_Contact__r.Name, Customer_Contact__r.Email, Customer_Contact__r.Phone From Account Where Id=:recId];
    }
    
    public static String getCustomerWrapper(Account acc, Boolean initialSubmission){
        SAP_CUSTOMER_WRAPPER sWrapper = new SAP_CUSTOMER_WRAPPER();
        
        sWrapper.SF_ID = acc.Id;
        sWrapper.CUSTOMER_NAME = acc.Name.length()>40?acc.Name.substring(0,40):acc.Name;
        sWrapper.CUSTOMER_NAME_2 = acc.Name.length()<40?'':acc.Name.substring(40,acc.Name.length());
        if(acc.BillingStreet != null) {
            List<String> billingSplit = splitBillingStreet(acc.BillingStreet);
            for(Integer i=0; i< billingSplit.size(); i++) {
                if(i == 0)
                    sWrapper.STREET = billingSplit[0];
                if(i == 1)
                    sWrapper.STREET_2 = billingSplit[1];
                if(i == 2) {
                    sWrapper.STREET_3 = billingSplit[2];
                    break;
                }
                
            }
            
            if(sWrapper.STREET == null)
                sWrapper.STREET = '';
            if(sWrapper.STREET_2 == null)
                sWrapper.STREET_2 = '';
            if(sWrapper.STREET_3 == null)
                sWrapper.STREET_3 = '';
        }
        sWrapper.POSTAL_CODE = acc.BillingPostalCode.replaceAll('\\s+','');
        sWrapper.CITY = acc.BillingCity;
        sWrapper.COUNTRY = Utility.getPickVal('Account','BillingCountryCode').get(acc.BillingCountry);
        sWrapper.STATE = Utility.getPickVal('Account','BillingStateCode').get(acc.BillingState);
        //sWrapper.SALES_EMP = acc.Owner.Name;
        sWrapper.SALES_EMP = acc.Owner.SAP_USER_CODE__c;
        sWrapper.CUSTOMER_CATEGORY = acc.RecordType.Name;
        //sWrapper.BUSINESS_HEAD_NAME = acc.User__r.Name;
        sWrapper.BUSINESS_HEAD_NAME = acc.User__r.SAP_USER_CODE__c;
        sWrapper.TAX_TYPE = initialSubmission ? null : acc.Tax_Type__c!=null ? acc.Tax_Type__c:'';
        sWrapper.GSTIN_NUMBER = initialSubmission ? null : acc.GST_number__c!=null?acc.GST_number__c:'';
        sWrapper.PAN_NUMBER = initialSubmission ? null : acc.PAN_Number__c!=null?acc.PAN_Number__c:'';
        sWrapper.CUSTOMER_GROUP = acc.Account_Segment__c!=null?acc.Account_Segment__c:'';
        sWrapper.XCURRENCY = acc.CurrencyIsoCode;
        sWrapper.DELIVERY_PLANT = acc.Delivery_Plant__c!=null?acc.Delivery_Plant__c:'';
        sWrapper.DOMESTIC_EXPORT = acc.Customer_Type__c!=null?acc.Customer_Type__c:'';
        sWrapper.PAYMENT_TERMS = initialSubmission ? null : acc.Payment_terms__c!=null?acc.Payment_terms__c:'';
        sWrapper.TCS = initialSubmission ? null : acc.Tax_Collected_At_Source__c!=null?acc.Tax_Collected_At_Source__c:'';
        sWrapper.ACC_OWNER_EMAIL = acc.Owner.Email;
        sWrapper.FSSAI_NUMBER = initialSubmission ? null : acc.FSSAI__c!=null?String.valueOf(acc.FSSAI__c):'';
        sWrapper.TRANSPORTATION_TERMS = initialSubmission ? null : acc.Transportation_Terms__c!=null?acc.Transportation_Terms__c:'';
        sWrapper.CUSTOMER_CONTACT_INFO = createConWrapper(acc);
        
        String body = JSON.serialize(sWrapper);
        body = body.replace('XCURRENCY','CURRENCY');
        
        return body;
    }
    
    public static List<SAP_CUSTOMER_WRAPPER.cls_CUSTOMER_CONTACT_INFOS> createConWrapper(Account acc){
        
        // for(Contact con : acc.Contacts){
        //     SAP_CUSTOMER_WRAPPER.cls_CUSTOMER_CONTACT_INFOS sConWrapper = new SAP_CUSTOMER_WRAPPER.cls_CUSTOMER_CONTACT_INFOS();
            
        //     sConWrapper.name = con.Name;
        //     sConWrapper.phone = con.Phone;
        //     sConWrapper.email = con.Email;
            
        //     sWrappers.add(sConWrapper);
        // }

        List<SAP_CUSTOMER_WRAPPER.cls_CUSTOMER_CONTACT_INFOS> sWrappers = new List<SAP_CUSTOMER_WRAPPER.cls_CUSTOMER_CONTACT_INFOS>();
        
        SAP_CUSTOMER_WRAPPER.cls_CUSTOMER_CONTACT_INFOS sConWrapper = new SAP_CUSTOMER_WRAPPER.cls_CUSTOMER_CONTACT_INFOS();
        sConWrapper.name = acc.Customer_Contact__r.Name;
        sConWrapper.phone = acc.Customer_Contact__r.Phone;
        sConWrapper.email = acc.Customer_Contact__r.Email;
        sWrappers.add(sConWrapper);
        
        return sWrappers;
    }
    
    public static List<String> splitBillingStreet(String input) {
        List<String> output = new List<String>();
        if (input.length() <= 40) {
            output.add(input);
        } else {
            String[] words = input.split(' ');
            String currentLine = '';
            for (String word : words) {
                if (String.isEmpty(currentLine) || currentLine.length() + word.length() + 1 <= 40) {
                    // Add word to current line
                    if (!String.isEmpty(currentLine)) {
                        currentLine += ' ';
                    }
                    currentLine += word;
                } else {
                    // Start a new line
                    output.add(currentLine);
                    currentLine = word;
                }
            }
            if (!String.isEmpty(currentLine)) {
                output.add(currentLine);
            }
        }
        return output;
    }
    
}