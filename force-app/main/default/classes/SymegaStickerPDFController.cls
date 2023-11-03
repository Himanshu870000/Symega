public without sharing class SymegaStickerPDFController {
    
    public  List<Sample_Line_Item__c> sampLineItemList {get; set;}
    public SamplePdfDetails__mdt sampDetails {get;set;} // custom 
    public  Project__c projRec  {get; set;}
    public string recordId = System.currentPageReference().getParameters().get('id'); 
    public User userRec {get; set;}
    public Integer totalQuantity {get; set;}
    
    public SymegaStickerPDFController(){
        
            try{
            
            sampDetails = [select Id, MasterLabel,CIN__c,City__c,Country__c,Hno__c,Landmark__c,mobile1__c,mobile2__c,Name__c,Pancode__c,Pincode__c,State__c,SyntPark__c,NHC_HNO__c,Email__c,Website__c,PAN__c,FSSAI_Nr__c,GST__c from SamplePdfDetails__mdt];
                      //ShippingCity,ShippingState,ShippingStreet,ShippingPostalCode,ShippingCountry   Opportunity__r.Account.ShippingCity,  Opportunity__r.Account.ShippingState, Opportunity__r.Account.ShippingStreet, Opportunity__r.Account.ShippingPostalCode, Opportunity__r.AccountShippingCountry
                      projRec = [SELECT ID,Name,Opportunity__c,Opportunity__r.AccountId,Opportunity__r.Account.Customer_Number__c,Invoice_No__c,Opportunity__r.CurrencyIsoCode,City__c,State__c,Street__c,Postal_Code__c,Country__c,Customers_Contact__c,Customers_Contact__r.Name,Customers_Contact__r.Phone,Customers_Contact__r.Email, No_Of_Cartoons__c,Mode_Of_Courier__c, Opportunity__r.Account.ShippingCity,  Opportunity__r.Account.ShippingState, Opportunity__r.Account.ShippingStreet, Opportunity__r.Account.ShippingPostalCode, Opportunity__r.Account.ShippingCountry,Airport_Of_Departure__c,Airport_Of_Destination__c, AWB_NO__c ,OwnerId FROM Project__c WHERE ID =:recordId];
                     userRec = [SELECT ID,FirstName,LastName FROM User where Id =:projRec.OwnerId];                  
             sampLineItemList = [SELECT ID,Sample__c,Product_Code__c,Mfg_Date__c,Product_Name__c,Product__c,Product__r.HSN_Code__c,Quantity__c,Quantity_Unit__c,Packaging_Quantity__c,Packaging_Unit__c FROM Sample_Line_Item__c WHERE Sample__c =:recordId];
                        
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