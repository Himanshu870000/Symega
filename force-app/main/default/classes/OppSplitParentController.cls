public without sharing class OppSplitParentController {

    @AuraEnabled
     public static List<Opportunity> getRecord(String oppId){
       try {
            System.debug('OppId'+oppId);
            return [Select Id, Account_Billing_Address__c, Customer_Billing_Address__c, Account_Shipping_Address__c, Customer_Shipping_Address__c, Shipping_Country__c, Shipping_Postal_Code__c, Shipping_Street__c, Shipping_State__c, Shipping_City__c, Billing_Country__c, Billing_Postal_Code__c, Billing_Street__c, Billing_City__c, Billing_State__c, Actual_Annual_Potential_Value__c, Target_Price_Kg__c, Annual_Volume_Full__c, Annual_Volume_in_units__c, Name,AccountId,CurrencyIsoCode,TotalOpportunityQuantity,Distributer_Customer__c,Pricebook2Id,End_Use_Application__c,	End_Use_Category__c,(SELECT Id,Name,Quantity,Product2Id,PricebookEntryId,UnitPrice,CurrencyIsoCode,TotalPrice,Packaging_Type__c,FERT_Code__c From OpportunityLineItems), Amount from opportunity where Id=:oppId];
        } catch (Exception e) {
            //HandleBusinessException.captureError('OppSplitParentController', 'getRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Opportunity> createOpp(Opportunity parentOpp,List<OppWrapper> oppWrappers){
        try {

            System.debug('ParentOPPPPP'+parentOpp);
            System.debug('OOPPWRAPPER----'+oppWrappers);
            List<Opportunity> oppList = new List<Opportunity>();
            for(OppWrapper opWrapper:oppWrappers){
                Opportunity opp = new Opportunity();
                opp.Name = opWrapper.oppName;
                opp.AccountId = parentOpp.AccountId;
                opp.TotalOpportunityQuantity = opWrapper.totalQuantity;
                //opp.Amount = opWrapper.totalAmount;
                opp.CurrencyIsoCode = parentOpp.CurrencyIsoCode;
                opp.Pricebook2Id = parentOpp.Pricebook2Id;
                opp.Parent_Opportunity__c = parentOpp.Id;
                opp.StageName = 'New';
                opp.CloseDate = system.today(); //Date.parse(opWrapper.closeDate);
                opp.Next_Order_Date__c = system.today(); //Date.parse(opWrapper.nextOrderDate);
                opp.End_Use_Category__c = parentOpp.End_Use_Category__c;
                opp.End_Use_Application__c = parentOpp.End_Use_Application__c;
                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('One Time').getRecordTypeId();
                
                opp.Annual_Volume_Full__c = parentOpp.Annual_Volume_Full__c;
                opp.Annual_Volume_in_units__c = parentOpp.Annual_Volume_in_units__c;
                opp.Target_Price_Kg__c = parentOpp.Target_Price_Kg__c;
                opp.Actual_Annual_Potential_Value__c = parentOpp.Actual_Annual_Potential_Value__c;

                opp.Billing_City__c = parentOpp.Billing_City__c;
                opp.Billing_State__c = parentOpp.Billing_State__c;
                opp.Billing_Street__c = parentOpp.Billing_Street__c;
                opp.Billing_Postal_Code__c = parentOpp.Billing_Postal_Code__c;
                opp.Billing_Country__c = parentOpp.Billing_Country__c;

                opp.Shipping_City__c = parentOpp.Shipping_City__c;
                opp.Shipping_State__c = parentOpp.Shipping_State__c;
                opp.Shipping_Street__c = parentOpp.Shipping_Street__c;
                opp.Shipping_Postal_Code__c = parentOpp.Shipping_Postal_Code__c;
                opp.Shipping_Country__c = parentOpp.Shipping_Country__c;

                opp.Customer_Shipping_Address__c = parentOpp.Customer_Shipping_Address__c;
                opp.Account_Shipping_Address__c = parentOpp.Account_Shipping_Address__c;
                opp.Customer_Billing_Address__c =  parentOpp.Customer_Billing_Address__c;
                opp.Account_Billing_Address__c = parentOpp.Account_Billing_Address__c;

                if(!String.isEmpty(parentOpp.Distributer_Customer__c)){
                    opp.Distributer_Customer__c = parentOpp.Distributer_Customer__c;
                }
                oppList.add(opp);
            }

            if(!oppList.isEmpty()){
                try{
                    insert oppList;
                }catch(Exception e){
                    HandleBusinessException.captureError('OppSplitParentController', 'createOpp', e);
                }
            }

            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            List<Sales_Order__c> salesList = new List<Sales_Order__c>();

            List<String> oppIdList = new List<String>();

            for(Integer i=0;i<oppList.size();i++){
                Opportunity opp = oppList[i];
                String oppId = opp.Id;
                oppIdList.add(oppId);
                List<LineItemWrapper> products = oppWrappers[i].products;
                for(LineItemWrapper lineWrapper:products){
                    if(lineWrapper.quantityChoosed!=0){
                        OpportunityLineItem oppLineItem = new OpportunityLineItem();
                        oppLineItem.OpportunityId = oppId;
                        oppLineItem.PricebookEntryId = lineWrapper.PricebookEntryId;
                        oppLineItem.Product2Id = lineWrapper.Product2Id;
                        oppLineItem.UnitPrice = lineWrapper.UnitPrice;
                        oppLineItem.Quantity = lineWrapper.quantityChoosed;
                        oppLineItem.Packaging_Type__c = lineWrapper.PackagingType;
                        oppLineItem.FERT_Code__c = lineWrapper.FERT_Code;
                        oppLineItems.add(oppLineItem);
                    }
                }
               // salesList.add(salesOrder);
            }
            try{
                System.debug('OPPLINEITEMS----'+oppLineItems);
                insert oppLineItems;
               // insert salesList;
            }catch (Exception e) {
                HandleBusinessException.captureError('OppSplitParentController', 'createOpp', e);
            }

            //Opportunity parOpp = new Opportunity(Id=parentOpp.Id,StageName='In-Progress');
            //update parOpp;
            
            return [SELECT Id,Account.Name,Name,StageName,RecordType.Name,Type,Amount,TotalOpportunityQuantity,CloseDate,Parent_Opportunity__c,Parent_Opportunity__r.Name FROM Opportunity WHERE RecordType.Name='One Time' AND Id IN:oppIdList];
        } catch (Exception e) {
            HandleBusinessException.captureError('OppSplitParentController', 'createOpp', e);
            System.debug('LineNumber ---'+e.getLineNumber());
            System.debug('get-message ---'+e.getMessage());
            throw new AuraHandledException(e.getMessage()+e.getLineNumber());
        }
    }

    public class OppWrapper{
        @AuraEnabled public String oppName{get;set;}
        @AuraEnabled public String nextOrderDate{get;set;}
        @AuraEnabled public String closeDate{get;set;}
        @AuraEnabled public Integer totalQuantity{get;set;}
        @AuraEnabled public Decimal totalAmount{get;set;}
        @AuraEnabled public List<LineItemWrapper> products{get;set;}  

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

        @AuraEnabled public Boolean accountBillAddress{get;set;}
        @AuraEnabled public Boolean accountShipAddress{get;set;}
        @AuraEnabled public Id customShippingAddress{get;set;}
        @AuraEnabled public Id customBillingAddress{get;set;}

    }

    public class LineItemWrapper {
        @AuraEnabled public String OpportunityId{get;set;}
        @AuraEnabled public String Id{get;set;}
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String Product2Id{get;set;}
        @AuraEnabled public String PackagingType{get;set;}
        @AuraEnabled public String PricebookEntryId{get;set;}
        @AuraEnabled public Integer Quantity{get;set;}
        @AuraEnabled public Decimal UnitPrice{get;set;}
        @AuraEnabled public Decimal TotalPrice{get;set;}
        @AuraEnabled public Integer quantityChoosed{get;set;}
        @AuraEnabled public String quantityUnit{get;set;}
        @AuraEnabled public Decimal amountChoosed{get;set;}
        @AuraEnabled public Integer remainingQuantity{get;set;}
        @AuraEnabled public Decimal remainingAmount{get;set;}
        @AuraEnabled public String FERT_Code{get;set;}
    }

    @AuraEnabled
    public static Map<String, Object> getAllCustomerAddress(String oppId){
        try {
            Map<String, Object> returnWrapperMap = new Map<String, Object>();
            List<CustomerAddressWrapper> customerShippingAddressWrapper = new List<CustomerAddressWrapper>();
            List<CustomerAddressWrapper> customerBillingAddressWrapper = new List<CustomerAddressWrapper>();
            System.debug('--- oppId'+oppId);
            if(!String.isBlank(oppId)) {
                Opportunity oppRec = [Select Id, Name, AccountId, CurrencyIsoCode, TotalOpportunityQuantity, Distributer_Customer__c, Pricebook2Id, End_Use_Application__c, End_Use_Category__c, Account.Name, Account.CurrencyIsoCode, Account.BillingState, Account.BillingStreet, Account.BillingCountry, Account.BillingPostalCode, Account.BillingCity, Account.GST_Number__c, Account.ShippingState, Account.ShippingStreet, Account.ShippingCountry, Account.ShippingCity, Account.ShippingPostalCode, (SELECT Id,Name,Quantity,Product2Id,PricebookEntryId,UnitPrice,CurrencyIsoCode,TotalPrice,Packaging_Type__c,FERT_Code__c From OpportunityLineItems), Amount from opportunity where Id=:oppId];
                
                if(oppRec != null && !String.isBlank(oppRec.Account.BillingCountry)) {
                    customerBillingAddressWrapper.add(new CustomerAddressWrapper('Billing', oppRec.Account.BillingStreet, oppRec.Account.BillingState, oppRec.Account.BillingCountry, oppRec.Account.BillingCity, oppRec.Account.BillingPostalCode, oppRec.Account.GST_Number__c, 'Billing', true));
                    returnWrapperMap.put('ship_selected_index', 0);
                }
                
                if(oppRec != null && !String.isBlank(oppRec.Account.ShippingCountry)) {
                    customerShippingAddressWrapper.add(new CustomerAddressWrapper('Shipping', oppRec.Account.ShippingStreet, oppRec.Account.ShippingState, oppRec.Account.ShippingCountry, oppRec.Account.ShippingCity, oppRec.Account.ShippingPostalCode, oppRec.Account.GST_Number__c, 'Shipping', true));
                    returnWrapperMap.put('bill_selected_index', 0);
                }

                for(Dispatch_Address__c custAddress :[SELECT Id, Address__Street__s, ToLabel(Address__StateCode__s), Address__PostalCode__s, GST_Number__c, ToLabel(Address__CountryCode__s), Address__City__s, Type__c FROM Dispatch_Address__c WHERE Account__c =: oppRec.AccountId]) {

                    if(custAddress.Type__c == 'Billing') {
                        customerBillingAddressWrapper.add(new customerAddressWrapper(custAddress.Id, custAddress.Address__Street__s, custAddress.Address__StateCode__s, custAddress.Address__CountryCode__s, custAddress.Address__City__s, custAddress.Address__PostalCode__s, custAddress.GST_Number__c, custAddress.Type__c, false));
                    }else {
                        customerShippingAddressWrapper.add(new customerAddressWrapper(custAddress.Id, custAddress.Address__Street__s, custAddress.Address__StateCode__s, custAddress.Address__CountryCode__s, custAddress.Address__City__s, custAddress.Address__PostalCode__s, custAddress.GST_Number__c, custAddress.Type__c, false));
                    }
                }

                //System.debug('--- customerAddressWrapper'+customerAddressWrapper);
                returnWrapperMap.put('Opportunity', oppRec);
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
        public String id;
        @auraEnabled
        public String street;
        @auraEnabled
        public String state;
        @auraEnabled
        public String country;
        @auraEnabled
        public String city;
        @auraEnabled
        public String gstNumber;
        @auraEnabled
        public String type;
        @AuraEnabled
        public String postalCode;
        @AuraEnabled
        public Boolean checked;

        public CustomerAddressWrapper(String id, String street, String state, String country, String city, String postalCode, String gstNumber, String type, Boolean checked) {
            this.id = id;
            this.street = street;
            this.state = state;
            this.country = country;
            this.city = city;
            this.gstNumber = gstNumber;
            this.postalCode = postalCode;
            this.type = type;
            this.checked = checked;
        }
    }
}