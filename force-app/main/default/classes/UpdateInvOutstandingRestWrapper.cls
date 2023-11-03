public without sharing class UpdateInvOutstandingRestWrapper {
    
    public List<cls_INVOICES> INVOICES;
    public class cls_INVOICES{
        public string INVOICE_NO;
        public decimal AMOUNT;
        public String RECEIVED_DATE;
    }
    
    public static UpdateInvOutstandingRestWrapper parse(string json){
        return (UpdateInvOutstandingRestWrapper) System.JSON.deserialize(json, UpdateInvOutstandingRestWrapper.class);
    }
}