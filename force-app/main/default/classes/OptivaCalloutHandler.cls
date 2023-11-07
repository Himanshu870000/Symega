public without sharing class OptivaCalloutHandler {
    
    public static OptivaCalloutHandler handlerInstance;

    private OptivaCalloutHandler(){}
    public static OptivaCalloutHandler getInstance(){
        if(handlerInstance==null)
            handlerInstance = new OptivaCalloutHandler();
        return handlerInstance;            
    }

    public Map<String,String> projectCreationHandler(String recId){
        Map<String,String> responseMap = new Map<String,String>();

        try{
            Project__c project = getProject(recId);

            if(!Utility.isOptivaSyncingEnable()){
                return createResponse('Failed','400','Sorry, Integrations are disabled');
            }

            if(project.Submitted_To_SAP_Optiva__c){
                return createResponse('Failed','400','Already Synced');
            }

            boolean hasAccountAndSchedule = false;

            String customerCode = '';
            String customerCodeOPTIVA = '';
            Boolean isAccount = false;
            Id custId;

            if(project.Opportunity__r.Account_Billing_Address__c){
                customerCode = project.Opportunity__r.Account.Customer_Code_SAP__c;
                customerCodeOPTIVA = project.Opportunity__r.Account.Customer_Code_OPTIVA__c;
                isAccount = true;
                custId = project.Opportunity__r.AccountId;
            }
            else if(project.Opportunity__r.Customer_Billing_Address__c != null){
                customerCode = project.Opportunity__r.Customer_Billing_Address__r.Customer_Code_SAP__c;
                customerCodeOPTIVA = project.Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c;
                isAccount = false;
                custId = project.Opportunity__r.Customer_Billing_Address__c;
            }

            if(!project.Product_Family__c.contains(Constants.FLAVOUR_API_NAME) && !project.Product_Family__c.contains(Constants.COLOR_API_NAME) && String.isEmpty(customerCode)){
                
                if(project.Type_Of_PR__c == 'New Product' && project.Approval_Status__c == 'Under Approval'){
                    return createResponse('Failed','400','Project is under approval');
                }
                
                String accValidationsResp = '';
                if(isAccount){
                    accValidationsResp = Utility.checkForInitialSubmission(project.Opportunity__r.AccountId);
                }
                else{
                    accValidationsResp = Utility.checkForInitialSubmissionAddress(project.Opportunity__r.Customer_Billing_Address__c);
                }

                if(accValidationsResp.equalsIgnoreCase('Success')){                    
                    if(isAccount){
                        Account acc = [SELECT Id, Initial_SAP_Update__c FROM Account WHERE Id =: project.Opportunity__r.AccountId];
                        if(acc.Initial_SAP_Update__c != true){
                            acc.Initial_SAP_Update__c = true;
                            update acc;
                        }
                        
                        if(!project.Opportunity__r.Account.Submitted_to_SAP__c){
                            system.debug('cust Id -- ' + custId);
                            String resp = SAP_CreateCustomerCallout.createCustomer(project.Opportunity__r.AccountId, true);
                            if(resp.equalsIgnoreCase('Success')){
                                updateAccountSubmittion(project.Opportunity__r.AccountId,'SAP');
                            }
                        }
                    }
                    else{
                        Dispatch_Address__c addr = [SELECT Id, Initial_SAP_Update__c FROM Dispatch_Address__c WHERE Id =: custId];
                        if(addr.Initial_SAP_Update__c != true){
                            addr.Initial_SAP_Update__c = true;
                            update addr;
                        }
                        
                        if(!project.Opportunity__r.Customer_Billing_Address__r.Submitted_to_SAP__c){
                            system.debug('cust Id -- ' + custId);
                            String resp = SAP_CreateAddressCustomerCallout.createCustomer(project.Opportunity__r.Customer_Billing_Address__c, true);
                            if(resp.equalsIgnoreCase('Success')){
                                updateAddressSubmittion(project.Opportunity__r.Customer_Billing_Address__c,'SAP');
                            }
                        }
                    }
                    hasAccountAndSchedule = true;
                }
                else{
                    return createResponse('Failure','400',accValidationsResp);
                }
            }

            System.debug('customerCodeOPTIVA -- '+ customerCodeOPTIVA);

            if((project.Product_Family__c.contains(Constants.FLAVOUR_API_NAME) || project.Product_Family__c.contains(Constants.COLOR_API_NAME)) && String.isEmpty(customerCodeOPTIVA)){
                System.debug('OPSPSPOSOPOSPS--');
                if(isAccount){
                    if(!project.Opportunity__r.Account.Submitted_to_Optiva__c){
                        String resp = OptivaCustomerCreation.syncCustomer(project.Opportunity__r.AccountId);
                        if(resp=='Success'){
                            updateAccountSubmittion(project.Opportunity__r.AccountId,'Optiva');
                        }
                    }
                }
                else{
                    if(!project.Opportunity__r.Customer_Billing_Address__r.Submitted_to_Optiva__c){
                        String resp = OptivaAddressCreation.syncCustomer(project.Opportunity__r.Customer_Billing_Address__c);
                        if(resp=='Success'){
                            updateAddressSubmittion(project.Opportunity__r.Customer_Billing_Address__c,'Optiva');
                        }
                    }
                }
                hasAccountAndSchedule = true;
            }

            if(hasAccountAndSchedule){
                project.Submit_Sample_To_Optiva__c = true;
                //project.Submitted_for_Customer_Creation__c = true;
                //project.Submitted_for_BH_Approval__c = false;
                update project;
                return createResponse('Success','200','Customer creation in progress');
            }

            if(project.Product_Family__c.contains(Constants.FLAVOUR_API_NAME) || project.Product_Family__c.contains(Constants.COLOR_API_NAME)){
                responseMap = Optiva_NPDCreationCallout.getInstance().createProject(getProjectWrapper(project));

                if(responseMap!=null && responseMap.get('status')=='Success'){
                    Project__c prod = new Project__c(Id=recId, Submitted_To_SAP_Optiva__c=true, Status__c = Constants.PROJECT_SUBMITTION_STATUS,Sample_Submitted_Date__c=System.today());
                    prod.Submit_Sample_To_Optiva__c = false;
                    prod.Error_Occured_On_Submitting_To_Optiva__c = false;
                    prod.Error_Message_On_Submitting_To_Optiva__c = '';
                    update prod;
                }
                else{
                    Utility.handlerErrorException(project.Id,responseMap.toString());
                }
                return responseMap;
            }
            else{
                responseMap = SAP_Project_Creation_Callout.createProject(recId);
                if(responseMap.get('status')=='Success' && !responseMap.get('message').equalsIgnoreCase('Customer creating in progress...')){
                    Project__c prod = new Project__c(Id=recId, Submitted_To_SAP_Optiva__c=true, Status__c = Constants.PROJECT_SUBMITTION_STATUS,Sample_Submitted_Date__c=System.today());
                    prod.Submit_Sample_To_Optiva__c = false;
                    prod.Error_Occured_On_Submitting_To_Optiva__c = false;
                    prod.Error_Message_On_Submitting_To_Optiva__c = '';
                    //prod.Submitted_for_BH_Approval__c = true;
                    //prod.Submitted_for_Customer_Creation__c = false;
                    update prod;
                }
                else if(responseMap.get('status')!='Success' && responseMap.get('message').equalsIgnoreCase('Customer creating in progress...')){
                    Utility.handlerErrorException(project.Id,responseMap.toString());
                }
                return responseMap;
            }
        }catch(Exception e){
            Project__c prod = new Project__c(Id=recId, Error_Occured_On_Submitting_To_Optiva__c=true,Submit_Sample_To_Optiva__c = true, Error_Message_On_Submitting_To_Optiva__c = e.getMessage());
            update prod;
            system.debug('ProjectAPI Error -- ' + e.getMessage());
            system.debug('ProjectAPI Line No -- ' + e.getLineNumber());
            return getExceptionMap(e);
        }
    }

    public Map<String,String> applicationCreationHandler(String recId){
        Map<String,String> responseMap = new Map<String,String>();
        Project__c project = getApplication(recId);

        try{
            if(!Utility.isOptivaSyncingEnable()){
                return createResponse('Failed','400','Sorry, Integrations are disabled');
            }
    
            if(project.Submitted_To_SAP_Optiva__c){
                return createResponse('Failure','400','Already Synced');
            }

            String customerCodeOPTIVA = '';
            Boolean isAccount = false;
            
            if(project.Opportunity__r.Account_Billing_Address__c){
                customerCodeOPTIVA = project.Opportunity__r.Account.Customer_Code_OPTIVA__c;
                isAccount = true;
            }
            else if(project.Opportunity__r.Customer_Billing_Address__c != null){
                customerCodeOPTIVA = project.Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c;
                isAccount = false;
            }
    
            boolean hasAccountAndSchedule = false;
            if(String.isEmpty(customerCodeOPTIVA)){
                if(isAccount){
                    if(!project.Opportunity__r.Account.Submitted_to_Optiva__c){
                        String resp = OptivaCustomerCreation.syncCustomer(project.Opportunity__r.AccountId);
                        if(resp=='Success'){
                            updateAccountSubmittion(project.Opportunity__r.AccountId,'Optiva');
                        }
                    }
                }
                else{
                    if(!project.Opportunity__r.Customer_Billing_Address__r.Submitted_to_Optiva__c){
                        String resp = OptivaAddressCreation.syncCustomer(project.Opportunity__r.Customer_Billing_Address__c);
                        if(resp=='Success'){
                            updateAddressSubmittion(project.Opportunity__r.Customer_Billing_Address__c,'Optiva');
                        }
                    }
                }
                hasAccountAndSchedule = true;
            }
    
            if(hasAccountAndSchedule){
                project.Submit_Sample_To_Optiva__c = true;
                update project;

                return createResponse('Success','200','Customer creation in progress');
            }
    
            responseMap = Optiva_NPDCreationCallout.getInstance().createProject(getApplicationWrapper(project));
            if(responseMap!=null && responseMap.get('status')=='Success'){
                Project__c prod = new Project__c(Id=recId, Submitted_To_SAP_Optiva__c=true, Status__c = Constants.APPLICATION_SUBMITTION_STATUS,Sample_Submitted_Date__c=System.today());
                prod.Submit_Sample_To_Optiva__c = false;
                prod.Error_Occured_On_Submitting_To_Optiva__c = false;
                prod.Error_Message_On_Submitting_To_Optiva__c = '';
                update prod;
            }else{
                Utility.handlerErrorException(project.Id,responseMap.toString());
            }
            return responseMap;
        }catch(Exception e){
            Project__c prod = new Project__c(Id=recId, Error_Occured_On_Submitting_To_Optiva__c=true,Submit_Sample_To_Optiva__c = true, Error_Message_On_Submitting_To_Optiva__c = e.getMessage());
            update prod;
            return getExceptionMap(e);
        }
    }
    
    //Prithvi: THIS IS MAIN FROM SF BUTTON
    public Map<String,String> sampleCreationHandler(String recId){
        System.debug('sampleCreationHandler Called');
        Project__c project = getSample(recId);
        System.debug('project==> ' + project);
        boolean isLeadAvailable = true;
        boolean isSubmittedToOptiva = false;
        Map<String,String> responseMap = new Map<String, String>();
        Symega_Configuration__c orgConfig = Symega_Configuration__c.getValues('Symega Configuration');

        try{
            
            if(project.Submitted_To_SAP_Optiva__c)
                return createResponse('Failure','400','Already Synced');

            Map<Id,Sample_Line_Item__c> optivaRecipieSLineItems = new Map<Id,Sample_Line_Item__c>();
            Map<Id,String> withoutOptivaRecipieSLineItems = new Map<Id,String>();

            String customerCodeOPTIVA = '';
            Boolean isAccount = false;

            if(project.Opportunity__r.Account_Billing_Address__c){
                customerCodeOPTIVA = project.Opportunity__r.Account.Customer_Code_OPTIVA__c;
                isAccount = true;
            }
            else if(project.Opportunity__r.Customer_Billing_Address__c != null){
                customerCodeOPTIVA = project.Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c;
                isAccount = false;
            }

            if(!project.Sample_Line_Items__r.isEmpty()){
                System.debug('project.Sample_Line_Items__r==> ' + project.Sample_Line_Items__r);
                for(Sample_Line_Item__c sli : project.Sample_Line_Items__r){
                    system.debug('sli.OPTIVA_Recipe__c -- ' + sli.OPTIVA_Recipe__c);
                    system.debug('sli.Project_Quotient__c -- ' + sli.Project_Quotient__c);
                    system.debug('sli.Product__c -- ' + sli.Product__c);
                    system.debug('sli.Product__r.Famil -- ' + sli.Product__r.Family);
                    //system.debug('sli.orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family) -- ' + orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family));
                    
                    if(!String.isEmpty(sli.OPTIVA_Recipe__c) || (!String.isEmpty(sli.Project_Quotient__c) && !String.isEmpty(sli.Project_Quotient__r.Sample_Project_Application__c) && sli.Project_Quotient__r.Sample_Project_Application__r.RecordType.DeveloperName == 'Project' && (sli.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c==Constants.FLAVOUR_API_NAME || sli.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c==Constants.COLOR_API_NAME)) || (!String.isEmpty(sli.Product__c) && !String.isEmpty(sli.Product__r.Family) && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family))){
                        optivaRecipieSLineItems.put(sli.Id,sli);
                    }else{
                        system.debug('HII');
                        withoutOptivaRecipieSLineItems.put(sli.Id,sli.Id);
                    }
                }

                System.debug('withoutOptivaRecipieSLineItems---'+withoutOptivaRecipieSLineItems);
                System.debug('optivaRecipieSLineItems---'+optivaRecipieSLineItems);

                if(!Utility.isOptivaSyncingEnable()){
                    if(withoutOptivaRecipieSLineItems.isEmpty()){
                        return createResponse('Failure','400','Sorry, Integrations are disabled');
                    }

                    sampleAssignNotification_ProdFamily.notifyWithoutRecipeSLI(withoutOptivaRecipieSLineItems.values());
                    updateProduct(project.Id);
                    return responseMap.isEmpty()?createResponse('Success','200','Sample Submitted Successfully'):responseMap;
                }else{
                    if(!String.isEmpty(project.Opportunity__r.AccountId) && !String.isEmpty(customerCodeOPTIVA)){
                        isLeadAvailable = false;
                    }    
        
                    if(!String.isEmpty(project.Opportunity__r.AccountId) && String.isEmpty(customerCodeOPTIVA)){
                        isLeadAvailable = false;
                        String resp;
                        if(isAccount){
                            if(!project.Opportunity__r.Account.Submitted_to_Optiva__c){
                                resp = OptivaCustomerCreation.syncCustomer(project.Opportunity__r.AccountId);
                                if(resp=='Success'){
                                    updateAccountSubmittion(project.Opportunity__r.AccountId,'Optiva');
                                }
                            }
                            else{
                                resp = 'Success';
                            }
                        }
                        else{
                            if(!project.Opportunity__r.Customer_Billing_Address__r.Submitted_to_Optiva__c){
                                resp = OptivaAddressCreation.syncCustomer(project.Opportunity__r.Customer_Billing_Address__c);
                                if(resp=='Success'){
                                    updateAddressSubmittion(project.Opportunity__r.Customer_Billing_Address__c,'Optiva');
                                }
                            }
                            else{
                                resp = 'Success';
                            }
                        }                        
                        
                        System.debug('CUSTOMER_RESPONSE----'+resp);
                        if(resp=='Success'){
                            //submittedToSAP(project.Id);
                            setPendingTOSubmit(project.Id);
                            return createResponse('Success','200','Customer creation in progress');
                        }
                        else{
                           return createResponse('Failure','400',resp);
                        }
                    }

                    if(!optivaRecipieSLineItems.isEmpty()){
                        String reqBody = getSampleWrapper(project,isLeadAvailable,optivaRecipieSLineItems);

                        System.debug('Body------'+reqBody);
                        responseMap = Optiva_NPDCreationCallout.getInstance().createProject(reqBody);
                        System.debug('ResponseMap----'+responseMap);
                        if(responseMap!=null && responseMap.get('status')=='Success'){
                            isSubmittedToOptiva = true;
                        }else if(responseMap!=null){
                            Utility.handlerErrorException(project.Id,responseMap.toString());
                            return responseMap;
                        }
                    }

                    sampleAssignNotification_ProdFamily.notifyWithoutRecipeSLI(withoutOptivaRecipieSLineItems.values());

                    if(isSubmittedToOptiva || !withoutOptivaRecipieSLineItems.isEmpty() ){
                        updateProduct(project.Id);
                        updateSampleSLI(optivaRecipieSLineItems);
                        return responseMap.isEmpty()?createResponse('Success','200','Sample Submitted Successfully'):responseMap;
                    }
                }
            }
            return createResponse('Failure','400','Please add Line items to this sample. Please make sure to select only Active products');
        }
        catch(Exception e){
            Project__c prod = new Project__c(Id=recId, Error_Occured_On_Submitting_To_Optiva__c=true,Submit_Sample_To_Optiva__c = true,Error_Message_On_Submitting_To_Optiva__c = e.getMessage());
            update prod;
            return getExceptionMap(e);
        }
    }

    public Map<String,String> techDocHandler(String recId){
        if(!Utility.isOptivaSyncingEnable()){
            return createResponse('Failed','400','Sorry, Integrations are disabled');
        }

        Project__c project = getProject(recId);

        Map<String,String> responseMap = Optiva_Tech_Doc_Project_Creation_Callout.submitProject(project);
        if(responseMap!=null && responseMap.get('status')=='Success'){
            Project__c prod = new Project__c(Id=recId, Submitted_To_SAP_Optiva__c=true, Status__c = 'Submitted for Tech Docs',Sample_Submitted_Date__c=System.today());
            update prod;
        }
        else{
            Utility.handlerErrorException(project.Id,responseMap.toString());
        }
        return responseMap;
    }

    public static void updateAccountSubmittion(String accId,String submitTo){
        //Account acc = new Account(Id=accId);
        Account acc = [SELECT Id, Submitted_to_SAP__c, Submitted_to_Optiva__c FROM Account WHERE Id =: accId];
        
        if(submitTo.equalsIgnoreCase('SAP')){
            acc.Submitted_to_SAP__c = true;
        }
        else{
            acc.Submitted_to_Optiva__c = true;
        }
        update acc;
    }
    
    public static void updateAddressSubmittion(String addressId, String submitTo){
        //Account acc = new Account(Id=accId);
        Dispatch_Address__c acc = [SELECT Id, Submitted_to_SAP__c, Submitted_to_Optiva__c FROM Dispatch_Address__c WHERE Id =: addressId];
        
        if(submitTo.equalsIgnoreCase('SAP')){
            acc.Submitted_to_SAP__c = true;
        }
        else{
            acc.Submitted_to_Optiva__c = true;
        }
        update acc;
    }

    public static Project__c getProject(String recId){
        return [Select Id, Name, CreatedBy.Name, Legal_Status__c, Application_product_shelf_life__c, Physical_Form__c, Minimum_order_quantity__c, Opportunity__r.Customer_Billing_Address__r.Submitted_to_SAP__c, Opportunity__r.Customer_Billing_Address__r.Submitted_to_Optiva__c, Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c, Opportunity__r.Customer_Billing_Address__r.Customer_Code_SAP__c, Opportunity__r.Customer_Billing_Address__c, Opportunity__r.Account_Billing_Address__c, Recipe_Cost__c, pH__c, Milk_Solids__c, Fat__c, Center_filling_Cream__c, Additive_Status__c, of_pulp_if_with_fruit_pulp__c, Product_Type__c, Account_Segment__c, Start_Date__c, Processing_condition__c, Preferred_thickness_Viscosity__c, Oil_sprinkling_Dust_on__c, Final_SNF__c, Customer_Name__c, Brix_degrees__c, Acidity__c, Opportunity__r.AccountId,  Opportunity__r.Account.Name,Type_of_PR__c,Approval_Status__c,Opportunity_Close_Date__c,Product_Family__c,Opportunity__r.Account.Submitted_to_Optiva__c,Opportunity__r.Account.Submitted_to_SAP__c,Opportunity__r.Account.Customer_Code_SAP__c,Opportunity__r.Account.Customer_Code_OPTIVA__c, Owner.Name,Project_Name__c,Product_Spec__c,MSDS__c,Country_of_Compliance__c,Allergen__c,Nutritional__c,Other__c,Product_ID__c,Target_Date__c,Submitted_To_SAP_Optiva__c,CreatedDate,Project_Type__c,Project_Category__c,Opportunity_Type__c,Opportunity_Sub_Type__c,End_Use_category__c,End_Use_Applications__c,Customer_Target_price__c,CurrencyIsoCode,Customer_Cost_in_USE_CIU__c,Expected_Volume_Unit__c,Expected_Annual_Value__c,Quantity__c,Required_End_Date__c,Proposed_date_of_dispatch__c,Customer_Launch_Date__c,Sensory_profiling_Report_Required__c,Application_Samples_Receipe_Support__c,Wet_Dry__c,Solublity__c,Current_Shelf_life__c,Supplier_Legal_Status__c,Dosage_Guidelines__c,Expected_Shelf_Life__c,Other_Application_Methods__c,Customer_Base_Details__c,Matching_Target_details__c,Sample_Size_for_trails__c,Sensory_Target_profile_expectation__c,Specific_inputs_by_customer__c,Allergin_Free_Decleration__c,GMO_Status__c,Halal_Certification__c,Kosher_Certification__c,Legal_Status_as_per_EU__c,Legal_Status_as_per_Indian_FSSAI__c,Legal_Status_as_per_US__c,Organic_Certification__c	,Product_approval_format_by_customer__c,Business_potential_value_INR_New__c,Annual_Volume_Full__c,First_Sample_due_date__c,Solubility_Preference__c From Project__c Where Id =:recId];
    }

    public static Project__c getApplication(String recId){
        return [Select Id, Name, CreatedBy.Name, Legal_Status__c, Application_product_shelf_life__c, Physical_Form__c, Minimum_order_quantity__c, Opportunity__r.Customer_Billing_Address__r.Submitted_to_SAP__c, Opportunity__r.Customer_Billing_Address__r.Submitted_to_Optiva__c, Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c, Opportunity__r.Customer_Billing_Address__r.Customer_Code_SAP__c, Opportunity__r.Customer_Billing_Address__c, Opportunity__r.Account_Billing_Address__c, Recipe_Cost__c, pH__c, Milk_Solids__c, Fat__c, Center_filling_Cream__c, Additive_Status__c, of_pulp_if_with_fruit_pulp__c, Product_Type__c, Account_Segment__c, Start_Date__c, Processing_condition__c, Preferred_thickness_Viscosity__c, Oil_sprinkling_Dust_on__c, Final_SNF__c, Customer_Name__c, Brix_degrees__c, Acidity__c, Opportunity__r.AccountId, Opportunity__r.Account.Name,Opportunity_Close_Date__c, Product_Family__c, Owner.Name,Opportunity__r.Account.Submitted_to_Optiva__c,Opportunity__r.Account.Submitted_to_SAP__c,Opportunity__r.Account.Customer_Code_OPTIVA__c,Submitted_To_SAP_Optiva__c,Application_Name__c,CreatedDate,Project_Type__c,Final_Fat__c,Project_Category__c,Opportunity_Type__c,Opportunity_Sub_Type__c,Confectionary_Type__c,Sugar__c,Flavour_CIU__c,Target_Date__c,Flavour_Legal_Status__c,End_Use_category__c,End_Use_Applications__c,Customer_Target_price__c,CurrencyIsoCode,Customer_Cost_in_USE_CIU__c,Expected_Volume_Unit__c,Expected_Annual_Value__c,Quantity__c,Required_End_Date__c,Proposed_date_of_dispatch__c,Customer_Launch_Date__c,Sensory_profiling_Report_Required__c,Application_Samples_Receipe_Support__c,Wet_Dry__c,Solublity__c,Current_Shelf_life__c,Supplier_Legal_Status__c,Dosage_Guidelines__c,Expected_Shelf_Life__c,Other_Application_Methods__c,Customer_Base_Details__c,Matching_Target_details__c,Sample_Size_for_trails__c,Sensory_Target_profile_expectation__c,Specific_inputs_by_customer__c,Allergin_Free_Decleration__c,GMO_Status__c,Halal_Certification__c,Kosher_Certification__c,Legal_Status_as_per_EU__c,Legal_Status_as_per_Indian_FSSAI__c,Legal_Status_as_per_US__c,Organic_Certification__c	,Product_approval_format_by_customer__c,Business_potential_value_INR_New__c,Annual_Volume_Full__c,First_Sample_due_date__c,Solubility_Preference__c From Project__c Where Id =:recId];
    }
    
    public static Project__c getSample(String recId){
        return [Select Id, Name, Legal_Status__c, Application_product_shelf_life__c, Physical_Form__c, Minimum_order_quantity__c, Opportunity__r.Customer_Billing_Address__r.Submitted_to_SAP__c, Opportunity__r.Customer_Billing_Address__r.Submitted_to_Optiva__c, Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c, Opportunity__r.Customer_Billing_Address__r.Customer_Code_SAP__c, Opportunity__r.Customer_Billing_Address__c, Opportunity__r.Account_Billing_Address__c, Start_Date__c, Recipe_Cost__c, Product_Type__c, Processing_condition__c, Preferred_thickness_Viscosity__c, pH__c, Oil_sprinkling_Dust_on__c, Milk_Solids__c, Final_SNF__c, Fat__c, Expected_Shelf_Life__c, Customer_Name__c, Center_filling_Cream__c, Brix_degrees__c, Additive_Status__c, Acidity__c,Account_Segment__c,of_pulp_if_with_fruit_pulp__c,Customers_Contact__r.FirstName, Customers_Contact__r.LastName, Contact_Number__c, Company_Name__c, Opportunity_Close_Date__c, Sample_Project__c,Sample_Project__r.Owner.Name,Quantity__c,Expected_Annual_Value__c,Business_potential_value_INR__c,Annual_Volume_Full__c,Business_potential_value_INR_New__c,Submitted_To_SAP_Optiva__c,Opportunity__r.AccountId,Opportunity__r.Account.Submitted_to_Optiva__c,Opportunity__r.Account.Submitted_to_SAP__c,Opportunity__r.Account.Customer_Code_OPTIVA__c,Lead__c,Lead__r.FirstName,Lead__r.LastName,Lead__r.Country,Lead__r.State,Lead__r.City,Lead__r.Street,Product_Family__c,Sample_Name__c,Project_Type__c,Project_Category__c,Project_Reference__c,CreatedBy.Name, City__c, Country__c, Postal_Code__c, State__c, Street__c, Opportunity__r.Account.Name,
        CreatedDate,Opportunity_Type__c,Opportunity_Sub_Type__c,End_Use_category__c,
        End_Use_Applications__c,CurrencyIsoCode,(Select Id,Quantity_Unit__c,Quantity__c,Packaging_Unit__c,
        Packaging_Quantity__c, Product__c, Product__r.ProductCode,Product__r.Family, OPTIVA_Recipe__c,Project_Quotient__r.Sample_Project_Application__r.RecordType.DeveloperName,Project_Quotient__r.Sample_Project_Application__r.Product_Family__c,Project_Quotient__r.SSC_Code__c,OPTIVA_Recipe__r.SSC_Code__c,First_Sample_due_date__c,Customer_Target_Price__c, Customer_Preferred_Name__c From Sample_Line_Items__r WHERE Submitted__c= false AND (OPTIVA_Recipe__r.SSC_Code__c != null OR Project_Quotient__c!=null OR (Product__c != null AND Product__r.isActive = true))) From Project__c Where Id=:recId];
    }

    public static String getProjectWrapper(Project__c project){
        Optiva_NPDCreationWrapper OpWrapper = new Optiva_NPDCreationWrapper();

        OpWrapper.project_sf_code = checkIfBlank(project.Id);
        OpWrapper.project_title = checkIfBlank(project.Name) + ':' + checkIfBlank(project.Project_Name__c);
        OpWrapper.created_by = checkIfBlank(project.Owner.Name);
        OpWrapper.project_type = 'External';//checkIfBlank(project.Project_Type__c);
        OpWrapper.project_category = checkIfBlank(project.Product_Family__c);//checkIfBlank(project.Project_Category__c);
        OpWrapper.opp_type_int = 'Development';//checkIfBlank(project.Opportunity_Type__c);
        OpWrapper.opp_sub_type_sales = 'NPD';//checkIfBlank(project.Opportunity_Sub_Type__c);
        OpWrapper.cust_code = project.Opportunity__r.Account_Billing_Address__c ? checkIfBlank(project.Opportunity__r.Account.Customer_Code_OPTIVA__c) : project.Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c;
        OpWrapper.end_use_cat = checkIfBlank(project.End_Use_category__c);
        OpWrapper.end_use_appli = checkIfBlank(project.End_Use_Applications__c);
        OpWrapper.cust_target_price = project.Customer_Target_price__c!=null?String.valueOf(project.Customer_Target_price__c):'NA';
        OpWrapper.curr_type = checkIfBlank(project.CurrencyIsoCode);
        OpWrapper.cust_ciu = project.Customer_Cost_in_USE_CIU__c!=null?String.valueOf(project.Customer_Cost_in_USE_CIU__c):'NA';
        OpWrapper.annual_vol = project.Annual_Volume_Full__c!=null?String.valueOf(project.Annual_Volume_Full__c):'NA';
        OpWrapper.business_potent_val = project.Business_potential_value_INR_New__c == NULL ? 0 : project.Business_potential_value_INR_New__c;
        //OpWrapper.curr_year_vol = project.Quantity__c!=null?String.valueOf(project.Quantity__c):'0';
        OpWrapper.curr_year_vol = project.Minimum_order_quantity__c!=null?String.valueOf(project.Minimum_order_quantity__c):'0'; // new
        OpWrapper.sensry_prfle_rpt = checkIfBlank(project.Sensory_profiling_Report_Required__c);
        OpWrapper.appl_smpl_recipe = checkIfBlank(project.Application_Samples_Receipe_Support__c);
        //OpWrapper.physical_form = checkIfBlank(project.Wet_Dry__c);
        OpWrapper.physical_form = checkIfBlank(project.Physical_Form__c); // new
        OpWrapper.solublity = checkIfBlank(project.Solubility_Preference__c);
        OpWrapper.shelf_life_flvr = checkIfBlank(project.Current_Shelf_life__c);
        OpWrapper.supplier_legal_stat = checkIfBlank(project.Supplier_Legal_Status__c);
        OpWrapper.dosage_guide_cust = checkIfBlank(project.Dosage_Guidelines__c);
        //OpWrapper.shelf_life_appl_prod = checkIfBlank(project.Expected_Shelf_Life__c);
        OpWrapper.shelf_life_appl_prod = checkIfBlank(project.Application_product_shelf_life__c); // new
        OpWrapper.appl_guide = checkIfBlank(project.Other_Application_Methods__c);
        OpWrapper.cust_base_details = checkIfBlank(project.Customer_Base_Details__c);
        OpWrapper.match_target_dtls = checkIfBlank(project.Matching_Target_details__c);
        OpWrapper.sample_size_trails = checkIfBlank(project.Sample_Size_for_trails__c);
        OpWrapper.sensry_target_prfl = checkIfBlank(project.Sensory_Target_profile_expectation__c);
        OpWrapper.inputs_by_cust = checkIfBlank(project.Specific_inputs_by_customer__c);
        OpWrapper.alrgn_free_declare = project.Allergin_Free_Decleration__c?'Yes':'No';
        OpWrapper.gmo_status = project.GMO_Status__c?'Yes':'No';
        OpWrapper.halal_cert = project.Halal_Certification__c?'Yes':'No';
        OpWrapper.kosher_cert = project.Kosher_Certification__c?'Yes':'No';
        OpWrapper.legal_status_eu = checkIfBlank(project.Legal_Status_as_per_EU__c);
        OpWrapper.legal_status_fssai = checkIfBlank(project.Legal_Status_as_per_Indian_FSSAI__c);
        OpWrapper.legal_status_us = checkIfBlank(project.Legal_Status_as_per_US__c);
        OpWrapper.organic_cert = project.Organic_Certification__c?'Yes':'No';
        OpWrapper.prod_apr_frmat_cust = checkIfBlank(project.Product_approval_format_by_customer__c);

        OpWrapper.creation_date = project.CreatedDate == null ? 'NA' : project.CreatedDate.format('dd/MM/yyyy');
        
        OpWrapper.opp_closedate = project.Opportunity_Close_Date__c!=null?formatDate(project.Opportunity_Close_Date__c):'NA';
        OpWrapper.cust_launch_date = project.Customer_Launch_Date__c!=null?formatDate(project.Customer_Launch_Date__c):'NA';
        OpWrapper.sample_duedate1 = project.First_Sample_due_date__c!=null?formatDate(project.First_Sample_due_date__c):'NA';


        //NEW ADDITIONS
        OpWrapper.expected_shelf_life = checkIfBlank(project.Expected_Shelf_Life__c);
        OpWrapper.legal_status = checkIfBlank(project.Legal_Status__c);

        return JSON.serialize(OpWrapper);
    }

    public static String getApplicationWrapper(Project__c project){
        Optiva_NPD_Application_Wrapper   OpAppWrapper = new Optiva_NPD_Application_Wrapper();
        OpAppWrapper.project_sf_code = checkIfBlank(project.Id);
        OpAppWrapper.project_title = checkIfBlank(project.Name) + ':' + checkIfBlank(project.Application_Name__c);
        OpAppWrapper.created_by = checkIfBlank(project.Owner.Name);
        OpAppWrapper.project_type = checkIfBlank(project.Project_Type__c);  //'External';
        OpAppWrapper.project_category = checkIfBlank(project.Product_Family__c);//checkIfBlank(project.Project_Category__c);
        OpAppWrapper.opp_type_int = 'Sales';//checkIfBlank(project.Opportunity_Type__c);
        OpAppWrapper.opp_sub_type_sales = 'Application';//checkIfBlank(project.Opportunity_Sub_Type__c);
        OpAppWrapper.cust_code = project.Opportunity__r.Account_Billing_Address__c ? checkIfBlank(project.Opportunity__r.Account.Customer_Code_OPTIVA__c) : project.Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c;
        OpAppWrapper.end_use_cat = checkIfBlank(project.End_Use_category__c);
        OpAppWrapper.end_use_appli = checkIfBlank(project.End_Use_Applications__c);
        OpAppWrapper.annual_vol = project.Annual_Volume_Full__c!=null?String.valueOf(project.Annual_Volume_Full__c):'NA';
        OpAppWrapper.business_potent_val = project.Business_potential_value_INR_New__c == null ? 0 : project.Business_potential_value_INR_New__c;
        OpAppWrapper.curr_year_vol = project.Quantity__c!=null?String.valueOf(project.Quantity__c):'NA';
        OpAppWrapper.cust_target_price = project.Customer_Target_price__c!=null?String.valueOf(project.Customer_Target_price__c):'NA';
        OpAppWrapper.curr_type = checkIfBlank(project.CurrencyIsoCode);
        OpAppWrapper.confectionary_type = checkIfBlank(project.Confectionary_Type__c);
        OpAppWrapper.final_fat = project.Final_Fat__c == null ? 0 : project.Final_Fat__c;
        OpAppWrapper.first_smpe_due_date = project.First_Sample_due_date__c != null ? formatDate(project.First_Sample_due_date__c):'NA';
        OpAppWrapper.flavor_ciu = project.Flavour_CIU__c == null ? 0 : project.Flavour_CIU__c;
        OpAppWrapper.flavor_legal_stat = checkIfBlank(project.Flavour_Legal_Status__c);
        OpAppWrapper.solubility = checkIfBlank(project.Solubility_Preference__c);
        OpAppWrapper.sugar = project.Sugar__c != null ? String.valueOf(project.Sugar__c):'NA';
        OpAppWrapper.creation_date = project.CreatedDate == null ? 'NA' : project.CreatedDate.format('dd/MM/yyyy');
        OpAppWrapper.opp_closedate = project.Opportunity_Close_Date__c != null ? formatDate(project.Opportunity_Close_Date__c) : 'NA';
        OpAppWrapper.target_date = project.Target_Date__c!=null ? formatDate(project.Target_Date__c) : 'NA';


        //NEW ADDITIONS
        OpAppWrapper.per_pulp = project.of_pulp_if_with_fruit_pulp__c != null ? String.valueOf(project.of_pulp_if_with_fruit_pulp__c) : '0';
        OpAppWrapper.account = checkIfBlank(project.Opportunity__r.AccountId);
        OpAppWrapper.account_seg = checkIfBlank(project.Account_Segment__c);
        OpAppWrapper.acidity_per = project.Acidity__c != null ? String.valueOf(project.Acidity__c) : '0';
        OpAppWrapper.additive_status = checkIfBlank(project.Additive_Status__c);
        OpAppWrapper.brix_deg = project.Brix_degrees__c != null ? String.valueOf(project.Brix_degrees__c) : '0';
        OpAppWrapper.center_cream = project.Center_filling_Cream__c != null ? String.valueOf(project.Center_filling_Cream__c) : '0';
        OpAppWrapper.cust_name = checkIfBlank(project.Customer_Name__c);
        OpAppWrapper.fat_per = project.Fat__c != null ? String.valueOf(project.Fat__c) : '0';
        OpAppWrapper.final_snf_per = project.Final_SNF__c != null ? String.valueOf(project.Final_SNF__c) : '0';
        OpAppWrapper.milk_solids = project.Milk_Solids__c != null ? String.valueOf(project.Milk_Solids__c) : '0';
        OpAppWrapper.oil_sprinkle = project.Oil_sprinkling_Dust_on__c != null ? String.valueOf(project.Oil_sprinkling_Dust_on__c) : '0';
        OpAppWrapper.ph = project.pH__c != null ? String.valueOf(project.pH__c) : '0';
        OpAppWrapper.viscocity = project.Preferred_thickness_Viscosity__c != null ? String.valueOf(project.Preferred_thickness_Viscosity__c) : '0';
        OpAppWrapper.processing_condition = checkIfBlank(project.Processing_condition__c);
        OpAppWrapper.recipe_cost = project.Recipe_Cost__c != null ? String.valueOf(project.Recipe_Cost__c) : '0';
        OpAppWrapper.start_date = project.Start_Date__c != null ? formatDate(project.Start_Date__c) : 'NA';

        return JSON.serialize(OpAppWrapper);
    }

    public static String getSampleWrapper(Project__c project, boolean isLeadAvailable,Map<Id,Sample_Line_Item__c> optivaRecipieSLineItems){
        Optiva_NPDSampleCreationWrapper OpWrapper = new Optiva_NPDSampleCreationWrapper();
        Symega_Configuration__c orgConfig = Symega_Configuration__c.getValues('Symega Configuration');

        System.debug('optivaRecipieSLineItems======>'+optivaRecipieSLineItems);

        if(isLeadAvailable){
            OpWrapper.project_sf_code = checkIfBlank(project.Id);
            OpWrapper.first_name = checkIfBlank(project.Lead__r.FirstName);
            OpWrapper.last_name = checkIfBlank(project.Lead__r.LastName);
        }else{
            OpWrapper.cust_code = project.Opportunity__r.Account_Billing_Address__c ? checkIfBlank(project.Opportunity__r.Account.Customer_Code_OPTIVA__c) : project.Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c;
            OpWrapper.project_sf_code = checkIfBlank(project.Id);
            OpWrapper.first_name = project.Customers_Contact__c == null ? checkIfBlank(project.Opportunity__r.Account.Name) : project.Customers_Contact__r.FirstName;
            OpWrapper.last_name = project.Customers_Contact__c == null ? checkIfBlank(project.Opportunity__r.Account.Name) : project.Customers_Contact__r.LastName;
        }
        //v.1
        OpWrapper.contact_number = checkIfBlank(project.Contact_Number__c);
        OpWrapper.company_name = checkIfBlank(project.Company_Name__c);
        OpWrapper.pincode = checkIfBlank(project.Postal_Code__c);
        OpWrapper.country = checkIfBlank(project.Country__c);
        OpWrapper.state = checkIfBlank(project.State__c);
        OpWrapper.city = checkIfBlank(project.City__c);
        OpWrapper.street = checkIfBlank(project.Street__c);
        
        OpWrapper.project_title = checkIfBlank(project.Name) + ':' + checkIfBlank(project.Sample_Name__c);
        OpWrapper.project_type = 'External';//checkIfBlank(project.Project_Type__c);
        OpWrapper.project_category = 'FLAVOUR';//project.Product_Family__c;//checkIfBlank(project.Project_Category__c);
        OpWrapper.project_ref = 'Dummy';//checkIfBlank(project.Project_Reference__c);


        if(!String.isBlank(project.Sample_Project__c)){
            OpWrapper.created_by = checkIfBlank(project.Sample_Project__r.Owner.Name);
        }else{
            OpWrapper.created_by = checkIfBlank(project.CreatedBy.Name);
        }
       
        OpWrapper.creation_date = project.CreatedDate == null ? 'NA' : project.CreatedDate.format('dd/MM/yyyy');
        OpWrapper.opp_type_int = 'Sales';//checkIfBlank(project.Opportunity_Type__c);
        OpWrapper.opp_sub_type_sales = 'Sampling';
     //   OpWrapper.cust_code = checkIfBlank(project.Customer_Code__c);
        OpWrapper.end_use_cat = checkIfBlank(project.End_Use_category__c);
        OpWrapper.end_use_appli = checkIfBlank(project.End_Use_Applications__c);
        OpWrapper.curr_type = checkIfBlank(project.CurrencyIsoCode);

        OpWrapper.opp_closedate = project.Opportunity_Close_Date__c!=null?formatDate(project.Opportunity_Close_Date__c):'NA'; 
        OpWrapper.annual_vol = project.Annual_Volume_Full__c!=null?String.valueOf(project.Annual_Volume_Full__c):'NA';
        OpWrapper.business_potent_val = project.Business_potential_value_INR_New__c!=null?String.valueOf(project.Business_potential_value_INR_New__c):'NA';
        OpWrapper.curr_type = checkIfBlank(project.CurrencyIsoCode);
        OpWrapper.curr_year_vol = project.Quantity__c!=null?String.valueOf(project.Quantity__c):'NA';


        for(Integer i=0;i<optivaRecipieSLineItems.values().size();i++){
            Sample_Line_Item__c sli = project.Sample_Line_Items__r[i];
            if(i==0){
                OpWrapper.uom1 = checkIfBlank(sli.Quantity_Unit__c);
                OpWrapper.tot_qty1 = checkIfBlank(String.valueOf(sli.Quantity__c));
                OpWrapper.no_units1 = sli.Packaging_Quantity__c!=null ? String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.pack_size1 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.selling_desc1 = sli.Customer_Preferred_Name__c!=null ? sli.Customer_Preferred_Name__c: 'NA';

                if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                    System.debug('SSCCODE====>'+sli.OPTIVA_Recipe__r);
                    OpWrapper.prod_code1_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                }else if(sli.Product__r!=null && sli.Product__r.Family!=null && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                    OpWrapper.prod_code1_dev = checkIfBlank(sli.Product__r.ProductCode);
                    System.debug('sli.Product__r.ProductCode====>'+sli.Product__r);
                }else{
                    OpWrapper.prod_code1_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                    System.debug('Project_Quotient__r====>'+sli.Project_Quotient__r);
                    System.debug('sli.Product__r.ProductCode====>'+sli.Product__r);
                    System.debug('sli.Product__r.ProductCode====>'+sli.Product__r.Family);
                    System.debug('sli.Product__r.ProductCode====>'+orgConfig.Prod_Families_Send_To_Optiva__c);
                }
                
                OpWrapper.sample_duedate1 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                OpWrapper.cust_target_price1 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
            }else if(i==1){
                OpWrapper.uom2 = checkIfBlank(sli.Quantity_Unit__c);
                OpWrapper.tot_qty2 = checkIfBlank(String.valueOf(sli.Quantity__c));
                OpWrapper.no_units2 = sli.Packaging_Quantity__c!=null ? String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.pack_size2 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.selling_desc2 = sli.Customer_Preferred_Name__c!=null ? sli.Customer_Preferred_Name__c: 'NA';

                if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                    OpWrapper.prod_code2_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                }else if(sli.Product__r!=null && sli.Product__r.Family!=null &&  orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                    OpWrapper.prod_code2_dev = checkIfBlank(sli.Product__r.ProductCode);
                }else{
                    OpWrapper.prod_code2_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                }

                //OpWrapper.prod_code2_dev = !String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)?sli.OPTIVA_Recipe__r.SSC_Code__c:sli.Project_Quotient__r.SSC_Code__c;
                OpWrapper.sample_duedate2 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                OpWrapper.cust_target_price2 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
            }else if(i==2){
                OpWrapper.uom3 = checkIfBlank(sli.Quantity_Unit__c);
                OpWrapper.tot_qty3 = checkIfBlank(String.valueOf(sli.Quantity__c));
                OpWrapper.no_units3 = sli.Packaging_Quantity__c!=null ? String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.pack_size3 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.selling_desc3 = sli.Customer_Preferred_Name__c!=null ? sli.Customer_Preferred_Name__c: 'NA';

                if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                    OpWrapper.prod_code3_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                }else if(sli.Product__r!=null && sli.Product__r.Family!=null && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                    OpWrapper.prod_code3_dev = checkIfBlank(sli.Product__r.ProductCode);
                }else{
                    OpWrapper.prod_code3_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                }

                //OpWrapper.prod_code3_dev = !String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)?sli.OPTIVA_Recipe__r.SSC_Code__c:sli.Project_Quotient__r.SSC_Code__c;
                OpWrapper.sample_duedate3 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                OpWrapper.cust_target_price3 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
            }else if(i==3){
                OpWrapper.uom4 = checkIfBlank(sli.Quantity_Unit__c);
                OpWrapper.tot_qty4 = checkIfBlank(String.valueOf(sli.Quantity__c));
                OpWrapper.no_units4 = sli.Packaging_Quantity__c!=null ? String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.pack_size4 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.selling_desc4 = sli.Customer_Preferred_Name__c!=null ? sli.Customer_Preferred_Name__c: 'NA';

                if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                    OpWrapper.prod_code4_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                }else if(sli.Product__r!=null && sli.Product__r.Family!=null && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                    OpWrapper.prod_code4_dev = checkIfBlank(sli.Product__r.ProductCode);
                }else{
                    OpWrapper.prod_code4_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                }

                //OpWrapper.prod_code3_dev = !String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)?sli.OPTIVA_Recipe__r.SSC_Code__c:sli.Project_Quotient__r.SSC_Code__c;
                OpWrapper.sample_duedate4 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                OpWrapper.cust_target_price4 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
            }else if(i==4){
                OpWrapper.uom5 = checkIfBlank(sli.Quantity_Unit__c);
                OpWrapper.tot_qty5 = checkIfBlank(String.valueOf(sli.Quantity__c));
                OpWrapper.no_units5 = sli.Packaging_Quantity__c!=null ? String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.pack_size5 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.selling_desc5 = sli.Customer_Preferred_Name__c!=null ? sli.Customer_Preferred_Name__c: 'NA';

                if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                    OpWrapper.prod_code5_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                }else if(sli.Product__r!=null && sli.Product__r.Family!=null && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                    OpWrapper.prod_code5_dev = checkIfBlank(sli.Product__r.ProductCode);
                }else{
                    OpWrapper.prod_code5_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                }

                //OpWrapper.prod_code3_dev = !String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)?sli.OPTIVA_Recipe__r.SSC_Code__c:sli.Project_Quotient__r.SSC_Code__c;
                OpWrapper.sample_duedate5 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                OpWrapper.cust_target_price5 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
            }else if(i==5){
                OpWrapper.uom6 = checkIfBlank(sli.Quantity_Unit__c);
                OpWrapper.tot_qty6 = checkIfBlank(String.valueOf(sli.Quantity__c));
                OpWrapper.no_units6 = sli.Packaging_Quantity__c!=null ? String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.pack_size6 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                OpWrapper.selling_desc6 = sli.Customer_Preferred_Name__c!=null ? sli.Customer_Preferred_Name__c: 'NA';

                if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                    OpWrapper.prod_code6_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                }else if(sli.Product__r!=null && sli.Product__r.Family!=null && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                    OpWrapper.prod_code6_dev = checkIfBlank(sli.Product__r.ProductCode);
                }else{
                    OpWrapper.prod_code6_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                }

                //OpWrapper.prod_code3_dev = !String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)?sli.OPTIVA_Recipe__r.SSC_Code__c:sli.Project_Quotient__r.SSC_Code__c;
                OpWrapper.sample_duedate6 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                OpWrapper.cust_target_price6 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
            }
        }

        return JSON.serialize(OpWrapper);
    }

    public static Map<String,String> getExceptionMap(Exception e){

        Map<String,String> exceptionMap = new Map<String,String>();
        exceptionMap.put('status','Failure');
        exceptionMap.put('code','400');
        exceptionMap.put('message',e.getMessage());

        HandleBusinessException.captureError('Optiva_LWC_NPD_Controller','createProject',e);
        return exceptionMap;
    }

    private static Map<String,String> createResponse(String status, String code,  String message){
        Map<String,String> responseMap = new Map<String,String>();
        responseMap.put('status',status);
        responseMap.put('code',code);
        responseMap.put('message',message);
        return responseMap;
    }

    public static void submittedToSAP(String recId){
        Project__c prod = new Project__c(Id=recId, Status__c = Constants.SAMPLING_SUBMITTION_STATUS,Sample_Submitted_Date__c=System.today());
        prod.Submit_Sample_To_Optiva__c = false;
        prod.Submitted_To_SAP_Optiva__c = true;
        prod.Error_Occured_On_Submitting_To_Optiva__c = false;
        prod.Error_Message_On_Submitting_To_Optiva__c = '';
        System.debug('Proj----Submit_Sample_To_Optiva__c');

        update prod;
    }

    public static void setPendingTOSubmit(String recId){
        Project__c prod = new Project__c(Id=recId);
        prod.Submit_Sample_To_Optiva__c = true;
        prod.Submitted_To_SAP_Optiva__c = false;
        prod.Error_Occured_On_Submitting_To_Optiva__c = false;
        prod.Error_Message_On_Submitting_To_Optiva__c = '';
        System.debug('Proj----Submit_Sample_To_Optiva__c');

        update prod;
    }

    public static void updateProduct(String recId){
        Project__c prod = new Project__c(Id=recId, Status__c = Constants.SAMPLING_SUBMITTION_STATUS,Sample_Submitted_Date__c=System.today());

        prod.Submit_Sample_To_Optiva__c = false;
        prod.Submitted_To_SAP_Optiva__c = true;
        prod.Error_Occured_On_Submitting_To_Optiva__c = false;
        prod.Error_Message_On_Submitting_To_Optiva__c = '';
        System.debug('Proj----Submitted_To_SAP_Optiva__c');
        update prod;
    }

    public static String formatDate(Date d){
        return d.day()+'/'+d.month()+'/'+d.year();
    }


    public static String checkIfBlank(String s){
        return String.isBlank(s) || s == null ?'NA':s;
    }

    public static void updateSampleSLI(Map<Id,Sample_Line_Item__c> sliMap){
        for(Sample_Line_Item__c sli: sliMap.values()){
            sli.Submitted__c = true;
            sli.Sample_Request_Status__c = Constants.SAMPLING_SUBMITTION_STATUS; //v.1
        }

        if(!sliMap.isEmpty()){
            try{
                update sliMap.values();
            }catch(Exception e){
                System.debug('Exception----'+e);
            }
        }
    }
}