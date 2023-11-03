public without sharing class OptivaAddressCreation {

    public static String syncCustomer(String recId){
        List<Dispatch_Address__c> addressList = [Select Id, Name, Account__c, Account__r.Language__c, Contact__c, GST_Number__c, Type__c, CurrencyIsoCode, Address__Street__s, Address__PostalCode__s, Address__City__s, toLabel(Address__StateCode__s), toLabel(Address__CountryCode__s), 
                Account__r.Tax_Type__c, Account__r.PAN_Number__c, Account__r.Account_Segment__c, Account__r.Delivery_Plant__c, Account__r.Customer_Type__c, Account__r.Payment_terms__c,
                Account__r.RecordType.Name, SAP_Customer_Code__c, Account__r.User__r.SAP_USER_CODE__c, Account__r.Owner.SAP_USER_CODE__c, Contact__r.Name, Contact__r.Phone, Contact__r.Email,
                Account__r.Tax_Collected_At_Source__c, Account__r.FSSAI__c, Account__r.Transportation_Terms__c, Account__r.Email__c,Account__r.Phone From Dispatch_Address__c Where Id =: recId];

        System.debug('addressList---'+addressList.size());
        if(addressList.isEmpty())
            return 'Record not found';
        
        Dispatch_Address__c addr = addressList[0];

        System.debug('addr-----'+addr);

        OptivaCreateCustomerWrapper oppWrapper = new OptivaCreateCustomerWrapper();
        oppWrapper.sf_id = addr.Id;
        oppWrapper.customer_grouping = 'Distributor';//checkIfBlank(acc.Customer_Type__c);
        oppWrapper.partner_role = checkIfBlank(addr.Account__r.Account_Segment__c);
        oppWrapper.customer_name = addr.Name;
        oppWrapper.street_2 = '';
        oppWrapper.street_3 = '';
        oppWrapper.street = checkIfBlank(addr.Address__Street__s);
        oppWrapper.postal_Code = checkIfBlank(addr.Address__PostalCode__s);
        oppWrapper.city = checkIfBlank(addr.Address__City__s);
        oppWrapper.country = checkIfBlank(addr.Address__CountryCode__s);
        oppWrapper.region = checkIfBlank(addr.Address__StateCode__s);
        oppWrapper.language = checkIfBlank(addr.Account__r.Language__c); 
        oppWrapper.telephone_number = checkIfBlank(addr.Account__r.Phone);
        oppWrapper.mobile_number = checkIfBlank(addr.Account__r.Phone);
        oppWrapper.email = checkIfBlank(addr.Account__r.Email__c);
        oppWrapper.gstin_number = checkIfBlank(addr.GST_Number__c);
        oppWrapper.pan_number = checkIfBlank(addr.Account__r.PAN_Number__c);
        
        String body = JSON.serialize(oppWrapper);
        System.debug('BODY)))))======'+body);
        return Optiva_CustomerCreationCallout.getInstance().createCustomer(body);
    }

    public static String checkIfBlank(String s){
        return String.isBlank(s)?'':s;
    }

}