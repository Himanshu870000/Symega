public class NoSplitOpportunityHelper {
    
    @AuraEnabled
    public static string createOneTimeOppRec(String oppId){
        try{
            if(!String.isBlank(oppId)) {
                List<Opportunity> parentOpportunity = new List<Opportunity>();
                list<Opportunity> childOpprtunitites = new list<Opportunity>();
                list<OpportunityLineItem> productToBeInserted = new list<OpportunityLineItem>();
                
                parentOpportunity = [Select Id, Name, AccountId, CloseDate, Customer_Followup_Date__c, Customer_response__c, Description, SyncedQuoteId,CurrencyIsoCode,
                                     TotalOpportunityQuantity, Probability,LeadSource, Next_Order_Date__c, NextStep, Sample__c,Reason_For_Loss_del__c,Primary_Contact__c,
                                     StageName, Type, Distributer_Customer__c,End_Use_Application__c, End_Use_Category__c,
                                     Account_Billing_Address__c, Customer_Billing_Address__c, Account_Shipping_Address__c, Customer_Shipping_Address__c, 
                                     Shipping_Country__c, Shipping_Postal_Code__c, Shipping_Street__c, Shipping_State__c, Shipping_City__c, 
                                     Billing_Country__c, Billing_Postal_Code__c, Billing_Street__c, Billing_City__c, Billing_State__c, 
                                     Actual_Annual_Potential_Value__c, Target_Price_Kg__c, Annual_Volume_Full__c, Annual_Volume_in_units__c, End_Use_Application_Other__c	
                                     From Opportunity Where Id = :oppId];
                
                productToBeInserted = [SELECT Id, OpportunityId, SortOrder, ServiceDate, Discount, Quantity, PricebookEntryId, Product2Id, Sales_Order__c,
                                       Primary__c, Secondary__c, Tertiary__c, Customized_Label__c, Symega_Logo__c, Material_Sector__c, Pvt_Label_Selling_Price__c,
                                       UnitPrice, Description,Packaging_Type__c, Packaging_Unit__c, Packaging_Quantity__c, FERT_Code__c FROM OpportunityLineItem WHERE OpportunityId = : oppId];
                
                childOpprtunitites = [SELECT Id, Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :oppId ];
                
                if(!childOpprtunitites.isEmpty()){
                    //throw new AuraHandledException('Child Opportunity is created'); 
                    return 'Child Opportunity is created';                   
                }
                
                
                if(!productToBeInserted.isEmpty()){
                    if(!parentOpportunity.isEmpty()) {
                        Opportunity oneTimeOppRec = new Opportunity();
                        oneTimeOppRec.Parent_Opportunity__c = parentOpportunity[0].Id;
                        oneTimeOppRec.RecordTypeId = Constants.OpportunityRecordTypeOneTime;
                        oneTimeOppRec.Name = parentOpportunity[0].Name+' - 1' ;
                        oneTimeOppRec.AccountId = parentOpportunity[0].AccountId;
                        oneTimeOppRec.CloseDate = parentOpportunity[0].CloseDate;
                        oneTimeOppRec.TotalOpportunityQuantity = parentOpportunity[0].TotalOpportunityQuantity ;
                        oneTimeOppRec.Customer_Followup_Date__c = parentOpportunity[0].Customer_Followup_Date__c ;
                        oneTimeOppRec.NextStep = parentOpportunity[0].NextStep ;
                        oneTimeOppRec.Customer_response__c = parentOpportunity[0].Customer_response__c ;
                        oneTimeOppRec.LeadSource = parentOpportunity[0].LeadSource ;
                        oneTimeOppRec.Next_Order_Date__c = parentOpportunity[0].Next_Order_Date__c ;
                        oneTimeOppRec.StageName  = 'New';
                        oneTimeOppRec.Probability    = parentOpportunity[0].Probability ;
                        oneTimeOppRec.Description = parentOpportunity[0].Description ;
                        //oneTimeOppRec.Sample__c  = parentOpportunity[0].Sample__c ;
                        oneTimeOppRec.SyncedQuoteId  = parentOpportunity[0].SyncedQuoteId ;
                        oneTimeOppRec.Reason_For_Loss_del__c  = parentOpportunity[0].Reason_For_Loss_del__c ;
                        oneTimeOppRec.Customer_response__c  = parentOpportunity[0].Customer_response__c ;
                        oneTimeOppRec.LeadSource  = parentOpportunity[0].LeadSource ;
                        oneTimeOppRec.Type = parentOpportunity[0].Type;
                        oneTimeOppRec.Distributer_Customer__c = parentOpportunity[0].Distributer_Customer__c ;
                        oneTimeOppRec.Primary_Contact__c = parentOpportunity[0].Primary_Contact__c ;
                        oneTimeOppRec.CurrencyIsoCode = parentOpportunity[0].CurrencyIsoCode ;
                        oneTimeOppRec.End_Use_Category__c = parentOpportunity[0].End_Use_Category__c;
                        oneTimeOppRec.End_Use_Application__c = parentOpportunity[0].End_Use_Application__c;
                        oneTimeOppRec.End_Use_Application_Other__c = parentOpportunity[0].End_Use_Application_Other__c;
                        
                        oneTimeOppRec.Annual_Volume_Full__c = parentOpportunity[0].Annual_Volume_Full__c;
                        oneTimeOppRec.Annual_Volume_in_units__c = parentOpportunity[0].Annual_Volume_in_units__c;
                        oneTimeOppRec.Target_Price_Kg__c = parentOpportunity[0].Target_Price_Kg__c;
                        oneTimeOppRec.Actual_Annual_Potential_Value__c = parentOpportunity[0].Actual_Annual_Potential_Value__c;
                        
                        oneTimeOppRec.Billing_City__c = parentOpportunity[0].Billing_City__c;
                        oneTimeOppRec.Billing_State__c = parentOpportunity[0].Billing_State__c;
                        oneTimeOppRec.Billing_Street__c = parentOpportunity[0].Billing_Street__c;
                        oneTimeOppRec.Billing_Postal_Code__c = parentOpportunity[0].Billing_Postal_Code__c;
                        oneTimeOppRec.Billing_Country__c = parentOpportunity[0].Billing_Country__c;
                        
                        oneTimeOppRec.Shipping_City__c = parentOpportunity[0].Shipping_City__c;
                        oneTimeOppRec.Shipping_State__c = parentOpportunity[0].Shipping_State__c;
                        oneTimeOppRec.Shipping_Street__c = parentOpportunity[0].Shipping_Street__c;
                        oneTimeOppRec.Shipping_Postal_Code__c = parentOpportunity[0].Shipping_Postal_Code__c;
                        oneTimeOppRec.Shipping_Country__c = parentOpportunity[0].Shipping_Country__c;
                        
                        oneTimeOppRec.Customer_Shipping_Address__c = parentOpportunity[0].Customer_Shipping_Address__c;
                        oneTimeOppRec.Account_Shipping_Address__c = parentOpportunity[0].Account_Shipping_Address__c;
                        oneTimeOppRec.Customer_Billing_Address__c =  parentOpportunity[0].Customer_Billing_Address__c;
                        oneTimeOppRec.Account_Billing_Address__c = parentOpportunity[0].Account_Billing_Address__c;
                        
                        insert oneTimeOppRec;
                        
                        
                        list<OpportunityLineItem> productList = new list<OpportunityLineItem>();
                        for(OpportunityLineItem productRec : productToBeInserted){
                            
                            OpportunityLineItem newProductRec = new OpportunityLineItem();
                            newProductRec.OpportunityId = oneTimeOppRec.Id;
                            newProductRec.UnitPrice = productRec.UnitPrice;
                            newProductRec.ServiceDate = productRec.ServiceDate;
                            newProductRec.FERT_Code__c = productRec.FERT_Code__c;
                            newProductRec.Quantity = productRec.Quantity;
                            newProductRec.PricebookEntryId = productRec.PricebookEntryId;
                            newProductRec.Product2Id = productRec.Product2Id;
                            newProductRec.SortOrder = productRec.SortOrder;
                            newProductRec.Description  = productRec.Description;
                            newProductRec.Packaging_Type__c = productRec.Packaging_Type__c;
                            newProductRec.Sales_Order__c = productRec.Sales_Order__c;
                            newProductRec.Pvt_Label_Selling_Price__c = productRec.Pvt_Label_Selling_Price__c;
                            newProductRec.Packaging_Quantity__c = productRec.Packaging_Quantity__c;
                            newProductRec.Packaging_Unit__c = productRec.Packaging_Unit__c;
                            newProductRec.Customized_Label__c = productRec.Customized_Label__c;
                            newProductRec.Symega_Logo__c = productRec.Symega_Logo__c;
                            newProductRec.Material_Sector__c = productRec.Material_Sector__c;
                            newProductRec.Primary__c = productRec.Primary__c;
                            newProductRec.Secondary__c = productRec.Secondary__c;
                            newProductRec.Tertiary__c = productRec.Tertiary__c;
                            
                            productList.add(newProductRec);
                        }
                        system.debug('---'+productList);
                        if(!productList.isEmpty()){
                            insert productList;
                            //parentOpportunity[0].StageName = 'In-Progress';
                            //update parentOpportunity[0];
                            return 'SUCCESS';
                        }                            
                    }
                }       
            } 
            return 'Id is not specified';
        }catch(exception ex){
            AuraHandledException excep = new AuraHandledException('');
            system.debug('error: ' + ex.getMessage()); //I can see the error in the system.debug log.
            excep.setMessage(ex.getMessage());
            throw excep;
            /*system.debug('Error==>'+ex.getMessage());
system.debug('Error@@==>'+ex.getLineNumber());*/
        }
    }
    
    @AuraEnabled
    public static string createOneTimeOppRecLWC(String oppId, OppWrapper opWrapper){
        try{
            if(!String.isBlank(oppId)) {
                List<Opportunity> parentOpportunity = new List<Opportunity>();
                list<Opportunity> childOpprtunitites = new list<Opportunity>();
                list<OpportunityLineItem> productToBeInserted = new list<OpportunityLineItem>();
                
                parentOpportunity = [Select Id, Name, AccountId, CloseDate, Customer_Followup_Date__c, Customer_response__c, Description, SyncedQuoteId,CurrencyIsoCode,
                                     TotalOpportunityQuantity, Probability,LeadSource, Next_Order_Date__c, NextStep, Sample__c,Reason_For_Loss_del__c,Primary_Contact__c,
                                     StageName, Type,Distributer_Customer__c,End_Use_Application__c,	End_Use_Category__c From Opportunity Where Id = :oppId];
                
                productToBeInserted = [SELECT Id, OpportunityId, SortOrder, ServiceDate, Discount, Quantity, PricebookEntryId, Product2Id, Sales_Order__c,
                                       Primary__c, Secondary__c, Tertiary__c, Customized_Label__c, Symega_Logo__c, Material_Sector__c, Pvt_Label_Selling_Price__c,
                                       UnitPrice, Description,Packaging_Type__c, Packaging_Unit__c, Packaging_Quantity__c, FERT_Code__c FROM OpportunityLineItem WHERE OpportunityId = : oppId];
                
                childOpprtunitites = [SELECT Id, Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :oppId ];
                
                if(!childOpprtunitites.isEmpty()){
                    //throw new AuraHandledException(''); 
                    return 'Child Opportunity is created';                    
                }
                
                if(!productToBeInserted.isEmpty()){
                    if(!parentOpportunity.isEmpty()) {
                        Opportunity oneTimeOppRec = new Opportunity();
                        oneTimeOppRec.Parent_Opportunity__c = parentOpportunity[0].Id;
                        oneTimeOppRec.RecordTypeId = Constants.OpportunityRecordTypeOneTime;
                        oneTimeOppRec.Name = parentOpportunity[0].Name+' - 1' ;
                        oneTimeOppRec.AccountId = parentOpportunity[0].AccountId;
                        oneTimeOppRec.CloseDate = parentOpportunity[0].CloseDate;
                        oneTimeOppRec.TotalOpportunityQuantity = parentOpportunity[0].TotalOpportunityQuantity ;
                        oneTimeOppRec.Customer_Followup_Date__c = parentOpportunity[0].Customer_Followup_Date__c ;
                        oneTimeOppRec.NextStep = parentOpportunity[0].NextStep ;
                        oneTimeOppRec.Customer_response__c = parentOpportunity[0].Customer_response__c ;
                        oneTimeOppRec.LeadSource = parentOpportunity[0].LeadSource ;
                        oneTimeOppRec.Next_Order_Date__c = parentOpportunity[0].Next_Order_Date__c ;
                        oneTimeOppRec.StageName  = 'New';
                        oneTimeOppRec.Probability    = parentOpportunity[0].Probability ;
                        oneTimeOppRec.Description = parentOpportunity[0].Description ;
                        oneTimeOppRec.Sample__c  = parentOpportunity[0].Sample__c ;
                        oneTimeOppRec.SyncedQuoteId  = parentOpportunity[0].SyncedQuoteId ;
                        oneTimeOppRec.Reason_For_Loss_del__c  = parentOpportunity[0].Reason_For_Loss_del__c ;
                        oneTimeOppRec.Customer_response__c  = parentOpportunity[0].Customer_response__c ;
                        oneTimeOppRec.LeadSource  = parentOpportunity[0].LeadSource ;
                        oneTimeOppRec.Type = parentOpportunity[0].Type;
                        oneTimeOppRec.Distributer_Customer__c = parentOpportunity[0].Distributer_Customer__c ;
                        oneTimeOppRec.Primary_Contact__c = parentOpportunity[0].Primary_Contact__c ;
                        oneTimeOppRec.CurrencyIsoCode = parentOpportunity[0].CurrencyIsoCode ;
                        oneTimeOppRec.End_Use_Category__c = parentOpportunity[0].End_Use_Category__c;
                        oneTimeOppRec.End_Use_Application__c = parentOpportunity[0].End_Use_Application__c;
                        
                        oneTimeOppRec.Billing_City__c = opWrapper.billCity;
                        oneTimeOppRec.Billing_State__c = opWrapper.billState;
                        oneTimeOppRec.Billing_Street__c = opWrapper.billStreet;
                        oneTimeOppRec.Billing_Postal_Code__c = opWrapper.billCode;
                        oneTimeOppRec.Billing_Country__c = opWrapper.billCountry;
                        
                        oneTimeOppRec.Shipping_City__c = opWrapper.shipCity;
                        oneTimeOppRec.Shipping_State__c = opWrapper.shipState;
                        oneTimeOppRec.Shipping_Street__c = opWrapper.shipStreet;
                        oneTimeOppRec.Shipping_Postal_Code__c = opWrapper.shipCode;
                        oneTimeOppRec.Shipping_Country__c = opWrapper.shipCountry;
                        
                        oneTimeOppRec.Customer_Shipping_Address__c = opWrapper.customShippingAddress;
                        oneTimeOppRec.Account_Shipping_Address__c = opWrapper.accountShipAddress;
                        oneTimeOppRec.Customer_Billing_Address__c =  opWrapper.customBillingAddress;
                        oneTimeOppRec.Account_Billing_Address__c = opWrapper.accountBillAddress;
                        
                        insert oneTimeOppRec;
                        
                        list<OpportunityLineItem> productList = new list<OpportunityLineItem>();
                        for(OpportunityLineItem productRec : productToBeInserted){
                            
                            OpportunityLineItem newProductRec = new OpportunityLineItem();
                            newProductRec.OpportunityId = oneTimeOppRec.Id;
                            newProductRec.UnitPrice = productRec.UnitPrice;
                            newProductRec.ServiceDate = productRec.ServiceDate;
                            newProductRec.FERT_Code__c = productRec.FERT_Code__c;
                            newProductRec.Quantity = productRec.Quantity;
                            newProductRec.PricebookEntryId = productRec.PricebookEntryId;
                            newProductRec.Product2Id = productRec.Product2Id;
                            newProductRec.SortOrder = productRec.SortOrder;
                            newProductRec.Description  = productRec.Description;
                            newProductRec.Packaging_Type__c = productRec.Packaging_Type__c;
                            newProductRec.Sales_Order__c = productRec.Sales_Order__c;
                            newProductRec.Pvt_Label_Selling_Price__c = productRec.Pvt_Label_Selling_Price__c;
                            newProductRec.Packaging_Quantity__c = productRec.Packaging_Quantity__c;
                            newProductRec.Packaging_Unit__c = productRec.Packaging_Unit__c;
                            newProductRec.Customized_Label__c = productRec.Customized_Label__c;
                            newProductRec.Symega_Logo__c = productRec.Symega_Logo__c;
                            newProductRec.Material_Sector__c = productRec.Material_Sector__c;
                            newProductRec.Primary__c = productRec.Primary__c;
                            newProductRec.Secondary__c = productRec.Secondary__c;
                            newProductRec.Tertiary__c = productRec.Tertiary__c;
                            
                            productList.add(newProductRec);
                        }
                        system.debug('---'+productList);
                        if(!productList.isEmpty()){
                            insert productList;
                            //parentOpportunity[0].StageName = 'In-Progress';
                            //update parentOpportunity[0];
                            return 'SUCCESS';
                        }                            
                    }
                }       
            } 
            return 'Id is not specified';
        }
        catch(exception ex){
            system.debug('error: ' + ex.getMessage() + 'at line no : ' + ex.getLineNumber()); //I can see the error in the system.debug log.
            return ex.getMessage();
            
            /*  AuraHandledException excep = new AuraHandledException('');
excep.setMessage(ex.getMessage());
throw excep;            
system.debug('Error==>'+ex.getMessage());
system.debug('Error@@==>'+ex.getLineNumber());
*/
        }
    }
    
    
    public class OppWrapper{
        @AuraEnabled public String shipCity{get;set;}
        @AuraEnabled public String shipCountry{get;set;}
        @AuraEnabled public String shipCode{get;set;}
        @AuraEnabled public String shipState{get;set;}
        @AuraEnabled public String shipStreet{get;set;}
        
        @AuraEnabled public String billCity{get;set;}
        @AuraEnabled public String billCountry{get;set;}
        @AuraEnabled public String billCode{get;set;}
        @AuraEnabled public String billState{get;set;}
        @AuraEnabled public String billStreet{get;set;}
        
        @AuraEnabled public Boolean accountBillAddress{get;set;}
        @AuraEnabled public Boolean accountShipAddress{get;set;}
        @AuraEnabled public Id customShippingAddress{get;set;}
        @AuraEnabled public Id customBillingAddress{get;set;}
        
    } 
}