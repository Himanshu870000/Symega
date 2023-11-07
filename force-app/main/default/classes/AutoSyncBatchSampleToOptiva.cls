public class AutoSyncBatchSampleToOptiva Implements Database.batchable<sobject>,Database.AllowsCallouts{

    Set<Id> proIdSet;
 
    public AutoSyncBatchSampleToOptiva(Set<Id> proIdSet) {
        System.debug('proIdSet---'+proIdSet);
        this.proIdSet = proIdSet;
    }

    public Database.QueryLocator Start(Database.BatchableContext bc){    
        return Database.getQueryLocator('SELECT Id, Legal_Status__c, Application_product_shelf_life__c, Physical_Form__c, Minimum_order_quantity__c, Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c, Opportunity__r.Account.Customer_Code_OPTIVA__c, Opportunity__r.Customer_Billing_Address__r.Customer_Code_SAP__c, Opportunity__r.Customer_Billing_Address__c, Opportunity__r.Account_Billing_Address__c, Opportunity__r.Account.Name, Opportunity__r.AccountId, Opportunity__r.Account.Customer_Code_SAP__c, Recipe_Cost__c, Processing_condition__c, Preferred_thickness_Viscosity__c, pH__c, Oil_sprinkling_Dust_on__c, Milk_Solids__c, Final_SNF__c, Fat__c, Center_filling_Cream__c, Brix_degrees__c, Additive_Status__c, Acidity__c, of_pulp_if_with_fruit_pulp__c, Name, Start_Date__c, Product_Type__c, Account_Segment__c, Customer_Name__c, Contact_Number__c, Company_Name__c, Postal_Code__c, Country__c, State__c, City__c, Street__c, Customers_Contact__r.FirstName,' +
                                        'Customers_Contact__r.LastName, Application_Name__c,Type_of_PR__c,Approval_Status__c,Sample_Project__c,Sample_Project__r.Owner.Name, ' +
                                        'Product_ID__c,Product_Spec__c,MSDS__c,Country_of_Compliance__c,Project_Name__c,Legal_Status_as_per_US__c,Proposed_date_of_dispatch__c,Allergen__c,Nutritional__c, '+
                                        'Other__c,Target_Date__c,Customer_Launch_Date__c,Required_End_Date__c,Product_approval_format_by_customer__c,Organic_Certification__c,GMO_Status__c,Halal_Certification__c, '+
                                        'Kosher_Certification__c,Legal_Status_as_per_EU__c,Legal_Status_as_per_Indian_FSSAI__c,Customer_Cost_in_USE_CIU__c,Specific_inputs_by_customer__c,Allergin_Free_Decleration__c, '+
                                        'Sensory_Target_profile_expectation__c,Other_Application_Methods__c,Sample_Size_for_trails__c,Customer_Base_Details__c,Matching_Target_details__c,Expected_Shelf_Life__c,Dosage_Guidelines__c, '+
                                        'Supplier_Legal_Status__c,Solublity__c,Current_Shelf_life__c,Wet_Dry__c,Sensory_profiling_Report_Required__c,Sugar__c,Application_Samples_Receipe_Support__c,Expected_Volume_Unit__c,Expected_Annual_Value__c, '+
                                        'Confectionary_Type__c,Final_Fat__c,Owner.Name,Submitted_To_SAP_Optiva__c,RecordType.name,Quantity__c,Business_potential_value_INR__c,Annual_Volume_Full__c,Opportunity_Close_Date__c, '+
                                        'Lead__c,Lead__r.FirstName,Lead__r.LastName,Lead__r.Country,Lead__r.State,Lead__r.City,Lead__r.Street,Customer_Target_price__c,Product_Family__c,Sample_Name__c,Project_Type__c,Project_Category__c, '+
                                        'Project_Reference__c,CreatedBy.Name,CreatedDate,Opportunity_Type__c,Opportunity_Sub_Type__c,End_Use_category__c,End_Use_Applications__c,CurrencyIsoCode,(SELECT Id,Quantity_Unit__c,Quantity__c,Packaging_Unit__c,Packaging_Quantity__c, '+
                                        'Additional_Comments__c,Product__r.ProductCode,Product__r.Family, OPTIVA_Recipe__c, OPTIVA_Recipe__r.SSC_Code__c,First_Sample_due_date__c,Customer_Target_Price__c,Project_Quotient__c,Project_Quotient__r.Sample_Project_Application__r.RecordType.DeveloperName, '+
                                        'Project_Quotient__r.Sample_Project_Application__r.Product_Family__c,Project_Quotient__r.SSC_Code__c, Customer_Preferred_Name__c FROM Sample_Line_Items__r WHERE Submitted__c=false),Flavour_Legal_Status__c,First_Sample_due_date__c,Flavour_CIU__c,Business_potential_value_INR_New__c,Solubility_Preference__c '+
                                        'FROM Project__c WHERE Submit_Sample_To_Optiva__c = true AND Id IN:proIdSet');
    }
    public void execute(Database.BatchableContext BC, List<Project__c> projects){
        system.debug('projects:: '+projects);
        try{
            
            if(!projects.isEmpty()){

                Symega_Configuration__c orgConfig = Symega_Configuration__c.getValues('Symega Configuration');
                List<Sample_Line_Item__c> slisToUpdate = new List<Sample_Line_Item__c>();
                for(Project__c project : projects){

                    String customerCodeSAP = '';
                    String customerCodeOPTIVA = '';

                    if(project.Opportunity__r.Account_Billing_Address__c){
                        customerCodeSAP = project.Opportunity__r.Account.Customer_Code_SAP__c;
                        customerCodeOPTIVA = project.Opportunity__r.Account.Customer_Code_OPTIVA__c;
                    }
                    else if(project.Opportunity__r.Customer_Billing_Address__c != null){
                        customerCodeSAP = project.Opportunity__r.Customer_Billing_Address__r.Customer_Code_SAP__c;
                        customerCodeOPTIVA = project.Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c;
                    }

                    System.debug('RecordTypeName--'+project.RecordType.name);
                    if(project.RecordType.name=='Sample'){  

                        if(String.isBlank(customerCodeOPTIVA)){
                            project.Error_Occured_On_Submitting_To_Optiva__c = true;
                            project.Error_Message_On_Submitting_To_Optiva__c = 'Customer code not found';
                            return;
                        }
                        Map<String,String> responseMap = new Map<String,String>();
                        Optiva_NPDSampleCreationWrapper OpWrapper = new Optiva_NPDSampleCreationWrapper();

                        

                        OpWrapper.country = checkIfBlank(project.Country__c);
                        OpWrapper.state = checkIfBlank(project.State__c);
                        OpWrapper.city = checkIfBlank(project.City__c);
                        OpWrapper.street = checkIfBlank(project.Street__c);
                        OpWrapper.contact_number = checkIfBlank(project.Contact_Number__c);
                        OpWrapper.company_name = checkIfBlank(project.Company_Name__c);
                        OpWrapper.pincode = checkIfBlank(project.Postal_Code__c);
                        
                        if(project.Opportunity__r.AccountId == null){
                            OpWrapper.first_name = checkIfBlank(project.Lead__r.FirstName);
                            OpWrapper.last_name = checkIfBlank(project.Lead__r.LastName);
                        }else{
                            OpWrapper.cust_code = checkIfBlank(customerCodeOPTIVA);
                            OpWrapper.first_name = project.Customers_Contact__c == null ? checkIfBlank(project.Opportunity__r.Account.Name) : project.Customers_Contact__r.FirstName;
                            OpWrapper.last_name = project.Customers_Contact__c == null ? checkIfBlank(project.Opportunity__r.Account.Name) : project.Customers_Contact__r.LastName;
                        }

                        OpWrapper.project_sf_code = checkIfBlank(project.Id);    
                        OpWrapper.cust_code = checkIfBlank(customerCodeOPTIVA);

                        OpWrapper.project_title = checkIfBlank(project.Name) + ':' + checkIfBlank(project.Sample_Name__c);
                        OpWrapper.project_type = 'External';//checkIfBlank(project.Project_Type__c);
                        OpWrapper.project_category = checkIfBlank(project.Product_Family__c);//checkIfBlank(project.Project_Category__c);
                        OpWrapper.project_ref = checkIfBlank(project.Project_Reference__c);
                        if(!String.isBlank(project.Sample_Project__c)){
                            OpWrapper.created_by = checkIfBlank(project.Sample_Project__r.Owner.Name);
                        }else{
                            OpWrapper.created_by = checkIfBlank(project.CreatedBy.Name);
                        }

                       // OpWrapper.created_by = checkIfBlank(project.CreatedBy.Name);
                        OpWrapper.creation_date = project.CreatedDate == null ? 'NA' : project.CreatedDate.format('dd/MM/yyyy');
                        OpWrapper.opp_type_int = 'Sales';//checkIfBlank(project.Opportunity_Type__c);
                        OpWrapper.opp_sub_type_sales = 'Sampling';
                        OpWrapper.end_use_cat = checkIfBlank(project.End_Use_category__c);
                        OpWrapper.end_use_appli = checkIfBlank(project.End_Use_Applications__c);
                        OpWrapper.curr_type = checkIfBlank(project.CurrencyIsoCode);

                        OpWrapper.opp_closedate = project.Opportunity_Close_Date__c!=null?formatDate(project.Opportunity_Close_Date__c):'NA'; 
                        OpWrapper.annual_vol = project.Annual_Volume_Full__c!=null?String.valueOf(project.Annual_Volume_Full__c):'NA';
                        OpWrapper.business_potent_val = project.Business_potential_value_INR_New__c!=null?String.valueOf(project.Business_potential_value_INR_New__c):'NA';
                        OpWrapper.curr_type = checkIfBlank(project.CurrencyIsoCode);
                        OpWrapper.curr_year_vol = project.Quantity__c!=null?String.valueOf(project.Quantity__c):'NA';

                        Map<Id,Sample_Line_Item__c> optivaRecipieSLineItems = new Map<Id,Sample_Line_Item__c>();
                        Map<Id,String> withoutOptivaRecipieSLineItems = new Map<Id,String>();

                        System.debug('project.Sample_Line_Items__r-----'+project.Sample_Line_Items__r);
                        if(!project.Sample_Line_Items__r.isEmpty()){
                            for(Sample_Line_Item__c sli : project.Sample_Line_Items__r){
                                System.debug('Family----'+sli.Product__r.Family);
                                if(!String.isEmpty(sli.OPTIVA_Recipe__c) || (!String.isEmpty(sli.Project_Quotient__c) && !String.isEmpty(sli.Project_Quotient__r.Sample_Project_Application__c) && sli.Project_Quotient__r.Sample_Project_Application__r.RecordType.DeveloperName == 'Project' && (sli.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c==Constants.FLAVOUR_API_NAME || sli.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c==Constants.COLOR_API_NAME)) || (!String.isEmpty(sli.Product__c) && !String.isEmpty(sli.Product__r.Family) && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family))){
                                    optivaRecipieSLineItems.put(sli.Id,sli);
                                }else{
                                    withoutOptivaRecipieSLineItems.put(sli.Id,sli.Id);
                                }
                            }

                            System.debug('optivaRecipieSLineItems---'+optivaRecipieSLineItems);
                            System.debug('withoutOptivaRecipieSLineItems---'+withoutOptivaRecipieSLineItems);
            
                            boolean isSubmittedToOptiva = false;
            
                            if(!optivaRecipieSLineItems.isEmpty()){
                                for(Integer i=0;i<optivaRecipieSLineItems.values().size();i++){
                                    Sample_Line_Item__c sli = project.Sample_Line_Items__r[i];
                                    if(i==0){
                                        OpWrapper.uom1 = checkIfBlank(sli.Quantity_Unit__c);
                                        OpWrapper.tot_qty1 = checkIfBlank(String.valueOf(sli.Quantity__c));
                                        OpWrapper.no_units1 = checkIfBlank(sli.Packaging_Unit__c);
                                        OpWrapper.pack_size1 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                                        //OpWrapper.selling_desc1 = checkIfBlank(sli.Additional_Comments__c);
                                        OpWrapper.selling_desc1 = checkIfBlank(sli.Customer_Preferred_Name__c);
                                        
                                        if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                                            OpWrapper.prod_code1_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                                        }else if(sli.Product__r!=null && sli.Product__r.Family!=null && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                                            OpWrapper.prod_code1_dev = checkIfBlank(sli.Product__r.ProductCode);
                                        }else{
                                            OpWrapper.prod_code1_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                                        }
                                        
                                        OpWrapper.sample_duedate1 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                                        OpWrapper.cust_target_price1 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
                                    }else if(i==1){
                                        OpWrapper.uom2 = checkIfBlank(sli.Quantity_Unit__c);
                                        OpWrapper.tot_qty2 = checkIfBlank(String.valueOf(sli.Quantity__c));
                                        OpWrapper.no_units2 = checkIfBlank(sli.Packaging_Unit__c);
                                        OpWrapper.pack_size2 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                                        OpWrapper.selling_desc2 = checkIfBlank(sli.Customer_Preferred_Name__c);
                                        
                                        if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                                            OpWrapper.prod_code2_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                                        }else if(sli.Product__r!=null && sli.Product__r.Family!=null && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                                            OpWrapper.prod_code2_dev = checkIfBlank(sli.Product__r.ProductCode);
                                        }else{
                                            OpWrapper.prod_code2_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                                        }
                                        OpWrapper.sample_duedate2 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                                        OpWrapper.cust_target_price2 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
                                    }else if(i==2){
                                         OpWrapper.uom3 = checkIfBlank(sli.Quantity_Unit__c);
                                        OpWrapper.tot_qty3 = checkIfBlank(String.valueOf(sli.Quantity__c));
                                        OpWrapper.no_units3 = checkIfBlank(sli.Packaging_Unit__c);
                                        OpWrapper.pack_size3 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                                        OpWrapper.selling_desc3 = checkIfBlank(sli.Customer_Preferred_Name__c);
                                        
                                        if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                                            OpWrapper.prod_code3_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                                        }else if(sli.Product__r!=null && sli.Product__r.Family!=null  && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                                            OpWrapper.prod_code3_dev = checkIfBlank(sli.Product__r.ProductCode);
                                        }else{
                                            OpWrapper.prod_code3_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                                        }
                                        OpWrapper.sample_duedate3 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                                        OpWrapper.cust_target_price3 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
                                    }
                                    else if(i==3){
                                        OpWrapper.uom4 = checkIfBlank(sli.Quantity_Unit__c);
                                        OpWrapper.tot_qty4 = checkIfBlank(String.valueOf(sli.Quantity__c));
                                        OpWrapper.no_units4 = checkIfBlank(sli.Packaging_Unit__c);
                                        OpWrapper.pack_size4 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                                        OpWrapper.selling_desc4 = checkIfBlank(sli.Customer_Preferred_Name__c);
                                        
                                        if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                                            OpWrapper.prod_code4_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                                        }else if(sli.Product__r!=null && sli.Product__r.Family!=null  && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                                            OpWrapper.prod_code4_dev = checkIfBlank(sli.Product__r.ProductCode);
                                        }else{
                                            OpWrapper.prod_code4_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                                        }
                                        OpWrapper.sample_duedate4 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                                        OpWrapper.cust_target_price4 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
                                    }
                                    else if(i==4){
                                         OpWrapper.uom5 = checkIfBlank(sli.Quantity_Unit__c);
                                        OpWrapper.tot_qty5 = checkIfBlank(String.valueOf(sli.Quantity__c));
                                        OpWrapper.no_units5 = checkIfBlank(sli.Packaging_Unit__c);
                                        OpWrapper.pack_size5 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                                        OpWrapper.selling_desc5 = checkIfBlank(sli.Customer_Preferred_Name__c);
                                        
                                        if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                                            OpWrapper.prod_code5_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                                        }else if(sli.Product__r!=null && sli.Product__r.Family!=null  && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                                            OpWrapper.prod_code5_dev = checkIfBlank(sli.Product__r.ProductCode);
                                        }else{
                                            OpWrapper.prod_code5_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                                        }
                                        OpWrapper.sample_duedate5 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                                        OpWrapper.cust_target_price5 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
                                    }
                                    else if(i==5){
                                         OpWrapper.uom6 = checkIfBlank(sli.Quantity_Unit__c);
                                        OpWrapper.tot_qty6 = checkIfBlank(String.valueOf(sli.Quantity__c));
                                        OpWrapper.no_units6 = checkIfBlank(sli.Packaging_Unit__c);
                                        OpWrapper.pack_size6 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'NA';
                                        OpWrapper.selling_desc6 = checkIfBlank(sli.Customer_Preferred_Name__c);
                                        
                                        if(!String.isEmpty(sli.OPTIVA_Recipe__r.SSC_Code__c)){
                                            OpWrapper.prod_code6_dev = checkIfBlank(sli.OPTIVA_Recipe__r.SSC_Code__c);
                                        }else if(sli.Product__r!=null && sli.Product__r.Family!=null  && orgConfig.Prod_Families_Send_To_Optiva__c.contains(sli.Product__r.Family)){
                                            OpWrapper.prod_code6_dev = checkIfBlank(sli.Product__r.ProductCode);
                                        }else{
                                            OpWrapper.prod_code6_dev = checkIfBlank(sli.Project_Quotient__r.SSC_Code__c);
                                        }
                                        OpWrapper.sample_duedate6 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'NA';
                                        OpWrapper.cust_target_price6 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'NA';
                                    }
                                }
            
            
                                System.debug('Body------'+OpWrapper.toString());
                                responseMap = Optiva_NPDCreationCallout.getInstance().createProject(JSON.serialize(OpWrapper));
                                System.debug('ResponseMap----'+responseMap);
                                if(responseMap!=null && responseMap.get('status')=='Success'){
                                    isSubmittedToOptiva = true;
                                }else{
                                    Utility.handlerErrorException(project.Id,responseMap.toString());
                                }
                            }
            
                            sampleAssignNotification_ProdFamily.notifyWithoutRecipeSLI(withoutOptivaRecipieSLineItems.values());
            
                            if(isSubmittedToOptiva || !withoutOptivaRecipieSLineItems.isEmpty()){
                                project.Submit_Sample_To_Optiva__c = false;
                                project.Submitted_To_SAP_Optiva__c = true;
                                project.Sample_Submitted_Date__c=System.today();
                                project.Status__c = Constants.SAMPLING_SUBMITTION_STATUS;
                                project.Error_Occured_On_Submitting_To_Optiva__c = false;
                                project.Error_Message_On_Submitting_To_Optiva__c = '';

                                if(!optivaRecipieSLineItems.isEmpty()){
                                    for(Sample_Line_Item__c sli: optivaRecipieSLineItems.values()){
                                        sli.Submitted__c = true;
                                        sli.Sample_Request_Status__c = Constants.SAMPLING_SUBMITTION_STATUS; //v.1
                                        slisToUpdate.add(sli);
                                    }
                                }
                            }
                        }
                    }
                    else if(project.RecordType.name=='Project'){
                        if((project.Product_Family__c.contains(Constants.FLAVOUR_API_NAME) || project.Product_Family__c.contains(Constants.COLOR_API_NAME)) && !String.isBlank(customerCodeOPTIVA)){
                            System.debug('CALLEDOPTIVA----');
                            Map<String,String> responseMap = new Map<String,String>();

                            if(project.Type_of_PR__c=='Tech Doc'){
                                responseMap = Optiva_Tech_Doc_Project_Creation_Callout.submitProject(project);
                            }else{
                                Optiva_NPDCreationWrapper OpWrapper = OptivaCreateWrapper.createProjectWrapper(project);
                                System.debug('Body------'+OpWrapper.toString());
                                
                                responseMap = Optiva_NPDCreationCallout.getInstance().createProject(JSON.serialize(OpWrapper));
                            }

                            if(responseMap!=null && responseMap.get('status')=='Success'){
                                project.Submit_Sample_To_Optiva__c = false;
                                project.Submitted_To_SAP_Optiva__c = true;
                                project.Error_Occured_On_Submitting_To_Optiva__c = false;
                                project.Error_Message_On_Submitting_To_Optiva__c = '';
                                project.Sample_Submitted_Date__c = System.today();
                                project.Status__c = Constants.PROJECT_SUBMITTION_STATUS;
                            }else{
                                Utility.handlerErrorException(project.Id,responseMap.toString());
                            }
                        }
                        else if(!String.isBlank(customerCodeSAP)){ //TODO: this should be called if trigger passed account sap code changes, or above should be invoked if optive code changes.
                            Map<String,String> responseMap = new Map<String,String>();

                            if(!(project.Type_Of_PR__c == 'New Product' && project.Approval_Status__c == 'Under Approval')){
                                System.debug('CAzLEDSAP-----');
                                responseMap = SAP_Project_Creation_Callout.createProject(project.Id);
                            }
                            if(responseMap!=null && (responseMap.get('status')=='Success' && responseMap.get('msgStatus').containsIgnoreCase('S')) ){
                                project.Submit_Sample_To_Optiva__c = false;
                                project.Submitted_To_SAP_Optiva__c = true;
                                project.Error_Occured_On_Submitting_To_Optiva__c = false;
                                project.Error_Message_On_Submitting_To_Optiva__c = '';
                                project.Sample_Submitted_Date__c = System.today();
                                project.Status__c = Constants.PROJECT_SUBMITTION_STATUS;
                                //project.Submitted_for_BH_Approval__c = true;
                                //project.Submitted_for_Customer_Creation__c = false;
                            }else{
                                Utility.handlerErrorException(project.Id,responseMap.toString());
                            }
                            
                        }
                        else{
                            project.Submit_Sample_To_Optiva__c = true;
                            project.Error_Occured_On_Submitting_To_Optiva__c = true;
                            project.Error_Message_On_Submitting_To_Optiva__c = 'Customer code not found';
                        }
                    }else{
                        if(String.isBlank(customerCodeOPTIVA)){
                            project.Submit_Sample_To_Optiva__c = true;
                            project.Error_Occured_On_Submitting_To_Optiva__c = true;
                            project.Error_Message_On_Submitting_To_Optiva__c = 'Customer code not found';
                            return;
                        }

                        Optiva_NPD_Application_Wrapper OpWrapper = OptivaCreateWrapper.createApplicationWrapper(project);
                        System.debug('Body------'+OpWrapper.toString());
                        Map<String,String> responseMap = new Map<String,String>();
                        responseMap = Optiva_NPDCreationCallout.getInstance().createProject(JSON.serialize(OpWrapper));
                        if(responseMap!=null && responseMap.get('status')=='Success'){
                            project.Submit_Sample_To_Optiva__c = false;
                            project.Submitted_To_SAP_Optiva__c = true;
                            project.Error_Occured_On_Submitting_To_Optiva__c = false;
                            project.Error_Message_On_Submitting_To_Optiva__c = '';
                            project.Sample_Submitted_Date__c=System.today();
                            project.Status__c = Constants.APPLICATION_SUBMITTION_STATUS;
                        }else{
                            Utility.handlerErrorException(project.Id,responseMap.toString());
                        }
                    }
                }
                update projects;
                if(!slisToUpdate.isEmpty()){
                    update slisToUpdate;
                }
            }
        }
        catch(Exception e){
            system.debug('Error>> '+e.getMessage() + 'at Line Number>> ' + e.getLineNumber());
        }
    }
    
    public void finish(Database.BatchableContext BC){
        /* List<Project__c> projects = Database.query('SELECT Id,Sample_Sub_Retry_Count__c,Sample_Sub_Retry_Count__c FROM Project__c WHERE Sample_Sub_Retry_Count__c<5 AND Submit_Sample_To_Optiva__c = true AND Account__c IN: accIdSet '+queryAddOn);
        System.debug('FINISHEDSIZE----'+projects.size());

        for(Project__c proj : projects){
            System.debug('FINISHID----'+proj.Id);
            proj.Sample_Sub_Retry_Count__c = proj.Sample_Sub_Retry_Count__c!=null? proj.Sample_Sub_Retry_Count__c+1:1;
        }

        Database.update(projects,false);

        if(!projects.isEmpty()){
            //Utility.scheduleAutoSyncSampleToOptiva();
        } */
        system.debug('Auto Sync Batch Exceuted Successfully!!');
    }

    public static String formatDate(Date d){
        return d.day()+'/'+d.month()+'/'+d.year();
    }

    public static String checkIfBlank(String s){
        return String.isBlank(s)?'':s;
    }


    public static void updateSampleSLI(Map<Id,Sample_Line_Item__c> sliMap){
        for(Sample_Line_Item__c sli: sliMap.values()){
            sli.Submitted__c = true;
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