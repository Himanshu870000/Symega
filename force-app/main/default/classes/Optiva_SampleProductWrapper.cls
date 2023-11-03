/**
 * Author: Anjali
 */
public without sharing class Optiva_SampleProductWrapper {

    public String exclusive_product_code;	//H567JB
    public String product_code;	//22642V3
    public String way_bill_no;	//78990
    public String courier;	//
    public String actual_dispatch_date;	//2022-03-29
    public String dispatch_details;	//Sample Line Item is dispatched
    public String request_status;	//Sample Accepted
    public String start_date;	//2022-03-29
    public String delivery_date;	//2022-03-29
    public String rejected_reason; //new field TODO:, Mandatory Data isn't available
    public String comments;// new field TODO:

	public static Optiva_SampleProductWrapper parse(String json){
		return (Optiva_SampleProductWrapper) System.JSON.deserialize(json, Optiva_SampleProductWrapper.class);
	}
}