/*
* Author: DeaGle
* https://www.youtube.com/watch?v=IpkrTUBuvVs
*/

public class RepeatOrderProcessorQueueable implements Queueable {
    
    Map<String, SAP_SO_Creation_Wrapper.SOWrapper> postedORdersMap = new Map<String, SAP_SO_Creation_Wrapper.SOWrapper>();
    SAP_SO_Creation_Wrapper.SOWrapper currentOrder;
    SAP_SaleOrderCreationRestHandler soCreationHandler;
    public RepeatOrderProcessorQueueable(Map<String, SAP_SO_Creation_Wrapper.SOWrapper> postedORdersMap, SAP_SO_Creation_Wrapper.SOWrapper currentOrder) {
        this.postedORdersMap = postedORdersMap;
        this.currentOrder = currentOrder;
        this.soCreationHandler = SAP_SaleOrderCreationRestHandler.getInstance();
    }
    
    public void execute(QueueableContext context) {
        processOrder(currentOrder);
    }

    //mainMethod
    private void processOrder(SAP_SO_Creation_Wrapper.SOWrapper currentOrder) {
        Savepoint sp;
        try {
            Map<String, List<SAP_SO_Creation_Wrapper.cls_products>> fertWiseSAPProductsMap = new Map<String, List<SAP_SO_Creation_Wrapper.cls_products>>();

            Set<String> fertSet = new Set<String>();
            for(SAP_SO_Creation_Wrapper.cls_products sapProd : currentOrder.PRODUCTS) {
                fertSet.add(sapProd.PRODUCT_CODE);
                if(fertWiseSAPProductsMap.containsKey(sapProd.PRODUCT_CODE)) {
                    fertWiseSAPProductsMap.get(sapProd.PRODUCT_CODE).add(sapProd);
                }else {
                    fertWiseSAPProductsMap.put(sapProd.PRODUCT_CODE, new List<SAP_SO_Creation_Wrapper.cls_products> {sapProd});
                }
            } 

            Map<Id, Opportunity> oppMap = soCreationHandler.getOpenOpportunityByCustomer(currentOrder.CUSTOMER_CODE);
            Map<Id,Integer> oppMatchingProductsCountMap = new Map<Id, Integer>();
            Opportunity matchingOpportunity;
            Map<Id, Map<String, OpportunityLineItem>> matchingoppLineMap = new Map<Id, Map<String, OpportunityLineItem>>();
            Map<String,Account> customerMap = soCreationHandler.getCustomerMap(new Set<String> {currentOrder.CUSTOMER_CODE});
            Map<String, OpportunityLineItem> fertProductMap = soCreationHandler.getRequestedProducts(fertSet, currentOrder.CUSTOMER_CODE);

            for(Opportunity opp : oppMap.values()) {
                //line items map
                for(OpportunityLineItem lineItem: opp.OpportunityLineItems) {
                    //existing opp products matching 
                    if(fertWiseSAPProductsMap.containsKey(lineItem.FERT_Code__c) && oppMatchingProductsCountMap.containsKey(opp.Id)) { //count++ in case of two ferts to same line item
                        //TODO: looks good, but debug once.
                        Integer matchCount = oppMatchingProductsCountMap.get(opp.Id);
                        matchCount++;
                        oppMatchingProductsCountMap.put(opp.Id, matchCount);
                    } else {
                        oppMatchingProductsCountMap.put(opp.Id, 1);
                    }

                    if(!matchingoppLineMap.containsKey(opp.Id)) {
                        matchingoppLineMap.put(opp.Id, new Map<String, OpportunityLineItem> {lineItem.FERT_Code__c => lineItem});
                    }else {
                        matchingoppLineMap.get(opp.Id).put(lineItem.FERT_Code__c, lineItem);
                    }
                    
                }
            }

            Integer highestLinMatchingOppCount = 0;
            for(Id oppId: oppMatchingProductsCountMap.keySet()) {
                if(highestLinMatchingOppCount < oppMatchingProductsCountMap.get(oppId)) {
                    matchingOpportunity = oppMap.get(oppId);
                    matchingOpportunity.Repeat_Order_Created__c = true;
                }else {
                    matchingOpportunity = null; //Sometimes, resetting is important! ;)
                }
            }
            sp = Database.setSavepoint();

            if(matchingOpportunity == null) {
                matchingOpportunity = soCreationHandler.createOpp(customerMap.get(currentOrder.CUSTOMER_CODE), 'Closed Won');
                matchingOpportunity.Repeat_Order_Created__c = true;
                matchingOpportunity.Annual_Volume_Full__c = 1;
                matchingOpportunity.Annual_Volume_in_units__c = 'Kg';
                matchingOpportunity.Target_Price_Kg__c = 1;
                matchingOpportunity.End_Use_Category__c = 'Baked Goods';
                matchingOpportunity.End_Use_Application__c = 'Crackers';
                insert matchingOpportunity;
            }else {
                matchingOpportunity.StageName = 'Closed Won';
                update matchingOpportunity;
            }
            
            
            System.debug('--- matchingOpportunity'+ matchingOpportunity);
            
            //process products

            Sales_Order__c sOrder = soCreationHandler.createSO(customerMap.get(currentOrder.CUSTOMER_CODE), currentOrder.REF_CODE);
            sOrder.SAP_Reference_Code__c = currentOrder.REF_CODE;
            sOrder.Customer_PO_Ref_no__c = currentOrder.CUSTOMER_PO_REF_NO;
            sOrder.Expected_Delivery_Date__c = Date.valueOf(currentOrder.EXPECTED_DELIVERY_DATE);
            sOrder.Remarks__c = currentOrder.REMARKS;
            sOrder.Order_quantity__c = currentOrder.GROSS_WEIGHT;
            sOrder.Opportunity__c = matchingOpportunity.Id;
            sOrder.Created_From_SAP__c = true;
            sOrder.Amount__c = 0; // update below

            insert sOrder;
            System.debug('--- sOrder'+ sOrder);

            

            List<OpportunityLineItem> oppProductListToUpsert = new List<OpportunityLineItem>();
            List<OpportunityLineItem> opToCloneIntoNewOpp = new List<OpportunityLineItem>();
            List<OpportunityLineItem> lineItemsToBeDeleted = new List<OpportunityLineItem>();
            //process opp product
            for(SAP_SO_Creation_Wrapper.cls_products prod : currentOrder.PRODUCTS) {
                System.debug('--- processing '+ prod);
                OpportunityLineItem oppLineItemToUpsert;
                
                if(matchingoppLineMap.containsKey(matchingOpportunity.Id) && matchingoppLineMap.get(matchingOpportunity.Id).containsKey(prod.PRODUCT_CODE)) {
                    system.debug('--- opp prod found'+prod);
                    OpportunityLineItem lineItemToBeDeleted = matchingoppLineMap.get(matchingOpportunity.Id).get(prod.PRODUCT_CODE);
                    oppLineItemToUpsert = lineItemToBeDeleted.clone(false, false, false, false);
                    //add to delete list;
                    System.debug('--- adding cloned line to be delted: '+lineItemToBeDeleted);
                    System.debug('--- adding cloned line to be delted Id: '+lineItemToBeDeleted.Id);
                    lineItemsToBeDeleted.add(lineItemToBeDeleted);
                    matchingoppLineMap.get(matchingOpportunity.Id).remove(prod.PRODUCT_CODE);
                    
                    if(fertProductMap.containsKey(prod.PRODUCT_CODE)){ //always true since we are checking entry level condition
                        OpportunityLineItem oliFERTPRice = fertProductMap.get(prod.PRODUCT_CODE);
                        System.debug('--- existing fert price'+ oliFERTPRice);
                        if(!String.isBlank(oliFERTPRice.Quantity_Unit__c) && !oliFERTPRice.Quantity_Unit__c.equalsIgnoreCase(prod.QUANTITY_UNIT)) {
                            oppLineItemToUpsert.UnitPrice = convertAmountIntoReqUnitBySAP(oliFERTPRice.UnitPrice, oliFERTPRice.Quantity_Unit__c.toLowerCase(), prod.QUANTITY_UNIT.toLowerCase());
                        } else{
                            oppLineItemToUpsert.UnitPrice = oliFERTPRice.UnitPrice;
                        }
                    }else {
                        oppLineItemToUpsert.UnitPrice = 0; //Ideally this statement should never execute, but you never TRUST external system. ESP SYMEGA SAP.
                    }

                    
                    String originalQuantityUnit = '';

                    if(oppLineItemToUpsert.Quantity_Unit__c != null && !oppLineItemToUpsert.Quantity_Unit__c.equalsIgnoreCase(prod.QUANTITY_UNIT)) {
                        originalQuantityUnit = oppLineItemToUpsert.Quantity_Unit__c;
                        oppLineItemToUpsert.Quantity = convertQuantityIntoReqUnitBySAP(oppLineItemToUpsert.Quantity, oppLineItemToUpsert.Quantity_Unit__c.toLowerCase(), prod.QUANTITY_UNIT.toLowerCase());
                    }
                    oppLineItemToUpsert.Quantity_Unit__c = prod.QUANTITY_UNIT; //overriding quantity unit, ideally this should be converted and then matched with so quantity.
                    //Quantity Split
                    if(oppLineItemToUpsert.Quantity > prod.QUANTITY) {
                        Decimal remainingQty = oppLineItemToUpsert.Quantity - prod.QUANTITY;

                        OpportunityLineItem qtySplitLineItem = oppLineItemToUpsert.clone(false, false, false, false);
                        qtySplitLineItem.Quantity = convertQuantityIntoReqUnitBySAP(remainingQty, prod.QUANTITY_UNIT.toLowerCase(), originalQuantityUnit.toLowerCase());
                        qtySplitLineItem.Repeat_Order_Details__c = Constants.PRODUCT_QTY_OF_MESSAGE;

                        oppLineItemToUpsert.Repeat_Order_Details__c = remainingQty + Constants.PRODUCT_MOVED_MESSAGE;
                        System.debug('--- quantity cloned line item'+qtySplitLineItem);
                        opToCloneIntoNewOpp.add(qtySplitLineItem); //add quantity overflow split product.

                    }else if(oppLineItemToUpsert.Quantity < prod.QUANTITY) {
                        oppLineItemToUpsert.Repeat_Order_Details__c = Constants.PRODUCT_QTY_ALTERED_MESSAGE + oppLineItemToUpsert.Quantity;
                        oppLineItemToUpsert.Quantity = prod.QUANTITY;
                    }
                    populateCommonFields(sOrder, fertProductMap, matchingOpportunity, oppLineItemToUpsert, prod);
                    
                    system.debug('--- used product'+ matchingoppLineMap.get(matchingOpportunity.Id).remove(prod.PRODUCT_CODE));
                }else {
                    oppLineItemToUpsert = new OpportunityLineItem(OpportunityId = matchingOpportunity.Id);

                    if(fertProductMap.containsKey(prod.PRODUCT_CODE)) {
                        OpportunityLineItem oliFERTPRice = fertProductMap.get(prod.PRODUCT_CODE);
                        oppLineItemToUpsert.PricebookEntryId = oliFERTPRice.PricebookEntryId;

                        if(!String.isBlank(oliFERTPRice.Quantity_Unit__c) && !oliFERTPRice.Quantity_Unit__c.equalsIgnoreCase(prod.QUANTITY_UNIT)) {
                            oppLineItemToUpsert.UnitPrice = convertAmountIntoReqUnitBySAP(oliFERTPRice.UnitPrice, oliFERTPRice.Quantity_Unit__c.toLowerCase(), prod.QUANTITY_UNIT.toLowerCase());
                        } else{
                            oppLineItemToUpsert.UnitPrice = oliFERTPRice.UnitPrice;
                        }
                        oppLineItemToUpsert.FERT_Code__c = fertProductMap.get(prod.PRODUCT_CODE).FERT_Code__c;
                    }
                    oppLineItemToUpsert.Quantity = prod.QUANTITY;
                    oppLineItemToUpsert.Quantity_Unit__c = prod.QUANTITY_UNIT;
                    populateCommonFields(sOrder, fertProductMap, matchingOpportunity, oppLineItemToUpsert, prod);
                }

                oppProductListToUpsert.add(oppLineItemToUpsert);
            }
            
            //clone to new opp:
            System.debug('matching opp line count ---'+ (matchingoppLineMap.containsKey(matchingOpportunity.Id) ? String.valueOf(matchingoppLineMap.get(matchingOpportunity.Id).size()) : ''));
            if(matchingoppLineMap.containsKey(matchingOpportunity.Id) && matchingoppLineMap.get(matchingOpportunity.Id).size() > 0) {
                //TODO: create and clone these products into new opp and delete from here.
                Opportunity clonedOpp = soCreationHandler.createOpp(customerMap.get(currentOrder.CUSTOMER_CODE), 'New');
                insert clonedOpp;
                System.debug('--- created opp clone, now tag products'+clonedOpp);
                for(OpportunityLineItem oli: matchingoppLineMap.get(matchingOpportunity.Id).values()) {
                    OpportunityLineItem clonedOli = oli.clone(false, false, false, false);
                    clonedOli.OpportunityId = clonedOpp.Id;
                    clonedOli.Repeat_Order_Details__c = 'This product is tagged from previous opportunity which was altered while repeat order creation, since this product was addition product in found existing opportunity, this has been moved to new opportunity.';
                    lineItemsToBeDeleted.add(oli);
                }
                for(OpportunityLineItem oli : opToCloneIntoNewOpp) {
                    oli.OpportunityId = clonedOpp.Id;
                    oppProductListToUpsert.add(oli);
                }
                
            }
            //address processing
            if(currentOrder.SHIPPING_ADDRESS != null && /* !currentOrder.SHIPPING_ADDRESS.size() > 0 && */ customerMap.containsKey(currentOrder.CUSTOMER_CODE)) {
                soCreationHandler.updateCustomerAddress(currentOrder.SHIPPING_ADDRESS, customerMap.get(currentOrder.CUSTOMER_CODE).Id);
            }
            System.debug('--- matching opp: '+matchingOpportunity);
            // DML's
            if(!oppProductListToUpsert.isEmpty()){
                update sOrder;
                upsert oppProductListToUpsert;
                System.debug('--- oppProductListToUpsert:'+oppProductListToUpsert);
                System.debug('--- updated Order:'+sOrder);
            }
            if(!lineItemsToBeDeleted.isEmpty()) {
                System.debug('--- lineItemsToBeDeleted:'+lineItemsToBeDeleted);
                delete lineItemsToBeDeleted;
            }

        }catch(Exception e) {
            Database.rollback(sp);
            System.debug('--- e.getMessage'+ e.getMessage());
            System.debug('--- e.getLineNumber'+ e.getLineNumber());
            HandleBusinessException.captureError('RepeatOrderProcessorQueueable', 'processOrder', e);
        }finally{

            if(postedORdersMap.containsKey(currentOrder.REF_CODE))
                postedORdersMap.remove(currentOrder.REF_CODE);
            
            //CHAIN THE JOB!
            if(!postedORdersMap.isEmpty()) {
                ID jobID = System.enqueueJob(new RepeatOrderProcessorQueueable(postedORdersMap, postedORdersMap.values()[0]));
                System.debug('--- jobID'+ jobID);
            }
        }

    }

    private void populateCommonFields(Sales_Order__c sOrder, Map<String, OpportunityLineItem> fertProductMap, Opportunity matchingOpportunity, OpportunityLineItem oppLineItemToUpsert, SAP_SO_Creation_Wrapper.cls_products prod) {
        
        sOrder.Amount__c = sOrder.Amount__c + (oppLineItemToUpsert.Quantity * oppLineItemToUpsert.UnitPrice);
        oppLineItemToUpsert.Plant__c = prod.PLANT;
        oppLineItemToUpsert.Sales_Order__c = sOrder.Id;
        
        if(oppLineItemToUpsert.OpportunityId == null)
            oppLineItemToUpsert.OpportunityId = matchingOpportunity.Id;

        if(!String.isBlank(prod.PLANNED_DELIVERY_DATE)){
            oppLineItemToUpsert.Planned_Delivery_Date__c = parseDate(prod.PLANNED_DELIVERY_DATE);
        }

        if(!String.isBlank(prod.SERVICE_RENDERING_DATE)){
            oppLineItemToUpsert.Service_Rendering_Date__c = parseDate(prod.SERVICE_RENDERING_DATE);
        }

        if(!String.isBlank(prod.SERVICE_RENDERING_DATE_REASON)){
            oppLineItemToUpsert.Service_Rendering_Date_Reason__c = prod.SERVICE_RENDERING_DATE_REASON;
        }
        
    }


    private static Date parseDate(String d){
        String[] dSplit = d.split('-');
        String cDate = dSplit[1]+'/'+dSplit[2]+'/'+dSplit[0];
        return Date.parse(cDate);
    }

    //price conversion
    private static Decimal convertAmountIntoReqUnitBySAP(Decimal currentAmount, String currentUnit, String convertUnitInto){
        switch on convertUnitInto {
            when 'kg' {
                return convertAmountToKg(currentAmount,currentUnit);
            }
            when 'gm' {
                return convertAmountToGm(currentAmount,currentUnit);
            }
            when 'liter' {
                return convertAmountToLiter(currentAmount,currentUnit);
            }
            when 'ml' {
                return convertAmountToML(currentAmount,currentUnit);
            }
            when else {
                return convertAmountToTonne(currentAmount,currentUnit);
            }
        }
    }

    private static Decimal convertAmountToKg(Decimal currentAmount,String currentUnit){
        switch on currentUnit {
            when 'kg' {
                return currentAmount;
            }
            when 'gm' {
                return currentAmount * 1000;
            }
            when 'liter' {
                return currentAmount;
            }
            when 'ml' {
                return currentAmount * 1000000;
            }
            when else {
                return currentAmount;
            }
        }
    }

    private static Decimal convertAmountToGm(Decimal currentAmount,String currentUnit){
        switch on currentUnit {
            when 'kg' {
                return currentAmount / 1000;
            }
            when 'gm' {
                return currentAmount;
            }
            when 'liter' {
                return currentAmount / 1000;
            }
            when 'ml' {
                return currentAmount * 1000;
            }
            when else {
                return currentAmount;
            }
        }
    }

    private static Decimal convertAmountToLiter(Decimal currentAmount,String currentUnit){
        switch on currentUnit {
            when 'kg' {
                return currentAmount;
            }
            when 'gm' {
                return currentAmount * 1000;
            }
            when 'liter' {
                return currentAmount;
            }
            when 'ml' {
                return currentAmount * 1000000;
            }
            when else {
                return currentAmount;
            }
        }
    }

    private static Decimal convertAmountToML(Decimal currentAmount,String currentUnit){
        //convert into ML;
        switch on currentUnit {
            when 'kg' {
                return currentAmount * 1000000;
            }
            when 'gm' {
                return currentAmount * 1000;
            }
            when 'liter' {
                return currentAmount * 1000000;
            }
            when 'ml' {
                return currentAmount;
            }
            when else {
                return currentAmount * 1000000;
            }
        }
    }

    private static Decimal convertAmountToTonne(Decimal currentAmount,String currentUnit){
        //convert into tonne;
        switch on currentUnit {
            when 'kg' {
                return currentAmount * 1000;
            }
            when 'gm' {
                return currentAmount * 1000000;
            }
            when 'liter' {
                return currentAmount * 1000;
            }
            when 'ml' {
                return currentAmount * 1000000000;
            }
            when else {
                return currentAmount;
            }
        }
    }


    //unit conversion
    private static Decimal convertQuantityIntoReqUnitBySAP(Decimal quantity, String currentUnit, String convertUnitInto){
        switch on convertUnitInto {
            when 'kg' {
                return convertUnitToKg(quantity,currentUnit);
            }
            when 'gm' {
                return convertUnitToGm(quantity,currentUnit);
            }
            when 'liter' {
                return convertUnitToLiter(quantity,currentUnit);
            }
            when 'ml' {
                return convertUnitToML(quantity,currentUnit);
            }
            when else {
                return convertUnitToTonne(quantity,currentUnit);
            }
        }
    }

    private static Decimal convertUnitToKg(Decimal quantity,String currentUnit){
        switch on currentUnit {
            when 'kg' {
                return quantity;
            }
            when 'gm' {
                return quantity / 1000;
            }
            when 'liter' {
                return quantity;
            }
            when 'ml' {
                return quantity / 1000000;
            }
            when else {
                return quantity;
            }
        }
    }

    private static Decimal convertUnitToGm(Decimal quantity,String currentUnit){
        switch on currentUnit {
            when 'kg' {
                return quantity * 1000;
            }
            when 'gm' {
                return quantity;
            }
            when 'liter' {
                return quantity * 1000;
            }
            when 'ml' {
                return quantity / 1000;
            }
            when else {
                return quantity;
            }
        }
    }

    private static Decimal convertUnitToLiter(Decimal quantity,String currentUnit){
        switch on currentUnit {
            when 'kg' {
                return quantity;
            }
            when 'gm' {
                return quantity / 1000;
            }
            when 'liter' {
                return quantity;
            }
            when 'ml' {
                return quantity / 1000000;
            }
            when else {
                return quantity;
            }
        }
    }

    private static Decimal convertUnitToML(Decimal quantity,String currentUnit){
        //convert into ML;
        switch on currentUnit {
            when 'kg' {
                return quantity / 1000000;
            }
            when 'gm' {
                return quantity / 1000;
            }
            when 'liter' {
                return quantity / 1000000;
            }
            when 'ml' {
                return quantity;
            }
            when else {
                return quantity / 1000000;
            }
        }
    }

    private static Decimal convertUnitToTonne(Decimal quantity,String currentUnit){
        //convert into tonne;
        switch on currentUnit {
            when 'kg' {
                return quantity / 1000;
            }
            when 'gm' {
                return quantity / 1000000;
            }
            when 'liter' {
                return quantity / 1000;
            }
            when 'ml' {
                return quantity / 1000000000;
            }
            when else {
                return quantity;
            }
        }
    }

    public static String initiateQueueable(Map<String, SAP_SO_Creation_Wrapper.SOWrapper> postedORdersMap) {

        ID jobID = System.enqueueJob(new RepeatOrderProcessorQueueable(postedORdersMap, postedORdersMap.values()[0]));
        System.debug('--- jobID'+ jobID);
        return jobID;
    }
}