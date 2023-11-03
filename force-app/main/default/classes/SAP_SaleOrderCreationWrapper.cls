public with sharing class SAP_SaleOrderCreationWrapper {
    
    public String ref_code;//2022-03-29
    public String customer_code;//Sample Accepted
    public String customer_po_ref_no;//2022-03-29
    public string customer_ref_date;//78990
    public String plant;//
    public String expected_delivery_date;//2022-03-29
    public String initiated_by;//Sample Line Item is dispatched
    public String order_fulfillment;//H567JB
    public string remarks;
    public string service_rendering_date;
    public String service_rendering_date_reason;
    public String gross_weight; 
    
    public List<prod_outcome_cls> products ;
    public class prod_outcome_cls {
        public String product_code;
        public String quantity;
        public String quantity_unit;
        public String net_weight_in_kgs;
    }
    public List<ship_add_cls> shipping_address ;
    public class ship_add_cls {
        public String name;
        public String city;
        public String country;
        public String postal_code;
        public String street;
    }

    
    public static SAP_SaleOrderCreationWrapper parse(String json){
        return (SAP_SaleOrderCreationWrapper) System.JSON.deserialize(json, SAP_SaleOrderCreationWrapper.class);
    }

}