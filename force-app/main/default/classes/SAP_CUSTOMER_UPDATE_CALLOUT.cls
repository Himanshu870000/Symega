public without sharing class SAP_CUSTOMER_UPDATE_CALLOUT {

    //TODO:- Change endpoint with customer update, haven't recieved from SAP Team Yet
    public static String syncCustomersWithSAP(String recId){
        
        String endpoint      = 'callout:SAP_CUSTOMER_UPDATE'+Constants.SAP_UPDATE_CUSTOMER_ENDPOINT;
        String tokenEndPoint = 'callout:SAP_CUSTOMER_UPDATE'+Constants.SAP_UPDATE_CUSTOMER_REQ_TOKEN;
        
        Map<String,String> tokenMap = SAPRequestTokenHeader.getInstance().getCSRFToken(tokenEndPoint, Constants.SAP_CUSTOMER_AUTH_HEADER);//'VwjYxecZl9_yUv2pLtoLHA==';
        String cookies = tokenMap.get('cookies');
        String token = tokenMap.get('token');

        if(token=='Failed')
            return 'Failed to reach target system';

        Account acc = getCustomer(recId);
        String body = getCustomerWrapper(acc);

        System.debug('AUTH TOKEN ------ '+token);
        System.debug('BODY-----'+body);

        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Content-Type','application/json');
        headerMap.put('X-CSRF-Token',token);
        headerMap.put('Cookie',cookies);
        //headerMap.put('Authorization',HTTPUtility.getSAPCalloutHeader(Constants.SAP_CUSTOMER_AUTH_HEADER));

        Map<String,String> respMap = HTTPUtility.getInstance().httpReqHelper(headerMap,'POST',body,endpoint);

        System.debug('ResponseMapXXX----'+respMap);

        if(respMap.get('code')!='200' && respMap.get('code')!='201'){
            return 'Failed - API STATUS CODE - '+respMap.get('code')+respMap.get('message');
        }

        return 'Success';
    }

    public static Account getCustomer(String recId){
        return [Select Id,Name,Customer_Code_SAP__c,RecordType.Name,BillingStreet,BillingPostalCode,BillingCity,BillingCountry,BillingState,Owner.Name,Owner.Email,
        Tax_Type__c,GST_number__c,PAN_Number__c,Account_Segment__c,CurrencyIsoCode,Delivery_Plant__c,Customer_Type__c,Payment_terms__c,(Select Id,Name,Email,Phone From Contacts),
        Tax_Collected_At_Source__c,FSSAI__c,User__r.Name,User__r.SAP_USER_CODE__c,Transportation_Terms__c,Owner.SAP_USER_CODE__c, Customer_Contact__r.Name, Customer_Contact__r.Phone, Customer_Contact__r.Email From Account Where Id=:recId];
    }

    public static String getCustomerWrapper(Account acc){
        SAP_CUSTOMER_UPDATE_WRAPPER sWrapper = new SAP_CUSTOMER_UPDATE_WRAPPER();
        
        sWrapper.SF_ID = acc.Id;
        sWrapper.CUSTOMER_NAME_2 = acc.Name.length()<40?'':acc.Name.substring(40,acc.Name.length());
        sWrapper.STATE = Utility.getPickVal('Account','BillingStateCode').get(acc.BillingState);
        sWrapper.TAX_TYPE = acc.Tax_Type__c!=null ? acc.Tax_Type__c:'';   
        sWrapper.CUSTOMER_SAP_CODE = acc.Customer_Code_SAP__c;

        sWrapper.CUSTOMER_NAME = acc.Name.length()>40?acc.Name.substring(0,40):acc.Name;
        sWrapper.STREET_2 = acc.BillingStreet;
        sWrapper.STREET_3 = acc.BillingStreet;
        sWrapper.STREET = acc.BillingStreet;
        sWrapper.POSTAL_CODE = acc.BillingPostalCode.replaceAll('\\s+','');
        sWrapper.CITY = acc.BillingCity;
        sWrapper.COUNTRY = Utility.getPickVal('Account','BillingCountryCode').get(acc.BillingCountry);
        //sWrapper.SALES_EMP = acc.Owner.Name;
        sWrapper.SALES_EMP = acc.Owner.SAP_USER_CODE__c;
        sWrapper.CUSTOMER_CATEGORY = acc.RecordType.Name;
        //sWrapper.BUSINESS_HEAD_NAME = acc.User__r.Name;
        sWrapper.BUSINESS_HEAD_NAME = acc.User__r.SAP_USER_CODE__c;
        sWrapper.GSTIN_NUMBER = acc.GST_number__c!=null?acc.GST_number__c:'';
        sWrapper.PAN_NUMBER = acc.PAN_Number__c!=null?acc.PAN_Number__c:'';
        sWrapper.CUSTOMER_GROUP = acc.Account_Segment__c!=null?acc.Account_Segment__c:'';
        sWrapper.DELIVERY_PLANT = acc.Delivery_Plant__c!=null?acc.Delivery_Plant__c:'';
        sWrapper.DOMESTIC_EXPORT = acc.Customer_Type__c!=null?acc.Customer_Type__c:'';
        sWrapper.PAYMENT_TERMS = acc.Payment_terms__c!=null?acc.Payment_terms__c:'';
        sWrapper.ACC_OWNER_EMAIL = acc.Owner.Email;
        sWrapper.FSSAI_NUMBER = acc.FSSAI__c!=null?String.valueOf(acc.FSSAI__c):'';
        sWrapper.TRANSPORTATION_TERMS = acc.Transportation_Terms__c!=null?acc.Transportation_Terms__c:'';
        sWrapper.CUSTOMER_CONTACT_INFO = createConWrapper(acc);
        
        sWrapper.XCURRENCY = acc.CurrencyIsoCode;
        sWrapper.TCS = acc.Tax_Collected_At_Source__c!=null?acc.Tax_Collected_At_Source__c:'';
        
        String body = JSON.serialize(sWrapper);
        body = body.replace('XCURRENCY','CURRENCY');

        return body;
    }

    public static List<SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER> createConWrapper(Account acc){
        // List<SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER> sWrappers = new List<SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER>();

        // for(Contact con : acc.Contacts){
        //     SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER sConWrapper = new SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER();

        //     sConWrapper.name = con.Name;
        //     sConWrapper.phone = con.Phone;
        //     sConWrapper.email = con.Email;

        //     sWrappers.add(sConWrapper);
        // }

        // return sWrappers;

        List<SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER> sWrappers = new List<SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER>();
        
        SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER sConWrapper = new SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER();
        sConWrapper.name = acc.Customer_Contact__r.Name;
        sConWrapper.phone = acc.Customer_Contact__r.Phone;
        sConWrapper.email = acc.Customer_Contact__r.Email;
        sWrappers.add(sConWrapper);
        
        return sWrappers;


    }
}