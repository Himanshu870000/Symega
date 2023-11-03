global class OrderManagementController {
    
    public String productName{get;set;}
    public String productUnitPrice{get;set;}
    public string accId{get;set;}
    public string visitId{get;set;}
    
    global OrderManagementController() {
        accId = apexpages.currentpage().getparameters().get('id');
        visitId = apexpages.currentpage().getparameters().get('vistId');
    }
    @RemoteAction
    global static string insertOrderItemS(List<orderItemWrapp> orderItemList,String accId){
        system.debug('orderList'+orderItemList);
        List<OrderItem> orderItemListToBeInsert = new List<OrderItem>();
        String orderNumber = '';
        pricebook2 stdPriceBook    = [select id, name from Pricebook2 where isStandard = true limit 1];
        
        try{
            if(stdPriceBook != null && !orderItemList.isEmpty()){
                order newOrder = new order();
                newOrder.AccountId = accId;
                newOrder.EffectiveDate = system.today();
                newOrder.Status = 'Draft';
                newOrder.Pricebook2Id = stdPriceBook.id;
                INSERT newOrder;
                for(orderItemWrapp orderRec : orderItemList){
                    Orderitem newOrderItem = new Orderitem();
                    newOrderItem.OrderId = newOrder.Id;
                    newOrderItem.Product2Id = orderRec.Product2Id;
                    newOrderItem.pricebookentryId = orderRec.id;//orderRec.Id;
                    newOrderItem.Quantity = orderRec.quant;
                    newOrderItem.UnitPrice = orderRec.unitPrice;
                    newOrderItem.ListPrice = orderRec.unitPrice;
                    orderItemListToBeInsert.add(newOrderItem);
                }
                if(!orderItemListToBeInsert.isEmpty()){
                    INSERT orderItemListToBeInsert;
                }
                orderNumber = [SELECT id,OrderNumber FROM order WHERE id =: newOrder.Id].OrderNumber;
            }
            if(orderNumber != '')
                return orderNumber;
            else 
                return 'Something went wrong. Please contact to your admin.';
        }
        catch(exception ex){
            System.debug('Exception trace::'+ex.getStackTraceString());
            return 'fail';
        }
    }
    @RemoteAction
    global static List<PricebookEntry> products(String id)
    { 
        Pricebook2 priceBook=[select Id from Pricebook2];
        List<PricebookEntry> productdetail = [Select Id,Name,UnitPrice,Product2Id,Pricebook2Id  FROM PricebookEntry where Pricebook2Id=:priceBook.Id AND Pricebook2.isStandard = true];
        system.debug('productdetail'+productdetail);
        return productdetail;       
    }
    @RemoteAction
    global Static List<PricebookEntry> pricebookEntry(List<STring> idList){
        List<PricebookEntry> productdetail = [Select Id,Name,UnitPrice,Product2Id,Pricebook2Id  FROM PricebookEntry where Product2Id in : idList AND Pricebook2.isStandard = true];
        system.debug('productdetail'+productdetail);
        return productdetail;
    }
    
    @RemoteAction
    global static String insertOpportunityitem(List<opportunityItemWrapper> opportunityWrapperList)
    {	
        try{
            List<OpportunityLineItem> oli = new List<OpportunityLineItem>();
            //List<Opportunity> opplist = new List<Opportunity>();
            
            for(opportunityItemWrapper opp:opportunityWrapperList){
                
                OpportunityLineItem oppLineItem = 		new OpportunityLineItem();
                oppLineItem.OpportunityId 		= 		'0065g000002lOp8';
                oppLineItem.PricebookEntryId	= 		opp.Id;
                oppLineItem.Quantity			= 		opp.quant;
                oppLineItem.UnitPrice			=       opp.UnitPrice;
                //oppLineItem.Name				=		opp.Name;
                //insert oppLineItem;
                oli.add(oppLineItem);
                System.debug('OpportunityLineItem'+oppLineItem.Id);    
                //opplist.add(New Opportunity(Name=opp.Name,TotalOpportunityQuantity=opp.quant,StageName=opp.StageName,Amount=opp.UnitPrice,CloseDate=opp.CloseDate));
            }
            insert oli;
            System.debug('oli==>'+oli);
            return 'oli';
            //insert opplist;
            //System.debug('opplist'+opplist);
            //return 'opplist';
            
        }
        catch(exception e){
            system.debug('error==='+e.getLineNumber()+ 'error====='+e.getMessage());
            return 'error==='+e.getLineNumber()+ 'error====='+e.getMessage();
        }
    }
    
    @RemoteAction
    global static String insertOpportunity(String Id)
    {
        OpportunityWrapper oppwrap = new OpportunityWrapper();
        Opportunity opp = new Opportunity();
        
        opp.CloseDate	=	oppwrap.closeDate;
        opp.Name		=	oppwrap.name;
        opp.StageName	=	oppwrap.stageName;
        
        return 'Success';
    }
    
    global class opportunityItemWrapper{
        String Id;
        Integer quant;
        Decimal UnitPrice;
        String Name;
        
    }
    global class OpportunityWrapper {
        String name= 'Newly-Created';
        String stageName='Prospecting';
        Date closeDate=System.today();
    }
    global class orderItemWrapp{
        string Product2Id;
        Integer quant;
        integer unitPrice;
        String Id;
        String Name;
        String Pricebook2Id;
    }    
}