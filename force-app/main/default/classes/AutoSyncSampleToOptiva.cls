public without sharing class AutoSyncSampleToOptiva {
    //abondend class
    public static Map<String,String> syncSample(){
        try{
            Map<String,String> responseMap = new Map<String,String>();

            List<Project__c> projects = [Select Id,Submitted_To_SAP_Optiva__c,Account__c,Opportunity__r.Account_Billing_Address__c,Opportunity__r.Customer_Billing_Address__c, Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c,Opportunity__r.Account.Customer_Code_OPTIVA__c,Lead__c,Lead__r.FirstName,Lead__r.LastName,Lead__r.Country,Lead__r.State,Lead__r.City,Lead__r.Street,Product_Family__c,Sample_Name__c,Project_Type__c,Project_Category__c,Project_Reference__c,CreatedBy.Name,
            CreatedDate,Opportunity_Type__c,Opportunity_Sub_Type__c,End_Use_category__c,
            End_Use_Applications__c,Currency_Type__c,(Select Id,Quantity_Unit__c,Quantity__c,Packaging_Unit__c,
            Packaging_Quantity__c,Additional_Comments__c,Product__r.ProductCode, OPTIVA_Recipe__c, OPTIVA_Recipe__r.SSC_Code__c,First_Sample_due_date__c,Customer_Target_Price__c, Customer_Preferred_Name__c From Sample_Line_Items__r) From Project__c Where Submit_Sample_To_Optiva__c = true AND Account__c!=null AND ( Opportunity__r.Account.Customer_Code_OPTIVA__c!=null OR Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c != null)];

            
            if(!projects.isEmpty()){
                responseMap.put('status','Failure');
                responseMap.put('code','400');
                responseMap.put('message','Record Not Found');
                return responseMap;
            }
            
            for(Project__c project : projects){
                Optiva_NPDSampleCreationWrapper OpWrapper = new Optiva_NPDSampleCreationWrapper();

                OpWrapper.city = '';
                OpWrapper.state = '';
                OpWrapper.street = '';
                OpWrapper.country = '';
                OpWrapper.last_name = '';
                OpWrapper.first_name = '';
                OpWrapper.project_sf_code = project.Id;    
                OpWrapper.cust_code = project.Opportunity__r.Account_Billing_Address__c ? project.Opportunity__r.Account.Customer_Code_OPTIVA__c : project.Opportunity__r.Customer_Billing_Address__r.OPTIVA_Customer_Code__c;

                OpWrapper.project_title = project.Sample_Name__c;
                OpWrapper.project_type = checkIfBlank(project.Project_Type__c);
                OpWrapper.project_category = checkIfBlank(project.Project_Category__c);
                OpWrapper.project_ref = checkIfBlank(project.Project_Reference__c);
                OpWrapper.created_by = checkIfBlank(project.CreatedBy.Name);
                OpWrapper.creation_date = project.CreatedDate.format('dd/MM/yyyy');
                OpWrapper.opp_type_int = checkIfBlank(project.Opportunity_Type__c);
                OpWrapper.opp_sub_type_sales = checkIfBlank(project.Opportunity_Sub_Type__c);
                //OpWrapper.cust_code = checkIfBlank(project.Customer_Code__c);
                OpWrapper.end_use_cat = checkIfBlank(project.End_Use_category__c);
                OpWrapper.end_use_appli = checkIfBlank(project.End_Use_Applications__c);
                OpWrapper.curr_type = checkIfBlank(project.Currency_Type__c);

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

                    sampleAssignNotification_ProdFamily.notifyWithoutRecipeSLI(withoutOptivaRecipieSLineItems.values());

                    if(!optivaRecipieSLineItems.isEmpty()){
                        for(Integer i=0;i<optivaRecipieSLineItems.values().size();i++){
                            Sample_Line_Item__c sli = project.Sample_Line_Items__r[i];
                            if(i==0){
                                OpWrapper.uom1 = sli.Quantity_Unit__c;
                                OpWrapper.tot_qty1 = String.valueOf(sli.Quantity__c);
                                OpWrapper.no_units1 = checkIfBlank(sli.Packaging_Unit__c);
                                OpWrapper.pack_size1 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'';
                                OpWrapper.selling_desc1 = checkIfBlank(sli.Customer_Preferred_Name__c);
                                OpWrapper.prod_code1_dev = sli.OPTIVA_Recipe__r.SSC_Code__c;
                                OpWrapper.sample_duedate1 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'';
                                OpWrapper.cust_target_price1 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'';
                            }else if(i==1){
                                OpWrapper.uom2 = sli.Quantity_Unit__c;
                                OpWrapper.tot_qty2 = String.valueOf(sli.Quantity__c);
                                OpWrapper.no_units2 = checkIfBlank(sli.Packaging_Unit__c);
                                OpWrapper.pack_size2 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'';
                                OpWrapper.selling_desc2 = checkIfBlank(sli.Customer_Preferred_Name__c);
                                OpWrapper.prod_code2_dev = sli.OPTIVA_Recipe__r.SSC_Code__c;
                                OpWrapper.sample_duedate2 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'';
                                OpWrapper.cust_target_price2 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'';
                            }else if(i==2){
                                OpWrapper.uom3 = sli.Quantity_Unit__c;
                                OpWrapper.tot_qty3 = String.valueOf(sli.Quantity__c);
                                OpWrapper.no_units3 = checkIfBlank(sli.Packaging_Unit__c);
                                OpWrapper.pack_size3 = sli.Packaging_Quantity__c!=null?String.valueOf(sli.Packaging_Quantity__c):'';
                                OpWrapper.selling_desc3 = checkIfBlank(sli.Customer_Preferred_Name__c);
                                OpWrapper.prod_code3_dev = sli.OPTIVA_Recipe__r.SSC_Code__c;
                                OpWrapper.sample_duedate3 = sli.First_Sample_due_date__c!=null?formatDate(sli.First_Sample_due_date__c):'';
                                OpWrapper.cust_target_price3 = sli.Customer_Target_Price__c!=null?String.valueOf(sli.Customer_Target_Price__c):'';
                            }
                        }
                    }
                }

                System.debug('Body------'+OpWrapper.toString());
                responseMap = Optiva_NPDCreationCallout.getInstance().createProject(JSON.serialize(OpWrapper));
                if(responseMap!=null && responseMap.get('status')=='Success'){
                    project.Submit_Sample_To_Optiva__c = true;
                    project.Submitted_To_SAP_Optiva__c = true;
                    project.Status__c = 'Submitted for Sampling';
                }
            }

            update projects;
            return responseMap;
        }catch(Exception e){
            HandleBusinessException.captureError('AutoSyncSampleToOptiva','syncSample',e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String formatDate(Date d){
        return d.day()+'/'+d.month()+'/'+d.year();
    }

    public static String checkIfBlank(String s){
        return String.isBlank(s)?'':s;
    }
}