public without sharing class SAP_InvoiceSyncRestServiceWrapper {
    
    public List<cls_BILLING> BILLING ;
    public class cls_BILLING {
        public string EMPLOYEE;
        public string SOLD_TOPARTY;
        public string SONO;
        public string BILLINGNO;
        public string MATERIAL;
        public string CANC_INV;
        public string VALUE_DOCCUR;
        public string EXPORT_CUR;
        public string QTY_UOM;
        public string SALE_UNIT;
        public string QTY_KG;
        public string BILLING_DATE;
        public string NET_VALUE;
        public string TAXBALE_VALUE;
        public string TOTAL_BILL;
        public string FREIGHT;
        public string MATERIL_DISC;
        public string EXPORT_VALUE;
        public string CUSTOMER_DIS;
        public string CASH_DIS;
        public string INSURANCE;
        public string TOTAL_GST;
        public string TRASACTION_TYPE;
        public string INVOICE_DATE;
    }
    
    public static SAP_InvoiceSyncRestServiceWrapper parse(string json){
        return (SAP_InvoiceSyncRestServiceWrapper) System.JSON.deserialize(json, SAP_InvoiceSyncRestServiceWrapper.class);
        
    }
}