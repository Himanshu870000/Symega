public class SAP_UpdateFertRestServiceWrapper{
	public cls_PRODUCT_DATA[] PRODUCT_DATA;
	public class cls_PRODUCT_DATA {
        public String FERT_CODE;
		public String PRODUCTCODE;	//206636_P2
		public String CUSTOMER_NUMBER;	//
		public String ACTIVE;	//NO
		public String PRODUCT_DESCRIPTION;	//TOMATO KETCHUP SACHETS-25169-8g P2.
		public String PRODUCTFAMILY;	//
		public String PRODUCTTYPE;	//FERT
		public String UNITOFMEASURE;	//KAR
		public String PRODUCT_USED_BY;	//
		public String LEGACYCODE;	//
		public Decimal HSN_TAX;	//0
		public String SALES_CODE;	//
		public String ALLERGEN_STATUS;	//TRUE
		public String DIETARYINFO;	//
		public Decimal MOQ;	//0.000 
		public String PRODUCTSUBCATEGORY;	//
	}
	public static SAP_UpdateFertRestServiceWrapper parse(String json){
		return (SAP_UpdateFertRestServiceWrapper) System.JSON.deserialize(json, SAP_UpdateFertRestServiceWrapper.class);
	}
}