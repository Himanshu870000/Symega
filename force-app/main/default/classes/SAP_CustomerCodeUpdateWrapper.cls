public class SAP_CustomerCodeUpdateWrapper {
    
    public string SAP_Code;
    
    public static SAP_CustomerCodeUpdateWrapper parse(String json){
		return (SAP_CustomerCodeUpdateWrapper) System.JSON.deserialize(json, SAP_CustomerCodeUpdateWrapper.class);
	}
}