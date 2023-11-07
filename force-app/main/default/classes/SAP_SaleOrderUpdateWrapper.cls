public with sharing class SAP_SaleOrderUpdateWrapper {

    public List<SALE_ORDER> SALE_ORDERS = new List<SALE_ORDER>();

    public class SALE_ORDER {
        
        public String REF_CODE;
        public String CUSTOMER_CODE;
        public string REMARKS;
        //public string SERVICE_RENDERING_DATE;
        public String SUBMITTED_DATE;//2022-03-29
        //public boolean PAYMENT_RECEIVED;
        //public String CHANGE_IN_DISPATCH_DATE; 
        
        public List<prod_outcome_cls> PRODUCTS ;
        public ship_add_cls SHIPPING_ADDRESS ;
    }
        
    public class prod_outcome_cls {
        public String PRODUCT_CODE;
        public String NET_WEIGHT_IN_KGS;
        public String SERVICE_RENDERING_DATE;
        public String CHANGE_IN_DISPATCH_DATE;
    }
    public class ship_add_cls {
        public String NAME;
        public String CITY;
        public String STATE;
        public String COUNTRY;
        public String POSTAL_CODE;
        public String STREET;

        //NEW
        public String CUST_CODE;
    }
    public static SAP_SaleOrderUpdateWrapper parse(String json){
        return (SAP_SaleOrderUpdateWrapper) System.JSON.deserialize(json, SAP_SaleOrderUpdateWrapper.class);
    }

}