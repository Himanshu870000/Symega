public class SAP_ProjectQuotientWrapper{
    
	public cls_PRODUCT_OUTCOME[] PRODUCT_OUTCOME;
	public class cls_PRODUCT_OUTCOME {
		public String HALB_CODE;	//1234
		public String PROD_NAME;	//
		public String CURRENT_SHELF_LIFE;	//10 months
		public String USAGE_LEVEL;	//
		public String COMMENTS;	//No Comment
	}
	public static SAP_ProjectQuotientWrapper parse(String json){
		return (SAP_ProjectQuotientWrapper) System.JSON.deserialize(json, SAP_ProjectQuotientWrapper.class);
	}
    
}