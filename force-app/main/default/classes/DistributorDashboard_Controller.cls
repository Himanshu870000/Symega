public without sharing class DistributorDashboard_Controller {
    
    public string tabValues                 {get;set;}
    static String code;
    public Boolean isSignUp                 {get;set;}
    public Boolean isLogin                  {get;set;}
    public Boolean isCustomer               {get;set;}
    public Boolean isCandidate              {get;set;}
    public boolean isMentorExist            {get;set;}
    public string  name                     {get;set;}
    public string  FbId                     {get;set;}
    public string  gId                      {get;set;}
    public string  gFname                   {get;set;}
    public string hasCodeUpdate             {get;set;}
    public string Error                     {get;set;}
    public static final String SITE  =      'Login';
    public string currentUserId             {get;set;}
    public string hasCode                   {get;set;}
    public string currentdonorId            {get;set;}
    public Boolean SignupCandidate          {get;set;}
    public Boolean SignupCustomer           {get;set;}
    public string isFBcustomerSignup        {get;set;}
    public string isFBcandidateSignup       {get;set;}
    public string selfAssesmentQuestions    {get;set;}
    public string jobFuncList               {get;set;}
    public string asignmentStatusList       {get;set;}
    public string jobShiftTimings           {get;set;}
    public string jobShiftAvailiblity       {get;set;}
    public string industryType              {get;set;}
    public String candidateSiteURL          {get;set;}
    public String candidateHashcode         {get;set;}
    public static String candidateId        {get;set;}
    public String distributorProfile {get;set;}
    public static String workingDaysValues  {get;set;}
    public static String getAllEvents       {get;set;}
    public String blobData                  {get;set;}
    public String temShiftStaffType         {get;set;}
    public String temShiftSpecialSkills     {get;set;}
    public String compSkillPickVal                 {get;set;}
    public String crownPicklistVal          {get;set;}
    public String imgeSoftwarePickVal       {get;set;}  
    public String pmsSkillPickVal           {get;set;}
    public String xrayProficiencyPickVal           {get;set;}
    public string  candidateName            {get;set;}
    public string staffList                 {get;set;}
    public string  ProfilePictureId         {get;set;}
    public static string  canId             {get;set;}
    
   /* public String blobData {
        get {
            try{
                list<DistributorDashboard_Helper.UserDocumentWrapper> userDocList = getContactUserDoc(getContactId(Apexpages.currentPage().getParameters().get('hc')));
                return EncodingUtil.Base64Encode(userDocList[0].blobFile);
            }catch(Exception e){
                return '';
            }
            
        }
    }  */

    
    public DistributorDashboard_Controller (){
        candidateSiteURL = Constants.DISTRIBUTOR_SITE;
        candidateHashcode = Apexpages.currentPage().getParameters().get('hc'); 
        system.debug('candidateHashcode---'+candidateHashcode);
        if(!string.isBlank(candidateHashcode)){
            candidateId = getContactId(candidateHashcode);
            
            Account distributor = [SELECT Id,Profile_Pic_Id__c,ShippingAddress,ShippingCity,
                               ShippingCountry,ShippingStreet,ShippingState,
                               ShippingPostalCode,BillingCity,BillingCountry,BillingStreet,BillingState,BillingPostalCode,Name, Outstanding_Balance__c, Credit_Limit__c, Customer_Discount__c FROM Account WHERE Id =:candidateId AND Recordtype.Name = :RequiterDashboardConstants.DISTRIBUTOR_RECORD_TYPE];

            distributorProfile = JSON.serialize(distributor);                   
            candidateName = distributor.Name;
            System.debug('IFCALLING'+candidateName);
            
            ProfilePictureId =  distributor.Profile_Pic_Id__c;
            canId = distributor.Id;
        }

        
        
        list<Distributor_Dashboard_Tabs__c> cdTabs=[select name,Tab_Label__c,id,Controller_Name__c,Display_Order__c from Distributor_Dashboard_Tabs__c ORDER BY Display_Order__c]; //TODO: remove this query.
        System.debug('cdTabs-----'+cdTabs);
        tabValues = JSON.serialize(cdTabs);
        System.debug(candidateId);
    }


    @RemoteAction
    public static boolean updateUserDetails(Account acc){
        try{
            update acc;
            return true;
        }catch(Exception e){
            System.debug('Exception-----'+e);
            return false;
        }
    }
    
    @RemoteAction
    public static List<Account> getDirectCustomers(){
        return [SELECT Id,Name FROM Account WHERE RecordType.Name='Direct Customer'];
    }
    
    @RemoteAction
    public static String createDirectCustomer(Account acc,String distributorId){
        if(acc!=null && !String.isEmpty(distributorId)){
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel and Food Service').getRecordTypeId();

            List<Account> existingAccounts = [Select Id,Name From Account Where Email__c=:acc.Email__c limit 1];
            Distributor_Allocation__c disAllocation = new Distributor_Allocation__c(Distributor_Account__c=distributorId);

            if(existingAccounts.size() > 0){
                disAllocation.Customer_Account__c = existingAccounts[0].Id;

                return existingAccounts[0].Name + ' is already a customer, Do you want to contiue?';
            }else{
                insert acc;
                disAllocation.Customer_Account__c = acc.Id;
                insert disAllocation;
                return 'Success';
            }
        }
        return 'Failed';
    }

    @RemoteAction
    public static String createDirectCustomerConfirmed(Account acc, String distributorId){
        try{
            if(acc!=null && !String.isEmpty(distributorId)){
                acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel and Food Service').getRecordTypeId();
    
                List<Account> existingAccounts = [Select Id From Account Where Email__c=:acc.Email__c limit 1];
                Distributor_Allocation__c disAllocation = new Distributor_Allocation__c(Distributor_Account__c=distributorId);
    
                if(existingAccounts.size() > 0){
                    disAllocation.Customer_Account__c = existingAccounts[0].Id;
                }else{
                    insert acc;
                    disAllocation.Customer_Account__c = acc.Id;
                }

                insert disAllocation;
                return 'Success';
            }
            return 'Failed to create customer';
        }catch(Exception ex){
            HandleBusinessException.captureError('DistributorDashboard_Controller','CreateOpportunity',ex);
            return ex.getMessage();
        }
    }

    @RemoteAction
    public static Map<String,List<String>> getPickListValues(String ObjectApi_name,List<String> fields){
        Map<String,List<String>> piclistMap = new Map<String,List<String>>();
        for(String field : fields){
            piclistMap.put(field,Utility.getPicklistValuesWithNone(ObjectApi_name,field));
        }

        return piclistMap;
    }
    
    @RemoteAction
    public static List<Pricebook2> getPriceBooks(){
        return [SELECT Id,Name FROM Pricebook2 WHERE IsActive=true];
    }
    @RemoteAction
    public static Boolean createOpportunity(Opportunity opp,Integer Day,Integer month,Integer Year,List<OpportunityLineItem> oppLineItems,List<String> deleteLineItems){
        try{
            Date closeDate= Date.newInstance(Year, month, day);
            opp.CloseDate=CloseDate;
            Id parentRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Constants.OPP_PARENT_RECORD_TYPE).getRecordTypeId();//[select Id,Name from RecordType where name='Parent'];
            opp.RecordTypeId = parentRTID;
            Pricebook2 price = [SELECT Id,Name from Pricebook2 where IsActive=true AND IsStandard = true/* Name = :Constants.CHANNEL_SALES_PB */];
            if(price != null){
                opp.Pricebook2Id = price.Id;
                upsert opp;

                set<Id> prodId=new set<Id>();
                for(OpportunityLineItem oppLine:oppLineItems){
                    prodId.add(oppLine.Product2Id);
                    System.debug(oppLine.Product2Id);
                }
                String isoCode = !String.isEmpty(opp.CurrencyIsoCode)?opp.CurrencyIsoCode:'INR';
                List<PricebookEntry> pbe = [select id, name,Product2Id from PriceBookEntry where Pricebook2id =:price.Id and Product2Id in: prodId AND CurrencyIsoCode =:isoCode];
                System.debug('PriceBook Entry-----'+pbe);
                if(opp.Id!=null){
                    for(OpportunityLineItem oppLines:oppLineItems){
                        if(oppLines.OpportunityId==null){
                            oppLines.OpportunityId=opp.Id;
                            for(PricebookEntry pricebooks:pbe){
                                System.debug(pricebooks.Product2Id);
                                System.debug(oppLines.Product2Id);
                                if(pricebooks.Product2Id==oppLines.Product2Id){
                                    oppLines.PricebookEntryId=pricebooks.Id;
                                }
                            }
                        }
                    }
                    upsert oppLineItems;

                    if(deleteLineItems.size()>0){
                        delete [Select Id From OpportunityLineItem Where Id In : deleteLineItems];
                    }
                    return true;
                }
            }
            return false;
        }catch(Exception ex){
            HandleBusinessException.captureError('DistributorDashboard_Controller','CreateOpportunity',ex);
            System.debug(ex.getCause());
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber());
            return false;
        }
    }
    
    @RemoteAction
    public static Boolean createLineItems(List<OpportunityLineItem> lineItems,Id oppId){
        try{
            Pricebook2 price=[SELECT Id,Name from Pricebook2 where IsActive=true AND IsStandard = true/* AND Name = :Constants.CHANNEL_SALES_PB */];
            if(price!=null){
                set<Id> prodId=new set<Id>();
                for(OpportunityLineItem oppLine:lineItems){
                    prodId.add(oppLine.Product2Id);
                    System.debug(oppLine.Product2Id);
                }
                List<PricebookEntry> pbe = [select id, name,Product2Id from PriceBookEntry where Pricebook2id =:price.Id and Product2Id in: prodId ];
                
                for(OpportunityLineItem oppLines:lineItems){
                    oppLines.OpportunityId=oppId;
                    for(PricebookEntry pricebooks:pbe){
                        System.debug(pricebooks.Product2Id);
                        System.debug(oppLines.Product2Id);
                        if(pricebooks.Product2Id==oppLines.Product2Id){
                            oppLines.PricebookEntryId=pricebooks.Id;
                        }
                    }
                }
                insert lineItems;
                return true;
            }
            return false;    
        }
        catch(Exception ex){
            System.debug(ex.getCause());
            System.debug(ex.getLineNumber());
            return false;
        }
        
    }
    @RemoteAction
    public Static List<Account> getAccounts(String distributorId){
        Contact cont=[SELECT AccountId FROM Contact WHERE Id=:distributorId ];
        if(cont!=null){
            return [SELECT Id,Name FROM Account WHERE Id=:cont.AccountId];
        }
        else{
            return new List<Account>();
        }
    }
    @RemoteAction
    public static List<Distributor_Allocation__c> getDistributionAllocation(String distributorId){
     
        System.debug(distributorId);
        if(distributorId!=null) return [SELECT Id,Distributor_Account__r.Name,Customer_Account__r.Name,Customer_Account__r.Email__c,
                               Customer_Account__r.Phone,Customer_Account__r.Type,Customer_Account__r.Customer_Type__c,
                               Customer_Account__r.Visible_Potential__c,Customer_Account__r.Partially_executed_actual_order_value_vs__c,
                               Customer_Account__r.COLOR_Opportunity_Closed_Value__c,Customer_Account__r.Current_year_Volume__c,
                               Customer_Account__r.Current_year_Volume_Unit__c,Customer_Account__r.Payment_terms__c,Customer_Account__r.NDA_required__c,
                               Customer_Account__r.Account_Segment__c,
                               Customer_Account__r.BillingAddress,Customer_Account__r.ShippingAddress,Customer_Account__r.ShippingCity,
                               Customer_Account__r.ShippingCountry,Customer_Account__r.ShippingStreet,Customer_Account__r.ShippingState,
                               Customer_Account__r.ShippingPostalCode,
                               Customer_Account__r.BillingCity,
                               Customer_Account__r.BillingCountry,
                               Customer_Account__r.BillingStreet,
                               Customer_Account__r.BillingPostalCode,
                               Customer_Account__r.BillingState
                               From Distributor_Allocation__c WHERE Distributor_Account__c=:distributorId];
        else return new List<Distributor_Allocation__c>();
    }


    @RemoteAction
    public static List<MyCustomerWrapper> getMyCustomers(String distributorId) {
        System.debug('--- '+distributorId);
        Map<Id, MyCustomerWrapper> customerWrapperMap = new Map<Id, MyCustomerWrapper>();
        if(distributorId!=null) {
            //Account distAcc = [SELECT Id, Customer_Discount__c FROM Account WHERE Id =:distributorId];

            Map<Id, Distributor_Allocation__c> distMap = new Map<Id,Distributor_Allocation__c>([SELECT Id,Customer_Account__c,Distributor_Account__r.Name,Customer_Account__r.Name,Customer_Account__r.Email__c,
            Customer_Account__r.Phone,Customer_Account__r.Type,Customer_Account__r.Customer_Type__c,
            Customer_Account__r.Visible_Potential__c,Customer_Account__r.Partially_executed_actual_order_value_vs__c,
            Customer_Account__r.COLOR_Opportunity_Closed_Value__c,Customer_Account__r.Current_year_Volume__c,
            Customer_Account__r.Current_year_Volume_Unit__c,Customer_Account__r.Payment_terms__c,Customer_Account__r.NDA_required__c,
            Customer_Account__r.Account_Segment__c,
            Customer_Account__r.BillingAddress,Customer_Account__r.ShippingAddress,Customer_Account__r.ShippingCity,
            Customer_Account__r.ShippingCountry,Customer_Account__r.ShippingStreet,Customer_Account__r.ShippingState,
            Customer_Account__r.ShippingPostalCode,
            Customer_Account__r.BillingCity,
            Customer_Account__r.BillingCountry,
            Customer_Account__r.BillingStreet,
            Customer_Account__r.BillingPostalCode,
            Customer_Account__r.BillingState
            From Distributor_Allocation__c WHERE Distributor_Account__c=:distributorId]);
            
            
            //Set<Id> distCustomerIdSet = new Set<Id>();
            MyCustomerWrapper custWrapper;
            for(Distributor_Allocation__c disAlc: distMap.values()) {
                custWrapper = new MyCustomerWrapper(disAlc, 0);
                customerWrapperMap.put(disAlc.Customer_Account__c, custWrapper);
                //distCustomerIdSet.add(disAlc.Id);
            }
            System.debug('--- customerWrapperMap'+customerWrapperMap);
            Map<Id,Double> customerXsalesMap = new Map<Id,Double>();
            if(!customerWrapperMap.isEmpty()) {
                List<Invoice__c> customerInvoiceList = [SELECT Id,Distributor_Customer__c,Total_Amount__c FROM Invoice__c WHERE Account__c = :distributorId AND Distributor_Customer__c IN: customerWrapperMap.keySet() AND Total_Amount__c > 0];

                System.debug('--- customerInvoiceList '+customerInvoiceList);
                for(Invoice__c customerRes : customerInvoiceList) {
                    if(customerXsalesMap.containsKey(customerRes.Distributor_Customer__c)) {
                        Double amt = customerXsalesMap.get(customerRes.Distributor_Customer__c);
                        amt += customerRes.Total_Amount__c;
                        customerXsalesMap.put(customerRes.Distributor_Customer__c, amt);
                    }else {
                        customerXsalesMap.put(customerRes.Distributor_Customer__c, customerRes.Total_Amount__c);
                    }
                }

            }

            for(MyCustomerWrapper cWrp : customerWrapperMap.values()) {
                if(customerXsalesMap.containsKey(cWrp.disAllocation.Customer_Account__c))
                    cWrp.totalSales = customerXsalesMap.get(cWrp.disAllocation.Customer_Account__c);
            }
            System.debug('---'+customerWrapperMap);
            return customerWrapperMap.values();
        }
        else {
            return customerWrapperMap.values();
        } 
    }

    class MyCustomerWrapper {
        Distributor_Allocation__c disAllocation = new Distributor_Allocation__c();
        Double totalSales;
        MyCustomerWrapper(Distributor_Allocation__c allocation, Double totalSales) {
            this.disAllocation = allocation;
            this.totalSales = totalSales;
        }
    }


    

    class MyProductsWrapper {
        PriceBookEntry pbe = new PriceBookEntry();
    }
     

    @RemoteAction
    public static Account getCustomerContacts(String accId){
        return [Select Customer_Contact__r.Id, Customer_Contact__r.Name From Account Where Id=:accId];
    }
    
    @RemoteAction
    public static Account getDistributorDetails(Id distributorId){
        Account acc = [SELECT Id,Name,CurrencyIsoCode,Profile_Pic_Id__c,Email__c,Phone,Outstanding_Balance__c, Credit_Limit__c, Customer_Discount__c FROM Account WHERE Id=:distributorId];
        return acc;
    }
    
    class SamplesAndLineItems{
        List<Project__c> samples;
        List<Sample_Line_Item__c> lineItems;
    }
    @RemoteAction
    public static SamplesAndLineItems getSamples(String distributorId){
        if(distributorId!=null) {
            List<Distributor_Allocation__c> distributorAll= [SELECT Id,Customer_Account__c,Customer_Account__r.Name FROM Distributor_Allocation__c WHERE Distributor_Account__c=:distributorId ];

            SamplesAndLineItems samplesLines=new SamplesAndLineItems();
            
            List<Project__c> samples=[SELECT Id,Name,RecordType.Name,Status__c,Submit_Sample_To_Optiva__c,Submitted_To_SAP_Optiva__c,Opportunity_Close_Date__c,Approval_Status__c,Distributer_Customer__r.Name,Distributer_Customer__c,Customers_Contact__c,
                                      Minimum_order_quantity__c,Minimum_order_quantity_unit__c,Regulatory_Requirements__c,First_Sample_due_date__c,Sample_Name__c,
                                      Annual_Volume_Full__c,Annual_Volume_in_units__c,Account__r.Name,City__c,Country__c,State__c,Street__c,Postal_Code__c
                                      FROM Project__c WHERE RecordType.Name='Sample' AND  Account__c =: distributorId];

            Set<Id> sampleIds = (new Map<Id,Project__c>(samples)).keySet();
            samplesLines.samples=samples;
            List<Sample_Line_Item__c> sampleLine= [SELECT Id,Product__r.Name,Product_Name__c,Quantity__c,Quantity_Unit__c,Current_Shelf_life__c,Expected_Shelf_Life__c,Customer_Instructions__c,Regulatory_Requirements__c,Packaging_Quantity__c,Packaging_Unit__c,Sample__c from Sample_Line_Item__c where Sample__c IN : sampleIds];
            samplesLines.lineItems=sampleLine;
            return samplesLines;
        }
        return null;
    }

    public static string getDisOwner(String distId){
        return [Select OwnerId From Account where Id=:distId].OwnerId;
    }

    @RemoteAction
    public static Boolean createSamples(Project__c projects,Integer selecteddate,Integer selectedmonth,Integer selectedyear,List<Sample_Line_Item__c> lineItems ,List<String> deleteLineItems){
        try{
            RecordType sampleRecord=[SELECT Id from RecordType WHERE Name='Sample'];

            Date closeDate=Date.newInstance(selectedyear, selectedmonth, selecteddate );

            projects.RecordTypeId=sampleRecord.Id;
            projects.Opportunity_Close_Date__c=closeDate;

            System.debug('Projects------'+projects);
            System.debug('LineItems------'+lineItems);

            String accOwnerId = getDisOwner(projects.Account__c); 
            projects.OwnerId = accOwnerId;

            upsert projects;
            if(projects.Id!=null){
                for(Sample_Line_Item__c lineItem:lineItems){
                    if(lineItem.Sample__c==null){
                        lineItem.Sample__c=projects.Id;   
                        lineItem.OwnerId = accOwnerId;
                    }
                }
                upsert lineItems;

                if(deleteLineItems.size()>0){
                    delete [Select Id From Sample_Line_Item__c Where Id In : deleteLineItems];
                }

                return true;
            }
            return false;   
        }
        catch(Exception ex){
            System.debug(ex.getCause());
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber());
            return false;
        }
    }
    @RemoteAction
    public static List<Pricebookentry> getSalesProducts(String distributorId){
        Account acc = [Select Id, Name,CurrencyIsoCode, Customer_Discount__c From Account Where Id=:distributorId];

        String CurrencyIsoCode = acc.CurrencyIsoCode!=null?acc.CurrencyIsoCode:'INR';

        List<Pricebookentry> entries = [select Id,Product2.Name,UnitPrice,Product2.ProductCode,Product2.Family,Product2.IsActive,
               Product2.QuantityUnitOfMeasure,Product2.Application__c,
               Product2.Current_Inventory__c
               ,Product2.Dosage_Guidelines__c,
                Product2.StockKeepingUnit,Product2.Sampling_Qty_UNIT__c,
               Product2.End_Use_Category__c
               from pricebookentry where PriceBook2.IsStandard = true /* Pricebook2.Name=:Constants.CHANNEL_SALES_PB */ AND Pricebook2.IsActive = true AND Product2.Product_Used_By__c = :Constants.CHANNEL_SALES_PB AND CurrencyIsoCode=:CurrencyIsoCode];
        if(acc.Customer_Discount__c!= null){
            for(Pricebookentry prod : entries){
                if(prod.UnitPrice!= null){
                    Double discountPrice = (prod.UnitPrice*acc.Customer_Discount__c)/100;
                    prod.UnitPrice = prod.UnitPrice - discountPrice;
                }else{
                    System.debug('Id----Ca'+prod.Id);
                }
            }
        }
               return entries;

    }
    
    @RemoteAction
    public static List<Product2> getChannelSalesProducts(String distributorId){
        Account acc = [Select Id, Name, Customer_Discount__c From Account Where Id=:distributorId];
        List<Product2> products =  [SELECT Id,Name,ProductCode,Family,IsActive,QuantityUnitOfMeasure,Application__c,
                Current_Inventory__c,
                Dosage_Guidelines__c,StockKeepingUnit,Sampling_Qty_UNIT__c,End_Use_Category__c,(Select Id,UnitPrice From PricebookEntries Where PriceBook2.IsStandard = true  AND Pricebook2.IsActive = true) FROM Product2 WHERE Product_Used_By__c = :Constants.CHANNEL_SALES_PB AND ProductCode!=null];

        if(acc.Customer_Discount__c!= null){
            for(Product2 prod : products){
                if(!prod.PricebookEntries.isEmpty()){
                    Double discountPrice = (prod.PricebookEntries[0].UnitPrice*acc.Customer_Discount__c)/100;
                    prod.PricebookEntries[0].UnitPrice = prod.PricebookEntries[0].UnitPrice - discountPrice;
                }else{
                    System.debug('Id----Ca'+prod.Id);
                }
            }
        }
        return products;
    }
    
    
    
    @RemoteAction
    public static List<Case> getCases(String distributorId,String customerDisId){
        // Contact cont =[SELECT AccountId FROM Contact WHERE Id =:distributorId ];
        set<Id> customersId= new set<Id>();
        if(distributorId!=null){
            // List<Distributor_Allocation__c> distributorAll= [SELECT Id,Customer_Account__c,Customer_Account__r.Name FROM Distributor_Allocation__c WHERE Distributor_Account__c=:cont.AccountId ];   
            // for(Distributor_Allocation__c dist:distributorall){
            //     customersId.add(dist.Customer_Account__c);
            //     System.debug(dist.Customer_Account__r.Name);
            // }
            String query = 'SELECT Id,CaseNumber,Type,Reason,Distributer_Customer__r.Name,Distributer_Customer__c,ContactMobile,ContactPhone,Priority,Subject,Description,Contact.Name,Account.Name,Status,Additional_Remarks__c,Batch_No__c,DOM__c,Origin,Invoice__r.Name FROM Case WHERE AccountId  =:distributorId';
            if(!customerDisId.equals('All')){
                query+=' And Distributer_Customer__c=:customerDisId';
            }
            return Database.query(query);

            // return [SELECT Id,CaseNumber,Reason,ContactMobile,ContactPhone,Priority,Subject,Description,Contact.Name,Account.Name,Status,
            //         Additional_Remarks__c,Batch_No__c,DOM__c,Origin,Invoice__r.Name,Distributer_Customer__r.Name
            //         FROM Case WHERE AccountId IN : customersId];
        }
        return null;
    }
    
    @RemoteAction
    public static List<Sales_Order__c> getSalesOrders(String distributorId,String customerDisId){
        // Contact cont =[SELECT AccountId FROM Contact WHERE Id =:distributorId ];
        if(distributorId!=null)
        {
            
            String query = 'SELECT Id,Opportunity__r.Name,Distributer_Customer__r.Name,Name,Account__r.Name,Amount__c,Opportunity__r.Account.Name,Submission_Date__c,Submitted_Date__c,Way_Bill_No__c,Expected_Delivery_Date__c,Order_quantity__c,Payment_term__c,Service_Rendering_date__c,Plant__c,Courier__c,Proposed_Execution_Date__c,( Select Account__c,Amount__c,Billed_Quantity__c,CGST__c,Change_in_Dispatch_Date_Reason__c,Courier__c,CurrencyIsoCode,Customer_Payment_Update__c,Dispatch_Date__c,Due_Date__c,Freight_Charges__c,GST__c,IGST__c,Insurance__c,Invoice_Date__c,Name,Invoice_Number__c,Net_Value__c,Number_of_Packs__c,Opportunity__c,Remarks__c,Sales_Order__c,SGST__c,Taxable_value__c,TCS_Value__c,Total_Amount__c,Way_Bill_No__c From Invoice__r) FROM Sales_Order__c where Opportunity__r.AccountId=:distributorId';
            if(!customerDisId.equals('All')){
                query+=' And Distributer_Customer__c=:customerDisId';
            }
            return Database.query(query);
        }
        return null;
    }
    
    @RemoteAction
    public static Boolean createCase(Case caseDetails){
        if(caseDetails!=null){
            upsert caseDetails;
            return true;
        }
        return false;
    }
    
    public class OppDetails
    {
        public List<Opportunity> opps;
        public List<OpportunityLineItem> lineItems;
        public List<Opportunity> childOpps;
        public list<Sales_Order__c> salesOrders;
    }
    
    @RemoteAction
    public static OppDetails getOpportunities(String distributorId){
        // Contact cont =[SELECT AccountId FROM Contact WHERE Id =:distributorId ];
        OppDetails details=new OppDetails();
        List<Opportunity> Opportunities=[SELECT Id,Account.Email__c,Account.Name,Name,StageName,Proposed_Date_of_Dispatch__c,Pre_carriage_By__c,Port_of_Discharge__c,Place_of_Reciept_by_Pre_Carrier__c,Port_of_Loading__c,Vessel_Flight_Name_Voy_No__c,RecordType.Name,Type,Distributer_Customer__r.Name,Distributer_Customer__r.Email__c,Distributer_Customer__c,CloseDate,Amount,TotalOpportunityQuantity,(Select Id,Name From Opportunities__r),(SELECT Id,Product2Id,Packaging_Quantity__c,Packaging_Unit__c,Quantity_Unit__c,Markup_Amount__c,MarkDown_Amount__c,Packaging_Type__c,Product2.Name,Quantity,ListPrice,UnitPrice,OpportunityId,Opportunity.Name,ProductCode FROM OpportunityLineItems),(Select Id, Name,AccountId,AdditionalAddress,AdditionalName,BillingAddress,BillingName,Delivery_Commitment__c,Description,Discount,Distributer_Customer__c,Email,ExpirationDate,GrandTotal,Month__c,Phone,QuoteNumber,QuoteToAddress,QuoteToName,ShippingAddress,ShippingName,ShippingHandling,Status,Subtotal,Tax,Total_Discount__c,TotalPrice,Total_Quantity_In_Kg__c From Quotes)FROM Opportunity WHERE AccountId=: distributorId AND RecordType.Name='Parent'];
        details.opps=Opportunities;
        Map<Id, Opportunity> OppMap = new Map<Id, Opportunity>(Opportunities);
        List<Opportunity> childOpps=[SELECT Id,Account.Name,Parent_Opportunity__r.Distributer_Customer__c,Distributer_Customer__c,Name,StageName,RecordType.Name,Type,Amount,TotalOpportunityQuantity,CloseDate,Parent_Opportunity__c,Parent_Opportunity__r.Name FROM Opportunity WHERE Parent_Opportunity__c IN : OppMap.keyset() AND RecordType.Name='One Time'];
        details.childOpps=childOpps;
        
        List<OpportunityLineItem> LineItems=[SELECT Id,Product2.Name,Packaging_Type__c,Quantity_Unit__c,Packaging_Quantity__c,Packaging_Unit__c,Markup_Amount__c,MarkDown_Amount__c,Quantity,ListPrice,UnitPrice,OpportunityId,Opportunity.Name,ProductCode FROM OpportunityLineItem WHERE  OpportunityId IN : OppMap.keyset()];
        details.lineItems=LineItems;
        
        List<Sales_Order__c> salesOrders=[SELECT Id,Opportunity__r.Name,Name,Account__r.Name,Amount__c,
                                          Opportunity__r.Account.Name,Submission_Date__c,Submitted_Date__c,Way_Bill_No__c,Expected_Delivery_Date__c,
                                          Order_quantity__c,Payment_term__c,Service_Rendering_date__c,Plant__c,
                                          Courier__c,Proposed_Execution_Date__c
                                           FROM Sales_Order__c WHERE Opportunity__c=:OppMap.keyset()];
        details.salesOrders=salesOrders;
        
        
        return details;
    }

    @RemoteAction
    public static List<Sales_Order__c> getChildOppSales(String childOppId){
        return  [SELECT Id,Opportunity__r.Name,Name,Account__r.Name,Amount__c,
                    Opportunity__r.Account.Name,Submission_Date__c,Submitted_Date__c,Way_Bill_No__c,Expected_Delivery_Date__c,
                    Order_quantity__c,Payment_term__c,Service_Rendering_date__c,Plant__c,
                    Distributer_Customer__r.Name,
                    Courier__c,Proposed_Execution_Date__c,
                    ( Select Account__c,Amount__c,Billed_Quantity__c,CGST__c,Change_in_Dispatch_Date_Reason__c,Courier__c,
                    CurrencyIsoCode,Customer_Payment_Update__c,Dispatch_Date__c,Due_Date__c,Freight_Charges__c,GST__c,IGST__c,Insurance__c,
                    Invoice_Date__c,Name,Invoice_Number__c,Net_Value__c,Number_of_Packs__c,Opportunity__c,Remarks__c,Sales_Order__c,SGST__c,Taxable_value__c,
                    TCS_Value__c,Total_Amount__c,Way_Bill_No__c From Invoice__r)
                    FROM Sales_Order__c WHERE Opportunity__c=:childOppId];
    }


    @RemoteAction
    public static String updateINROpp(String oppId,String purposeDate){
        try {
            Opportunity opp = new Opportunity(Id=oppId, Proposed_Date_of_Dispatch__c=Date.parse(purposeDate));
            update opp;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @RemoteAction
    public static string createQuote(Quote q,String expirationDate){
        try {

            boolean isInserted = false;
            q.ExpirationDate = Date.parse(expirationDate);
            List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
            List<OpportunityLineItem> oppLineItems = [SELECT Approval_Markdown__c,CreatedById,CreatedDate,CurrencyIsoCode,Customized_Label__c,Description,
            Discount,FERT_Code__c,Id,IsDeleted,Is_Parent_Opportunity__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,ListPrice,MarkDown_Amount__c,
            Markup_Amount__c,Material_Sector__c,Name,OpportunityId,Packaging_Quantity__c,Packaging_Type__c,Packaging_Unit__c,PricebookEntryId,Primary__c,Product2Id,
            ProductCode,Pvt_Label_Selling_Price__c,Quantity,Sales_Order__c,Secondary__c,ServiceDate,SortOrder,Sub_Total__c,Symega_Logo__c,SystemModstamp,Tertiary__c,
            TotalPrice,UnitPrice FROM OpportunityLineItem Where OpportunityId=:q.OpportunityId];
            
            isInserted = q.Id==null;
            upsert q;

            if(isInserted){
                for(OpportunityLineItem opp: oppLineItems){
                    quoteLineItems.add(new QuoteLineItem(Product2Id=opp.Product2Id,QuoteId=q.Id,Approval_Markdown__c=opp.Approval_Markdown__c,
                        Customized_Label__c=opp.Customized_Label__c,Description=opp.Description,Discount=opp.Discount,
                        Markdown_Amount__c=opp.Markdown_Amount__c,Markup_Amount__c=opp.Markup_Amount__c,Material_Sector__c=opp.Material_Sector__c,Packaging_Quantity__c=opp.Packaging_Quantity__c,
                        Packaging_Type__c = opp.Packaging_Type__c, Packaging_Unit__c=opp.Packaging_Unit__c, PricebookEntryId = opp.PricebookEntryId,Primary__c=opp.Primary__c,Pvt_Label_Selling_Price__c=opp.Pvt_Label_Selling_Price__c,
                        Quantity = opp.Quantity,Secondary__c=opp.Secondary__c,ServiceDate=opp.ServiceDate,SortOrder=opp.SortOrder,Symega_Logo__c=opp.Symega_Logo__c,Tertiary__c=opp.Tertiary__c,UnitPrice=opp.UnitPrice
                    ));    
                }

                insert quoteLineItems;
            }
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @RemoteAction
    public static string updateUSAOpp(String oppId, String carriageBy, String dischargePort,String reciept, String portLoading, String vessel){
        return PerformaInvoicePDFController.updateUSAOpp(oppId, carriageBy, dischargePort, reciept,portLoading,vessel);
    }
    
    @RemoteAction
    public static String sendInvoiceToClient(String url,String oppId){
        return PerformaInvoicePDFController.emailToClient(url, oppId);
    }

    @RemoteAction
    public static String sendQuoteInvoiceToClient(String url,String email){
        return PerformaInvoicePDFController.quoteEmailToClient(url, email);
    }

    
    @RemoteAction
    public static void syncQuote(String quoteId){
        SyncToOpportunityHelper.createQuoteLineItem(quoteId);
    }

    @RemoteAction
    public static Account loginUser(string userName, string password){
       return DistributorDashboard_Helper.loginUser(userName, password);
    } 

    
    public PageReference authenticateUser(){
        system.debug('authenticateUser');
        return DistributorDashboard_Helper.authenticateUser(Apexpages.currentPage().getParameters().get('id'));
    }

    @RemoteAction
    public static String doUploadAttachment(string type, String attachmentBody, String attachmentName,string conId, String attachmentId, string attId) {
        return DistributorDashboard_Helper.doUploadAttachment(type,attachmentBody, attachmentName,conId, attachmentId, attId);
    }

    @RemoteAction
    public static String doCUploadAttachment(String attachmentBody, String attachmentName, string cvId, string udId) {
        return DistributorDashboard_Helper.doCUploadAttachment(attachmentBody, attachmentName, cvId, udId);
    }

    @RemoteAction
    public static String updateUserDoc(Id attId, Id contentVersionId) {
        return DistributorDashboard_Helper.updateUserDoc(attId, contentVersionId);
    }

    @RemoteAction
    public static string getContactId(string hashcode){
        system.debug('conHashCode---'+hashcode);
        List<Account> currentUser = [select name,id from Account where login_hash_code__c =:hashcode];
        system.debug('currentUser--'+currentUser);
        if(currentUser.size() > 0 ){
            return currentUser[0].Id;
        }else{
            return null;
        }
    }
   
    @RemoteAction
    public static list<DistributorDashboard_Helper.UserDocumentWrapper> getContactUserDoc(string parentId) {
        list<DistributorDashboard_Helper.UserDocumentWrapper> userDocList = DistributorDashboard_Helper.getContactUserDoc(parentId);
        return userDocList; 
    }

    @RemoteAction
    public static void updateDocExpirydate(integer day,integer month,integer year,string userDocId){
        DistributorDashboard_Helper.updateDocExpirydate(day,month,year,userDocId);
    }
    
    @RemoteAction
    public static void LogoutClass(String candidateId){
        DistributorDashboard_Helper.logoutCandidate(candidateId);
    }

    @RemoteAction
    public static String noSplit(String oppId){
        return NoSplitOpportunityHelper.createOneTimeOppRec(oppId);
    }
    
    @RemoteAction
    public static List<Opportunity> getRecord(String oppId){
       try {
            System.debug('OppId'+oppId);
            return [Select Id, Name,AccountId,TotalOpportunityQuantity,Pricebook2Id,(SELECT Id,Name,Quantity,Product2Id,PricebookEntryId,Packaging_Type__c,TotalPrice,UnitPrice From OpportunityLineItems), Amount from opportunity where Id=:oppId];
        } catch (Exception e) {
            //HandleBusinessException.captureError('OppSplitParentController', 'getRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @RemoteAction
    public static List<Opportunity> createOpp(String oppId,List<OppSplitParentController.OppWrapper> oppWrappers){
        Opportunity parentOpp = [Select Id,AccountId,Pricebook2Id,Distributer_Customer__c From Opportunity Where Id=:oppId];

        return OppSplitParentController.createOpp(parentOpp,oppWrappers);
    }

    @RemoteAction
    public static String SendSONotification(String sOId){
        Utility.sendSONotification(sOId);
        OpportunityCreateSaleOrderController.updateOpp(soId);
        return 'Success';
    }

    @RemoteAction
    public static Sales_Order__c createSalesOrder(SalesOrderWrapper sWrapper){
        System.debug('Wrapper------'+sWrapper);
        Sales_Order__c so = new Sales_Order__c();

        try{
            so.Account__c = sWrapper.accId;
            so.Opportunity__c = sWrapper.oppId;
            so.Amount__c = sWrapper.amount;
            so.Order_quantity__c = sWrapper.quantity;
            so.Name              = sWrapper.name;
            so.Expected_Delivery_Date__c = Date.parse(sWrapper.expectedDate);
            so.Remarks__c = sWrapper.remarks;
            
           
            if(!String.isEmpty(sWrapper.plant)){
                so.Plant__c = sWrapper.plant;
            }

            so.Customer_PO_Ref_no__c = sWrapper.customerPoNumber;


            if(!String.isEmpty(sWrapper.customer)){
                so.Distributer_Customer__c  = sWrapper.customer;
            }

            insert so;

            so = [SELECT Id,Opportunity__r.Name,Name,Account__r.Name,Amount__c,
                    Opportunity__r.Account.Name,Submission_Date__c,Submitted_Date__c,Way_Bill_No__c,Expected_Delivery_Date__c,
                    Order_quantity__c,Payment_term__c,Service_Rendering_date__c,Plant__c,
                    Courier__c,Proposed_Execution_Date__c,
                    ( Select Account__c,Amount__c,Billed_Quantity__c,CGST__c,Change_in_Dispatch_Date_Reason__c,Courier__c,
                    CurrencyIsoCode,Customer_Payment_Update__c,Dispatch_Date__c,Due_Date__c,Freight_Charges__c,GST__c,IGST__c,Insurance__c,
                    Invoice_Date__c,Name,Invoice_Number__c,Net_Value__c,Number_of_Packs__c,Opportunity__c,Remarks__c,Sales_Order__c,SGST__c,Taxable_value__c,
                    TCS_Value__c,Total_Amount__c,Way_Bill_No__c From Invoice__r)
                    FROM Sales_Order__c WHERE Id=:so.Id];

            return so;
        }catch(Exception e){
            System.debug('Exception------'+e);
            return null;
        }
    }

    @RemoteAction
    public static boolean updateSalesOrder(UpdateSalesOrderWrapper sWrapper){

        try{
            Sales_Order__c so = new Sales_Order__c();
            so.Id = sWrapper.id;
            so.Account__c = sWrapper.accId;
            so.Opportunity__c = sWrapper.oppId;
            so.Amount__c = sWrapper.amount;
            so.Order_quantity__c = sWrapper.quantity;
            so.Name              = sWrapper.name;

            so.Remarks__c = sWrapper.remarks;
            
            if(!String.isEmpty(sWrapper.plant)){
                so.Plant__c = sWrapper.plant;
            }
            if(!String.isEmpty(sWrapper.expectedDate)){
                so.Expected_Delivery_Date__c = Date.parse(sWrapper.expectedDate);
            }

            so.Customer_PO_Ref_no__c = sWrapper.customerPoNumber;


            if(!String.isEmpty(sWrapper.customer)){
                so.Distributer_Customer__c  = sWrapper.customer;
            }


            upsert so;
            return true;
        }catch(Exception e){
            System.debug('Exception------'+e);
            return false;
        }
    }

    @RemoteAction
    public static Map<String,String> submitSampleToOptiva(String recId, String recType){
        return Optiva_LWC_NPD_Controller.syncSample(recId,recType);
    }

    @RemoteAction
    public class SalesOrderWrapper
    {
        public String accId;
        public String oppId;
        public String name;
        public String customer;
        public Integer quantity;
        public double amount;
        public String expectedDate;
        public String customerPoNumber;
        public String remarks;
        public String plant;
    }

    @RemoteAction
    public class UpdateSalesOrderWrapper
    {
        public String id;
        public String accId;
        public String oppId;
        public String name;
        public String customer;
        public Integer quantity;
        public double amount;
        public String expectedDate;
        public String customerPoNumber;
        public String remarks;
        public String plant;
    }

}