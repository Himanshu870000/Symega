public without sharing class SampleInvoiceDomesticPDFController {
    
    public  List<Sample_Line_Item__c> sampLineItemList {get; set;}
    public SamplePdfDetails__mdt sampDetails {get;set;} // custom 
    public  Project__c projRec  {get; set;}
    public string recordId = System.currentPageReference().getParameters().get('id'); 
    public User userRec {get; set;}
    public Integer totalQuantity {get; set;}
    
    public SampleInvoiceDomesticPDFController() {
        try{
            
            sampDetails = [select Id, MasterLabel,CIN__c,City__c,Country__c,Hno__c,Landmark__c,mobile1__c,mobile2__c,Name__c,Pancode__c,Pincode__c,State__c,SyntPark__c,NHC_HNO__c,Email__c,Website__c,PAN__c,FSSAI_Nr__c,GST__c from SamplePdfDetails__mdt];

            projRec = [SELECT ID, Name, City__c,State__c,Street__c,Postal_Code__c,Country__c, No_Of_Cartoons__c,Mode_Of_Courier__c, Invoice_No__c, Airport_Of_Departure__c,Airport_Of_Destination__c, AWB_NO__c ,OwnerId,
                       Customers_Contact__c, Customers_Contact__r.Name,Customers_Contact__r.Phone,Customers_Contact__r.Email, 
                       Opportunity__r.CurrencyIsoCode, Opportunity__r.Account.Name, Opportunity__r.Account.Transportation_Terms__c, Opportunity__r.Account.Payment_terms__c, Opportunity__c,Opportunity__r.AccountId,
                       Opportunity__r.Account.ShippingCity,  Opportunity__r.Account.ShippingState, Opportunity__r.Account.ShippingStreet, Opportunity__r.Account.ShippingPostalCode, Opportunity__r.Account.ShippingCountry,
                       Opportunity__r.Account.BillingCity,  Opportunity__r.Account.BillingState, Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingPostalCode, Opportunity__r.Account.BillingCountry,
                       Opportunity__r.Account.PAN_Number__c, Opportunity__r.Account.GST_number__c, Opportunity__r.Sale_Order_No__c
                       FROM Project__c WHERE ID =:recordId];
            
            userRec = [SELECT ID,FirstName,LastName FROM User where Id =:projRec.OwnerId];
            
            sampLineItemList = [SELECT ID,Sample__c,Product_Code__c,Product_Name__c,Product__c,Product__r.HSN_Code__c,Quantity__c,Quantity_Unit__c,Packaging_Quantity__c,Packaging_Unit__c FROM Sample_Line_Item__c WHERE Sample__c =:recordId];
            
            for(Sample_Line_Item__c sliRec: sampLineItemList){
                
                totalQuantity += (integer) sliRec.Quantity__c ;                
            }
            System.debug('totalQuantity------>'+totalQuantity);    
        }catch(exception e){
            system.debug('Exception Line Number--->'+e.getLineNumber());
            System.debug('Exception Message--->'+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string savePDF(String url,String id,String fileName){
        try {
            string  disReqId = id;
            PageReference ref = new PageReference(url);
            ContentVersion cont = new ContentVersion();
            
            cont.Title = fileName;
            cont.PathOnClient = fileName+'.pdf';
            cont.VersionData = ref.getContentAsPdf();
            cont.Origin = 'H';            
            insert cont;
            
            ContentDocumentLink cdl = createContentLink(cont.Id, id);
            return 'Success';    
            
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } 
        catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
}