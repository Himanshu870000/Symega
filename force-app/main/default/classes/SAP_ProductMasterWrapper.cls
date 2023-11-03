public without sharing class SAP_ProductMasterWrapper {
    public List<ProductMasterSyncWrapper> PRODUCT_DATA;
	public class ProductMasterSyncWrapper {
		public String ACTIVE;	//NO
		public String PRODUCTCODE;	//22642V3
		public String PRODUCT_DESCRIPTION;	//HOMOGENISED PREMIX FOR TATA 1.
		public String PRODUCTFAMILY;	//
		public String TARGET_DISH;	//
		public String UNITOFMEASURE;	//KG
		public String APPLICATION;	//
		public String PRODUCT_USED_BY;	//
		public String LEGALSTATUS;	//
		public Double LISTPRICE;	//0
		public Double HSN_TAX;	//0
		public String TARGETCOUNTRY;	//
		public String ALLERGEN_STATUS;	//TRUE
		//public String DIETARYINFO;	//
		public String PRODUCT_PROFILE;	//
		public Integer MAXIMUM_SAMPLING_QUANTITY;	//00000
		public String SAMPLING_QTY_UNIT;	//
		public String RAD_APPLICATION;	//
		public String PRODUCTSUBCATEGORY;	//
		public String ENDAPPLICATION;	//
		public String PLANT;
        
        //NEW
        public String TO_BE_SOLD_BY;
        public String VISIBILITY;
        
    }
    
	public static SAP_ProductMasterWrapper parse(String json){
		return (SAP_ProductMasterWrapper) System.JSON.deserialize(json, SAP_ProductMasterWrapper.class);
	}
}