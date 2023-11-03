public without sharing class Optiva_LWC_NPD_Controller {
    
    @AuraEnabled
    public static Project__c getRecordTypeName(String recId){
        System.debug('getRecordTypeName Called');
        try {
            return [Select Id,RecordType.name,Submitted_To_SAP_Optiva__c FROM Project__c where Id =:recId];
        } catch (Exception e) {
            HandleBusinessException.captureError('Optiva_LWC_NPD_Controller','getRecordTypeName',e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,String> syncSample(String recId, String recType){
        try {
            System.debug('syncSample Called');
            System.debug('recId==> ' + recId + ' recType==> ' + recType);
            if(recType=='Project'){
                return Optiva_Callout.projectCreation(recId);
            }else if(recType=='Application'){
                return Optiva_Callout.applicationCreation(recId);
            }else if(recType=='Sample'){
                return Optiva_Callout.sampleCreation(recId); // create sample in optiva or create task for SAP
            }else{
                System.debug('SOSOSOS----'+recType);
                return Optiva_Callout.techDocCreation(recId);
            }
        } catch (Exception e) {
            HandleBusinessException.captureError('Optiva_LWC_NPD_Controller','syncSample',e);
            throw new AuraHandledException(e.getMessage());
        }
    }

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
    public static void updateAccount(String accId, String dlvryPlant, String custType, String accSeg){
        System.debug('Update Account Method Called');
        try{
            Account accRec = [SELECT Id, Account_Segment__c, Delivery_Plant__c, Customer_Type__c FROM Account WHERE Id =: accId LIMIT 1];
            accRec.Account_Segment__c = accSeg;
            accRec.Delivery_Plant__c = dlvryPlant;
            accRec.Customer_Type__c = custType;
            update accRec;                
        }
        catch(exception e){
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ==> ' + e.getLineNumber());
        }
    }

     @AuraEnabled
    public static oppProdWrapper getProjectAndOppDet(String projId){
        
        try{
            List<string> missingFieldsList = new List<string>();
            List<Project__c> projList = [SELECT Id, Name, Opportunity__c, Opportunity__r.Account_Billing_Address__c, Opportunity__r.Customer_Billing_Address__c, Opportunity__r.AccountId
            FROM Project__c WHERE Id =: projId];
            System.debug('projList---->'+projList);
            
            Id custId;
            oppProdWrapper opWrap = new oppProdWrapper();
            if(projList[0].Opportunity__r.Account_Billing_Address__c){
                custId = projList[0].Opportunity__r.AccountId;
                opwrap.isAccount = true;
            }
            else{
                custId = projList[0].Opportunity__r.Customer_Billing_Address__c;
                opwrap.isAccount = false;
            }
            //opWrap.oliList = projList;

            missingListWrapper selectedAddressWrapper = getOppRelatedAccountDetails(custId, opwrap.isAccount);
            
            opWrap.missingFieldsList = selectedAddressWrapper.missingFieldList;
            opWrap.missingFieldsListForUser = selectedAddressWrapper.missingFieldListForUser;
            opWrap.missingFieldsListForBH = selectedAddressWrapper.missingFieldsListForBH;
            opwrap.accId = projList[0].Opportunity__r.AccountId;
            opwrap.dispId = custId;
            opwrap.userIdList = selectedAddressWrapper.userIdList;
            opwrap.bhIdList = selectedAddressWrapper.bhIdList;
            opwrap.onlyAccMissingFieldList = selectedAddressWrapper.onlyAccMissingFieldList;
            return opWrap;
        }
        catch(Exception e){
            System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception Message-->'+e.getMessage());
            return null;
        }
    }

    private static missingListWrapper getOppRelatedAccountDetails(String accId, Boolean isAccount){
        
        List<String> missingFieldsList = new List<String>();
        List<String> onlyAccMissingFieldList = new List<String>();
        List<string> missingFieldsListForUser = new List<string>();
        List<string> userIdList = new List<string>();
        List<string> missingFieldsListForBH = new List<string>();
        List<string> bhIdList = new List<string>();
        
        missingListWrapper mlw = new missingListWrapper();
        try{
            Id userId;
            Id bhId;
            
            if(isAccount){
                Account accRec = [Select Id, Name, User__c, Customer_Contact__c, Customer_Type__c,OwnerId,CurrencyIsoCode,BillingCity,BillingCountry,BillingStreet,BillingPostalCode,BillingState,Delivery_Plant__c,Account_Segment__c,Transportation_Terms__c,PAN_Number__c,GST_number__c From Account Where Id =: accId];
                userId = accRec.OwnerId;
                bhId = accRec.User__c;
                
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
            else{
                Dispatch_Address__c disRec = [select id, Account__r.User__c, Address__city__s, Address__Street__s, Address__PostalCode__s, toLabel(Address__CountryCode__s), toLabel(Address__StateCode__s),
                Contact__c,Account__c,Type__c, OwnerId, Account__r.Customer_Type__c, Account__r.Account_Segment__c, Account__r.Delivery_Plant__c, CurrencyIsoCode
                from Dispatch_Address__c WHERE Id =:accId];

                userId = disRec.OwnerId;
                bhId = disRec.Account__r.User__c;
                
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
            
            System.debug('missingFieldsList---->'+missingFieldsList); 
            
            userIdList.add(userId);
            List<User> userRec = [SELECT Id, Name, SAP_USER_CODE__c FROM User WHERE Id =: userId];
            if(userRec.size()>0 && userRec[0].SAP_USER_CODE__c == null){
                missingFieldsListForUser.add('SAP_USER_CODE__c');
                mlw.missingFieldListForUser = missingFieldsListForUser;
                mlw.userIdList = userIdList;
            }
            
            bhIdList.add(bhId);
            List<User> bhRec = [SELECT Id, Name, SAP_USER_CODE__c FROM User WHERE Id =: bhId];
            if(bhRec.size()>0 && bhRec[0].SAP_USER_CODE__c == null){
                missingFieldsListForBH.add('SAP_USER_CODE__c');
                mlw.missingFieldsListForBH = missingFieldsListForBH;
                mlw.bhIdList = bhIdList;
            }
            
            mlw.missingFieldList = missingFieldsList;
            mlw.onlyAccMissingFieldList = onlyAccMissingFieldList;
            return mlw;
        }
        catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return mlw;
    }
    
    
    
    @AuraEnabled
    Public Static String updateOppProdList(List<OpportunityLineItem> oppLineList,List<Product2> prod2List){        
        String result;
        try{
            update oppLineList;
            update prod2List;
            //   result = GetFERTCodeController.sendFERTCodeReqEmailNotificaiton(oppLineList[0].OpportunityId);
            result = 'SUCCESS';
        }
        catch(Exception e){
            System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception Message-->'+e.getMessage());
            result = e.getMessage();
        }    
        return result;
    }
    
    public class WrapperData{
        @AuraEnabled
        public  Id prodId ;
        @AuraEnabled
        public Boolean bool ;
        @AuraEnabled 
        public Id prod2Id;
    }
    
    public class missingListWrapper{
        @AuraEnabled
        public List<String> onlyAccMissingFieldList = new list<string>();
        @AuraEnabled
        public List<String> missingFieldList = new list<string>();
        @AuraEnabled
        public  List<String> missingFieldListForUser = new list<string>(); 
        @AuraEnabled
        public  List<String> userIdList = new list<string>();
        @AuraEnabled
        public  List<String> missingFieldsListForBH = new list<string>();
        @AuraEnabled
        public  List<String> bhIdList = new list<string>();
        
    }

    public class oppProdWrapper{
        @AuraEnabled
        public  List<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        @AuraEnabled
        public Id accId;
        @AuraEnabled 
        public Id dispId;
        @AuraEnabled
        public List<String> missingFieldsList = new list<string>();
        @AuraEnabled
        public List<String> missingFieldsListForUser = new list<string>();
        @AuraEnabled
        public List<String> userIdList = new list<string>();
        @AuraEnabled
        public List<String> missingFieldsListForBH = new list<string>();
        @AuraEnabled
        public List<String> bhIdList = new list<string>();
        @AuraEnabled
        public Boolean isAccount;
        @AuraEnabled
        public List<String> onlyAccMissingFieldList = new list<string>();
    }

     @AuraEnabled
    Public Static Map<String,Map<String,List<String>>> GetPicklistValues_Object(){
        string ObjectName,FieldApi_Name;
        
        ObjectName='OpportunityLineItem';FieldApi_Name='Label__c';
        getPickListValuesIntoList(ObjectName,FieldApi_Name);
        
        Map<String,Map<String,List<String>>> ObjectName_FieldApiName_PickListValue=new Map<String,Map<String,List<String>>>();
        
        if(FieldApi_Name=='Label__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name); 
            ObjectName_FieldApiName_PickListValue.put('Label',getPickListValuesIntoList);
            ObjectName='OpportunityLineItem';FieldApi_Name='Ingredients_List_Declared_With_Customer__c';
        }
        if(FieldApi_Name=='Ingredients_List_Declared_With_Customer__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Ingredients_List_Declared_With_Customer',getPickListValuesIntoList);
            ObjectName='OpportunityLineItem';FieldApi_Name='Packaging_Type__c';
            
        }
        if(FieldApi_Name=='Packaging_Type__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Packaging_Type',getPickListValuesIntoList);
            ObjectName='Product2';FieldApi_Name='Plant__c';  
            
        }
        if(FieldApi_Name=='Plant__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Plant',getPickListValuesIntoList);
            ObjectName='Product2';FieldApi_Name='Veg_Nonveg_Logo_In_Label__c';              
        }
        if(FieldApi_Name=='Veg_Nonveg_Logo_In_Label__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('veglogo',getPickListValuesIntoList);
            ObjectName='Account';FieldApi_Name='Delivery_Plant__c';              
        }

        if(FieldApi_Name=='Delivery_Plant__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Delivery_Plant__c',getPickListValuesIntoList);
            ObjectName='Account';FieldApi_Name='Customer_Type__c';  
        }
        if(FieldApi_Name=='Customer_Type__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Customer_Type__c',getPickListValuesIntoList);
            ObjectName='Account';FieldApi_Name='Account_Segment__c';              
        }
        if(FieldApi_Name=='Account_Segment__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Account_Segment__c',getPickListValuesIntoList);
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
        
}