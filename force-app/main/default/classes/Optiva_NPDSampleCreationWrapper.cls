public without sharing class Optiva_NPDSampleCreationWrapper {
    public String project_sf_code='';	//1212131 Id
	public String first_name;
	public String last_name;
	public String country='';
	public String state='';
	public String city='';
	public String street='';

	public String project_title;	//Testing Sampling Sample_Name__c
	public String project_type;	//EXTERNAL Project_Type__c
	public String project_category;	//FLAVOUR Project_Category__c
	public String project_ref;	//C123 Project_Reference__c
	
	public String created_by;	//AJEET CreatedBy.Name
	public String creation_date;	//27/07/2022 CreatedDate
	public String opp_type_int;	//SALES Opportunity_Type__c
	public String opp_sub_type_sales;	//SAMPLING Opportunity_Sub_Type__c
	public String cust_code='';	//C00512 Customer_Code__c
	public String end_use_cat;	//CONFECTIONERY End_Use_category__c
	public String end_use_appli;	//SAUCES End_Use_Applications__c
	

	public String opp_closedate = '';
	public String annual_vol = '';
	public String business_potent_val = '';
	public String curr_type;	//EURO Currency_Type__c
	public String curr_year_vol;


    //lineitem
	public String uom1 = '';	//G Qunatity_Unit__c
	public String uom2 = '';	//
	public String uom3 ='';	//
	public String uom4 ='';	//
	public String uom5 ='';	//
	public String uom6 ='';	//

    public String tot_qty1 = '';	//12 Quantity__c
	public String tot_qty2 = '';	//
	public String tot_qty3 = '';	//
	public String tot_qty4 = '';	//
	public String tot_qty5 = '';	//
	public String tot_qty6 = '';	//

    public String no_units1 = '';	//1 Packaging_Unit__c
	public String no_units2 = '';	//
	public String no_units3 = '';	//
	public String no_units4 = '';	//
	public String no_units5 = '';	//
	public String no_units6 = '';	//
   

    public String pack_size1 = '';	//1 Packaging_Quantity__c
    public String pack_size2 = '';	//
    public String pack_size3 = '';	//
    public String pack_size4 = '';	//
    public String pack_size5 = '';	//
    public String pack_size6 = '';	//

    
    public String selling_desc1 = '';	//ABC Additional_Comments__c
    public String selling_desc2 = '';	//
    public String selling_desc3 = '';	//
    public String selling_desc4 = '';	//
    public String selling_desc5 = '';	//
    public String selling_desc6 = '';	//

    public String prod_code1_dev = '';	//SSC0001015 Product__r.ProductCode
	public String prod_code2_dev = '';	//
	public String prod_code3_dev = '';	//
	public String prod_code4_dev = '';	//
	public String prod_code5_dev = '';	//
	public String prod_code6_dev = '';	//

    public String sample_duedate1 = '';	//23/05/2022 First_Sample_due_date__c
	public String sample_duedate2 = '';	//
	public String sample_duedate3 = '';	//
	public String sample_duedate4 = '';	//
	public String sample_duedate5 = '';	//
	public String sample_duedate6 = '';	//
    
    
	public String cust_target_price1 = '';	//100 Customer_Target_Price__c
	public String cust_target_price2 = '';	//
	public String cust_target_price3 = '';	//
	public String cust_target_price4 = '';	//
	public String cust_target_price5 = '';	//
	public String cust_target_price6 = '';	//

    //v2 - new additions
    public String contact_number = '';
    public String company_name = '';
    public String pincode = '';

}