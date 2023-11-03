public without sharing class OptivaCustomerCreation {
    
    public static String syncCustomer(String recId){
        List<Account> accList = [Select Id,Name,Customer_Type__c,Language__c,Phone,Email__c,GST_number__c,PAN_Number__c,shippingStreet,shippingCity,shippingState,shippingCountry,shippingPostalCode,Account_Segment__c From Account Where Id=:recId];

        System.debug('ACCLIST---'+accList.size());
        if(accList.isEmpty())
            return 'Record not found';
        
        Account acc = accList[0];

        System.debug('ACC-----'+acc);

        OptivaCreateCustomerWrapper oppWrapper = new OptivaCreateCustomerWrapper();
        oppWrapper.sf_id = acc.Id;
        oppWrapper.customer_grouping = 'Distributor';//checkIfBlank(acc.Customer_Type__c);
        oppWrapper.partner_role = checkIfBlank(acc.Account_Segment__c);
        oppWrapper.customer_name = acc.Name;
        oppWrapper.street_2 = '';
        oppWrapper.street_3 = '';
        oppWrapper.street = checkIfBlank(acc.shippingStreet);
        oppWrapper.postal_Code = checkIfBlank(acc.shippingPostalCode);
        oppWrapper.city = checkIfBlank(acc.shippingCity);
        oppWrapper.country = checkIfBlank(acc.shippingCountry);
        oppWrapper.region = checkIfBlank(acc.shippingState);
        oppWrapper.language = checkIfBlank(acc.Language__c); 
        oppWrapper.telephone_number = checkIfBlank(acc.Phone);
        oppWrapper.mobile_number = checkIfBlank(acc.Phone);
        oppWrapper.email = checkIfBlank(acc.Email__c);
        oppWrapper.gstin_number = checkIfBlank(acc.GST_number__c);
        oppWrapper.pan_number = checkIfBlank(acc.PAN_Number__c);
        
        String body = JSON.serialize(oppWrapper);
        System.debug('BODY)))))======'+body);
        return Optiva_CustomerCreationCallout.getInstance().createCustomer(body);
    }

    public static String checkIfBlank(String s){
        return String.isBlank(s)?'':s;
    }


    
}