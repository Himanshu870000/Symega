public without sharing class OperationsPortalController {
    public string quantityUnit  {get;set;}
    public string endUseCategory  {get;set;}
    public string sampleReqBy  {get;set;}
    public string mainReasonForSelPro  {get;set;}
    public string annulaVolInUnits  {get;set;}
    public string transportationTerms  {get;set;}
    
    public string packingType {get;set;}
    public string vegNonVegLabel {get;set;}
    public string ingredients {get;set;}
    public string label {get;set;}
    public string plant {get;set;}
    public string customerType {get;set;}
    public string currencyCode {get;set;}
    public string deliveryPlant {get;set;}
    public string accountSegmant {get;set;}
    public string customerAddType {get;set;}
    
    public OperationsPortalController() {
        
        quantityUnit = JSON.serialize(Utility.getPicklistValues('Sample_Line_Item__c' , 'Quantity_Unit__c'));
        endUseCategory = JSON.serialize(Utility.getPicklistValues('Project__c' , 'End_Use_category__c'));
        sampleReqBy = JSON.serialize(Utility.getPicklistValues('Project__c' , 'Sample_Requested_by__c'));
        mainReasonForSelPro = JSON.serialize(Utility.getPicklistValues('Project__c' , 'Main_reason_for_selecting_product__c'));
        annulaVolInUnits = JSON.serialize(Utility.getPicklistValues('Project__c' , 'Annual_Volume_in_units__c'));
        transportationTerms = JSON.serialize(Utility.getPicklistValues('Account' , 'Transportation_Terms__c'));
        packingType = JSON.serialize(Utility.getPicklistValues('OpportunityLineItem' , 'Packaging_Type__c'));
        vegNonVegLabel = JSON.serialize(Utility.getPicklistValues('Product2' , 'Veg_Nonveg_Logo_In_Label__c'));
        ingredients = JSON.serialize(Utility.getPicklistValues('OpportunityLineItem' , 'Ingredients_List_Declared_With_Customer__c'));
        label = JSON.serialize(Utility.getPicklistValues('OpportunityLineItem' , 'Label__c'));
        plant = JSON.serialize(Utility.getPicklistValues('OpportunityLineItem' , 'Plant__c'));
        customerType = JSON.serialize(Utility.getPicklistValues('Account' , 'Customer_Type__c'));
        currencyCode = JSON.serialize(Utility.getPicklistValues('Account' , 'CurrencyIsoCode'));
        deliveryPlant = JSON.serialize(Utility.getPicklistValues('Account' , 'Delivery_Plant__c'));
        accountSegmant = JSON.serialize(Utility.getPicklistValues('Account' , 'Account_Segment__c'));
        customerAddType = JSON.serialize(Utility.getPicklistValues('Dispatch_Address__c' , 'Type__c'));
    }

    @RemoteAction
    public static Contact loginUser(String username, String password){
        try{
            List<Contact> conRecord = [SELECT Id,Name,Email,Password__c,Role__c FROM Contact WHERE Email=: username AND Password__c=: password LIMIT 1];
            if(conRecord.size() > 0 ){
                conRecord[0].Login_Hash_Code__c = generateRandomString();
                System.debug('The Hash Code Value');
                update conRecord;                    
                return conRecord[0];
            }else{
                return null;
            }
        }catch(Exception e){
            system.debug(e.getLineNumber()+'---error Message---'+e.getMessage());
                return null;
        }
    }

    public static String generateRandomString(){
        Integer len = 10;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr+string.ValueOf(system.now().getTime()); 
    }

    @RemoteAction
    public static accountDetailWrapper getCustomerDetails(string hashCode){
        try{
            system.debug('hashCode ====> '+hashCode);
            Set<Id> setOfAccountIds = New Set<Id>();
            Set<Id> setOfSampleIds = New Set<Id>();
            Set<Id> setOfOppIds = New Set<Id>();
            List<OpportunityLineItem> oppLIneItems = New List<OpportunityLineItem>();
            List<Opportunity> oppList = New List<Opportunity>();
            List<Account> allCustomerList = New List<Account>();
            List<Project__c> listOfSamples = New List<Project__c>();

            Contact conRecord = [SELECT Id,Name,Role__c,Login_Hash_Code__c,FirstName,LastName,Email,Phone,Password__c FROM Contact WHERE Login_Hash_Code__c =: hashCode];
            List<Sample_Line_Item__c> listOfAllSLI = [SELECT Id,Name,Sample__c,Sample_Type__c,Sample_Request_Status__c,Product__r.Name,Product_Family__c,Contact__c,Contact__r.Login_Hash_Code__c,Account_Id__c FROM Sample_Line_Item__c WHERE Contact__r.Login_Hash_Code__c =: hashCode];
            system.debug('listOfAllSLI ====> '+listOfAllSLI);
            accountDetailWrapper wrapper = new accountDetailWrapper();
            wrapper.listOfSLI = listOfAllSLI;
            wrapper.conRec = conRecord;
            if(!listOfAllSLI.isEmpty()){
                for(Sample_Line_Item__c SLI : listOfAllSLI){
                    setOfAccountIds.add(SLI.Account_Id__c);
                    setOfSampleIds.add(SLI.Sample__c);
                }
                system.debug('setOfAccountIds ===> '+setOfAccountIds);
            }
            if(!setOfAccountIds.isEmpty()){
                allCustomerList = [SELECT Id,Name,Email__c,Phone,RecordType.Name,Customer_Number__c FROM Account WHERE Id IN : setOfAccountIds];
                system.debug('allCustomerList ====> '+allCustomerList);
                oppList = [SELECT Id,Name,Account.Name,Amount,CloseDate,AccountId,StageName,Probability,Type,RecordType.Name FROM Opportunity WHERE AccountId IN : setOfAccountIds];
            }
            if(!oppList.isEmpty()){
                for(Opportunity op : oppList){
                    setOfOppIds.add(op.Id);
                }
            }
            if(!setOfOppIds.isEmpty()){
                oppLIneItems = [SELECT Id,Name,OpportunityId,Product2Id,Product2.Name,Quantity,ListPrice,UnitPrice,TotalPrice,Price_In_KG__c,Quantity_In_KG__c FROM OpportunityLineItem WHERE OpportunityId IN : setOfOppIds];
            }
            if(!setOfSampleIds.isEmpty()){
                listOfSamples = [SELECT Id,Name,Record_Type_Name__c,Sample_Name__c,Shipping_Type__c,Status__c,Product_Family__c,Sample_Requested_by__c From Project__c WHERE Id IN : setOfSampleIds];
            }
            wrapper.accList = allCustomerList;
            wrapper.accRecord = Null;
            wrapper.listOfSamples = listOfSamples;
            wrapper.oppList = oppList;
            wrapper.oppProductList = oppLIneItems;

            return wrapper;
        }catch(Exception e){
            return null;
        }

    }

    @RemoteAction
    public static accountDetailWrapper getSampleDetails(string sampleId, string userHashId){
        try{
            List<Contact> conRecord = [SELECT Id,Name,Login_Hash_Code__c, (SELECT Id, Name, Sample_Assignment_Team_Type__c FROM Account__r) /*Sample_Assignment_Team__r.Team_Type__c*/ FROM Contact WHERE Login_Hash_Code__c =: userHashId];
            List<Project__c> sampleRec = [SELECT Account__c,Acc_Email__c,Acidity__c,Actual_Date_of_Dispatch__c,Additional_Comments__c,Additive_Status__c,
            Allergen__c,Allergin_Free_Decleration__c,Annual_Value__c,Annual_Volume_Full__c,Annual_Volume_in_units__c,Application_guidelines_if_any__c,
            Application_method__c,Application_Name__c,Application_product_shelf_life__c,Application_Ready__c,Application_reciepe_code__c,
            Application_Samples_Receipe_Support__c,Application_Trails__c,Approval_Status__c,Approver_Name__c,Auto_Submit_Sample__c,Brix_degrees__c,
            Business_potential_value_INR_New__c,Business_potential_value_INR__c,Category_Buyer__c,Category_description_as_per_FSSAI__c,
            Center_filling_Cream__c,City__c,Company_Name__c,Confectionary_Type__c,Contact_Number__c,Cost_in_Use_target__c,Cost_in_use__c,
            Country_of_Compliance__c,Country_Regulation__c,Country__c,Courier__c,CreatedById,CreatedDate,Critical__c,CurrencyIsoCode,Currency_Type__c,
            Current_Cost__c,Current_Packaging__c,Current_RM_FG_Code__c,Current_Shelf_life__c,Current_Supplier_Name__c,Customers_Contact__c,
            Customer_Base_Details__c,Customer_Brand_details__c,Customer_Comments__c,Customer_Cost_in_USE_CIU__c,Customer_Feedback__c,Customer_Launch_Date__c,
            Customer_Name__c,Customer_Target_price__c,Dispatch_Details__c,Distributer_Customer__c,Documentation_Support__c,Dosage_guidelines_by_customer__c,
            Dosage_Guidelines__c,End_Application_Category__c,End_Use_Applications__c,End_use_application_other__c,End_Use_category__c,Error_Message_On_Submitting_To_Optiva__c,
            Error_Occured_On_Submitting_To_Optiva__c,Expected_Annual_Value__c,Expected_Shelf_Life__c,Expected_Volume_Unit__c,Export__c,External_Id__c,Fat__c,
            Final_Fat__c,Final_SNF__c,First_Sample_due_date__c,Flavor_Legal_Status__c,Flavour_CIU__c,Flavour_Legal_Status__c,Follow_Up_Count__c,GMO_Status__c,
            Halal_Certification__c,Id,If_Private_Label__c,If_yes_Flavour_Details__c,Ingredient_Specific_If_Any__c,Integration_Product_Type__c,IsDeleted,
            Is_Shipping_Complete__c,Kosher_Certification__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lead_Time__c,
            Lead__c,Legal_Status_as_per_EU__c,Legal_Status_as_per_Indian_FSSAI__c,Legal_Status_as_per_US__c,Legal_Status__c,Matching_Target_details__c,
            Milk_Solids__c,Minimum_order_quantity_unit__c,Minimum_order_quantity__c,Moved_Production_date__c,MSDS__c,Name,Name__c,New_Supplier__c,Nutritional__c,
            of_pulp_if_with_fruit_pulp__c,Oil_sprinkling_Dust_on__c,Opportunity_Close_Date__c,Opportunity_Sub_Type__c,Opportunity_Type__c,Opportunity__c,
            Organic_Certification__c,Other_Application_Methods__c,Other_Project_Composition__c,Other__c,OwnerId,Packaging_Unit__c,Parent_Project__c,
            Payment_Terms__c,Physical_Form__c,pH__c,Postal_Code__c,Preferred_thickness_Viscosity__c,Priority__c,Processing_condition__c,Product_approval_format_by_customer__c,
            Product_Code__c,Product_Description__c,Product_Family__c,Product_ID__c,Product_Instruction__c,Product_Link__c,Product_recommended__c,Product_Spec__c,
            Product_Type__c,Project_Category__c,Project_Completion_Date__c,Project_Name__c,Project_Reference__c,Project_Title__c,Project_Type__c,Proposed_Cost__c,
            Proposed_date_of_dispatch__c,Proposed_Supplier_Name__c,Prototype_Feedback__c,Quantity_Unit__c,Quantity__c,Quote_Volume_in_units__c,Raw_Material_Name__c,
            Reason_for_New_Supplier__c,Reason_for_rejection__c,Main_reason_for_selecting_product__c,Recipe_Cost__c,RecordTypeId,Record_Type_Name__c,Regulatory_Requirements__c,
            Required_End_Date__c,Revert_Date_Count__c,RM_Category__c,R_D_Approval_Status__c,Sales_Code__c,Sales_head_review__c,Sample_Delivery_Date__c,
            Sample_Name__c,Sample_Project__c,Sample_Requested_by__c,Sample_Revert_Date__c,Sample_Size_for_trails__c,Sample_Submitted_Date__c,Sample_Sub_Retry_Count__c,
            Sampling_Quantity_details__c,Sampling_Quantity_Unit__c,SAP_User_Code__c,Scaled_up_date__c,Sensory_profiling_Report_Required__c,Sensory_Target_profile_expectation__c,
            Ship_To_Address__c,Show_BH_Approval__c,Solubility_Preference__c,Solublity__c,Specific_inputs_by_customer__c,Specify_other_reason__c,Start_Date__c,
            State__c,Status__c,Street__c,Submitted_To_SAP_Optiva__c,Submit_Sample_To_Optiva__c,Sugar__c,Supplier_COA__c,Supplier_Food_Grade_Status__c,
            Supplier_Legal_Status__c,Supplier_MSDS__c,Supplier_Spec__c,SystemModstamp,S_O_Date__c,Target_Date__c,Target_GM_Improvement_at_FG_levels__c,
            Target_Price__c,Target_Saving_Percentage__c,Technical_Complexity__c,Tech_Doc_Name__c,Tested_at_Flavor_Level__c,Time_Duration_in_hours__c,Total_Project_Quotient__c,
            Total_Solids__c,Type_of_PR__c,Usage_Levels_in_Recipes_Average__c,Way_Bill_No__c,Wet_Dry__c,Where_Used__c,who_requested_the_sample__c,
            Opportunity__r.Name,Account__r.Name,(SELECT Id, Name, Product__c,Project_Quotient__c,OPTIVA_Recipe__c, Quantity__c, Quantity_Unit__c, Packaging_Quantity__c, Packaging_Unit__c, Product_Max_Qty__c, Formula_Packaging_Qty__c, Product__r.Regulatory__c,OPTIVA_Recipe__r.Name, OPTIVA_Recipe__r.Regulatory__c, OPTIVA_Recipe__r.Shelf_Life__c,Product_Family__c,
                                                  Expected_Shelf_Life__c, Additional_Comments__c, Customer_Instructions__c, Sample__c,Project_Quotient__r.Name, Project_Quotient__r.SSC_Code__c, Product__r.Sampling_Qty_UNIT__c, Product__r.Name, Product__r.Max_sampling_Qty__c, Product__r.ProductCode, Product__r.Current_Shelf_Life__c, OPTIVA_Recipe__r.SSC_Code__c
                                                  FROM Sample_Line_Items__r) FROM Project__c WHERE Id =: sampleId];
            
            List<Contact> conRec = [SELECT Id,Name, (SELECT Id, Name, Sample_Assignment_Team_Type__c FROM Account__r)/*Sample_Assignment_Team__r.Team_Type__c*/ FROM Contact WHERE Login_Hash_Code__c =: userHashId];
            
            accountDetailWrapper wrapper = new accountDetailWrapper();
            List<String> typeList = new List<String>();
            for(Sample_Allocation_Team__c st : conRec[0].Account__r){
                if(st.Sample_Assignment_Team_Type__c != null && st.Sample_Assignment_Team_Type__c != ''){
                    typeList.add(st.Sample_Assignment_Team_Type__c);
                }
            }
            List<Product2> productList = [SELECT Id,ProductCode,Name,Family FROM Product2 WHERE Family IN : typeList];
            List<OPTIVA_Recipe__c> opRecipeList = [SELECT Id,Name,SSC_Code__c,Recipe_Family__c FROM OPTIVA_Recipe__c WHERE Recipe_Family__c IN : typeList];
            List<Project_Quotient__c> proQuotientList = [SELECT Id,Name,SSC_Code__c,Sample_Project_Application__c,Sample_Project_Application__r.Product_Family__c FROM Project_Quotient__c WHERE Sample_Project_Application__r.Product_Family__c IN : typeList];
            wrapper.listOfSamples = sampleRec;
            wrapper.listOfProducts = productList;
            wrapper.listOfOptivaRecipe = opRecipeList;
            wrapper.listOfProQuotient = proQuotientList;
            wrapper.conRec = conRec[0];
            
            return wrapper;
        }catch(Exception e){
            return null;
        }
    }
    

    @RemoteAction
    public static Sample_Line_Item__c getSLIDetails(string sliId){
        try{
            List<Sample_Line_Item__c> SLIRec = [SELECT Account_Id__c,Actual_date_of_dispatch__c,Additional_Comments__c,Contact__c,Courier__c,CreatedById,
            CreatedDate,CurrencyIsoCode,Current_Shelf_Life__c,Customer_Instructions__c,Customer_Name__c,Customer_Target_price__c,Dispatch_Details__c,
            Distributer_Customer__c,Exclusive_customer_product_code__c,Expected_Shelf_Life__c,First_Sample_Due_Date__c,Formula_Packaging_Qty__c,Id,
            IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Line_Item_Name__c,Name,OPTIVA_Recipe__c,
            OwnerEmail__c,OwnerId,Packaging_Quantity__c,Packaging_Unit__c,Product_Code__c,Product_Family__c,Product_Max_Qty__c,Product_Name__c,Product__c,
            Project_Quotient__c,Qty_in_KGs__c,Quantity_Unit__c,Quantity__c,Reason_For_Rejection__c,Regulatory_Requirements__c,Sample_delivery_date__c,
            Sample_Invoice_Date__c,Sample_Request_Status__c,Sample_Submitted_Date__c,Sample_Type__c,Sample__c,SLI_Dispatched__c,Start_Date__c,Submitted__c,
            SystemModstamp,Way_Bill_No__c,Sample__r.Name,Project_Quotient__r.Name,(SELECT Id,Name,Comment__c,Comment_By__r.Name FROM Comments__r) FROM Sample_Line_Item__c WHERE Id =: sliId];
            return SLIRec[0];
        }catch(Exception e){
            return null;
        }
    }

    @AuraEnabled
    public static Account getAccRecord(String id){
        try {
            if(String.isBlank(id))
                return null;
            return [SELECT Id, Name FROM Account where Id =:id];
                    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getProjectRecordTypeId(string recordTypeName){
        try {
            system.debug('recordTypeName ====> '+recordTypeName);
            // system.debug('idd'+Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId());
            return '0129D000001KUxvQAG';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @RemoteAction
    public static accountDetailWrapper getCustomerDetail(String accId, String hashCode){
        try{
            List<Contact> conRec = [SELECT Id,Name,(SELECT Id, Name, Sample_Assignment_Team_Type__c FROM Account__r)/*Sample_Assignment_Team__r.Team_Type__c*/,Role__c FROM Contact WHERE Login_Hash_Code__c =: hashCode];
            List<Account> accRecord = [SELECT AccountSource,Account_Potential__c,
            Account_Segment__c,Account_Type__c,BillingAddress,BillingCity,BillingCountry,
            BillingCountryCode,BillingGeocodeAccuracy,BillingLatitude,BillingLongitude,
            BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Billing_Block__c,
            Billing_To_Shipping__c,Brands__c,Closed_Opportunity_Value_New__c,
            Closed_Opportunity_Value__c,Closed_opportunity__c,COLOR_Opportunity_Closed_Value_New__c,
            COLOR_Opportunity_Closed_Value__c,Contract_period__c,CPD_Opportunity_Closed_Value_New__c,
            CPD_Opportunity_Closed_Value__c,CreatedById,CreatedDate,Credit_Block__c,Credit_Limit_Finance__c,
            Credit_Limit__c,Credit_Period_Finance__c,Credit_Period__c,CurrencyIsoCode,
            Currency__c,Current_year_Volume_Unit__c,Current_year_Volume__c,Customer_Code_OPTIVA__c,
            Customer_Code_SAP__c,Customer_Contact__r.Name,Customer_Discount__c,Customer_Number__c,
            Customer_Type__c,Delivery_Block__c,Delivery_Plant__c,Description,DISTRIBUTOR_BASIC_RATE_in_INR__c,
            DISTRIBUTOR_LANDING_in_INR__c,Document_Category__c,Email__c,Existing_product_portfolio_of_the_compny__c,
            FLAVOR_Opportunity_Closed_Value_New__c,FLAVOR_Opportunity_Closed_Value__c,FSSAI__c,GST_number__c,
            Id,Industry,InitiatedCustomerCreation__c,IsDeleted,Jigsaw,JigsawCompanyId,Language__c,
            LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,
            Launching_in_brands_associated__c,Lead_generated_by__c,Lead_generated_by__r.Name,Login_Hash_Code__c,MasterRecordId,
            Missing_Fields__c,Name,NDA_required__c,Owner.FirstName,User__r.Name,Next_Follow_up_Date__c,NumberOfEmployees,
            Number_of_closed_opportunity_new__c,Number_of_closed_opportunity__c,Number_of_open_opportunity_new__c,
            Number_of_open_opportunity__c,Number_of_Total_Opportunity_new__c,Number_of_Total_Opportunity__c,
            Number_Of_Won_Opportunity_new__c,Number_of_won_opportunity_partially_exec__c,Number_of_won_opportunity_partially_new__c,
            Number_Of_Won_Opportunity__c,Outstanding_Balance__c,Overall_Block__c,OwnerEmail__c,
            OwnerId,PAN_Number__c,ParentId,Partially_executed_actual_order_value_vs__c,
            Password__c,Payment_terms__c,Percentage_Value__c,Phone,PhotoUrl,PLANT_BASED_Opportunity_Closed_Value_New__c,
            PLANT_BASED_Opportunity_Closed_Value__c,Potential_Opportunity__c,Profile_Pic_Id__c,
            RecordTypeId,Record_Type_Name__c,Run_Validation_Rule__c,ShippingAddress,ShippingCity,
            ShippingCountry,ShippingCountryCode,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,
            ShippingPostalCode,ShippingState,ShippingStateCode,ShippingStreet,Show_Parent_Account_Summary__c,
            SicDesc,Single_Multiple__c,SPD_Opportunity_Closed_Value_New__c,SPD_Opportunity_Closed_Value__c,
            Status__c,Submitted_to_Optiva__c,Submitted_to_SAP__c,SystemModstamp,Tax_Collected_At_Source__c,
            Tax_Type__c,Total_Team_Members__c,Transportation_Terms__c,Type,User__c,Visible_Potential__c,
            Website,Win_rate__c,Won_opportunity_value_product_wise__c,(SELECT Id From Opportunities),(SELECT Id,Name,Comment__c,Comment_By__r.Name FROM Comments__r) FROM Account WHERE Id =: accId];

            set<Id> setOfOppIds = New set<Id>();
            if(!accRecord[0].Opportunities.isEmpty()){
                for(Opportunity opp : accRecord[0].Opportunities){
                    setOfOppIds.add(opp.Id);
                }
            }
            system.debug('setOfOppIds =====> '+setOfOppIds);
            
            List<Project__c> listOfAllSampleRecords = [SELECT Id,Name,Record_Type_Name__c,Sample_Name__c,Shipping_Type__c,Status__c,Product_Family__c,Sample_Requested_by__c,Opportunity__c From Project__c WHERE Opportunity__c IN : setOfOppIds];
            system.debug('listOfAllSampleRecords ====> '+listOfAllSampleRecords);
            accountDetailWrapper wrapper = new accountDetailWrapper();
            wrapper.accRecord = (accRecord.size() > 0) ? accRecord[0] : null;
            wrapper.listOfSamples = listOfAllSampleRecords;
            wrapper.conRec = conRec[0];
            return wrapper;
        }catch(Exception e){
            return null;
        }
    }

    @RemoteAction
    public static accountDetailWrapper getOpportunityDetails(string oppId){
        try{
            List<Account> accRec = New List<Account>();
            List<Dispatch_Address__c> custAddRecord = New List<Dispatch_Address__c>();
            List<Contact> conTactList = New List<Contact>();
            List<Opportunity> oppRecord = [SELECT AccountId,Account_Billing_Address__c,Customer_Billing_Address__c,accShipAdr__c,AgeInDays,Amount,Approval_Status__c,Approved_by_Business_Head__c,Approved_by_Manager__c,
            Approved_by_MD__c,Approver_Name__c,CampaignId,Child_Opp__c,CloseDate,Color_Opportunity__c,ContactId,ContractId,CPD_Opportunity__c,CreatedById,
            Billing_Street__c,Billing_City__c,Billing_State__c,Billing_Country__c,Billing_Postal_Code__c,CreatedDate,CurrencyIsoCode,Customer_Followup_Date__c,Customer_response__c,Description,Distributer_Customer__c,Email__c,End_Use_Application__c,
            End_Use_Category__c,Fiscal,FiscalQuarter,FiscalYear,Fiscal_Year__c,Flavor_Opportunity__c,ForecastCategory,ForecastCategoryName,Freight_charges__c,
            HasOpenActivity,HasOpportunityLineItem,HasOverdueTask,Id,Include_Freight_Charges__c,Initial_Discount_Approved__c,IsClosed,IsDeleted,
            IsPriorityRecord,IsWon,LastActivityDate,LastActivityInDays,LastAmountChangedHistoryId,LastCloseDateChangedHistoryId,LastModifiedById,
            LastModifiedDate,LastReferencedDate,LastStageChangeDate,LastStageChangeInDays,LastViewedDate,Last_Opp_Closure_Reminder_Date__c,LeadSource,
            Markdown__c,Name,NextStep,Next_Order_Date__c,Opportunity_Age__c,Opportunity_Reference_No__c,OwnerEmail__c,OwnerId,Parent_Opportunity__c,
            Performa_Invoice_No__c,Place_of_Reciept_by_Pre_Carrier__c,Plant_Based_Opportunity__c,Port_of_Discharge__c,Port_of_Loading__c,Pre_carriage_By__c,
            Pricebook2Id,Primary_Contact__c,Probability,Proposed_Date_of_Dispatch__c,PushCount,Pvt_Label_Item_Count__c,Reason_For_Loss_del__c,RecordTypeId,
            Repeat_Order_Created__c,Sample__c,Send_Fert_Notification_Email__c,Show_FERT_Button__c,SPD_Opportunity__c,StageName,
            SyncedQuoteId,SystemModstamp,TotalOpportunityQuantity,Total_FERT_Products__c,Total_Freight_Charges__c,Total_List_Price__c,Total_Markdown_Price__c,
            Total_Qty_In_Kg__c,Total_Quantity__c,Total_Unit_Price__c,Type,Vessel_Flight_Name_Voy_No__c,RecordType.Name,
            Account.Name,Primary_Contact__r.Name,Pricebook2.Name FROM Opportunity WHERE Id =: oppId];
            
            List<OpportunityLineItem> oliList = [SELECT Applied_Volume_Based_Markup__c,Approval_Markdown__c,Art_Work__c,Change_in_Dispatch_Date__c,CreatedById,CreatedDate,CurrencyIsoCode,
                                 Cusinery_identity__c,Customer_Code__c,Customer_Discount_Applied__c,Customer_Type__c,Customized_Label__c,Description,Discount,Discount_Description__c,
                                 FERT_Code__c,Fert_Description__c,Id,If_Organised_set_Micro_as_Long_Term__c,Ingredients_List_Declared_With_Customer__c,Ingredient_list__c,IsDeleted,
                                 Is_Parent_Opportunity__c,Is_PIR_Created__c,Label__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,ListPrice,ListPriceXQty__c,
                                 MarkdownXQty__c,MarkDown_Amount__c,Markup_Amount__c,Material_Sector__c,Name,OpportunityId,Order_Quantity__c,Packaging_Quantity__c,Packaging_Type__c,
                                 Packaging_Unit__c,Planned_Delivery_Date__c,Plant__c,PricebookEntryId,Price_In_KG__c,Primary__c,Product2Id,Product2.Name,ProductCode,Product_Family__c,
                                 Pvt_Label_Selling_Price__c,Quantity,Quantity_In_KG__c,Quantity_Unit__c,Reveal_Symega_Identity__c,Sales_Order__c,Sales_Remarks__c,
                                 Sale_Order_Submitted__c,Secondary__c,ServiceDate,Service_Rendering_Date_Reason__c,Service_Rendering_Date__c,SortOrder,SSC_Code_for_Flavours__c,
                                 Sub_Total__c,Symega_Logo__c,SystemModstamp,Tertiary__c,TotalPrice,Type__c,UnitPrice,UnitPriceXQty__c,Unit_Of_Measure__c,Volume_Based_Amount__c,Product2.Shelf_Life__c, 
                                 Product2.Allergen_Status_Required__c,Product2.Control_Code_HSN_Code__c,Product2.Veg_Nonveg_Logo_In_Label__c FROM OpportunityLineItem WHERE OpportunityId =: oppId];
            
            
            
            if(oppRecord[0].AccountId != null && oppRecord[0].Account_Billing_Address__c == true){
				accRec = [Select Id,Name, Customer_Type__c,CurrencyIsoCode,BillingCity,BillingCountry,BillingStreet,BillingPostalCode,BillingState,Delivery_Plant__c,Account_Segment__c,
                          Transportation_Terms__c,PAN_Number__c,GST_number__c From Account WHERE Id =: oppRecord[0].AccountId];
                conTactList = [SELECT Id,Name FROM Contact WHERE AccountId =: accRec[0].Id];
                                
            }
            if(oppRecord[0].Customer_Billing_Address__c != null){
               custAddRecord = [select Id,Address__city__s,Address__Street__s,Address__PostalCode__s,toLabel(Address__CountryCode__s),toLabel(Address__StateCode__s),Contact__c,Account__c,
                                Type__c from Dispatch_Address__c WHERE Id =: oppRecord[0].Customer_Billing_Address__c]; 
                conTactList = [SELECT Id,Name FROM Contact WHERE AccountId =: custAddRecord[0].Account__c];
            }
            
            accountDetailWrapper wrapper = new accountDetailWrapper();
            wrapper.oppList = oppRecord;
            if(!accRec.isEmpty()){
                wrapper.accRecord = accRec[0];
            }
            
            if(!custAddRecord.isEmpty()){
               wrapper.customerAddRec = custAddRecord[0];
            }
            if(!oliList.isEmpty()){
                wrapper.oppProductList = oliList;
            }
            if(!conTactList.isEmpty()){
                wrapper.conList = conTactList;
            }
            return wrapper;
        }catch(Exception e){
            return null;
        }
    }

    @RemoteAction
    public static OpportunityLineItem getOppProductDetails(string oliId){
        try{
            List<OpportunityLineItem> oppProdRecord = [SELECT Applied_Volume_Based_Markup__c,Approval_Markdown__c,Change_in_Dispatch_Date__c,CreatedById,
            CreatedDate,CurrencyIsoCode,Customer_Code__c,Customer_Discount_Applied__c,Customer_SF_Id__c,Customer_Type__c,Customized_Label__c,Description,
            Discount,Discount_Description__c,FERT_Code__c,Id,If_Organised_set_Micro_as_Long_Term__c,IsDeleted,Is_Parent_Opportunity__c,Is_PIR_Created__c,
            LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,ListPrice,ListPriceXQty__c,MarkdownXQty__c,MarkDown_Amount__c,Markup_Amount__c,
            Material_Sector__c,Name,OpportunityId,Packaging_Quantity__c,Packaging_Type__c,Packaging_Unit__c,Planned_Delivery_Date__c,Plant__c,PricebookEntryId,
            Price_In_KG__c,Primary__c,Product2Id,ProductCode,Product_Family__c,Pvt_Label_Selling_Price__c,Quantity,Quantity_In_KG__c,Quantity_Unit__c,
            Repeat_Order_Details__c,Sales_Order__c,Secondary__c,ServiceDate,Service_Rendering_Date_Reason__c,Service_Rendering_Date__c,SortOrder,Sub_Total__c,
            Symega_Logo__c,SystemModstamp,Tertiary__c,TotalPrice,UnitPrice,UnitPriceXQty__c,Volume_Based_Amount__c,Volume_Based_Unit__c,
            Opportunity.Name,Product2.Name,Sales_Order__r.Name FROM OpportunityLineItem WHERE Id =: oliId];
            return oppProdRecord[0];
        }catch(Exception e){
            return null;
        }
    }

    public class accountDetailWrapper{
        public Account accRecord { get; set; }
        public List<Project__c> listOfSamples { get; set; }
        public List<Sample_Line_Item__c> listOfSLI { get; set; }
        public List<Account> accList { get; set; }
        public Contact conRec { get; set; }
        public List<Opportunity> oppList { get; set; }
        public List<OpportunityLineItem> oppProductList { get; set; }
        public Dispatch_Address__c customerAddRec {get; set;}
        public list<Product2> listOfProducts { get; set; }
        public list<OPTIVA_Recipe__c> listOfOptivaRecipe { get; set; }
        public list<Project_Quotient__c> listOfProQuotient { get; set; }
        public list<Contact> conList { get; set; }
    }

    @RemoteAction
    public static List<Sample_Line_Item__c> getAllSampleLineItems(String hashCode){
        try{
            if(!String.isBlank(hashCode)){
                List<Sample_Line_Item__c> listOfAllSLI = [SELECT Id,Name,Product__c,Product__r.Name,Quantity_Unit__c,Quantity__c,Packaging_Unit__c,
                Packaging_Quantity__c,Contact__c,Contact__r.Login_Hash_Code__c,Contact__r.Name,Contact__r.Email,Contact__r.FirstName,Contact__r.LastName,Contact__r.MobilePhone FROM Sample_Line_Item__c WHERE Contact__r.Login_Hash_Code__c =: hashCode];
                if(!listOfAllSLI.isEmpty()){
                    return listOfAllSLI;
                }else{
                    return null;
                }
            }
            return null;
        }catch(Exception e){
            system.debug('Error ===> '+e.getMessage()+e.getLineNumber());
            return null;
        }
    }

    @RemoteAction
    public static List<Map<String, Object>> getDetailrecordOfSLI(String SLIid){
        try{
            List<Map<String, Object>> accountFields = new List<Map<String, Object>>();
            Sample_Line_Item__c acc = [SELECT Name,Actual_date_of_dispatch__c,Additional_Comments__c,Contact__c,Courier__c,Current_Shelf_Life__c,
            Customer_Instructions__c,Customer_Name__c,Customer_Target_price__c,Dispatch_Details__c,Distributer_Customer__c,Exclusive_customer_product_code__c,
            Expected_Shelf_Life__c,First_Sample_Due_Date__c,Formula_Packaging_Qty__c,Line_Item_Name__c,OPTIVA_Recipe__c,OwnerEmail__c,
            Packaging_Quantity__c,Packaging_Unit__c,Product__c,Product_Code__c,Product_Family__c,Product_Max_Qty__c,Product_Name__c,Project_Quotient__c,
            Qty_in_KGs__c,Quantity__c,Quantity_Unit__c,Reason_For_Rejection__c,Regulatory_Requirements__c,Sample__c,CreatedById,LastModifiedDate,
            Sample_delivery_date__c,Sample_Invoice_Date__c,Sample_Request_Status__c,Sample_Submitted_Date__c,OwnerId,Isdeleted,CreatedDate,LastModifiedById,
            Sample_Type__c,SLI_Dispatched__c,Start_Date__c,Submitted__c,Way_Bill_No__c,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDate
             FROM Sample_Line_Item__c WHERE Id = :SLIid LIMIT 1];
            system.debug('acc =====> '+acc);

        // Get the Schema information for the Account object
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Sample_Line_Item__c.fields.getMap();
        system.debug('fieldMap ====> '+fieldMap);
        for (String fieldName : fieldMap.keySet()) {
            Object fieldValue = acc.get(fieldName);
            Map<String, Object> fieldData = new Map<String, Object>();
            if (fieldMap.containsKey(fieldName)) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                String fieldLabel = field.getDescribe().getLabel();
                System.debug('Field Label: ' + fieldLabel);
                fieldData.put('fieldLabel', fieldLabel);
            }
            fieldData.put('fieldValue', fieldValue);
            system.debug('fieldData =====> '+fieldData);
            accountFields.add(fieldData);
        }
        system.debug('accountFields ====> '+accountFields);

        return accountFields;
        }catch(Exception e){
            return null;
        }
    }

    @RemoteAction
    public static String LogoutApplicant(String loginHasgCode){
        try{
           
            contact conRec = [SELECT Name,Id FROM Contact where Login_Hash_Code__c =:loginHasgCode limit 1];
            conRec.Login_Hash_Code__c=null;
            update conRec;
            return 'success';
        }
        catch(Exception e){
            system.debug('The Error :: '+e.getMessage()+' AND Line No :: '+e.getLineNumber()+'');
            return e.getMessage()+e.getLineNumber();
        }
    }

    @RemoteAction
    public static string updateProfile(Contact ConDetails){
        try{
            update ConDetails;
            return 'SUCCESS';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }

    @RemoteAction
        public static String resetpassword(String emailId){
            try{
                List<Contact> conList = [SELECT FirstName,LastName,Name,Email,Password__c,Login_Hash_Code__c FROM Contact WHERE Email =: emailId LIMIT 1];
                if(conList.size()>0){

                    EmailTemplate temp = [SELECT Id,Name,HTMLValue,Subject, Body FROM EmailTemplate WHERE Name =: 'Forgot Password'];
                    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                    Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress ].Id;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
                    mail.setToAddresses(new String[] {conList[0].Email});
                    mail.setSubject(temp.Subject);//Set Subject
                    string emailHtmlValue = temp.HtmlValue;

                    if(!string.isBlank(conList[0].FirstName))
                    emailHtmlValue = emailHtmlValue.replace('{!Contact.FirstName}', conList[0].FirstName);
                    if(!string.isBlank(conList[0].LastName))
                    emailHtmlValue = emailHtmlValue.replace('{!Contact.LastName}', conList[0].LastName);
                    if(!string.isBlank(conList[0].Login_Hash_Code__c))
                    emailHtmlValue = emailHtmlValue.replace('{!Contact.Login_Hash_Code__c}', conList[0].Login_Hash_Code__c);

                    mail.setHtmlBody(emailHtmlValue);//Set HTML Body
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                return 'SUCCESS';
            }catch(Exception e){
                return e.getMessage()+e.getLineNumber();
            }
        }

        @RemoteAction
        public static String resetpassApplication(String password, String loginhashcode){
            try{
            Contact conToUpdate = [SELECT Name,Email, Password__c, Login_Hash_Code__c FROM Contact WHERE Login_Hash_Code__c =: loginhashcode LIMIT 1];
            conToUpdate.Password__c = password;
            conToUpdate.Login_Hash_Code__c = Utility.generateRandomString();
            update conToUpdate;
            return 'SUCCESS';
            }catch(Exception e){
            System.debug('The Error---->'+e.getMessage());
            System.debug('The Error Line---->'+e.getLineNumber());
            }
            return 'error';
        }

    @RemoteAction
    public static string updateSLIRecord(Sample_Line_Item__c SLIRecord, Integer dispatchYear, Integer dispatchmonth, Integer dispatchday, Integer invoiceYear, Integer invoicemonth, Integer invoiceday){
        try{
            //system.debug('comment ====> '+comment);
            if(dispatchYear == 0 && dispatchmonth==0 && dispatchday==0){
                
            }else{
                SLIRecord.Actual_date_of_dispatch__c = Date.newInstance(dispatchYear, dispatchmonth, dispatchday); 
            }
            if(invoiceYear == 0 && invoicemonth==0 && invoiceday==0){
                
            }else{
                SLIRecord.Sample_Invoice_Date__c = Date.newInstance(invoiceYear, invoicemonth, invoiceday); 
            }
            update SLIRecord;
            //insert comment;
            return 'Success';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }

    @RemoteAction
    public static List<Sample_Line_Item__c> searchOLI(string serachKey, string hashCode){
        try{
            List<Sample_Line_Item__c> listOfSLI = [SELECT Id,Name,Product__r.Name FROM Sample_Line_Item__c WHERE Product__r.Name LIKE :('%' + serachKey + '%') AND Contact__r.Login_Hash_Code__c =: hashCode];
            return listOfSLI;
        }catch(Exception e){
            return null;
        }
    }
    
    @RemoteAction
    public static List<Project__c> searchSample(string serachKey, List<Project__c> listOfSamp){
        try{
            Set<Id> setOfSampleIds = New Set<Id>();
            if(!listOfSamp.isEmpty()){
                for(Project__c samp : listOfSamp){
                    setOfSampleIds.add(samp.Id);
                }
            }
            List<Project__c> listOfSample = [SELECT Id,Name,Sample_Name__c,Record_Type_Name__c,Shipping_Type__c,Status__c,Product_Family__c,Sample_Requested_by__c FROM Project__c WHERE Sample_Name__c LIKE :('%' + serachKey + '%') AND Id IN : setOfSampleIds];
            return listOfSample;
        }catch(Exception e){
            return null;
        }
    }
    
    @RemoteAction
    public static List<Opportunity> searchOpportunity(string serachKey, List<Opportunity> listOfOpp){
        try{
            Set<Id> setOfOppIds = New Set<Id>();
            if(!listOfOpp.isEmpty()){
                for(Opportunity opp : listOfOpp){
                    setOfOppIds.add(opp.Id);
                }
            }
            List<Opportunity> listOfOpportunity = [SELECT Id,Name,Account.Name,Amount,CloseDate,AccountId,StageName,Probability,Type,RecordType.Name FROM Opportunity WHERE Name LIKE :('%' + serachKey + '%') AND Id IN : setOfOppIds];
            return listOfOpportunity;
        }catch(Exception e){
            return null;
        }
    }
    
    @RemoteAction
    public static List<OpportunityLineItem> searchOppProds(string serachKey, List<OpportunityLineItem> listOfOLI){
        try{
            Set<Id> setOfOLIIds = New Set<Id>();
            if(!listOfOLI.isEmpty()){
                for(OpportunityLineItem oli : listOfOLI){
                    setOfOLIIds.add(oli.Id);
                }
            }
            List<OpportunityLineItem> listOfOppProducts = [SELECT Id,Name,OpportunityId,Product2Id,Product2.Name,Quantity,ListPrice,UnitPrice,TotalPrice,Price_In_KG__c,Quantity_In_KG__c FROM OpportunityLineItem WHERE Name LIKE :('%' + serachKey + '%') AND Id IN : setOfOLIIds];
            return listOfOppProducts;
        }catch(Exception e){
            return null;
        }
    }
    
    @RemoteAction
    public static List<Account> searchAccount(string serachKey, List<Account> listOfAcc){
        try{
            Set<Id> setOfAccIds = New Set<Id>();
            if(!listOfAcc.isEmpty()){
                for(Account acc : listOfAcc){
                    setOfAccIds.add(acc.Id);
                }
            }
            List<Account> listOfAccount = [SELECT Id,Name,Email__c,Phone FROM Account WHERE Name LIKE :('%' + serachKey + '%') AND Id IN : setOfAccIds];
            return listOfAccount;
        }catch(Exception e){
            return null;
        }
    }
    
    @RemoteAction
    public static string generateInvoice(List<Id> listOfSampleIds){
        try{
            String PDFName;
            system.debug('listOfSampleIds =====> '+listOfSampleIds);
            if(!listOfSampleIds.isEmpty()){
                List<Project__c> listOfSamples = [SELECT Id,Name,Shipping_Type__c FROM Project__c WHERE Id IN : listOfSampleIds];
                List<ContentVersion> fileDataList = new List<ContentVersion>();
            	List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
                if(listOfSamples[0].Shipping_Type__c == 'Domestic'){
                    PDFName = 'SampleInvoiceDomesticPDF';
                }else{
                   PDFName = 'SampleInvoicePDF'; 
                }
                
                for (Id parentId : listOfSampleIds) {
                    PageReference ref;
                    if(PDFName == 'SampleInvoiceDomesticPDF'){
                        ref = Page.SampleInvoiceDomesticPDF;
                    }else{
                       ref = Page.SampleInvoicePDF; 
                    }
                    //PageReference ref = Page.SampleInvoiceDomesticPDF;
                    ref.getParameters().put('id', parentId);
                    system.debug('ref -- ' + ref);
                    system.debug('ref.getParameters() -- ' + ref.getParameters());
                    ContentVersion fileData = new ContentVersion();
                    fileData.Title = listOfSamples[0].Shipping_Type__c+'Invoice';
                    fileData.VersionData = ref.getContentAsPdf();
                    fileData.PathOnClient = listOfSamples[0].Shipping_Type__c+'Invoice' + '.pdf'; // Set the file path
                    fileData.FirstPublishLocationId = parentId;
                    
                    fileDataList.add(fileData);
            	}
                insert fileDataList;
            	system.debug('fileDataList -- ' + fileDataList);
                
                set<Id> cvIdSet = new set<Id>();
            for (ContentVersion fileData : fileDataList) {
                cvIdSet.add(fileData.Id);
            }
            system.debug('cvIdSet -- ' + cvIdSet);
            
            List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE Id IN: cvIdSet];
            // Get the ContentDocumentIds after the insert operation
            Map<Id, Id> parentIdToContentDocumentIdMap = new Map<Id, Id>();
            for (ContentVersion fileData : cvList) {
                parentIdToContentDocumentIdMap.put(fileData.FirstPublishLocationId, fileData.ContentDocumentId);
            }
            system.debug('parentIdToContentDocumentIdMap -- ' + parentIdToContentDocumentIdMap);
            
            // Create ContentDocumentLink records using the ContentDocumentIds
            List<ContentDocumentLink> existingContentDocumentLinks = [
                SELECT Id, ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :parentIdToContentDocumentIdMap.values()
                AND LinkedEntityId IN :listOfSampleIds
            ];
            
            Set<String> uniqueContentDocumentLinks = new Set<String>();
            for (ContentDocumentLink existingLink : existingContentDocumentLinks) {
                String uniqueKey = existingLink.ContentDocumentId + '_' + existingLink.LinkedEntityId;
                uniqueContentDocumentLinks.add(uniqueKey);
            }
            
            // Create ContentDocumentLink records using the ContentDocumentIds
            for (Id parentId : listOfSampleIds) {
                String contentDocumentId = parentIdToContentDocumentIdMap.get(parentId);
                String uniqueKey = contentDocumentId + '_' + parentId;
                
                if (!uniqueContentDocumentLinks.contains(uniqueKey)) {
                    contentDocumentLinks.add(new ContentDocumentLink(
                        ContentDocumentId = contentDocumentId,
                        LinkedEntityId = parentId,
                        ShareType = 'V' // 'V' represents sharing the file with the record and its related users
                    ));
                    uniqueContentDocumentLinks.add(uniqueKey);
                }
            }
            
            Database.upsert(contentDocumentLinks, false); // Upsert ContentDocumentLink records
            }
            return 'SUCCESS';
        }catch(Exception e){
           return e.getMessage()+e.getLineNumber(); 
        }
    }
    
    @RemoteAction
    public static string saveComment(Comment__c com, String hashCode, string SLIid){
        try{
            List<Contact> conRec = [SELECT Id,Name,Login_Hash_Code__c FROM Contact WHERE Login_Hash_Code__c =: hashCode];
            com.Comment_By__c = conRec[0].Id;
            com.Sample_Line_Item__c = SLIid;
            system.debug('com =====> '+com);
           	insert com;
            return com.Id;
        }catch(Exception e){
           return e.getMessage()+e.getLineNumber(); 
        }
    }
    
    @RemoteAction
    public static string saveComment2(Comment__c com, String hashCode, string accId){
        try{
            List<Contact> conRec = [SELECT Id,Name,Login_Hash_Code__c FROM Contact WHERE Login_Hash_Code__c =: hashCode];
            com.Comment_By__c = conRec[0].Id;
            com.Account__c = accId;
            system.debug('com =====> '+com);
           	insert com;
            return com.Id;
        }catch(Exception e){
           return e.getMessage()+e.getLineNumber(); 
        }
    }
    
    @RemoteAction
    public static string saveReply(Comment__c com, String hashCode, string comId){
        try{
            List<Contact> conRec = [SELECT Id,Name,Login_Hash_Code__c FROM Contact WHERE Login_Hash_Code__c =: hashCode];
            com.Comment_By__c = conRec[0].Id;
            com.Comments__c = comId;
            system.debug('com =====> '+com);
           	insert com;
            return com.Id;
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }
    
    @RemoteAction
    public static string saveSLIDetails(List<Sample_Line_Item__c> ListOfSLI){
        try{
            upsert ListOfSLI;
            return 'SUCCESS';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
        
    }
    
    @RemoteAction
    public static string SaveSampleDetails(Project__c sampleDetails, Integer year, Integer month, Integer day){
        try{
            if(year == 0 && month==0 && day==0){
                
            }else{
                sampleDetails.Opportunity_Close_Date__c = Date.newInstance(year, month, day); 
            }
            update sampleDetails;
           return 'SUCCESS'; 
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }
    
    @RemoteAction
    public static string saveAccDetails(Account accRec, Integer year, Integer month, Integer day){
        try{
            if(year == 0 && month==0 && day==0){
                
            }else{
                accRec.Next_Follow_up_Date__c = Date.newInstance(year, month, day); 
            }
            update accRec;
           return 'SUCCESS'; 
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }
    
    @RemoteAction
    public static string updateDetails(Account accRec,Dispatch_Address__c CustomerAddRec){
        try{
            if(accRec.Name != ''){
                update accRec;
            }
            if(CustomerAddRec.Name != ''){
                update CustomerAddRec;
            }
            return 'SUCCESS';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }
    
    @RemoteAction
    public static string updateOppProductDetails(List<OpportunityLineItem> listOfOLIToUpdate){
        try{
            system.debug('listOfOLIToUpdate ===> '+listOfOLIToUpdate);
            if(!listOfOLIToUpdate.isEmpty()){
               update listOfOLIToUpdate; 
            }
            return 'SUCCESS';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }
}