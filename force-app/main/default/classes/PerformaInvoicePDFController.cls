public without sharing class PerformaInvoicePDFController {
    
    public String recordId =  System.currentPageReference().getParameters().get('id');
    public Symega_Configuration__c symObj {get;set;}
    public Opportunity oppDetails {get;set;}
    public String shippingAddress {get;set;}
    public decimal sumOfQuantity {get;set;}
    public decimal sumOfValue {get;set;}
    public decimal sumOfUnitPrice {get;set;}
    public decimal sumOfSubTotal {get;set;}
    public integer sumOfAmount {get;set;}
    public decimal sumOfINRAmount {get;set;}
    public string numInWords {get;set;}
    public string sumOfAmtIntoWords {get;set;}
    public string sumOfAmtINRWords {get;set;}
    public decimal sumOfTotalCharges {get;set;}
    public decimal insurance {get;set;}
    public integer day {get;set;}
    public integer year {get;set;}
    public integer month {get;set;}
    public integer dispatchDay {get;set;}
    public integer dispatchYear {get;set;}
    public integer dispatchMonth {get;set;}
    
    public PerformaInvoicePDFController(){
        try{
            
            sumOfQuantity = 0;
            sumOfValue = 0;
            sumOfAmount = 0;
            sumOfSubTotal = 0; 
            sumOfTotalCharges = 0;
            insurance = 0;
            sumOfUnitPrice = 0;
            sumOfINRAmount = 0;
            
            day = SYSTEM.TODAY().day();
            month = SYSTEM.TODAY().month();
            year = SYSTEM.TODAY().year();
            
            symObj = Symega_Configuration__c.getValues('Symega Configuration');
            System.debug('symObj'+symObj.symega_address__c);
            
            oppDetails = [SELECT id, Total_Qty_In_Kg__c, Total_Freight_Charges__c, Freight_charges__c, Fiscal_Year__c, TotalOpportunityQuantity, accShipAdr__c, Pvt_Label_Item_Count__c, Proposed_Date_of_Dispatch__c, Performa_Invoice_No__c, Pre_carriage_By__c, Place_of_Reciept_by_Pre_Carrier__c,Port_of_Discharge__c,Vessel_Flight_Name_Voy_No__c,Port_of_Loading__c,Include_Freight_Charges__c,
                          (SELECT Product2Id, ProductCode, Description, Quantity, UnitPrice, TotalPrice, ListPrice, Sub_Total__c, Product2.ProductCode, FERT_Code__c, Product2.Name, Product2.HSN_Code__c, Product2.HSN_TAX__c FROM OpportunityLineItems), 
                          Account.Name, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingStateCode, Account.Payment_terms__c, Account.Transportation_Terms__c,
                          Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode , Account.BillingStateCode, Account.GST_number__c, Account.PAN_Number__c
                          FROM Opportunity WHERE Id =: recordId];
            system.debug('oppDetails :: ' +oppDetails); 
            system.debug('accShipAdr__c :: ' +oppDetails.accShipAdr__c); 
            
            if(oppDetails.Proposed_Date_of_Dispatch__c != NULL){
                dispatchDay = oppDetails.Proposed_Date_of_Dispatch__c.day();
                dispatchMonth = oppDetails.Proposed_Date_of_Dispatch__c.month();
                dispatchYear = oppDetails.Proposed_Date_of_Dispatch__c.year();
            }
            
            for(OpportunityLineItem opp1 : oppDetails.OpportunityLineItems){
                if(opp1.Quantity == NULL){
                    opp1.Quantity = 0;
                }
                if(opp1.TotalPrice == NULL){
                    opp1.TotalPrice = 0;
                }
                if(opp1.TotalPrice != NULL){
                    opp1.TotalPrice = (opp1.TotalPrice).setScale(2);
                }
                if(opp1.UnitPrice != NULL){
                    opp1.UnitPrice = (opp1.UnitPrice).setScale(2);
                }
                sumOfUnitPrice = (sumOfUnitPrice + opp1.UnitPrice).setScale(2);
                sumOfQuantity = (sumOfQuantity + opp1.Quantity).setScale(2);
                sumOfValue = (sumOfValue + opp1.TotalPrice).setScale(2);
                sumOfAmount = sumOfAmount + integer.valueOf(opp1.TotalPrice);
                sumOfSubTotal = sumOfSubTotal +  opp1.Sub_Total__c;  
                sumOfTotalCharges = (sumOfTotalCharges + opp1.TotalPrice).setScale(2);
                sumOfINRAmount = sumOfINRAmount + opp1.TotalPrice;
            }
            if(oppDetails.Freight_charges__c ==NULL){
                oppDetails.Freight_charges__c = 0;
            }
            insurance = ((sumOfValue * 0.3)/100).setScale(2);
            
            if(oppDetails.Include_Freight_Charges__c){
                sumOfTotalCharges = (sumOfTotalCharges + oppDetails.Total_Freight_Charges__c).setScale(2);
            }
            
            //numInWords = english_number(sumOfSubTotal);
            sumOfAmtIntoWords = Utility.english_number(sumOfAmount);
            sumOfAmtINRWords = Utility.getNumberTOWordConvertion(sumOfINRAmount);
            system.debug('sumOfAmtINRWords-- ' + sumOfAmtINRWords);
        }
        
        catch(Exception ex){
            system.debug('ERROR:: ' + ex.getMessage()+' at line no' + ex.getLineNumber());
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
            ContentDocumentLink cdl = createContentLink(cont.Id, id);
            return 'Success';
            
        } catch (Exception e) {
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
    public static string emailToClient(String url,String oppId){
        try {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Opportunity> opprec = [SELECT Id, Account.id, Account.Name, Account.Email__c, Owner.Name From Opportunity Where Id =: oppId];
            PageReference ref = new PageReference(url);
            Blob emailAttach = ref.getContentAsPdf();
            if(!opprec.isEmpty()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('Invoice');
                efa.setBody(emailAttach);
                efa.setContentType('application/pdf');
                
                List<String> recipients = new List<String>();
                recipients.add(opprec[0].Account.Email__c);
                system.debug('recipients------'+recipients);
                mail.setToAddresses(recipients);
                mail.setSenderDisplayName('Symega');
                String subject = 'Proforma Invoice';
                String htmlBody = 'Dear ' + opprec[0].Account.Name +', ';
                htmlBody += ' <br> <br> Kindly find attached the Proforma Invoice for products of your interest. ';
                htmlBody += ' <br> <br> Please feel free to reach out to me in case of any queries or clarifications sought. ';
                htmlBody += '<br> <br> Thanks and Regards <br>';
                htmlBody += opprec[0].Owner.Name;
                htmlBody += '<br> "Symega Email Signature"';
                
                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
                mail.setSaveAsActivity(true);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
                mails.add(mail);
                system.debug('mails-->'+mails.size());
                if(!mails.isEmpty())
                    system.debug('mails-->'+mails.size());
                Messaging.sendEmail(mails);
            }
            return 'Success';                
            
        }catch(exception e){
            system.debug('Error :: ' + e.getMessage() + 'At Line No :: ' + e.getLineNumber());
            return e.getStackTraceString();
        }
    }
    
    @AuraEnabled
    public static string quoteEmailToClient(String url,String emailId){
        try {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            PageReference ref = new PageReference(url);
            
            Blob emailAttach = ref.getContentAsPdf();
            if(!String.isEmpty(emailId)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('Quote Invoice');
                efa.setBody(emailAttach);
                efa.setContentType('application/pdf');
                
                List<String> recipients = new List<String>();
                recipients.add(emailId);
                
                system.debug('recipients------'+recipients);
                mail.setToAddresses(recipients);
                mail.setSenderDisplayName('Symega');
                String subject = 'Test Subject';
                String htmlBody = 'Test Email Body';
                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
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
    public static Opportunity getOppRecord(String id){
        try {
            if(String.isBlank(id))
                return null;
            return [Select Id, Name,CurrencyIsoCode,Freight_charges__c,Proposed_Date_of_Dispatch__c,Pre_carriage_By__c,Port_of_Discharge__c,Place_of_Reciept_by_Pre_Carrier__c,Port_of_Loading__c,Vessel_Flight_Name_Voy_No__c FROM Opportunity where Id =:id];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static string updateINROpp(String oppId,String purposeDate, decimal freightChrg, boolean includeFreight){
        try {
            if(freightChrg == null){
                freightChrg = 0;
            }
            Opportunity opp = new Opportunity(Id = oppId, Freight_charges__c = freightChrg, Include_Freight_Charges__c = includeFreight);
            system.debug('freightChrg --' + freightChrg);
            
            if(!purposeDate.containsIgnoreCase('NaN')){
                opp.Proposed_Date_of_Dispatch__c = Date.parse(purposeDate);
            }
            update opp;
            return 'Success';
        } catch (Exception e) {
            System.debug('error: ' + e.getMessage() + ' line no -- ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateUSAOpp(String oppId, String carriageBy, String dischargePort,String reciept, String portLoading, String vessel){
        try {
            Opportunity opp = new Opportunity();
            if(!String.isEmpty(oppId)){
                opp.Id = oppId;
            }
            if(!String.isEmpty(carriageBy)){
                opp.Pre_carriage_By__c = carriageBy;
            }
            if(!String.isEmpty(dischargePort)){
                opp.Port_of_Discharge__c = dischargePort;
            }
            if(!String.isEmpty(reciept)){
                opp.Place_of_Reciept_by_Pre_Carrier__c = reciept;
            }
            if(!String.isEmpty(portLoading)){
                opp.Port_of_Loading__c = portLoading;
            }
            if(!String.isEmpty(vessel)){
                opp.Vessel_Flight_Name_Voy_No__c = vessel;
            }
            update opp;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }     
    
}