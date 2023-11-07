public without sharing class OptivaCreateWrapper {
    
    public static Optiva_NPDSampleCreationWrapper createSampleWrapper(Project__c project){
        Optiva_NPDSampleCreationWrapper OpWrapper = new Optiva_NPDSampleCreationWrapper();
        OpWrapper.city = 'NA';
        OpWrapper.state = 'NA';
        OpWrapper.street = 'NA';
        OpWrapper.country = 'NA';
        OpWrapper.last_name = 'NA';
        OpWrapper.first_name = 'NA';
        OpWrapper.project_sf_code = checkIfBlank(project.Id);    
        OpWrapper.cust_code = project.Opportunity__r.Account_Billing_Address__c ? checkIfBlank(project.Opportunity__r.Account.Customer_Code_OPTIVA__c) : project.Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c;

        OpWrapper.project_title = checkIfBlank(project.Name) + ':' + checkIfBlank(project.Sample_Name__c);
        OpWrapper.project_type = 'External';//checkIfBlank(project.Project_Type__c);
        OpWrapper.project_category = checkIfBlank(project.Product_Family__c);//checkIfBlank(project.Project_Category__c);
        OpWrapper.project_ref = 'Dummy';
        OpWrapper.created_by = checkIfBlank(project.CreatedBy.Name);
        OpWrapper.creation_date = project.CreatedDate == null ? 'NA' : project.CreatedDate.format('dd/MM/yyyy');
        OpWrapper.opp_type_int = 'Sales';//checkIfBlank(project.Opportunity_Type__c);
        OpWrapper.opp_sub_type_sales = 'Sampling';
        //OpWrapper.cust_code = checkIfBlank(project.Customer_Code__c);
        OpWrapper.end_use_cat = checkIfBlank(project.End_Use_category__c);
        OpWrapper.end_use_appli = checkIfBlank(project.End_Use_Applications__c);
        OpWrapper.curr_type = checkIfBlank(project.CurrencyIsoCode);

        OpWrapper.opp_closedate = project.Opportunity_Close_Date__c!=null?formatDate(project.Opportunity_Close_Date__c):'NA'; 
        OpWrapper.annual_vol = project.Expected_Annual_Value__c!=null?String.valueOf(project.Expected_Annual_Value__c):'NA';
        OpWrapper.business_potent_val = project.Business_potential_value_INR__c!=null?String.valueOf(project.Business_potential_value_INR__c):'NA';
        OpWrapper.curr_type = checkIfBlank(project.CurrencyIsoCode);
        OpWrapper.curr_year_vol = project.Quantity__c!=null?String.valueOf(project.Quantity__c):'NA';

        Map<Id,Sample_Line_Item__c> optivaRecipieSLineItems = new Map<Id,Sample_Line_Item__c>();
        Map<Id,String> withoutOptivaRecipieSLineItems = new Map<Id,String>();

        if(!project.Sample_Line_Items__r.isEmpty()){
            for(Sample_Line_Item__c sli : project.Sample_Line_Items__r){
                if(!String.isEmpty(sli.OPTIVA_Recipe__c)){
                    optivaRecipieSLineItems.put(sli.Id,sli);
                }else{
                    withoutOptivaRecipieSLineItems.put(sli.Id,sli.Id);
                }
            }

            boolean isSubmittedToOptiva = false;
            
            sampleAssignNotification_ProdFamily.notifyWithoutRecipeSLI(withoutOptivaRecipieSLineItems.values());

            if(!optivaRecipieSLineItems.isEmpty()){
                for(Integer i=0;i<optivaRecipieSLineItems.values().size();i++){
                    Sample_Line_Item__c sli = project.Sample_Line_Items__r[i];
                    if(i==0){
                        OpWrapper.uom1 = checkIfBlank(sli.Quantity_Unit__c);
                        OpWrapper.tot_qty1 = checkIfBlank(String.valueOf(sli.Quantity__c));
                        OpWrapper.no_units1 = checkIfBlank(sli.Packaging_Unit__c);
                        OpWrapper.pack_size1 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                        OpWrapper.selling_desc1 = checkIfBlank(sli.Customer_Preferred_Name__c);
                        OpWrapper.sample_duedate1 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                        OpWrapper.cust_target_price1 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
                        OpWrapper.prod_code1_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);  
                    }else if(i==1){
                        OpWrapper.uom2 = checkIfBlank(sli.Quantity_Unit__c);
                        OpWrapper.tot_qty2 = checkIfBlank(String.valueOf(sli.Quantity__c));
                        OpWrapper.no_units2 = checkIfBlank(sli.Packaging_Unit__c);
                        OpWrapper.pack_size2 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                        OpWrapper.selling_desc2 = checkIfBlank(sli.Customer_Preferred_Name__c);
                        OpWrapper.sample_duedate2 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                        OpWrapper.cust_target_price2 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
                        OpWrapper.prod_code2_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                       
                    }else if(i==2){
                       OpWrapper.uom3 = checkIfBlank(sli.Quantity_Unit__c);
                        OpWrapper.tot_qty3 = checkIfBlank(String.valueOf(sli.Quantity__c));
                        OpWrapper.no_units3 = checkIfBlank(sli.Packaging_Unit__c);
                        OpWrapper.pack_size3 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                        OpWrapper.selling_desc3 = checkIfBlank(sli.Customer_Preferred_Name__c);
                        OpWrapper.sample_duedate3 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                        OpWrapper.cust_target_price3 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
                        OpWrapper.prod_code3_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                    }
                }
            }
        }

        return OpWrapper;
    }

    public static Optiva_NPD_Application_Wrapper createApplicationWrapper(Project__c project){
        Optiva_NPD_Application_Wrapper OpAppWrapper = new Optiva_NPD_Application_Wrapper();
        OpAppWrapper.project_sf_code = checkIfBlank(project.Id);
        OpAppWrapper.project_title = checkIfBlank(project.Name) + ':' + checkIfBlank(project.Application_Name__c);
        OpAppWrapper.created_by = checkIfBlank(project.Owner.Name);
        OpAppWrapper.project_type = 'External';//checkIfBlank(project.Project_Type__c);
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
        OpAppWrapper.first_smpe_due_date = project.First_Sample_due_date__c!=null?formatDate(project.First_Sample_due_date__c):'NA';
        OpAppWrapper.flavor_ciu = project.Flavour_CIU__c == null ? 0 : project.Flavour_CIU__c;
        OpAppWrapper.flavor_legal_stat = checkIfBlank(project.Flavour_Legal_Status__c);
        OpAppWrapper.solubility = checkIfBlank(project.Solubility_Preference__c);
        OpAppWrapper.sugar = project.Sugar__c!=null?String.valueOf(project.Sugar__c):'NA';
        OpAppWrapper.creation_date = project.CreatedDate == null ? 'NA' : project.CreatedDate.format('dd/MM/yyyy');
        OpAppWrapper.opp_closedate = project.Opportunity_Close_Date__c!=null?formatDate(project.Opportunity_Close_Date__c):'NA';
        OpAppWrapper.target_date = project.Target_Date__c!=null?formatDate(project.Target_Date__c):'NA';


        //NEW ADDITIONS
        OpAppWrapper.per_pulp = project.of_pulp_if_with_fruit_pulp__c != null ? String.valueOf(project.of_pulp_if_with_fruit_pulp__c) : '0';
        OpAppWrapper.account = checkIfBlank(project.Account__c);
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

        return OpAppWrapper;
    }

    public static Optiva_NPDCreationWrapper createProjectWrapper(Project__c project){
        Optiva_NPDCreationWrapper OpWrapper = new Optiva_NPDCreationWrapper();

        if(project.Product_Family__c.contains(Constants.FLAVOUR_API_NAME) || project.Product_Family__c.contains(Constants.COLOR_API_NAME)){
            OpWrapper.project_sf_code = checkIfBlank(project.Id);
            OpWrapper.project_title = checkIfBlank(project.Name) + ':' + checkIfBlank(project.Project_Name__c);
            OpWrapper.created_by = checkIfBlank(project.Owner.Name);
            OpWrapper.project_type = checkIfBlank(project.Project_Type__c); // 'External';
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
            OpWrapper.business_potent_val = project.Business_potential_value_INR_New__c == null ? 0 : project.Business_potential_value_INR_New__c;
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

        }
        return OpWrapper;
    }

    public static String formatDate(Date d){
        return d.day()+'/'+d.month()+'/'+d.year();
    }

    public static String checkIfBlank(String s){
        return String.isBlank(s) || s == null ? 'NA' : s;
    }

}