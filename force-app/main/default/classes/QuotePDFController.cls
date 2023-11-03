public without sharing class QuotePDFController {
    public String recordId =  System.currentPageReference().getParameters().get('id');
    public Symega_Configuration__c symObj {get;set;}
    public Quote quoteDetails {get;set;}
    public integer day {get;set;}
    public integer year {get;set;}
    public integer month {get;set;}
    public decimal sumOfPackQuantity {get;set;}
    public decimal sumOfTotalCharges {get;set;}
    public integer quoteExpDay {get;set;}
    public integer quoteExpYear {get;set;}
    public integer quoteExpMonth {get;set;}
    
    public QuotePDFController(){
        try{ 
            sumOfPackQuantity = 0;
            sumOfTotalCharges=0;
            
            symObj = Symega_Configuration__c.getValues('Symega Configuration');
            System.debug('symObj'+symObj.symega_address__c);
            
            quoteDetails = [SELECT id, Total_Freight_Charges__c, Freight_charges__c, BillingAddress, Createddate, QuoteNumber, Total_Quantity_In_Kg__c, ShippingAddress, ShippingStreet, ShippingCity,  ShippingState, ShippingCountry, ShippingPostalCode, ExpirationDate, Month__c, Include_Freight_Charges__c,
                            (SELECT Id, LineNumber, Product2Id, UnitPrice, Quantity, TotalPrice, ListPrice, Packaging_Quantity__c, FERT_Code__c, Product2.Name, Product2.ProductCode FROM QuoteLineItems), 
                            Account.Name, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingCountry, Account.ShippingPostalCode, Account.Payment_terms__c, Account.Transportation_Terms__c,
                            Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode , Account.GST_number__c, Account.PAN_Number__c, Account.RecordType.Name, Account.Customer_Discount__c
                            FROM Quote WHERE Id =: recordId];
            
            if(quoteDetails.ExpirationDate != NULL){
                quoteExpDay = quoteDetails.ExpirationDate.day();
                quoteExpMonth = quoteDetails.ExpirationDate.month();
                quoteExpYear = quoteDetails.ExpirationDate.year();
            }
            
            day = SYSTEM.TODAY().day();
            month = SYSTEM.TODAY().month();
            year = SYSTEM.TODAY().year();
            
            for(QuoteLineItem quoteRec : quoteDetails.QuoteLineItems){
                if(quoteRec.Packaging_Quantity__c == NULL){
                    quoteRec.Packaging_Quantity__c = 0;
                }
                sumOfPackQuantity = sumOfPackQuantity + quoteRec.Packaging_Quantity__c;
                
                if(quoteRec.UnitPrice == NULL){
                    quoteRec.UnitPrice = 0;
                }
                sumOfTotalCharges = (sumOfTotalCharges + quoteRec.UnitPrice).setScale(2);
            }
            if(quoteDetails.Freight_charges__c == NULL){
                quoteDetails.Freight_charges__c = 0;
            }            
            if(quoteDetails.Include_Freight_Charges__c){
                sumOfTotalCharges = (sumOfTotalCharges + quoteDetails.Total_Freight_Charges__c).setScale(2);            
            }
            
            system.debug('sumOfTotalCharges :: ' + sumOfTotalCharges);
        }
        
        catch(Exception ex){
            system.debug('ERROR:: ' + ex.getMessage()+' at line no ' + ex.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static string savePDF(String url,String id,String fileName){
        try {
            PageReference ref = new PageReference(url);
            ContentVersion cont = new ContentVersion();
            
            cont.Title = fileName;
            cont.PathOnClient = fileName+'.pdf';
            cont.VersionData = ref.getContentAsPdf();
            cont.Origin = 'H';
            
            insert cont;    
            createContentLink(cont.Id, id);
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
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    @AuraEnabled
    public static string quoteEmailToClient(String url, String quoteId){
        try {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Quote> quoteRec = [SELECT Id, Account.Name, Account.id, Account.Email__c, Owner.Name From Quote Where Id =: quoteId];
            PageReference ref = new PageReference(url);
            Blob emailAttach = ref.getContentAsPdf();
            if(!quoteRec.isEmpty()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> recipients = new List<String>();
                recipients.add(quoteRec[0].Account.Email__c);
                system.debug('recipients------'+recipients);
                
                mail.setToAddresses(recipients);
                mail.setSenderDisplayName('Symega');
                String subject = 'Quote PDF Generated';
                String htmlBody = 'Dear ' + quoteRec[0].Account.Name + ',';
                htmlBody += ' <br> <br> Kindly find attached the Quotation document for products of your interest. ';
                htmlBody += ' <br> <br> Please feel free to reach out to me in case of any queries or clarifications sought. ';
                htmlBody += '<br> <br> Thanks and Regards <br>';
                htmlBody += quoteRec[0].Owner.Name;
                htmlBody += '<br> "Symega Email Signature"';
                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
                mail.setSaveAsActivity(true);
                
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('Quote Invoice');
                efa.setBody(emailAttach);
                efa.setContentType('application/pdf');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
                mails.add(mail);
                system.debug('mails-->'+mails.size());
                if(!mails.isEmpty())
                    system.debug('mails-->'+mails.size());
                Messaging.sendEmail(mails);
            }
            return 'Success';
        }catch(exception e){
            return e.getStackTraceString();
        }
    }
    
    @AuraEnabled
    public static void updateOnQuote(String recId, Boolean check, Decimal frChrge){
        try{
            if(frChrge == null){
                frChrge = 0;
            }
            Quote qt = new Quote(Id =recId, Include_Freight_Charges__c = check, Freight_charges__c = frChrge);
            update qt;
        }
        catch(Exception e){
            system.debug('Error -- ' + e.getMessage() + 'At Line No -- ' + e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static decimal getQtDetails(String recId){
        Quote qt = [SELECT Id, Include_Freight_Charges__c, Freight_charges__c FROM Quote WHERE Id =: recId];
        return qt.Freight_charges__c;
    }
    
}