public without sharing class SAP_Project_Creation_Callout {
    
    public static Map<String,String> createProject(String recId){
        Map<String,String> responseMap = new Map<String,String>();
        String endPoint = 'callout:Project_Creation_SAP'+Constants.SAP_CREATE_PROJECT_ENDPOINT;
        String tokenEndPoint = 'callout:Project_Creation_SAP'+Constants.SAP_CREATE_PROJECT_REQ_TOKEN;
        
        Project__c proj = getProject(recId);
        String body = getProjectCreationWrapper(proj);

        String customerCode = '';
        Boolean isAccount = false;
        Id custId;
        
        if(proj.Opportunity__r.Account_Billing_Address__c){
            customerCode = proj.Opportunity__r.Account.Customer_Code_SAP__c;
            isAccount = true;
            custId = proj.Opportunity__r.AccountId;
        }
        else if(proj.Opportunity__r.Customer_Billing_Address__c != null){
            customerCode = proj.Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c;
            isAccount = false;
            custId = proj.Opportunity__r.Customer_Billing_Address__c;
        }
        
        if(String.isEmpty(customerCode)){
            String response = SAP_CreateCustomerCallout.createCustomer(custId, isAccount);
            
            responseMap.put('code',response=='Success'?'200':'400');
            responseMap.put('message',response=='Success'?'Customer creating in progress...':response);
            responseMap.put('status',response=='Success'?'Success':'Failure');
            
            if(response=='Success'){
                //Utility.scheduleAutoSyncSampleToOptiva();
                if(isAccount){
                    Account acc = [SELECT Id, SAP_Update_Customer__c FROM Account WHERE Id =: proj.Opportunity__r.AccountId];
                    if(acc.SAP_Update_Customer__c != true){
                        acc.SAP_Update_Customer__c = true;
                        update acc;
                    }
                }
                else{
                    Dispatch_Address__c addr = [SELECT Id, SAP_Update_Customer__c FROM Dispatch_Address__c WHERE Id =: proj.Opportunity__r.Customer_Billing_Address__c];
                    if(addr.SAP_Update_Customer__c != true){
                        addr.SAP_Update_Customer__c = true;
                        update addr;
                    }
                }

                proj.Submit_Sample_To_Optiva__c = true;
                update proj;
            }
            else{
                proj.Submit_Sample_To_Optiva__c = true;
                proj.Error_Occured_On_Submitting_To_Optiva__c = true;
                proj.Error_Message_On_Submitting_To_Optiva__c = 'SAP Customer creation response Failure: '+response;
                update proj;
            }
            return responseMap;
        }
        
        System.debug('Body---'+body);
        
        Map<String,String> tokenMap = SAPRequestTokenHeader.getInstance().getCSRFToken(tokenEndPoint,Constants.SAP_PROJECT_AUTH_HEADER);
        String cookies = tokenMap.get('cookies');
        String token = tokenMap.get('token');
        
        if(token=='Failed'){
            responseMap.put('code','400');
            responseMap.put('message','Failed to fetch access_token');
            responseMap.put('status','Failure');
        }
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Content-Type','application/json');
        headerMap.put('X-CSRF-Token',token);
        headerMap.put('Cookie',cookies);
        headerMap.put('Authorization',HTTPUtility.getSAPCalloutHeader(Constants.SAP_PROJECT_AUTH_HEADER));
        
        responseMap = HTTPUtility.getInstance().httpReqHelper(headerMap,'POST',body,endPoint);
        return responseMap;
    }
    
    public static Map<String,String> getExceptionMap(Exception e){
        
        Map<String,String> exceptionMap = new Map<String,String>();
        exceptionMap.put('status','Failure');
        exceptionMap.put('code','400');
        exceptionMap.put('message',e.getMessage());
        
        HandleBusinessException.captureError('SAP_Project_Creation_Callout','createProject',e);
        return exceptionMap;
    }
    
    
    public static Project__c getProject(String recId){
        return [Select Id,Name,Project_Name__c,Error_Occured_On_Submitting_To_Optiva__c,Error_Message_On_Submitting_To_Optiva__c,Country_Regulation__c,Customer_Comments__c,Customer_Launch_Date__c,Expected_Annual_Value__c,Customer_Feedback__c,Product_approval_format_by_customer__c,Additional_Comments__c,Application_method__c,Matching_Target_details__c,Dosage_Guidelines__c,Cost_in_use__c,Sales_head_review__c,Opportunity__r.AccountId, Opportunity__r.Account.Customer_Code_SAP__c,Owner.Name, Expected_Shelf_Life__c,Expected_Volume_Unit__c,If_Private_Label__c,Ingredient_Specific_If_Any__c,Minimum_order_quantity__c,Minimum_order_quantity_unit__c,Other_Application_Methods__c,Other_Project_Composition__c,Packaging_Unit__c,Proposed_date_of_dispatch__c,
                Prototype_Feedback__c,Quantity__c,Quantity_Unit__c,Regulatory_Requirements__c,Required_End_Date__c,Sampling_Quantity_details__c,Sampling_Quantity_Unit__c,Solubility_Preference__c,Solublity__c,Specific_inputs_by_customer__c,Sugar__c,Supplier_Legal_Status__c,Target_Date__c,Target_Price__c,Wet_Dry__c,Where_Used__c,
                Status__c,Reason_for_rejection__c,Allergin_Free_Decleration__c,End_Application_Category__c,Opportunity__r.Account.Customer_Type__c,GMO_Status__c,Halal_Certification__c,Kosher_Certification__c,Legal_Status_as_per_US__c,Legal_Status_as_per_EU__c,Organic_Certification__c, SAP_User_Code__c, End_Use_category__c, Product_Family__c, Customers_Contact__r.FirstName, Customers_Contact__r.LastName, Customers_Contact__r.Phone, Type_Of_PR__c,
                Opportunity__r.Account_Billing_Address__c, Opportunity__r.Customer_Billing_Address__c, Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c
                From Project__c Where Id=:recId];
    }
    
    
    public static String getProjectCreationWrapper(Project__c proj){
        List<ProcessInstance> pworkList = [SELECT CreatedById,CreatedDate,Id,IsDeleted,LastActorId,LastModifiedById,ProcessDefinitionId,Status,SubmittedById,TargetObjectId FROM ProcessInstance Where TargetObjectId =:proj.Id AND Status='Approved' AND LastActorId!=null];
        
        if(pworkList.isEmpty() && proj.Type_Of_PR__c == 'New Product')
            return 'Approval Pending';
        
        
        User u ;
        if(!pworkList.isEmpty()){
            u =  [Select Id,Name From User Where Id=:pworkList[0].LastActorId];
        }    
        
        // User u =  [Select Id,Name From User Where Id=:pworkList[0].LastActorId];
        
        SAP_PROJECT_CREATION_WRAPPER wrapper = new SAP_PROJECT_CREATION_WRAPPER();
        wrapper.CUSTOMER_CODE = proj.Opportunity__r.Account_Billing_Address__c ? proj.Opportunity__r.Account.Customer_Code_SAP__c : proj.Opportunity__r.Customer_Billing_Address__r.SAP_Customer_Code__c;
        wrapper.REF_CODE = proj.Id;
        wrapper.PROJECT_CODE = proj.Id;
        wrapper.PROJECT_INITIATED_BY = proj.SAP_User_Code__c;
        wrapper.APP_NAME = proj.Project_Name__c;
        wrapper.PROJECT_CATEGORY = proj.End_Use_category__c;
        wrapper.PROJECT_NAME = proj.Project_Name__c;
        wrapper.APPROVER_NAME = u!=null?u.Name:'';
        wrapper.SALES_HEAD_REVIEW = proj.Owner.Name;
        wrapper.CUSTOMER_CONTACT = proj.Customers_Contact__r.FirstName + ' ' + proj.Customers_Contact__r.LastName;
        wrapper.CUSTOMER_PHONE = proj.Customers_Contact__r.Phone;
        wrapper.COUNTRY_REGULATION = getCountryRegulation(proj.Country_Regulation__c);
        wrapper.COST_IN_USE = proj.Cost_in_use__c;
        wrapper.CUSTOMER_COMMENTS = checkIfBlank(proj.Customer_Comments__c);
        wrapper.DOSAGE_GUIDELINE = checkIfBlank(proj.Dosage_Guidelines__c);
        wrapper.MATCHING_TARGET_DETAILS = checkIfBlank(proj.Matching_Target_details__c);
        wrapper.PRODUCT_APP_CUSTOMER = checkIfBlank(proj.Product_approval_format_by_customer__c);
        wrapper.ADDITIONAL_COMMENTS = checkIfBlank(proj.Additional_Comments__c);
        wrapper.APPLICATION_METHOD = checkIfBlank(proj.Application_method__c);
        wrapper.END_APPLICATION_CATEGORY = checkIfBlank(proj.End_Application_Category__c);
        wrapper.CUSTOMER_FEEDBACK = checkIfBlank(proj.Customer_Feedback__c);
        wrapper.CUSTOMER_LAUNCH_DATE = proj.Customer_Launch_Date__c!=null?String.valueOf(proj.Customer_Launch_Date__c):'';
        wrapper.EXPECTED_ANNUAL_VALUE = proj.Expected_Annual_Value__c;
        wrapper.EXPECTED_SHELF_LIFE = checkIfBlank(proj.Expected_Shelf_Life__c);
        wrapper.EXPECTED_VOLUME_UNIT = checkIfBlank(proj.Expected_Volume_Unit__c);
        wrapper.IF_PRIVATE_LABEL = checkIfBlank(proj.If_Private_Label__c);//privateLabelToBoolean(proj.If_Private_Label__c);
        wrapper.INGREDIENT_SPECIFIC_IF_ANY = proj.Ingredient_Specific_If_Any__c;
        wrapper.MINIMUM_ORDER_QUANTITY = proj.Minimum_order_quantity__c;
        //wrapper.MINIMUM_ORDER_QUANTITY_UNIT = proj.Minimum_order_quantity_unit__c;
        wrapper.OTHER_APPLICATION_METHODS = proj.Other_Application_Methods__c;
        wrapper.OTHER_PROJECT_COMPOSITION = checkIfBlank(proj.Other_Project_Composition__c);
        wrapper.PACKAGING_UNIT = checkIfBlank(proj.Packaging_Unit__c);
        wrapper.PROPOSED_DATE_OF_DISPATCH = proj.Proposed_date_of_dispatch__c!=null?String.valueOf(proj.Proposed_date_of_dispatch__c):'';
        wrapper.PROTOTYPE_FEEDBACK = checkIfBlank(proj.Prototype_Feedback__c);
        wrapper.QUANTITY = proj.Quantity__c;
        wrapper.QUANTITY_UNIT = proj.Quantity_Unit__c;
        wrapper.REGULATORY_REQUIREMENTS = checkIfBlank(proj.Regulatory_Requirements__c);
        wrapper.REQUIRED_END_DATE = proj.Required_End_Date__c!=null?String.valueOf(proj.Required_End_Date__c):'';
        wrapper.SAMPLING_QUANTITY_DETAILS = proj.Sampling_Quantity_details__c;
        wrapper.SAMPLING_QUANTITY_UNIT = proj.Sampling_Quantity_Unit__c;
        wrapper.SOLUBILITY_PREFERENCE = checkIfBlank(proj.Solubility_Preference__c);
        wrapper.SOLUBLITY = proj.Solublity__c;
        wrapper.SPECIFIC_INPUTS_BY_CUSTOME = proj.Specific_inputs_by_customer__c;
        wrapper.SUGAR = proj.Sugar__c!=null?String.valueOf(proj.Sugar__c):'';
        wrapper.SUPPLIER_LEGAL_STATUS = checkIfBlank(proj.Supplier_Legal_Status__c);
        wrapper.TARGET_DATE = proj.Target_Date__c!=null?String.valueOf(proj.Target_Date__c):'';
        wrapper.TARGET_PRICE = proj.Target_Price__c;
        wrapper.WET_DRY = checkIfBlank(proj.Wet_Dry__c);
        wrapper.WHERE_USED = checkIfBlank(proj.Where_Used__c);
        wrapper.STATUS = proj.Status__c;
        wrapper.REASON_FOR_REJECTION = checkIfBlank(proj.Reason_for_rejection__c);
        wrapper.ALLERGIN_FREE_DECLERATION = proj.Allergin_Free_Decleration__c;
        wrapper.GMO_STATUS = proj.GMO_Status__c;
        wrapper.HALAL_CERTIFICATION = proj.Halal_Certification__c;
        wrapper.KOSHER_CERTIFICATION = proj.Kosher_Certification__c;
        wrapper.LEGAL_STATUS_AS_PER_US = checkIfBlank(proj.Legal_Status_as_per_US__c);
        wrapper.LEGAL_STATUS_AS_PER_EU = checkIfBlank(proj.Legal_Status_as_per_EU__c);
        wrapper.ORGANIC_CERTIFICATION = proj.Organic_Certification__c;
        wrapper.ORDER_TYPE = proj.Opportunity__r.Account.Customer_Type__c;
        wrapper.PRODUCT_FAMILY = proj.Product_Family__c == Constants.FAMILY_PLANT_BASED ? Constants.SAP_PLANT_BASED_FAMILY_MAPPING_VALUE : proj.Product_Family__c;
        wrapper.TYPE_OF_PR = getTypeOfPr(!String.isBlank(proj.Type_Of_PR__c) ? replaceSpace(proj.Type_Of_PR__c) : '');
        return JSON.serialize(wrapper);
    }
    
    private static String getTypeOfPr(String typeOfPrSF){
        SAP_Type_Of_PR_Mapping__mdt mc = SAP_Type_Of_PR_Mapping__mdt.getInstance(typeOfPrSF);
        if(mc!=null){
            return mc.Label;
        }
        return null;
    }
    
    private static String replaceSpace(String text) {
        if(!String.isBlank(text)) {
            return text.replaceAll(' ','_');
        }
        return text;
    }
    
    public static String checkIfBlank(String s){
        return s==null?'':s;
    }
    
    public static boolean privateLabelToBoolean(String s){
        return s=='Yes';
    }
    
    public static String getCountryRegulation(String cReg){
        if(String.isBlank(cReg)) return '';
        return cReg.contains(';')?cReg.split(';')[0]:cReg;
    }
}