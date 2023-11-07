public without sharing class ProjectHanlder {
    public ProjectHanlder() {}
    
    @AuraEnabled
    public static Lead getLeadRecord(String leadId){
        try {
            if(String.isBlank(leadId))
                return null;
            return [Select Id, Name, Company, Address, CurrencyIsoCode FROM Lead where Id =:leadId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Account getAccRecord(String accId){
        try {
            if(String.isBlank(accId))
                return null;
            return [Select Id, Name, Customer_Contact__c, Customer_Contact__r.MailingCity, Customer_Contact__r.MailingCountry, Customer_Contact__r.MailingPostalCode, Customer_Contact__r.MailingStreet, 
                    Customer_Contact__r.MailingState, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, AccountSource, 
                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, CurrencyIsoCode FROM Account where Id =:accId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Opportunity getOppRecord(String id){
        try {
            if(String.isBlank(id))
                return null;
            return [Select Id, CloseDate, Primary_Contact__c, End_Use_Application_Other__c, End_Use_Category__c, End_Use_Application__c, Target_Price_Kg__c, Annual_Volume_Full__c, Annual_Volume_in_units__c, Annual_Potential_Value__c, Actual_Annual_Potential_Value__c,
                    Name, AccountId, Account.Name, Account.Customer_Contact__c, Amount,
                    Billing_City__c, Billing_State__c, Billing_Street__c, Billing_Postal_Code__c, Billing_Country__c, 
                    Shipping_City__c, Shipping_State__c, Shipping_Street__c, Shipping_Postal_Code__c, Shipping_Country__c,
                    CurrencyIsoCode, Proposed_Date_of_Dispatch__c, Pre_carriage_By__c, Port_of_Discharge__c, Place_of_Reciept_by_Pre_Carrier__c,
                    Port_of_Loading__c, Vessel_Flight_Name_Voy_No__c, TotalOpportunityQuantity FROM Opportunity where Id =:id];
                    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Opportunity getOppRecordLWC(String id){
        try {
            if(String.isBlank(id))
                return null;
            return [Select Id, Name, Target_Price_Kg__c, Annual_Volume_Full__c, Annual_Volume_in_units__c, Annual_Potential_Value__c, Actual_Annual_Potential_Value__c, CurrencyIsoCode, Proposed_Date_of_Dispatch__c, Pre_carriage_By__c, Port_of_Discharge__c, Place_of_Reciept_by_Pre_Carrier__c,
                    Port_of_Loading__c, Vessel_Flight_Name_Voy_No__c, Amount, TotalOpportunityQuantity, AccountId, Freight_charges__c, Include_Freight_Charges__c FROM Opportunity where Id =:id];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    @AuraEnabled
    public static Map<String,Object> createFeedback(String id, String feedback, Date cDate){
        Map<String,Object> returnMap = new Map<String,Object>();
        try {
            
            if(String.isBlank(id) || String.isBlank(feedback) || cDate == null) {
                returnMap.put('status',false);
                returnMap.put('message','Please fill all necessary details.');
                return returnMap;
            }
                
            Project__c project = [SELECT Account__c, Acidity__c, Actual_Date_of_Dispatch__c, Additional_Comments__c, Additive_Status__c, Allergen__c, Allergin_Free_Decleration__c, Annual_Value__c, Annual_Volume_Full__c, Annual_Volume_in_units__c, Application_Name__c, Application_Ready__c, Application_Samples_Receipe_Support__c, Application_Trails__c, Application_guidelines_if_any__c, Application_method__c, Application_product_shelf_life__c, Application_reciepe_code__c, Approval_Status__c, Brix_degrees__c, Business_potential_value_INR__c, Category_Buyer__c, Category_description_as_per_FSSAI__c, Center_filling_Cream__c, City__c, Confectionary_Type__c, Cost_in_Use_target__c, Cost_in_use__c, Country_Regulation__c, Country__c, Country_of_Compliance__c, Courier__c, CreatedById, CreatedDate, Critical__c, CurrencyIsoCode, Currency_Type__c, Current_Cost__c, Current_Packaging__c, Current_RM_FG_Code__c, Current_Shelf_life__c, Current_Supplier_Name__c, Customer_Base_Details__c, Customer_Brand_details__c, Customer_Comments__c, Customer_Cost_in_USE_CIU__c, Customer_Launch_Date__c, Customer_Name__c, Customer_Target_price__c, Customers_Contact__c, Dispatch_Details__c, Distributer_Customer__c, Documentation_Support__c, Dosage_Guidelines__c, Dosage_guidelines_by_customer__c, End_Application_Category__c, End_Use_Applications__c, End_Use_category__c, End_use_application_other__c, Error_Message_On_Submitting_To_Optiva__c, Error_Occured_On_Submitting_To_Optiva__c, Expected_Annual_Value__c, Expected_Shelf_Life__c, Expected_Volume_Unit__c, Export__c, External_Id__c, Fat__c, Final_Fat__c, Final_SNF__c, First_Sample_due_date__c, Flavor_Legal_Status__c, Flavour_CIU__c, Flavour_Legal_Status__c, GMO_Status__c, Halal_Certification__c, Id, If_Private_Label__c, If_yes_Flavour_Details__c, Ingredient_Specific_If_Any__c, Integration_Product_Type__c, IsDeleted, Kosher_Certification__c, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Lead_Time__c, Lead__c, Legal_Status__c, Legal_Status_as_per_EU__c, Legal_Status_as_per_Indian_FSSAI__c, Legal_Status_as_per_US__c, MSDS__c, Matching_Target_details__c, Milk_Solids__c, Minimum_order_quantity__c, Minimum_order_quantity_unit__c, Moved_Production_date__c, Name, Name__c, New_Supplier__c, Nutritional__c, Oil_sprinkling_Dust_on__c, Opportunity_Close_Date__c, Opportunity_Sub_Type__c, Opportunity_Type__c, Opportunity__c, Organic_Certification__c, Other_Application_Methods__c, Other_Project_Composition__c, Other__c, OwnerId, Packaging_Unit__c, Parent_Project__c, Payment_Terms__c, Physical_Form__c, Postal_Code__c, Preferred_thickness_Viscosity__c, Priority__c, Processing_condition__c, Product_Description__c, Product_Family__c, Product_ID__c, Product_Instruction__c, Product_Spec__c, Product_Type__c, Product_approval_format_by_customer__c, Product_recommended__c, Project_Category__c, Project_Completion_Date__c, Project_Name__c, Project_Reference__c, Project_Title__c, Project_Type__c, Proposed_Cost__c, Proposed_Supplier_Name__c, Proposed_date_of_dispatch__c, Prototype_Feedback__c, Quantity_Unit__c, Quantity__c, Quote_Volume_in_units__c, RM_Category__c, R_D_Approval_Status__c, Raw_Material_Name__c, Reason_for_New_Supplier__c, Reason_for_rejection__c, Recipe_Cost__c, RecordTypeId, Regulatory_Requirements__c, Required_End_Date__c, Revert_Date_Count__c, S_O_Date__c, Sales_Code__c, Sales_head_review__c, Sample_Delivery_Date__c, Sample_Name__c, Sample_Project__c, Sample_Revert_Date__c, Sample_Size_for_trails__c, Sample_Sub_Retry_Count__c, Sample_Submitted_Date__c, Sampling_Quantity_Unit__c, Sampling_Quantity_details__c, Scaled_up_date__c, Sensory_Target_profile_expectation__c, Sensory_profiling_Report_Required__c, Ship_To_Address__c, Show_BH_Approval__c, Solubility_Preference__c, Solublity__c, Specific_inputs_by_customer__c, Start_Date__c, State__c, Status__c, Street__c, Submit_Sample_To_Optiva__c, Submitted_To_SAP_Optiva__c, Sugar__c, Supplier_COA__c, Supplier_Food_Grade_Status__c, Supplier_Legal_Status__c, Supplier_MSDS__c, Supplier_Spec__c, SystemModstamp, Target_Date__c, Target_GM_Improvement_at_FG_levels__c, Target_Price__c, Target_Saving_Percentage__c, Tech_Doc_Name__c, Technical_Complexity__c, Tested_at_Flavor_Level__c, Time_Duration_in_hours__c, Total_Project_Quotient__c, Total_Solids__c, Type_of_PR__c, Usage_Levels_in_Recipes_Average__c, Way_Bill_No__c, Wet_Dry__c, Where_Used__c, of_pulp_if_with_fruit_pulp__c, pH__c FROM Project__c WHERE Id=:id];
            
            project.Specific_inputs_by_customer__c = feedback;
            project.Actual_Date_of_Dispatch__c = cDate;
            project.Product_Family__c = project.Product_Family__c;
            project.RecordTypeId = project.RecordTypeId;
            project.Status__c = 'New';
            project.Parent_Project__c = id;
            project.Id = null;
            insert project;
            returnMap.put('status',true);
            returnMap.put('message',project.id);
        } catch (Exception e) {
            System.debug('--- Exception'+e.getMessage());
            returnMap.put('status',false);
            returnMap.put('message',e.getMessage());
        }
        return returnMap;
    }

    @AuraEnabled
    public static List<Project__c> getProjectRecord(Id projectId){
        try {
            return [SELECT Id, Name, Account__c, Opportunity_Close_Date__c, Project_Name__c, Sample_Name__c, Application_Name__c,End_Use_Applications__c,End_Use_category__c, CurrencyIsoCode FROM Project__c WHERE ID = :projectId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getOppRecordTypeId(string recordTypeName){
        try {
            return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getProjectRecordTypeId(string recordTypeName){
        try {
            system.debug('idd'+Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId());
            return Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static OpportunityLineItem getOppProductRecord(String lineItemId){
        try {
            if(String.isBlank(lineItemId))
                return null;
            return [Select Id, Name, OpportunityId, Sales_Order__c, TotalPrice, Quantity FROM OpportunityLineItem where Id =:lineItemId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Sales_Order__c getSaleOrderRecord(String SO_Id){
        try {
            if(String.isBlank(SO_Id))
                return null;
            return [Select Id, Name, Return_created__c FROM Sales_Order__c where Id =:SO_Id];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateSaleOrder(String soId){
        try {
            system.debug('soId:: ' + soId);
            Sales_Order__c sOrder = new Sales_Order__c(Id=soId,Return_created__c=False);
            update sOrder;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Project_Quotient__c getPrjQntRecord(String id){
        try {
            if(String.isBlank(id))
                return null;
            return [Select Id, Name, CurrencyIsoCode, SSC_Code__c, Sample_Project_Application__c, Sample_Project_Application__r.Account__c, Product_Name__c, Usage_Level__c,
                    Current_Shelf_Life__c, Comments__c FROM Project_Quotient__c where Id =:id];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    Public static Sample_Line_Item__c getSliRecord(String sampLId){
        try{
            if(String.isBlank(sampLId))
            return null;
            return [Select Id,CurrencyIsoCode,Product__c,Sample__r.Opportunity__r.Account.Id,Sample__r.Opportunity__r.Account.Name,Line_Item_Name__c,Product__r.Name FROM Sample_Line_Item__c WHERE Id =:sampLId];

        }catch(exception e){
             throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Product2 getProdRecord(String id){
        try {
            if(String.isBlank(id))
                return null;
            return [Select Id, Name, CurrencyIsoCode FROM Product2 where Id =:id];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Optiva_Recipe__c getOptivaRecpRecord(String id){
        try {
            if(String.isBlank(id))
                return null;
            return [Select Id, Name, CurrencyIsoCode, SSC_Code__c FROM Optiva_Recipe__c where Id =:id];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> getAllCustomerAddress(String custId){
        try {
            Map<String, Object> returnWrapperMap = new Map<String, Object>();
            List<CustomerAddressWrapper> customerShippingAddressWrapper = new List<CustomerAddressWrapper>();
            List<CustomerAddressWrapper> customerBillingAddressWrapper = new List<CustomerAddressWrapper>();
            System.debug('--- custId'+custId);
            if(!String.isBlank(custId)) {
                Account customerAcc = [SELECT Id, Name, CurrencyIsoCode, BillingState, BillingStreet, BillingCountry, BillingPostalCode, BillingCity, GST_Number__c, ShippingState, ShippingStreet, ShippingCountry, ShippingCity, ShippingPostalCode, AccountSource FROM Account WHERE Id = :custId];
                
                if(customerAcc != null && !String.isBlank(customerAcc.BillingCountry)) {
                    customerBillingAddressWrapper.add(new CustomerAddressWrapper('Billing', customerAcc.BillingStreet, customerAcc.BillingState, customerAcc.BillingCountry, customerAcc.BillingCity, customerAcc.BillingPostalCode, customerAcc.GST_Number__c, 'Billing', true));
                    returnWrapperMap.put('ship_selected_index', 0);
                }
                
                if(customerAcc != null && !String.isBlank(customerAcc.ShippingCountry)) {
                    customerShippingAddressWrapper.add(new CustomerAddressWrapper('Shipping', customerAcc.ShippingStreet, customerAcc.ShippingState, customerAcc.ShippingCountry, customerAcc.ShippingCity, customerAcc.ShippingPostalCode, customerAcc.GST_Number__c, 'Shipping', true));
                    returnWrapperMap.put('bill_selected_index', 0);
                }

                for(Dispatch_Address__c custAddress :[SELECT Id, Address__Street__s, ToLabel(Address__StateCode__s), Address__PostalCode__s, GST_Number__c, ToLabel(Address__CountryCode__s), Address__City__s, Type__c FROM Dispatch_Address__c WHERE Account__c =:custId]) {

                    if(custAddress.Type__c == 'Billing') {
                        customerBillingAddressWrapper.add(new customerAddressWrapper(custAddress.Id, custAddress.Address__Street__s, custAddress.Address__StateCode__s, custAddress.Address__CountryCode__s, custAddress.Address__City__s, custAddress.Address__PostalCode__s, custAddress.GST_Number__c, custAddress.Type__c, false));
                    }else {
                        customerShippingAddressWrapper.add(new customerAddressWrapper(custAddress.Id, custAddress.Address__Street__s, custAddress.Address__StateCode__s, custAddress.Address__CountryCode__s, custAddress.Address__City__s, custAddress.Address__PostalCode__s, custAddress.GST_Number__c, custAddress.Type__c, false));
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