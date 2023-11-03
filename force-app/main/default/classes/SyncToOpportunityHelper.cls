/*
*      Author: Anjali Singh
*/

public without sharing class SyncToOpportunityHelper {
    
    @AuraEnabled
    public static void createQuoteLineItem(String quoteId){
        try{
            if(!String.isBlank(quoteId)) {
                system.debug('Quote Id:: '+ quoteId);
                List<Quote> qtList = [SELECT Id, OpportunityId FROM Quote WHERE Id =: quoteId];
                                
                list<QuoteLineItem> productListToBeSynced = new list<QuoteLineItem>([SELECT Id, OpportunityLineItem.Quantity, OpportunityLineItem.Quantity_In_KG__c, OpportunityLineItemId, OpportunityLineItem.FERT_Code__c, OpportunityLineItem.Packaging_Quantity__c, OpportunityLineItem.Packaging_Type__c, OpportunityLineItem.Packaging_Unit__c, OpportunityLineItem.Pvt_Label_Selling_Price__c,
                                                                                     OpportunityLineItem.MarkDown_Amount__c,OpportunityLineItem.Markup_Amount__c,OpportunityLineItem.Primary__c,OpportunityLineItem.Secondary__c, OpportunityLineItem.Approval_Markdown__c,
                                                                                     OpportunityLineItem.Tertiary__c, OpportunityLineItem.Symega_Logo__c, OpportunityLineItem.Material_Sector__c, OpportunityLineItem.Customized_Label__c, OpportunityLineItem.Description
                                                                                     FROM QuoteLineItem WHERE QuoteId =:quoteId]);
                
                List<Id> oppLineItemIdList = new List<Id>();
                List<QuoteLineItem> qliListToBeInserted = new List<QuoteLineItem>();
                
                if(!productListToBeSynced.isEmpty()) {
                    for(QuoteLineItem productRec : productListToBeSynced){
                        
                        /* newQuoteLineRec.UnitPrice = productRec.UnitPrice;
                        newQuoteLineRec.ServiceDate = productRec.ServiceDate;
                        newQuoteLineRec.Discount = productRec.Discount;*/

                        productRec.Quantity = productRec.OpportunityLineItem.Quantity;
                        productRec.Quantity_in_KG__c = productRec.OpportunityLineItem.Quantity_In_KG__c;
                        productRec.FERT_Code__c = productRec.OpportunityLineItem.FERT_Code__c;
                        productRec.Description = productRec.OpportunityLineItem.Description;
                        productRec.Symega_Logo__c = productRec.OpportunityLineItem.Symega_Logo__c;
                        productRec.Material_Sector__c = productRec.OpportunityLineItem.Material_Sector__c;
                        productRec.Customized_Label__c  = productRec.OpportunityLineItem.Customized_Label__c ; 
                        productRec.Packaging_Quantity__c = productRec.OpportunityLineItem.Packaging_Quantity__c;
                        productRec.Packaging_Type__c = productRec.OpportunityLineItem.Packaging_Type__c;
                        productRec.Packaging_Unit__c = productRec.OpportunityLineItem.Packaging_Unit__c;
                        productRec.MarkDown_Amount__c = productRec.OpportunityLineItem.MarkDown_Amount__c;
                        productRec.Markup_Amount__c = productRec.OpportunityLineItem.Markup_Amount__c;
                        productRec.Primary__c = productRec.OpportunityLineItem.Primary__c;
                        productRec.Secondary__c = productRec.OpportunityLineItem.Secondary__c;
                        productRec.Tertiary__c = productRec.OpportunityLineItem.Tertiary__c;
                        productRec.Pvt_Label_Selling_Price__c = productRec.OpportunityLineItem.Pvt_Label_Selling_Price__c;
                        productRec.Approval_Markdown__c = productRec.OpportunityLineItem.Approval_Markdown__c;
                        oppLineItemIdList.add(productRec.OpportunityLineItemId);
                    }
                    system.debug('---'+productListToBeSynced);
                    update productListToBeSynced;                            
                }
                
                List<OpportunityLineItem> oppLineItemsList = [SELECT Id, Quantity_In_KG__c, FERT_Code__c, PricebookEntryId, Product2Id, Quantity, UnitPrice, Packaging_Quantity__c, Packaging_Type__c, Packaging_Unit__c, Pvt_Label_Selling_Price__c, MarkDown_Amount__c, Markup_Amount__c, 
                                                              Primary__c, Secondary__c, Approval_Markdown__c, Tertiary__c, Symega_Logo__c, Material_Sector__c, Customized_Label__c, Description
                                                              FROM OpportunityLineItem WHERE OpportunityId =: qtList[0].OpportunityId AND Id NOT IN: oppLineItemIdList];
                
                if(oppLineItemsList.size() >0 ){
                    for(OpportunityLineItem lineItem : oppLineItemsList){
                        
                        QuoteLineItem qli = new QuoteLineItem();
                        qli.QuoteId = qtList[0].Id;
                        qli.OpportunityLineItemId = lineItem.Id;
                        qli.PricebookEntryId = lineItem.PricebookEntryId;
                        qli.Product2Id = lineItem.Product2Id;
                        qli.Quantity_in_KG__c = lineItem.Quantity_In_KG__c;
                        qli.Quantity = lineItem.Quantity;
                        qli.UnitPrice = lineItem.UnitPrice;
                        qli.Description = lineItem.Description;
                        qli.Symega_Logo__c = lineItem.Symega_Logo__c;
                        qli.Material_Sector__c = lineItem.Material_Sector__c;
                        qli.Customized_Label__c  = lineItem.Customized_Label__c ; 
                        qli.Packaging_Quantity__c = lineItem.Packaging_Quantity__c;
                        qli.Packaging_Type__c = lineItem.Packaging_Type__c;
                        qli.Packaging_Unit__c = lineItem.Packaging_Unit__c;
                        qli.MarkDown_Amount__c = lineItem.MarkDown_Amount__c;
                        qli.Markup_Amount__c = lineItem.Markup_Amount__c;
                        qli.Primary__c = lineItem.Primary__c;
                        qli.Secondary__c = lineItem.Secondary__c;
                        qli.Tertiary__c = lineItem.Tertiary__c;
                        qli.Pvt_Label_Selling_Price__c = lineItem.Pvt_Label_Selling_Price__c;
                        qli.Approval_Markdown__c = lineItem.Approval_Markdown__c;
                        qli.FERT_Code__c = lineItem.FERT_Code__c;
                        
                        qliListToBeInserted.add(qli);
                    }
                }
                
                if(!qliListToBeInserted.isEmpty())
                    insert qliListToBeInserted;
                                        
            }
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error@@==>'+ex.getLineNumber());
        }
    }
    
}