public without sharing class OPTIVA_SubmitDocLinkWrapper {
	public cls_document_link[] document_linksync;
	public class cls_document_link {
		public String document_name;	
		public String document_link;	
	}
	public static OPTIVA_SubmitDocLinkWrapper parse(String json){
		return (OPTIVA_SubmitDocLinkWrapper) System.JSON.deserialize(json, OPTIVA_SubmitDocLinkWrapper.class);
	}
    
}