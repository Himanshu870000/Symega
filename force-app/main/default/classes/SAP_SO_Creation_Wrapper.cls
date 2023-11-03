public without sharing class SAP_SO_Creation_Wrapper {
   
	public List<SOWrapper> SALE_ORDERS;

	public class cls_products {
		public String PRODUCT_CODE;	//HSN0000159
		public Decimal QUANTITY;	//10
		public String QUANTITY_UNIT;	//KG
		public Decimal NET_WEIGHT_IN_KGS;	//1000
		public String PLANT;	//BREAKFAST MIX DIV
		public String PLANNED_DELIVERY_DATE;
		public String SERVICE_RENDERING_DATE;
		public String SERVICE_RENDERING_DATE_REASON;
	}
	public class cls_shipping_address {
		public String NAME;	//address
		public String CITY;	//Banglore
		public String STATE;	//KA
		public String COUNTRY;	//IN
		public String POSTAL_CODE;	//560060
		public String STREET;	//#10, 23rd main, BTM 2nd stage
        
        //NEW
        public String CUST_CODE;	//S-01
	}

	public class SOWrapper{
		public String REF_CODE;	//1234ABC
		public String CUSTOMER_CODE;	//SAP customer code
		public String CUSTOMER_PO_REF_NO;	//PO123
		public String CUSTOMER_REF_DATE;	//2023-04-12
		public String INITIATED_BY;	//JESS
		public String EXPECTED_DELIVERY_DATE;	//2023-04-12
		public String ORDER_FULFILLMENT;	//2023-04-10
		public String REMARKS;	//SO remarks
		public Decimal GROSS_WEIGHT;	//100
		public cls_products[] PRODUCTS;
		public cls_shipping_address SHIPPING_ADDRESS;
	}
}