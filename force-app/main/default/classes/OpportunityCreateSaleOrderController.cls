public without sharing class OpportunityCreateSaleOrderController {
    
    
    @AuraEnabled
    public static void updateUser(String userSAPcode, String userId){
        System.debug('Update User Method Called');
        try{
            User userRec = [SELECT Id, Name, SAP_USER_CODE__c FROM User WHERE Id=:userId LIMIT 1];
            userRec.SAP_USER_CODE__c = userSAPcode;
            update userRec;                
        }
        catch(exception e){
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ==> ' + e.getLineNumber());
        }
    }

    @AuraEnabled
    public static void updateAccount(String accId, String dlvryPlant, String custType, String accSeg, 
                                     String taxType, String taxCollect, String paymentTerms, 
                                     String transportTerms, String Gst, String Pan, Integer fssai){
        System.debug('Update Account Method Called');
        try{
            Account accRec = [SELECT Id, Account_Segment__c, Delivery_Plant__c, Customer_Type__c, 
                              Tax_Type__c, Tax_Collected_At_Source__c, Payment_terms__c, Transportation_Terms__c,  
                              GST_number__c, PAN_Number__c, FSSAI__c
                              FROM Account WHERE Id =: accId LIMIT 1];
            accRec.Account_Segment__c = accSeg != null && accSeg != '' ? accSeg : accRec.Account_Segment__c;
            accRec.Delivery_Plant__c = dlvryPlant != null && dlvryPlant != '' ? dlvryPlant : accRec.Delivery_Plant__c;
            accRec.Customer_Type__c = custType != null && custType != '' ? custType : accRec.Customer_Type__c;
            accRec.Tax_Type__c = taxType != null && taxType != '' ? taxType : accRec.Tax_Type__c;
            accRec.Tax_Collected_At_Source__c = taxCollect != null && taxCollect != '' ? taxCollect : accRec.Tax_Collected_At_Source__c;
            accRec.Payment_terms__c = paymentTerms != null && paymentTerms != '' ? paymentTerms : accRec.Payment_terms__c;
            accRec.Transportation_Terms__c = transportTerms != null && transportTerms != '' ? transportTerms : accRec.Transportation_Terms__c;
            accRec.GST_number__c = Gst != null && Gst != '' ? Gst : accRec.GST_number__c;
            accRec.PAN_Number__c = Pan != null && Pan != '' ? Pan : accRec.PAN_Number__c;
            accRec.FSSAI__c = fssai != null && fssai > 0 ? fssai : accRec.FSSAI__c;
            update accRec;                
        }
        catch(exception e){
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ==> ' + e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static soWrapper getLineItemDetails(String recId){
        List<OpportunityLineItem> lineItems = [SELECT Id, Sales_Order__c, Sales_Order__r.Account__c, Sales_Order__r.Account__r.Initial_SAP_Update__c,
                                               Sales_Order__r.Opportunity__r.Account_Billing_Address__c, Sales_Order__r.Opportunity__r.AccountId, Sales_Order__r.Opportunity__r.Customer_Billing_Address__c
                                               FROM OpportunityLineItem WHERE Sales_Order__c =: recId];
        List<OpportunityLineItem> withFERTcodeItems = [SELECT Id, FERT_Code__c FROM OpportunityLineItem WHERE Sales_Order__c =: recId AND FERT_Code__c != NULL];
        system.debug('withFERTcodeItems.size() -- ' + withFERTcodeItems.size());
        system.debug('lineItems.size() -- ' + lineItems.size());
        
        soWrapper sWrap = new soWrapper();
        sWrap.accRecId = lineItems[0].Sales_Order__r.Account__c;
        sWrap.initiallySubmitted = lineItems[0].Sales_Order__r.Account__r.Initial_SAP_Update__c;
        
        if(lineItems.size() == withFERTcodeItems.size()){
            sWrap.fertCodesPresentForAll = true;
        }
        else{
            sWrap.fertCodesPresentForAll = false;
        }
        
        string accValidationsResp = '';
        Id custId;
        
        if(lineItems[0].Sales_Order__r.Opportunity__r.Account_Billing_Address__c){
            accValidationsResp = Utility.checkSAPCustomerReqField(lineItems[0].Sales_Order__r.Opportunity__r.AccountId);
            custId = lineItems[0].Sales_Order__r.Opportunity__r.AccountId;
            sWrap.isAccount = true;
        }
        else if(lineItems[0].Sales_Order__r.Opportunity__r.Customer_Billing_Address__c != null){
            accValidationsResp = Utility.checkSAPCustomerReqFieldAddress(lineItems[0].Sales_Order__r.Opportunity__r.Customer_Billing_Address__c);
            sWrap.dispRecId = lineItems[0].Sales_Order__r.Opportunity__r.Customer_Billing_Address__c;
            custId = lineItems[0].Sales_Order__r.Opportunity__r.Customer_Billing_Address__c;
            sWrap.isAccount = false;
        }
        
        if(accValidationsResp.equalsIgnoreCase('success')) {
            sWrap.reqFieldsMissing = false;
        }
        else{
            sWrap.reqFieldsMissing = true;
            missingListWrapper getMissingDetails = getOppRelatedAccountDetails(custId, sWrap.isAccount); 
            sWrap.missingFieldsList = getMissingDetails.missingFieldList;
            sWrap.onlyAccMissingFieldList = getMissingDetails.onlyAccMissingFieldList;
            sWrap.userId = getMissingDetails.userId;
            sWrap.bhId = getMissingDetails.bhId;
            sWrap.pickValList = GetPicklistValues_Object();
        }
        
        return sWrap;
    }
    
    public class soWrapper{
        @AuraEnabled
        public boolean initiallySubmitted;
        @AuraEnabled
        public boolean reqFieldsMissing;
        @AuraEnabled
        public Id accRecId;
        @AuraEnabled
        public boolean fertCodesPresentForAll;
        
        @AuraEnabled 
        public Id dispRecId;
        @AuraEnabled
        public List<String> missingFieldsList = new list<string>();
        @AuraEnabled 
        public Id userId;
        @AuraEnabled 
        public Id bhId;
        @AuraEnabled
        public Boolean isAccount;
        @AuraEnabled
        public List<String> onlyAccMissingFieldList = new list<string>();
        
        @AuraEnabled
        public Map<String,Map<String,List<String>>> pickValList = new Map<String,Map<String,List<String>>>();
    }
    
    
    
    public class missingListWrapper{
        @AuraEnabled
        public List<String> onlyAccMissingFieldList = new list<string>();
        @AuraEnabled
        public List<String> missingFieldList = new list<string>();
        @AuraEnabled 
        public Id userId;
        @AuraEnabled 
        public Id bhId;
    }
    
    private static missingListWrapper getOppRelatedAccountDetails(String selectedAddressId, Boolean isAccount){
        
        List<String> missingFieldsList = new List<String>();
        List<String> onlyAccMissingFieldList = new List<String>();
        missingListWrapper mlw = new missingListWrapper();
        
        try{
            Id userId;
            Id bhId;
            
            if(isAccount){
                Account accRec = [Select Id, Initial_SAP_Update__c, Name, User__c, Customer_Contact__c, Customer_Type__c,OwnerId,CurrencyIsoCode,BillingCity,BillingCountry,BillingStreet,BillingPostalCode,BillingState,
                                  Delivery_Plant__c,Account_Segment__c,Transportation_Terms__c,PAN_Number__c,GST_number__c,Tax_Type__c, Payment_terms__c, Tax_Collected_At_Source__c, FSSAI__c 
                                  From Account Where Id =: selectedAddressId];
                userId = accRec.OwnerId;
                bhId = accRec.User__c;
                
                if(!accRec.Initial_SAP_Update__c){
                    if((accRec.Name == null) || (accRec.Name == '')){
                        missingFieldsList.add('Name');
                    }
                    
                    if((accRec.BillingCity == null) || (accRec.BillingCity == '')){
                        missingFieldsList.add('BillingCity');
                    }
                    
                    if(((accRec.BillingState == null) || (accRec.BillingState == '')) && accRec.Customer_Type__c!='Export'){
                        missingFieldsList.add('BillingState');
                        
                    }               
                    
                    if((accRec.BillingStreet == null) || (accRec.BillingStreet == '')){
                        missingFieldsList.add('BillingStreet');
                    }
                    
                    if((accRec.BillingCountry == null) || (accRec.BillingCountry == '')){
                        missingFieldsList.add('BillingCountry');
                    }
                    
                    if((accRec.BillingPostalCode == null) || (accRec.BillingPostalCode == '')){
                        missingFieldsList.add('BillingPostalCode');
                    }
                    
                    if((accRec.Customer_Type__c == null) || (accRec.Customer_Type__c == '')){
                        missingFieldsList.add('Customer_Type__c');
                    }
                    
                    if((accRec.Account_Segment__c == null) || (accRec.Account_Segment__c == '')){
                        missingFieldsList.add('Account_Segment__c');
                    }
                    
                    if((accRec.CurrencyIsoCode == null) || (accRec.CurrencyIsoCode == '')){
                        missingFieldsList.add('CurrencyIsoCode');
                    }
                    if(accRec.Customer_Contact__c == null){
                        missingFieldsList.add('Customer_Contact__c');
                    }                
                    
                    if((accRec.Delivery_Plant__c == null) || (accRec.Delivery_Plant__c == '')){
                        missingFieldsList.add('Delivery_Plant__c');
                    }
                }
                
                if(String.isBlank(accRec.Tax_Type__c)){
                    missingFieldsList.add('Tax_Type__c');
                }
                if(!String.isBlank(accRec.BillingCountry) && accRec.BillingCountry.equalsIgnoreCase('India') && (String.isBlank(accRec.PAN_Number__c) || String.isBlank(accRec.GST_number__c))){
                    if(String.isBlank(accRec.PAN_Number__c)){
                        missingFieldsList.add('PAN_Number__c');
                    }
                    if(String.isBlank(accRec.GST_number__c)){
                        missingFieldsList.add('GST_number__c');
                    }
                }
                if(String.isBlank(accRec.Payment_terms__c)){
                    missingFieldsList.add('Payment_terms__c');
                }
                if(String.isBlank(accRec.Tax_Collected_At_Source__c)){
                    missingFieldsList.add('Tax_Collected_At_Source__c');
                }
                if(accRec.FSSAI__c == null || accRec.FSSAI__c == 0){
                    missingFieldsList.add('FSSAI__c');
                }
                if(String.isBlank(accRec.Transportation_Terms__c)){
                    missingFieldsList.add('Transportation_Terms__c');
                }                
                
            }
            else{
                Dispatch_Address__c disRec = [select id, Initial_SAP_Update__c, Account__r.User__c, Address__city__s, Address__Street__s, Address__PostalCode__s, Address__CountryCode__s, Address__StateCode__s,
                                              Contact__c,Account__c,Type__c, OwnerId, Account__r.Customer_Type__c, Account__r.Account_Segment__c, Account__r.Delivery_Plant__c, CurrencyIsoCode, GST_Number__c,
                                              Account__r.Transportation_Terms__c, Account__r.PAN_Number__c, Account__r.Tax_Type__c, Account__r.Payment_terms__c, Account__r.Tax_Collected_At_Source__c, Account__r.FSSAI__c
                                              from Dispatch_Address__c WHERE Id =: selectedAddressId];
                
                userId = disRec.OwnerId;
                bhId = disRec.Account__r.User__c;
                
                if(!disRec.Initial_SAP_Update__c){
                    if((disRec.Address__city__s == null) || (disRec.Address__city__s == '')){
                        missingFieldsList.add('Address__city__s');
                    }
                    
                    if(((disRec.Address__StateCode__s == null) || (disRec.Address__StateCode__s == '')) && disRec.Account__r.Customer_Type__c!='Export'){
                        missingFieldsList.add('Address__StateCode__s');
                    }               
                    
                    if((disRec.Address__Street__s == null) || (disRec.Address__Street__s == '')){
                        missingFieldsList.add('Address__Street__s');
                    }
                    
                    if((disRec.Address__CountryCode__s == null) || (disRec.Address__CountryCode__s == '')){
                        missingFieldsList.add('Address__CountryCode__s');
                    }
                    
                    if((disRec.Address__PostalCode__s == null) || (disRec.Address__PostalCode__s == '')){
                        missingFieldsList.add('Address__PostalCode__s');
                    }
                    
                    if(disRec.Contact__c == null){
                        missingFieldsList.add('Contact__c');
                    } 
                    
                    if((disRec.CurrencyIsoCode == null) || (disRec.CurrencyIsoCode == '')){
                        missingFieldsList.add('CurrencyIsoCode');
                    }
                    
                    if((disRec.Account__r.Customer_Type__c == null) || (disRec.Account__r.Customer_Type__c == '')){
                        onlyAccMissingFieldList.add('Customer_Type__c');
                    }
                    
                    if((disRec.Account__r.Account_Segment__c == null) || (disRec.Account__r.Account_Segment__c == '')){
                        onlyAccMissingFieldList.add('Account_Segment__c');
                    }
                    
                    if((disRec.Account__r.Delivery_Plant__c == null) || (disRec.Account__r.Delivery_Plant__c == '')){
                        onlyAccMissingFieldList.add('Delivery_Plant__c');
                    }
                }
                
                if(String.isBlank(disRec.Account__r.Tax_Type__c)){
                    onlyAccMissingFieldList.add('Tax_Type__c');
                }
                if(!String.isBlank(disRec.Address__CountryCode__s) && disRec.Address__CountryCode__s.equalsIgnoreCase('India') && (String.isBlank(disRec.Account__r.PAN_Number__c) || String.isBlank(disRec.GST_number__c))){
                    if(String.isBlank(disRec.Account__r.PAN_Number__c)){
                        onlyAccMissingFieldList.add('PAN_Number__c');
                    }
                    if(String.isBlank(disRec.GST_number__c)){
                        onlyAccMissingFieldList.add('GST_number__c');
                    }
                }
                if(String.isBlank(disRec.Account__r.Payment_terms__c)){
                    onlyAccMissingFieldList.add('Payment_terms__c');
                }
                if(String.isBlank(disRec.Account__r.Tax_Collected_At_Source__c)){
                    onlyAccMissingFieldList.add('Tax_Collected_At_Source__c');
                }
                if(disRec.Account__r.FSSAI__c == null || disRec.Account__r.FSSAI__c == 0){
                    onlyAccMissingFieldList.add('FSSAI__c');
                }
                if(String.isBlank(disRec.Account__r.Transportation_Terms__c)){
                    onlyAccMissingFieldList.add('Transportation_Terms__c');
                }                    
                
            }
            
            System.debug('missingFieldsList---->'+missingFieldsList); 
            
            List<User> userRec = [SELECT Id, Name, SAP_USER_CODE__c FROM User WHERE Id =: userId];
            if(userRec.size()>0 && userRec[0].SAP_USER_CODE__c != null){
                userId = null;
            }
            
            List<User> bhRec = [SELECT Id, Name, SAP_USER_CODE__c FROM User WHERE Id =: bhId];
            if(bhRec.size()>0 && bhRec[0].SAP_USER_CODE__c != null){
                bhId = null;
            }
            
            mlw.missingFieldList = missingFieldsList;
            mlw.onlyAccMissingFieldList = onlyAccMissingFieldList;
            mlw.userId = userId;
            mlw.bhId = bhId;
            return mlw;
        }
        catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return mlw;
    }
        
    
    private static Map<String,Map<String,List<String>>> GetPicklistValues_Object(){
        string ObjectName,FieldApi_Name;
        
        ObjectName='Account';FieldApi_Name='Delivery_Plant__c';
        getPickListValuesIntoList(ObjectName,FieldApi_Name);
        
        Map<String,Map<String,List<String>>> ObjectName_FieldApiName_PickListValue=new Map<String,Map<String,List<String>>>();
        
        if(FieldApi_Name=='Delivery_Plant__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Delivery_Plant__c',getPickListValuesIntoList);
            FieldApi_Name='Customer_Type__c';  
        }
        if(FieldApi_Name=='Customer_Type__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Customer_Type__c',getPickListValuesIntoList);
            FieldApi_Name='Account_Segment__c';              
        }
        if(FieldApi_Name=='Account_Segment__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Account_Segment__c',getPickListValuesIntoList);
            FieldApi_Name='Tax_Type__c';              
        }
        if(FieldApi_Name=='Tax_Type__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Tax_Type__c',getPickListValuesIntoList);
            FieldApi_Name='Tax_Collected_At_Source__c';   
        }
        if(FieldApi_Name=='Tax_Collected_At_Source__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Tax_Collected_At_Source__c',getPickListValuesIntoList);
            FieldApi_Name='Payment_terms__c';              
        }
        if(FieldApi_Name=='Payment_terms__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Payment_terms__c',getPickListValuesIntoList);
            FieldApi_Name='Transportation_Terms__c';   
        }
        if(FieldApi_Name=='Transportation_Terms__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Transportation_Terms__c',getPickListValuesIntoList);
        }
        
        return ObjectName_FieldApiName_PickListValue;
    }
    
    public static Map<String,List<String>> getPickListValuesIntoList(String ObjectName,String FieldApiName){
        
        Map<String,List<String>> ObjectName_FieldApiName_PickListValue=new  Map<String,List<String>>();
        List<String> pickListValuesList= new List<String>();
        
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(FieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());  
        }
        ObjectName_FieldApiName_PickListValue.put(FieldApiName,pickListValuesList);
        return ObjectName_FieldApiName_PickListValue;
    }

    
    @AuraEnabled
    public static string sendSONotification(String id){
        try {
            Sales_Order__c so = [Select Id,Account__c,Account__r.Customer_Code_SAP__c,
                                 Opportunity__r.Account_Billing_Address__c,Opportunity__r.Customer_Billing_Address__c,
                                 Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c
                                 From Sales_Order__c Where Id=:id];
            
            String customerCode = '';
            if(so.Opportunity__r.Account_Billing_Address__c){
                customerCode = so.Opportunity__r.Account.Customer_Code_SAP__c;
            }
            else if(so.Opportunity__r.Customer_Billing_Address__c != null){
                customerCode = so.Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c;
            }
            
            if(String.isEmpty(customerCode)){
                return 'Customer Creation Initiated';    
            }
            Utility.sendSONotification(id);
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateSO(Sales_Order__c so){
        try {
            so.Send_Sales_Ops_Email__c = true;
            update so;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateOpp(String soId){
        try {
            Sales_Order__c so = [Select Id,Account__c,Account__r.Customer_Code_SAP__c,Opportunity__r.AccountId,
                                 Opportunity__r.Account_Billing_Address__c,Opportunity__r.Customer_Billing_Address__c,
                                 Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c
                                 From Sales_Order__c Where Id=:soId];
            
            String customerCode = '';
            Boolean isAccount = false;
            Id custId;
            if(so.Opportunity__r.Account_Billing_Address__c){
                customerCode = so.Opportunity__r.Account.Customer_Code_SAP__c;
                isAccount = true;
                custId = so.Opportunity__r.AccountId;
            }
            else if(so.Opportunity__r.Customer_Billing_Address__c != null){
                customerCode = so.Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c;
                isAccount = false;
                custId = so.Opportunity__r.Customer_Billing_Address__c;
            }
            
            if(String.isEmpty(customerCode)){
                String response  = SAP_CreateCustomerCallout.createCustomer(custId, isAccount);
                System.debug('ResponseXXX----'+response);
                if(response!='Success'){
                    return response;
                }
                else{
                    if(isAccount){
                        Account acc = [SELECT Id, SAP_Update_Customer__c FROM Account WHERE Id =: custId];
                        if(acc.SAP_Update_Customer__c != true){
                            acc.SAP_Update_Customer__c = true;
                            update acc;
                        }
                    }
                }
                return updateSO(so);
            }
            
            // if(String.isEmpty(so.Account__r.Customer_Code_SAP__c)){
            //     String accValidationsResp = Utility.checkSAPCustomerReqField(so.Account__c);
            //     if(accValidationsResp.equalsIgnoreCase('success')) {
            //         String response  = SAP_CreateCustomerCallout.createCustomer(so.Account__c);
            //         System.debug('ResponseXXX----'+response);
            //         if(response!='Success')
            //             return response;
            //         return updateSO(so);
            //     }
            //     else{
            //         return 'Customer key fields missing: '+accValidationsResp;
            //     }
            // }
            
            String oppId = [Select Opportunity__c from Sales_Order__c Where Id =:soId].Opportunity__c;
            if(!String.isEmpty(oppId)){
                Opportunity opp = new Opportunity(Id=oppId, StageName='Closed Won');
                update opp;
            }
            
            Sales_Order__c sOrder = new Sales_Order__c(Id=soId, Submission_Date__c=Date.Today());
            update sOrder;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void updateOppInBulk(List<Id> accIds){
        try {
            List<Utility.SOWRAPPER> SOWRAPPERS = new List<Utility.SOWRAPPER>();
            Map<Id,Sales_Order__c> soMap = new Map<Id,Sales_Order__c>([Select Id,Name,Opportunity__c, OwnerId, Owner.Email, Submission_Date__c From Sales_Order__c Where Account__c IN : accIds AND Send_Sales_Ops_Email__c = true]);
            
            if(!soMap.isEmpty()){
                Map<Id,Opportunity> oppToUpdate = new Map<Id,Opportunity>();
                
                Map<Id,OpportunityLineItem> oppLineItems = new Map<Id,OpportunityLineItem>([SELECT Id, Product2.Family,Sales_Order__c FROM OpportunityLineItem WHERE Sales_Order__c IN : soMap.keySet()]);
                
                Map<Id,List<OpportunityLineItem>> saleOrderLineItemsMap = new Map<Id,List<OpportunityLineItem>>();
                
                for(OpportunityLineItem oppItem : oppLineItems.values()){
                    if(saleOrderLineItemsMap.containsKey(oppItem.Sales_Order__c)){
                        saleOrderLineItemsMap.get(oppItem.Sales_Order__c).add(oppItem);
                    }else{
                        saleOrderLineItemsMap.put(oppItem.Sales_Order__c,new List<OpportunityLineItem>{oppItem});
                    }
                }
                
                for(Id key : saleOrderLineItemsMap.keySet()){
                    Utility.SOWRAPPER sWrapper = new Utility.SOWRAPPER();
                    sWrapper.soId = key;
                    sWrapper.oppProdsList = saleOrderLineItemsMap.get(key);
                    sWrapper.replyToEmail = soMap.containsKey(key) ? soMap.get(key).Owner.Email : UserInfo.getUserEmail();
                    sWrapper.senderID = soMap.containsKey(key) ? soMap.get(key).OwnerId : UserInfo.getUserId();
                    SOWRAPPERS.add(sWrapper);                
                }
                
                System.debug('calling utility');
                Utility.sendBulkSONotification(SOWRAPPERS);
                
                for(Sales_Order__c so : soMap.values()){
                    so.Send_Sales_Ops_Email__c = false;
                    so.Submission_Date__c = Date.Today();
                    oppToUpdate.put(so.Opportunity__c,new Opportunity(Id=so.Opportunity__c,StageName='Closed Won'));
                }
                
                update soMap.values();
                update oppToUpdate.values();
            }
        } catch (Exception e) {
            
        }
    }
    
    
    
    
}