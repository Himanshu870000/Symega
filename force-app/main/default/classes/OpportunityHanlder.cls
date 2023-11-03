public with sharing class OpportunityHanlder {
    public OpportunityHanlder() {}

    @AuraEnabled
    public static List<Opportunity> getRecord(String oppId){
        try {
            System.debug('OppId'+oppId);
            return [Select Id, Name, AccountId,TotalOpportunityQuantity, Amount, CurrencyIsoCode from opportunity where Id=:oppId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateAddress(String oppId,OppWrapper1 recordAddress){
          String result ;
          System.debug('oppId---->'+oppId);
          System.debug('recordAddress----->'+recordAddress);
         
        //  CustomerAddressWrapper csw = new CustomerAddressWrapper();
        try{

            opportunity oppRec = [SELECT ID,Name FROM Opportunity WHERE ID =:oppId LIMIT 1];
            System.debug('oppRec---->'+oppRec);
             //Billing_State__c, Billing_Street__c, Billing_Country__c, Billing_Postal_Code__c, Billing_City__c, Shipping_State__c, Shipping_Street__c, Shipping_Country__c, Shipping_City__c, Shipping_Postal_Code__c
                // Billing Address
                oppRec.Billing_State__c =  recordAddress.billState;
                oppRec.Billing_Street__c = recordAddress.billStreet;
                oppRec.Billing_Country__c  = recordAddress.billCountry;
                oppRec.Billing_Postal_Code__c = recordAddress.billCode;
                 oppRec.Billing_City__c = recordAddress.billCity;
               // shipping Address
                oppRec.Shipping_State__c =  recordAddress.shipState;
                oppRec.Shipping_Street__c =  recordAddress.shipStreet;
                oppRec.Shipping_Country__c  =  recordAddress.shipCountry;
                oppRec.Shipping_City__c =  recordAddress.shipCity;
                oppRec.Shipping_Postal_Code__c =  recordAddress.shipCode;

                Update oppRec;

                result ='SUCCESS';

        }catch(Exception e){
            System.debug('Exception Line Number--->'+e.getLineNumber());
            System.debug('Exception Message--->'+e.getMessage());
            result = e.getMessage();
        }
        return result;
    }


     public class OppWrapper1{
        @AuraEnabled public String shipCity{get;set;}
        @AuraEnabled public String shipCountry{get;set;}
        @AuraEnabled public String shipCode{get;set;}
        @AuraEnabled public String shipState{get;set;}
        @AuraEnabled public String shipStreet{get;set;}
        
        @AuraEnabled public String billCity{get;set;}
        @AuraEnabled public String billCountry{get;set;}
        @AuraEnabled public String billCode{get;set;}
        @AuraEnabled public String billState{get;set;}
        @AuraEnabled public String billStreet{get;set;}
        
        // @AuraEnabled public Boolean accountBillAddress{get;set;}
        // @AuraEnabled public Boolean accountShipAddress{get;set;}
        // @AuraEnabled public Id customShippingAddress{get;set;}
        // @AuraEnabled public Id customBillingAddress{get;set;}
        
    } 

    @AuraEnabled
    public static String createOpp(OppWrapper wrapper){
        List<OpportunityLineItem> parentOppProductList = [Select Id, OpportunityId,UnitPrice,Quantity From OpportunityLineItem Where OpportunityId=:wrapper.record.Id];
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<OpportunityLineItem> newOppLineItem = new List<OpportunityLineItem>();

        List<OpportunityWrapper> opWrapperList = wrapper.oppList;
        for(OpportunityWrapper opportunityWrap: opWrapperList){
            Opportunity opp = new Opportunity();
            opp.Name = opportunityWrap.Name;
            opp.RecordTypeId = opportunityWrap.RecordTypeId;
            opp.Amount = opportunityWrap.Amount;
            opp.AccountId = opportunityWrap.AccountId;
            opp.Parent_Opportunity__c = opportunityWrap.ParenOpp;
            opp.StageName = opportunityWrap.StageName;
            opp.CloseDate = opportunityWrap.CloseDate;
            opp.Next_Order_Date__c = opportunityWrap.nextOrderDate;
            opp.TotalOpportunityQuantity = opportunityWrap.TotalOpportunityQuantity;
            oppList.add(opp);
        }
        insert oppList;

        for(OpportunityLineItem oppLineItem: parentOppProductList){
            OpportunityLineItem oppItem = oppLineItem;
            // opp.
        }





        
        //List<Opportunity> oppList = wrapper.oppList;
        // insert oppList;

        
        
        // for(Opportunity opp: oppList){

        // }
        // Parent_Opportunity__c
        


        return JSON.serialize(wrapper);
    }

    public class OppWrapper{
        @AuraEnabled public Opportunity record{get;set;}
        @AuraEnabled public List<OpportunityWrapper> oppList{get;set;}  
    }

    public class OpportunityWrapper {
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String RecordTypeId{get;set;}
        @AuraEnabled public Decimal Amount{get;set;}
        @AuraEnabled public String AccountId{get;set;}
        @AuraEnabled public String ParenOpp{get;set;}
        @AuraEnabled public String StageName{get;set;}
        @AuraEnabled public Date CloseDate{get;set;}
        @AuraEnabled public Date nextOrderDate{get;set;}
        @AuraEnabled public Decimal TotalOpportunityQuantity{get;set;}
        @AuraEnabled public Decimal percent{get;set;}
    }

     @AuraEnabled
    public static Map<String, Object> getAllCustomerAddress(String custId){
        try {
            Map<String, Object> returnWrapperMap = new Map<String, Object>();
            List<CustomerAddressWrapper> customerShippingAddressWrapper = new List<CustomerAddressWrapper>();
            List<CustomerAddressWrapper> customerBillingAddressWrapper = new List<CustomerAddressWrapper>();
            System.debug('--- custId'+custId);
            if(!String.isBlank(custId)) {
              //  Opportunity oppRec = [SELECT ID,NAME,AccountId FROM Opportunity WHERE Id = : custId];
              //  Account customerAcc = [SELECT Id, Name, CurrencyIsoCode, BillingState, BillingStreet, BillingCountry, BillingPostalCode, BillingCity, GST_Number__c, ShippingState, ShippingStreet, ShippingCountry, ShippingCity, ShippingPostalCode, AccountSource FROM Account WHERE Id = :oppRec.AccountId];
                  Opportunity customerAcc = [SELECT Id, Name,AccountId, CurrencyIsoCode, Billing_State__c, Billing_Street__c, Billing_Country__c, Billing_Postal_Code__c, Billing_City__c, Shipping_State__c, Shipping_Street__c, Shipping_Country__c, Shipping_City__c, Shipping_Postal_Code__c FROM Opportunity WHERE Id = :custId];
                
                if(customerAcc != null && !String.isBlank(customerAcc.Billing_Country__c)) {
                    customerBillingAddressWrapper.add(new CustomerAddressWrapper('Billing', customerAcc.Billing_Street__c, customerAcc.Billing_State__c, customerAcc.Billing_Country__c, customerAcc.Billing_City__c, customerAcc.Billing_Postal_Code__c, 'Billing', true));  // customerAcc.GST_Number__c,
                    returnWrapperMap.put('ship_selected_index', 0);
                }
                
                if(customerAcc != null && !String.isBlank(customerAcc.Shipping_Country__c)) {
                    customerShippingAddressWrapper.add(new CustomerAddressWrapper('Shipping', customerAcc.Shipping_Street__c, customerAcc.Shipping_State__c, customerAcc.Shipping_Country__c, customerAcc.Shipping_City__c, customerAcc.Shipping_Postal_Code__c, 'Shipping', true));  //customerAcc.GST_Number__c
                    returnWrapperMap.put('bill_selected_index', 0);
                }

                for(Dispatch_Address__c custAddress :[SELECT Id, Address__Street__s, ToLabel(Address__StateCode__s), Address__PostalCode__s, GST_Number__c, ToLabel(Address__CountryCode__s), Address__City__s, Type__c FROM Dispatch_Address__c WHERE Account__c =:customerAcc.AccountId]) {

                    if(custAddress.Type__c == 'Billing') {
                        customerBillingAddressWrapper.add(new customerAddressWrapper(custAddress.Id, custAddress.Address__Street__s, custAddress.Address__StateCode__s, custAddress.Address__CountryCode__s, custAddress.Address__City__s, custAddress.Address__PostalCode__s,  custAddress.Type__c, false)); //custAddress.GST_Number__c,
                    }else {
                        customerShippingAddressWrapper.add(new customerAddressWrapper(custAddress.Id, custAddress.Address__Street__s, custAddress.Address__StateCode__s, custAddress.Address__CountryCode__s, custAddress.Address__City__s, custAddress.Address__PostalCode__s,  custAddress.Type__c, false)); //custAddress.GST_Number__c,
                    }
                }

                //System.debug('--- customerAddressWrapper'+customerAddressWrapper);
                returnWrapperMap.put('account', customerAcc);
                returnWrapperMap.put('customer_ship_addresses', customerShippingAddressWrapper);
                returnWrapperMap.put('customer_bill_addresses', customerBillingAddressWrapper);
                System.debug('--- response Wrapper '+returnWrapperMap);
            }
            return returnWrapperMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class CustomerAddressWrapper {
        @auraEnabled
        public String id {get;set;}
        @auraEnabled
        public String street {get;set;}
        @auraEnabled
        public String state {get;set;}
        @auraEnabled
        public String country {get;set;}
        @auraEnabled
        public String city {get;set;}
        @auraEnabled
        public String gstNumber {get;set;}
        @auraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String postalCode {get;set;}
        @AuraEnabled
        public Boolean checked {get;set;}

        public CustomerAddressWrapper(String id, String street, String state, String country, String city, String postalCode,  String type, Boolean checked) { //String gstNumber,
            this.id = id;
            this.street = street;
            this.state = state;
            this.country = country;
            this.city = city;
           // this.gstNumber = gstNumber;
            this.postalCode = postalCode;
            this.type = type;
            this.checked = checked;
        }
    }
    
}