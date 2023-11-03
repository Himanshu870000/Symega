public class ReturnTriggerHandler {
    static ReturnTriggerHandler handlerInstance;
    public static ReturnTriggerHandler getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new ReturnTriggerHandler();
        return handlerInstance;
    }

    public void onBeforeInsert(List<Return__c> returnList) {
        system.debug('Return List:: ' + returnList);
        set<Id> lineItemIdSet = new set<Id>();   
        set<Id> saleOrderIdSet = new set<Id>();   
        for(Return__c newReturn : returnList) {
            saleOrderIdSet.add(newReturn.Sale_Order__c);
            lineItemIdSet.add(newReturn.Opportunity_Product__c);
        }
        
        list<Sales_Order__c> IsReturnCreatedList = new list<Sales_Order__c>();
        Map<Id, Sales_Order__c> saleOrderMap = new Map<Id, Sales_Order__c>([SELECT Id, Name, Return_created__c FROM Sales_Order__c WHERE Id IN:saleOrderIdSet]);
        for(Sales_Order__c SO_Rec : saleOrderMap.values()){
            system.debug('SO_Rec.Return_created__c:: ' + SO_Rec.Return_created__c);
            SO_Rec.Return_created__c = True;
            system.debug('SO_Rec.Return_created__c:: ' + SO_Rec.Return_created__c);
            IsReturnCreatedList.add(SO_Rec);
        }
        
        update IsReturnCreatedList;
        
        system.debug('lineItemIdSet:: ' + lineItemIdSet);
        Map<Id, OpportunityLineItem> lineItemMap = new Map<Id, OpportunityLineItem>([SELECT Id, Name, Quantity FROM OpportunityLineItem WHERE Id IN:lineItemIdSet]);
        
        List<Return__c> oldReturnList = [SELECT Id, Name, Quantity__c, Opportunity_Product__c FROM Return__c WHERE Opportunity_Product__c IN:lineItemIdSet];
        
        Decimal getTotalReturnsQty = 0;
        for(Return__c newReturn : oldReturnList){
            getTotalReturnsQty += newReturn.Quantity__c;
        }
        system.debug('getTotalReturnsQty :: ' + getTotalReturnsQty);
                
        for(Return__c newReturn : returnList) {
            if(getTotalReturnsQty != NULL && getTotalReturnsQty > lineItemMap.get(newReturn.Opportunity_Product__c).Quantity){
                newReturn.addError(Constants.QTY_ERROR);
            }
        }        
    }
    
    public void onAfterUpdate(List<Return__c> returnList, Map<id, Return__c> oldReturnMap) {
        system.debug('Return List:: ' + returnList);
        set<Id> lineItemIdSet = new set<Id>();        
        for(Return__c newReturn : returnList) {
            lineItemIdSet.add(newReturn.Opportunity_Product__c);
        }
        
        system.debug('lineItemIdSet:: ' + lineItemIdSet);
        Map<Id, OpportunityLineItem> lineItemMap = new Map<Id, OpportunityLineItem>([SELECT Id, Name, Quantity FROM OpportunityLineItem WHERE Id IN:lineItemIdSet]);
        
        List<Return__c> oldReturnList = [SELECT Id, Name, Quantity__c, Opportunity_Product__c FROM Return__c WHERE Opportunity_Product__c IN:lineItemIdSet];
        
        Decimal getTotalReturnsQty = 0;
        for(Return__c newReturn : oldReturnList){
            getTotalReturnsQty += newReturn.Quantity__c;
        }
        system.debug('getTotalReturnsQty :: ' + getTotalReturnsQty);
        
        for(Return__c newReturn : returnList) {
            if(oldReturnMap.containsKey(newReturn.Id) && newReturn.Quantity__c != oldReturnMap.get(newReturn.Id).Quantity__c  && getTotalReturnsQty > lineItemMap.get(newReturn.Opportunity_Product__c).Quantity){
                newReturn.addError(Constants.QTY_ERROR);
            }
        }
        
    }
}