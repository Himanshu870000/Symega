public class SAP_ProjectStatusUpdateWrapper {
    
    public String START_DATE;	//24-03-2022
    public String PROJECT_REQUEST_STATUS;	//Project Ready To Dispatch
    public String COMPLETION_DATE;	//24-03-2022
    public String REJECTED_REASON;	//Mandatory Data isn't available
    public String COMMENTS;	//No Comment
    
    public static SAP_ProjectStatusUpdateWrapper parse(String json){
        return (SAP_ProjectStatusUpdateWrapper) System.JSON.deserialize(json, SAP_ProjectStatusUpdateWrapper.class);
    }
}