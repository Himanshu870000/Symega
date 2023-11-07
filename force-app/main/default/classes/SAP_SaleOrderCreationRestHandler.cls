public without sharing class SAP_SaleOrderCreationRestHandler {
    
    static SAP_SaleOrderCreationRestHandler soHandlerObj;

    public static SAP_SaleOrderCreationRestHandler getInstance(){
        if(soHandlerObj==null) soHandlerObj = new SAP_SaleOrderCreationRestHandler();
        return soHandlerObj;
    }

    public Map<Id, Opportunity> getOpenOpportunityByCustomer(String customerNumber/* , Set<String> fertCodeSet */) {
        return new Map<Id, Opportunity> ([SELECT Id,(Select Id, Quantity, Quantity_In_KG__c, Quantity_Unit__c, FERT_Code__c, UnitPrice, PricebookEntryId, OpportunityId, Product2Id, Opportunity.Account_Billing_Address__c, Opportunity.Customer_Billing_Address__c, Opportunity.Customer_Billing_Address__r.Customer_Code_SAP__c, Opportunity.Account.Customer_Code_SAP__c, ProductCode FROM OpportunityLineItems /* WHERE  FERT_Code__c IN : fertCodeSet AND FERT_Code__c != null*/) FROM Opportunity WHERE (Account.Customer_Code_SAP__c = : customerNumber OR Customer_Billing_Address__r.Customer_Code_SAP__c =: customerNumber) AND RecordType.Name='One Time' AND StageName != 'Closed Won' AND StageName != 'Closed Lost']);
    }

    public Map<String,OpportunityLineItem> getRequestedProductsByCustCode(Set<String> fertCodeSet,String customerSAPCode){
        Map<String,OpportunityLineItem> prodCodeSet = new Map<String,OpportunityLineItem>();

        List<OpportunityLineItem> olis =  [Select Id, Quantity, Quantity_In_KG__c, Quantity_Unit__c, FERT_Code__c,UnitPrice,PricebookEntryId,Product2Id,Opportunity.Account_Billing_Address__c,Opportunity.Account.Customer_Code_SAP__c,Opportunity.Customer_Billing_Address__r.Customer_Code_SAP__c,Opportunity.Customer_Billing_Address__c,ProductCode From OpportunityLineItem Where FERT_Code__c IN : fertCodeSet AND (Opportunity.Account.Customer_Code_SAP__c = :customerSAPCode OR Opportunity.Customer_Billing_Address__r.Customer_Code_SAP__c =: customerSAPCode) AND FERT_Code__c!=null AND Opportunity.RecordType.Name='One Time' AND Opportunity.StageName = 'Closed Won' ORDER BY CreatedDate DESC];

        for(OpportunityLineItem opli : olis){
            if(!prodCodeSet.containsKey(opli.FERT_Code__c)) //pick latest fert for pricing
                prodCodeSet.put(opli.FERT_Code__c,opli);
        }

        return prodCodeSet;
    }

    public Map<String,OpportunityLineItem> getRequestedProducts(Set<String> fertCodeSet, Set<String> customerSAPCodeSet){
        Map<String,OpportunityLineItem> prodCodeSet = new Map<String,OpportunityLineItem>();

        List<OpportunityLineItem> olis =  [Select Id, Quantity, Quantity_In_KG__c, Quantity_Unit__c, FERT_Code__c,UnitPrice,PricebookEntryId,Product2Id,Opportunity.Account.Customer_Code_SAP__c,ProductCode From OpportunityLineItem Where FERT_Code__c IN : fertCodeSet AND Opportunity.Account.Customer_Code_SAP__c IN :customerSAPCodeSet AND FERT_Code__c!=null AND Opportunity.RecordType.Name='One Time' AND Opportunity.StageName = 'Closed Won' ORDER BY CreatedDate DESC];

        for(OpportunityLineItem opli : olis){
            if(!prodCodeSet.containsKey(opli.FERT_Code__c)) //pick latest fert for pricing
                prodCodeSet.put(opli.FERT_Code__c,opli);
        }

        return prodCodeSet;
    }

    public Pricebook2 getStdPriceBook() {
        return [select id, name from Pricebook2 where isStandard = true limit 1];    
    }


    public String checkIfOrderExists(Set<String> soCodeSet) {
        List<String> existingSONumberList = new List<String>();
        for(Sales_Order__c so: [SELECT SAP_Reference_Code__c FROM Sales_Order__c WHERE SAP_Reference_Code__c IN: soCodeSet]) {
            existingSONumberList.add(so.SAP_Reference_Code__c);
        }
        String responseString = null;
        if(!existingSONumberList.isEmpty()) {
            String soDupes = String.join(existingSONumberList, ',');
            responseString = 'Error: Duplicate SO Numbers:' + soDupes;
        }

        return responseString;
    }
    /* public List<OpportunityLineItem> getAllOppLineItemsBasedOnCustomer(Set<Id> oppSet,String customerSAPCode){
        Map<String,List<OpportunityLineItem>> oppLineItemsBasedOnCustomer = new Map<String,List<OpportunityLineItem>>();
        List<OpportunityLineItem> olis = [Select Id,ProductCode,Plant__c,Quantity,UnitPrice,Opportunity.Parent_Opportunity__c,Opportunity.Account.Customer_Code_SAP__c,PricebookEntryId,Quantity_Unit__c,OpportunityId,Quantity_In_KG__c,FERT_Code__c From OpportunityLineItem Where OpportunityId IN : oppSet And Opportunity.Repeat_Order_Created__c = false AND Opportunity.Account.Customer_Code_SAP__c = :customerSAPCode AND Opportunity.RecordType.Name='One Time'];

        for(OpportunityLineItem oli : olis){
            if(oppLineItemsBasedOnCustomer.containsKey(oli.Opportunity.Account.Customer_Code_SAP__c)){
                oppLineItemsBasedOnCustomer.get(oli.Opportunity.Account.Customer_Code_SAP__c).add(oli);
            }else{
                oppLineItemsBasedOnCustomer.put(oli.Opportunity.Account.Customer_Code_SAP__c,new List<OpportunityLineItem>{oli});
            }
        }

        return oppLineItemsBasedOnCustomer;
    } */

    /* public Map<String,List<OpportunityLineItem>> getOppLineItemsBasedOnCustomer(Set<String> productCode,Set<String> customerSAPCode){
        Map<String,List<OpportunityLineItem>> oppLineItemsBasedOnCustomer = new Map<String,List<OpportunityLineItem>>();

        List<OpportunityLineItem> olis = [Select Id,ProductCode,Plant__c,Quantity,UnitPrice,Opportunity.Parent_Opportunity__c,Opportunity.Account.Customer_Code_SAP__c,PricebookEntryId,Quantity_Unit__c,OpportunityId,Quantity_In_KG__c,FERT_Code__c From OpportunityLineItem Where ProductCode IN : productCode And Opportunity.Repeat_Order_Created__c = false AND Opportunity.Account.Customer_Code_SAP__c IN :customerSAPCode AND Opportunity.RecordType.Name='One Time'];

        for(OpportunityLineItem oli : olis){
            if(oppLineItemsBasedOnCustomer.containsKey(oli.Opportunity.Account.Customer_Code_SAP__c)){
                oppLineItemsBasedOnCustomer.get(oli.Opportunity.Account.Customer_Code_SAP__c).add(oli);
            }else{
                oppLineItemsBasedOnCustomer.put(oli.Opportunity.Account.Customer_Code_SAP__c,new List<OpportunityLineItem>{oli});
            }
        }

        return oppLineItemsBasedOnCustomer;
    } */

    /* public Account getCustomer(String customerSAPCode){
        List<Account> accList = [Select Id,Name From Account Where Customer_Code_SAP__c=:customerSAPCode];
        return accList.isEmpty()?null:accList[0];
    } */

    public Map<String,Account> getCustomerMap(Set<String> customerCodeSet){
        Map<String,Account> accMap = new Map<String,Account>();

        List<Account> accList = [Select Id,Name,Customer_Code_SAP__c From Account Where Customer_Code_SAP__c IN : customerCodeSet];

        for(Account acc : accList){
            accMap.put(acc.Customer_Code_SAP__c,acc);
        }

        return accMap;
    }

    /* public List<Dispatch_Address__c> getCustomerAddress(String accId){
        return [Select Id,City__c,Country__c,Postal_Code__c,State__c,Street__c From Dispatch_Address__c Where Account__c=:accId];
    } */


    public String updateCustomerAddress(SAP_SO_Creation_Wrapper.cls_shipping_address shippingAddress, Id accountId){
        
        /*List<Dispatch_Address__c> dAdress = [Select Id, Address__Street__s, Address__City__s, Address__PostalCode__s, toLabel(Address__StateCode__s), toLabel(Address__CountryCode__s), Account__c 
                                             From Dispatch_Address__c Where Account__c = :accountId];
        
        if(!isDuplicateAddress(dAdress, shippingAddress.CITY, shippingAddress.STATE, shippingAddress.POSTAL_CODE)){
            Dispatch_Address__c address = new Dispatch_Address__c(Address__City__s = shippingAddress.city, Address__CountryCode__s = shippingAddress.country, Address__PostalCode__s = shippingAddress.POSTAL_CODE, 
                                                                  Address__StateCode__s = shippingAddress.STATE, Address__Street__s = shippingAddress.STREET, Account__c = accountId, Customer_Code_SAP__c = shippingAddress.CUST_CODE);
            
            System.debug('--- address not found, inserting new address:'+ address);
            insert address;
        }*/

        Account accRec = [SELECT Id, Shipping_Customer_Code_SAP__c FROM Account WHERE Id =: accountId];
        if(accRec.Shipping_Customer_Code_SAP__c == shippingAddress.CUST_CODE){
            return 'success';
        }
        else{
            List<Dispatch_Address__c> dAdress = [Select Id, Address__Street__s, Address__City__s, Address__PostalCode__s, toLabel(Address__StateCode__s), toLabel(Address__CountryCode__s), Account__c 
                                                 From Dispatch_Address__c Where Account__c =: accountId AND Customer_Code_SAP__c =: shippingAddress.CUST_CODE];
            
            if(dAdress.size() == 0){
                Dispatch_Address__c address = new Dispatch_Address__c(Type__c = 'Shipping', Address__City__s = shippingAddress.city, Address__CountryCode__s = shippingAddress.country, Address__PostalCode__s = shippingAddress.POSTAL_CODE, 
                                                                      Address__StateCode__s = Utility.getPickVal('Dispatch_Address__c','Address__StateCode__s').get(shippingAddress.STATE), Address__Street__s = shippingAddress.STREET, Account__c = accountId, Customer_Code_SAP__c = shippingAddress.CUST_CODE);
                
                System.debug('--- address not found, inserting new address:'+ address);
                insert address;
                return address.Id;
            }
            return dAdress[0].Id;
        }
    }


    /* public void updateCustomerAddress(String accId, List<SAP_SO_Creation_Wrapper.cls_shipping_address> shippingAddress){
        List<Dispatch_Address__c> dAdress = getCustomerAddress(accId);
        List<Dispatch_Address__c> newAddress = new List<Dispatch_Address__c>();

        if(shippingAddress!=null){
            for(SAP_SO_Creation_Wrapper.cls_shipping_address adress : shippingAddress){
                if(dAdress.isEmpty() || !isDuplicateAddress(dAdress,adress.city,adress.state)){
                    newAddress.add(new Dispatch_Address__c(City__c=adress.city,Country__c=adress.country,Postal_Code__c=adress.postal_code,State__c=adress.state,Street__c=adress.street,Account__c=accId));
                }
            }

            if(!newAddress.isEmpty()){
                insert newAddress;
            }
        }
    } */

    public boolean isDuplicateAddress(List<Dispatch_Address__c> dAdress,String city, String state, String postalCode){
        for(Dispatch_Address__c da : dAdress){
            if(da.Address__City__s.equalsIgnoreCase(city) && da.Address__StateCode__s.equalsIgnoreCase(state) && da.Address__PostalCode__s.equalsIgnoreCase(postalCode)){
                return true;     
            }
        }
        return false;
    }

    public Opportunity createOpp(Account acc,String stageName){
        //add close date = today+30;
        //recordType oneTime
        String oneTimeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('One Time').getRecordTypeId();
        Opportunity opp = new Opportunity(Name=acc.Name+'-opp_repeat_order', AccountId=acc.Id, StageName=StageName, CloseDate=System.today(), RecordTypeId=oneTimeRecordTypeId, 
                          Annual_Volume_Full__c = 1, Annual_Volume_in_units__c = 'Kg', Target_Price_Kg__c = 1, End_Use_Category__c = 'Baked Goods',
                          End_Use_Application__c = 'Crackers');
        return opp;
    }

    public OpportunityLineItem createOppLineItem(OpportunityLineItem oli){
        OpportunityLineItem newOLI = oli.clone();
        newOLI.Id = null;
        return newOLI;
    }

    public Sales_Order__c createSO(Account acc, String refCode){
        Sales_Order__c so = new Sales_Order__c(Name = acc.Name + ' Order ' + refCode, Account__c=acc.Id,Created_From_SAP__c = true);
        return so;
    }

    public String syncProducts(List<OpportunityLineItem> oppProducts){
        try{
            update oppProducts;
            return 'Success';
        }catch(DMLException e){
            HandleBusinessException.captureError('SAP_SaleOrderCreationRestService', 'syncProducts', e);
            return e.getMessage();
        }
    }

    public String insertSO(Sales_Order__c so){
        try{
            insert so;
            return 'Success';
        }catch(DMLException e){
            HandleBusinessException.captureError('SAP_SaleOrderCreationRestService', 'insertSO', e);
            return e.getMessage();
        }
    }

    public String insertOpp(Opportunity opp){
        try{
            insert opp;
            return 'Success';
        }catch(DMLException e){
            HandleBusinessException.captureError('SAP_SaleOrderCreationRestService', 'insertOpp', e);
            return e.getMessage();
        }
    }

    /* public OpportunityLineItem syncProduct(SAP_SO_Creation_Wrapper.cls_products upProd, OpportunityLineItem oli){
        oli.Quantity = upProd.quantity;
        oli.Plant__c = upProd.plant;
        oli.Quantity_Unit__c = upProd.quantity_unit;

        return oli;
    } */    
}