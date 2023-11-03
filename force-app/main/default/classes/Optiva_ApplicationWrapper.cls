/*
* Author: Anjali Singh
*/
public without sharing class Optiva_ApplicationWrapper {
    
    public String way_bill_no;	//78990
    public String application_ready;	//H567JB
    public String courier;	//
    public String actual_dispatch_date;	//2022-03-29
    public string country_regulation;
    public string current_shelf_life;
    public String dispatch_details;	//Sample Line Item is dispatched
    public String start_date;	//2022-03-29
    public String delivery_date;	//2022-03-29
    public String rejected_reason; //new field TODO:, Mandatory Data isn't available (Reason of Rnd Rejection new field on Project)
    public String comments;// new field TODO:
    
    public List<prod_outcome_cls> product_outcome;
    public class prod_outcome_cls {
      public String ssc_code;	
      public String prod_name;	
	}

	public static Optiva_ApplicationWrapper parse(String json){
		return (Optiva_ApplicationWrapper) System.JSON.deserialize(json, Optiva_ApplicationWrapper.class);
	}
}