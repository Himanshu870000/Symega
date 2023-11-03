@isTest
private class TriggerTestClass{
    @isTest(SeeAllData=true)
    private static void run(){
        Database.SaveResult dsr;
        User_Document__c ud = new User_Document__c();
        ud.Name = 'Test';
        insert ud;
        ud.Display_On_Portal__c = true;
        update ud;
    }
    
    @isTest(SeeAllData=true)
    private static void run1(){
        Database.SaveResult dsr;
        Opportunity opp = new Opportunity(Name='ABC', StageName ='New', CloseDate= system.today());
        insert opp;
        opp.StageName = 'New';
        update opp;
    }
    
    @isTest(SeeAllData=true)
    private static void run2(){
        Database.SaveResult dsr;
        Opportunity opp = new Opportunity(Name='ABC', StageName ='New', CloseDate= system.today());
        insert opp;
        Quote qt = new Quote(Name='ABC');
        qt.OpportunityId = opp.Id;
        insert qt;

    }
    
    @isTest(SeeAllData=true)
    private static void run3(){
        Database.SaveResult dsr;
        Opportunity opp = new Opportunity(Name='ABC', StageName ='New', CloseDate= system.today());
        insert opp;
        
        Pricebook2 book = new Pricebook2(IsActive=true, Name='Std Book');
        insert book;
        
        Product2 prod = new Product2(IsActive=true, Name='AAM PANNA', To_Be_Sold_By__c ='Direct', Product_Visibility__c = 'Public', Product_Used_By__c = 'Tailor Made');
        insert prod;
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry entry = new PricebookEntry(IsActive=true, UnitPrice=900, UseStandardPrice=false);
        entry.Pricebook2Id=book.Id;
        entry.Product2Id=prod.Id;	
        insert entry;
        
        OpportunityLineItem OLI = new OpportunityLineItem(Quantity=20.00, Packaging_Type__c='Bulk', TotalPrice=200);
        OLI.OpportunityId=opp.id;
        OLI.PricebookEntryId = standardPBE.id;
        insert OLI;
        OLI.Quantity = 1;
        update OLI;
    }
    
    @isTest(SeeAllData=true)
    private static void run4(){
        Database.SaveResult dsr;
        Lead ld = new Lead(FirstName='ABC', LastName='XYZ', Company ='New', Status='New', Email='dummy@gmail.com');
        insert ld;
        ld.Company = 'Old';
        update ld;
    }
    
    @isTest(SeeAllData=true)
    private static void run5(){
        Database.SaveResult dsr;
        Opportunity opp = new Opportunity(Name='ABC', StageName ='New', CloseDate= system.today());
        insert opp;
        
        Pricebook2 book = new Pricebook2(IsActive=true, Name='Std Book');
        insert book;
        
        Product2 prod = new Product2(IsActive=true, Name='AAM PANNA', To_Be_Sold_By__c ='Direct', Product_Visibility__c = 'Public', Product_Used_By__c = 'Tailor Made');
        insert prod;
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry entry = new PricebookEntry(IsActive=true, UnitPrice=900, UseStandardPrice=false);
        entry.Pricebook2Id=book.Id;
        entry.Product2Id=prod.Id;	
        insert entry;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(Packaging_Type__c = 'Private Label', OpportunityId = opp.Id, Discount = 67, Quantity = 45, TotalPrice=678);
        oppLineItem.PricebookEntryId = standardPBE.id;
        insert oppLineItem;
        
        Sales_Order__c saleOrder = new Sales_Order__c(Name='ABC', Opportunity__c = opp.Id);
        insert saleOrder;
        
        Account acc = new Account(Name = 'ACC-INVOICE');
        insert acc;
        
        Invoice__c invoice = new Invoice__c(Sales_Order__c = saleOrder.Id, Account__c = acc.Id, Invoice_Number__c = '4sj');
        insert invoice;
        
        Return__c returnObj = new Return__c(Quantity__c  = 1, Opportunity_Product__c = oppLineItem.Id, Sale_Order__c = saleOrder.Id, Invoice__c = invoice.Id);
        insert returnObj;
        
        returnObj.Quantity__c = 1;
        update returnObj;
    }
    
    /*@isTest(SeeAllData=true)
    private static void insertOppProd(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Manager'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='salesMngr@123.com');

        
        Opportunity oppExtRec = [SELECT Id, Name FROM Opportunity WHERE Id = '0065j00000iIvQzAAK'];
        Product2 pr = [SELECT Id, CurrencyISOCode FROM Product2 WHERE Id = '01t5j000005iDiiAAE'];
        
        /*Pricebook2 standardPB = [select id from Pricebook2 where Id = '01s5j000005dsKSAAY'];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pr.Id, UnitPrice = 1900, IsActive = true, CurrencyIsoCode = pr.CurrencyIsoCode);
        insert standardPBE;
        
        PricebookEntry entry = new PricebookEntry(IsActive=true, UnitPrice=900, UseStandardPrice=false);
        entry.Pricebook2Id = standardPB.Id;
        entry.Product2Id = pr.Id;
        insert entry; -- 
        
        OpportunityLineItem oli = new OpportunityLineItem ();
        oli.OpportunityId = oppExtRec.Id;
        oli.Product2Id = pr.Id;
        oli.Quantity = 20;
        oli.Packaging_Type__c = 'Bulk';
        oli.TotalPrice = 200;
        oli.PricebookEntryId = '01u5j000003AdSQAA0';
        insert oli;
        
        System.runAs(u) {
              System.debug('Current User: ' + UserInfo.getUserName());
              System.debug('Current Profile: ' + UserInfo.getProfileId());
          }
        
        
    }*/   
    
}