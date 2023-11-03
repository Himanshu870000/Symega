public with sharing class Optiva_ProjectWrapper {

    public String start_date;	//2022-03-29
    public String project_request_status;	//Sample Accepted
    public String actual_dispatch_date;	//2022-03-29
    public string way_bill_no;	//78990
    public String courier;	//
    public String delivery_date;	//2022-03-29
    public String dispatch_details;	//Sample Line Item is dispatched
    public String rd_approval_status;	//H567JB
    public string usage_level;
    public string current_shelf_life;
    public String completion_date;
    public String rejected_reason; //new field TODO:, Mandatory Data isn't available (Reason of Rnd Rejection new field on Project)
    public String comments;// new field TODO:

    public List<prod_outcome_cls> product_outcome;
    //public String product_outcome ;
    public class prod_outcome_cls {
      public String ssc_code;	
      public String prod_name;	
	}


	public static Optiva_ProjectWrapper parse(String json){
		return (Optiva_ProjectWrapper) System.JSON.deserialize(json, Optiva_ProjectWrapper.class);
	}
}