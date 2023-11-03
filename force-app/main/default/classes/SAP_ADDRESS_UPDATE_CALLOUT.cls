public without sharing class SAP_ADDRESS_UPDATE_CALLOUT {
    
    //TODO:- Change endpoint with customer update, haven't recieved from SAP Team Yet
    public static String syncAddressCustomersWithSAP(String recId){
        
        String endpoint      = 'callout:SAP_CUSTOMER_UPDATE'+Constants.SAP_UPDATE_CUSTOMER_ENDPOINT;
        String tokenEndPoint = 'callout:SAP_CUSTOMER_UPDATE'+Constants.SAP_UPDATE_CUSTOMER_REQ_TOKEN;
        
        Map<String,String> tokenMap = SAPRequestTokenHeader.getInstance().customerAuthToken(tokenEndPoint);//'VwjYxecZl9_yUv2pLtoLHA==';
        String cookies = tokenMap.get('cookies');
        String token = tokenMap.get('token');
        
        if(token=='Failed')
            return 'Failed to reach target system';
        
        Dispatch_Address__c addr = getAddress(recId);
        String body = getCustomerWrapperByAddress(addr);
        
        System.debug('AUTH TOKEN ------ '+token);
        System.debug('BODY-----'+body);
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Content-Type','application/json');
        headerMap.put('X-CSRF-Token',token);
        headerMap.put('Cookie',cookies);
        headerMap.put('Authorization',HTTPUtility.getAuthHeader());
        
        Map<String,String> respMap = HTTPUtility.getInstance().httpReqHelper(headerMap,'POST',body,endpoint);
        
        System.debug('ResponseMapXXX----'+respMap);
        
        if(respMap.get('code')!='200' && respMap.get('code')!='201'){
            return 'Failed - API STATUS CODE - '+respMap.get('code')+respMap.get('message');
        }
        
        return 'Success';
    }
    
    public static Dispatch_Address__c getAddress(String recId){
        return [Select Id, Name, Account__c, Company_Legal_Name__c, Contact__c, GST_Number__c, Type__c, CurrencyIsoCode, Address__Street__s, Address__PostalCode__s, Address__City__s, toLabel(Address__StateCode__s), toLabel(Address__CountryCode__s), 
                Account__r.Tax_Type__c, Account__r.PAN_Number__c, Account__r.Account_Segment__c, Account__r.Delivery_Plant__c, Account__r.Customer_Type__c, Account__r.Payment_terms__c,
                Account__r.RecordType.Name, SAP_Customer_Code__c, Account__r.User__r.SAP_USER_CODE__c, Account__r.Owner.SAP_USER_CODE__c, Contact__r.Name, Contact__r.Phone, Contact__r.Email,
                Account__r.Tax_Collected_At_Source__c, Account__r.FSSAI__c, Account__r.Transportation_Terms__c From Dispatch_Address__c Where Id=:recId];
    }
    
    
    public static String getCustomerWrapperByAddress(Dispatch_Address__c addressRec){
        
        SAP_CUSTOMER_UPDATE_WRAPPER sWrapper = new SAP_CUSTOMER_UPDATE_WRAPPER();
        
        sWrapper.CUSTOMER_SAP_CODE = addressRec.SAP_Customer_Code__c;
        sWrapper.CUSTOMER_NAME = addressRec.Name.length()>40?addressRec.Name.substring(0,40):addressRec.Name;
        sWrapper.STREET_2 = addressRec.Address__Street__s;
        sWrapper.STREET_3 = addressRec.Address__Street__s;
        sWrapper.STREET = addressRec.Address__Street__s;
        sWrapper.POSTAL_CODE = addressRec.Address__PostalCode__s.replaceAll('\\s+','');
        sWrapper.CITY = addressRec.Address__City__s;
        sWrapper.COUNTRY = Utility.getPickVal('Account','BillingCountryCode').get(addressRec.Address__CountryCode__s);
        sWrapper.SALES_EMP = addressRec.Account__r.Owner.SAP_USER_CODE__c;
        sWrapper.CUSTOMER_CATEGORY = addressRec.Account__r.RecordType.Name;
        sWrapper.BUSINESS_HEAD_NAME = addressRec.Account__r.User__r.SAP_USER_CODE__c;
        sWrapper.GSTIN_NUMBER = addressRec.GST_number__c!=null?addressRec.GST_number__c:'';
        sWrapper.PAN_NUMBER = addressRec.Account__r.PAN_Number__c!=null?addressRec.Account__r.PAN_Number__c:'';
        sWrapper.CUSTOMER_GROUP = addressRec.Account__r.Account_Segment__c!=null?addressRec.Account__r.Account_Segment__c:'';
        sWrapper.DELIVERY_PLANT = addressRec.Account__r.Delivery_Plant__c!=null?addressRec.Account__r.Delivery_Plant__c:'';
        sWrapper.DOMESTIC_EXPORT = addressRec.Account__r.Customer_Type__c!=null?addressRec.Account__r.Customer_Type__c:'';
        sWrapper.PAYMENT_TERMS = addressRec.Account__r.Payment_terms__c!=null?addressRec.Account__r.Payment_terms__c:'';
        sWrapper.ACC_OWNER_EMAIL = addressRec.Owner.Email;
        sWrapper.FSSAI_NUMBER = addressRec.Account__r.FSSAI__c!=null?String.valueOf(addressRec.Account__r.FSSAI__c):'';
        sWrapper.TRANSPORTATION_TERMS = addressRec.Account__r.Transportation_Terms__c!=null?addressRec.Account__r.Transportation_Terms__c:'';
        sWrapper.CUSTOMER_CONTACT_INFO = createConWrapperByAddress(addressRec);
        
        sWrapper.XCURRENCY = addressRec.CurrencyIsoCode;
        sWrapper.TCS = addressRec.Account__r.Tax_Collected_At_Source__c!=null?addressRec.Account__r.Tax_Collected_At_Source__c:'';
        
        String body = JSON.serialize(sWrapper);
        body = body.replace('XCURRENCY','CURRENCY');
        
        return body;
    }
    
    public static List<SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER> createConWrapperByAddress(Dispatch_Address__c addressRec){
        List<SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER> sWrappers = new List<SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER>();
        
        SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER sConWrapper = new SAP_CUSTOMER_UPDATE_WRAPPER.CUSTOMER_CONTACT_WRAPPER();
        sConWrapper.name = addressRec.Contact__r.Name;
        sConWrapper.phone = addressRec.Contact__r.Phone;
        sConWrapper.email = addressRec.Contact__r.Email;
        sWrappers.add(sConWrapper);
        
        return sWrappers;
    }
}