/**
* Author: DeaGle
* Edits: v1.1, added product visibility validations.
*/
public without sharing class OpportunityLineItemTriggerHandler {
    static final String OPP_PARENT_RECORD_TYPE = 'Parent';
    private OpportunityLineItemTriggerHandler() {}
    public static OpportunityLineItemTriggerHandler handlerInstance;
    
    public static OpportunityLineItemTriggerHandler getInstance() {
        if(handlerInstance == null)
            handlerInstance = new OpportunityLineItemTriggerHandler();
        return handlerInstance;
    }
    
    public void onAfterInsert(List<OpportunityLineItem> lineItemList) {
        System.debug('--- lineItemList '+lineItemList);
        //FERT variables
        Map<Id,Id> opTooppMap = new Map<Id,Id>();
        Set<Id> productIdSet = new Set<Id>();
        List<OpportunityLineItem> fertCloneOppList = new List<OpportunityLineItem>();
        for(OpportunityLineItem lineItem : lineItemList) {
            if(lineItem.Is_Parent_Opportunity__c) {
                //FERT
                opTooppMap.put(lineItem.Id, lineItem.OpportunityId);
                productIdSet.add(lineItem.Product2Id);
            }else if(lineItem.Is_Parent_Opportunity__c){
                fertCloneOppList.add(new OpportunityLineItem(Id = lineItem.Id, FERT_Code__c = lineItem.ProductCode));
            }
        }

        if(!opTooppMap.isEmpty()) {
            checkAndUpdateFERT(opTooppMap, lineItemList, productIdSet);
        }

        if(!fertCloneOppList.isEmpty()) {
            try{
                Database.update(fertCloneOppList, false);
            }catch(DmlException e){
                System.debug('--- getMessage '+e.getMessage());
                System.debug('--- getLineNo '+e.getLineNumber());
                HandleBusinessException.captureError('OpportunityLineItemTriggerHandler', 'onAfterInsert', e);
            }
        }
    }

    public void onBeforeInsert(List<OpportunityLineItem> lineItemList) {
        Set<Id> parentOppIdSet = new Set<Id>();
        Map<Id,Set<String>> oppToLinePackageSetMap = new Map<Id,Set<String>>();
        List<OpportunityLineItem> markUpAmountList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> markDownAmountList = new List<OpportunityLineItem>();
        Set<Id> productIdSet = new Set<Id>();
        Set<String> requiredCurrencyCodeSet = new Set<String>();
        List<OpportunityLineItem> parentLineItemsList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> updatePricePerUnitList = new List<OpportunityLineItem>();
        
        //Map<Id, List<OpportunityLineItem>> productCode2OliMap = new Map<Id, List<OpportunityLineItem>>(); //v1.1 product visibility enhancement.
        Set<Id> customerIdSet = new Set<Id>();
        for(OpportunityLineItem lineItem : lineItemList) {
            System.debug('--- isParentOpportunity '+lineItem.Is_Parent_Opportunity__c);
            if(lineItem.Is_Parent_Opportunity__c) {
                parentOppIdSet.add(lineItem.OpportunityId);
                if(oppToLinePackageSetMap.containsKey(lineItem.OpportunityId) && !oppToLinePackageSetMap.get(lineItem.OpportunityId).contains(lineItem.Packaging_Type__c)) {
                    lineItem.addError(Constants.LINE_ITEM_PACKAGING_TYPE_RESTRICTION_ERR_MSG);
                }
                else {
                    oppToLinePackageSetMap.put(lineItem.OpportunityId, new Set<String>{ lineItem.Packaging_Type__c });
                }
                
                productIdSet.add(lineItem.Product2Id);
                requiredCurrencyCodeSet.add(lineItem.CurrencyIsoCode);
                
                if(lineItem.UnitPrice != null && lineItem.Markup_Amount__c != null) {
                    markUpAmountList.add(lineItem);
                    updatePricePerUnitList.add(lineItem);
                }else if(lineItem.UnitPrice != null && lineItem.MarkDown_Amount__c != null) {
                    markDownAmountList.add(lineItem);
                    updatePricePerUnitList.add(lineItem);
                }else {
                    System.debug('line item price before conversion'+lineItem.UnitPrice);
                    lineItem.UnitPrice = this.unitConversionHelper(lineItem.UnitPrice, lineItem.Quantity_Unit__c); //UnitPrice conversion
                    System.debug('line item price after conversion'+lineItem.UnitPrice);
                }
                parentLineItemsList.add(lineItem);

                //v1.1
                System.debug('--- productCode' +lineItem.Product2Id);
                /* if(productCode2OliMap.containsKey(lineItem.Product2Id)) {
                    productCode2OliMap.get(lineItem.Product2Id).add(lineItem);
                }else {
                    productCode2OliMap.put(lineItem.Product2Id, new List<OpportunityLineItem> { lineItem });
                } */
                customerIdSet.add(lineItem.Customer_SF_Id__c);
            }
        }
        
        if(!parentOppIdSet.isEmpty()) {
            checkProdCreationAcceptanceCriteria(lineItemList, productIdSet, customerIdSet); //v1.1 product visibility validation
            validatePackageType(lineItemList, parentOppIdSet, null);
            restrictLineItemCreationOrUpdation(lineItemList, parentOppIdSet);
        }

        if(!markUpAmountList.isEmpty()) {
            salesPriceMarkUpCalculator(markUpAmountList);
        }
        if(!markDownAmountList.isEmpty()) {
            salesPriceMarkDownCalculator(markDownAmountList, getStandardPrice(productIdSet, requiredCurrencyCodeSet));
        }

        for(OpportunityLineItem oli: updatePricePerUnitList) {
            System.debug('line item price before conversion'+oli.UnitPrice);
            oli.UnitPrice = this.unitConversionHelper(oli.UnitPrice, oli.Quantity_Unit__c); //UnitPrice conversion
            System.debug('line item price after conversion'+oli.UnitPrice);
        }

        if(!parentLineItemsList.isEmpty()) {
            //VolumeBasedDiscountCalculation.getInstance().calculateVolumeBasedDiscount(lineItemList,false); //TODO: uncomment, once changes are made w.r.t LISTPRICE from UNITPRICE
        }

        
    }

    public void validatePackageType(List<OpportunityLineItem> lineItemList, Set<Id> parentOppIdSet, Set<Id> lineItemIdSet) {
        
        List<OpportunityLineItem> oppLineItemList;
        
        if(lineItemIdSet == null)
            oppLineItemList = [SELECT Id, Packaging_Type__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId In :parentOppIdSet AND Packaging_Type__c != NULL];
        else
            oppLineItemList = [SELECT Id, Packaging_Type__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId In :parentOppIdSet AND Id NOT IN: lineItemIdSet AND Packaging_Type__c != NULL];
        
        system.debug('oppLineItemList:: '+oppLineItemList);
        
        if(!oppLineItemList.isEmpty()) {
            for(OpportunityLineItem oppItem : lineItemList){
                if(String.isBlank(oppItem.Packaging_Type__c) || oppItem.Packaging_Type__c != oppLineItemList[0].Packaging_Type__c){
                    oppItem.addError(Constants.LINE_ITEM_PACKAGING_TYPE_RESTRICTION_ERR_MSG);
                }
            }                       
        }  
    }

    public void restrictLineItemCreationOrUpdation(List<OpportunityLineItem> oppLineItemList, Set<Id> parentOppIdSet) {
        List<Opportunity> oneTimeOppList = [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c IN:parentOppIdSet AND Parent_Opportunity__r.RecordType.DeveloperName = :OPP_PARENT_RECORD_TYPE];
        Set<Id> parentOppIdToRestrict = new Set<Id>();
        for(Opportunity opp: oneTimeOppList) {
            parentOppIdToRestrict.add(opp.Parent_Opportunity__c);
        }

        for(OpportunityLineItem lineItem: oppLineItemList) {
            if(parentOppIdToRestrict.contains(lineItem.OpportunityId))
                lineItem.addError(Constants.LINE_ITEM_ADDITION_RESTRICTION_ERR_MSG);
        }
    }
    
    public void onBeforeUpdate(List<OpportunityLineItem> lineItemList, Map<Id,OpportunityLineItem> oldLineItemMap) {
        System.debug('old---'+oldLineItemMap);
        System.debug('lineItemList---'+lineItemList);
        Set<Id> parentOppIdSet = new Set<Id>();
        Map<Id,Set<String>> oppToLinePackageSetMap = new Map<Id,Set<String>>();
        List<OpportunityLineItem> markUpAmountList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> markDownAmountList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> volumeBasedDiscountList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> updatePricePerUnitList = new List<OpportunityLineItem>();

        

        for(OpportunityLineItem lineItem : lineItemList) {
            if(lineItem.Is_Parent_Opportunity__c) {
                parentOppIdSet.add(lineItem.OpportunityId);
                if(oppToLinePackageSetMap.containsKey(lineItem.OpportunityId) && !oppToLinePackageSetMap.get(lineItem.OpportunityId).contains(lineItem.Packaging_Type__c)) {
                    lineItem.addError(Constants.LINE_ITEM_PACKAGING_TYPE_RESTRICTION_ERR_MSG);
                }
                else {
                    oppToLinePackageSetMap.put(lineItem.OpportunityId, new Set<String>{ lineItem.Packaging_Type__c });
                }
                if(lineItem.UnitPrice != null && lineItem.Markup_Amount__c != null && lineItem.Markup_Amount__c != oldLineItemMap.get(lineItem.Id).Markup_Amount__c) {
                    markUpAmountList.add(lineItem);
                    updatePricePerUnitList.add(lineItem);
                }else if(lineItem.UnitPrice != null && lineItem.MarkDown_Amount__c != null && lineItem.MarkDown_Amount__c != oldLineItemMap.get(lineItem.Id).MarkDown_Amount__c) {
                    markDownAmountList.add(lineItem);
                    updatePricePerUnitList.add(lineItem);
                }else if((lineItem.Quantity != null && lineItem.Quantity != oldLineItemMap.get(lineItem.Id).Quantity) || (lineItem.Quantity_Unit__c != null && lineItem.Quantity_Unit__c != oldLineItemMap.get(lineItem.Id).Quantity_Unit__c) || lineItem.Markup_Amount__c != oldLineItemMap.get(lineItem.Id).Markup_Amount__c || lineItem.Markdown_Amount__c != oldLineItemMap.get(lineItem.Id).Markdown_Amount__c) { //Price conversion 
                    System.debug('line item price before conversion'+lineItem.UnitPrice);
                    System.debug('line item price Price_In_KG__c before conversion'+lineItem.Price_In_KG__c);
                    lineItem.UnitPrice = this.unitConversionHelper(this.getKgPrice(lineItem.UnitPrice, oldLineItemMap.get(lineItem.Id).Quantity_Unit__c), lineItem.Quantity_Unit__c); //UnitPrice conversion
                    volumeBasedDiscountList.add(lineItem);
                    System.debug('line item price after conversion'+lineItem.UnitPrice);
                }
            }
        }
        
        
        if(!parentOppIdSet.isEmpty()) {
            validatePackageType(lineItemList, parentOppIdSet, oldLineItemMap.keySet());
            restrictLineItemCreationOrUpdation(lineItemList, parentOppIdSet);
        }

        if(!markUpAmountList.isEmpty()) {
            salesPriceMarkUpCalculator(markUpAmountList);
        }
        if(!markDownAmountList.isEmpty()) {
            salesPriceMarkDownCalculator(markDownAmountList, null);
        }

        for(OpportunityLineItem lineItem: updatePricePerUnitList) {
            System.debug('line item price before conversion'+lineItem.UnitPrice);
            System.debug('line item price Price_In_KG__c before conversion'+lineItem.Price_In_KG__c);
            lineItem.UnitPrice = this.unitConversionHelper(this.getKgPrice(lineItem.UnitPrice, oldLineItemMap.get(lineItem.Id).Quantity_Unit__c), lineItem.Quantity_Unit__c); //UnitPrice conversion
            volumeBasedDiscountList.add(lineItem);
            System.debug('line item price after conversion'+lineItem.UnitPrice);
        }

        if(!volumeBasedDiscountList.isEmpty()) {
            VolumeBasedDiscountCalculation.getInstance().calculateVolumeBasedDiscount(volumeBasedDiscountList,true);
        }

        //For fert API. 
        Map<String,OpportunityLineItem> fertXOliMap = new Map<String,OpportunityLineItem>(); //TODO: check this
        //For FERT SAP update
        for(OpportunityLineItem lineItem : lineItemList) {
            if(lineItem.Is_Parent_Opportunity__c) {
                if(!String.isBlank(lineItem.Fert_Code__c) && ((lineItem.UnitPrice != oldLineItemMap.get(lineItem.Id).UnitPrice) || (oldLineItemMap.get(lineItem.Id).FERT_Code__c == null))) {
                    fertXOliMap.put(lineItem.Fert_Code__c, lineItem);
                }
            }
        }
        System.debug('fertXOliMap-----'+fertXOliMap);
        if(!fertXOliMap.isEmpty()) {
            //call method here
            sapFertUpdateHelper(fertXOliMap);
        }
    }

    private void salesPriceMarkUpCalculator(List<OpportunityLineItem> markUpOLIList) {
        for(OpportunityLineItem oli : markUpOLIList) {
            oli.UnitPrice = oli.UnitPrice != null ? oli.UnitPrice + oli.Markup_Amount__c : oli.ListPrice + oli.Markup_Amount__c;
        }
    }

    private void salesPriceMarkDownCalculator(List<OpportunityLineItem> markDownOLIList, Map<Id,Map<String,Double>> productXprice) {
        for(OpportunityLineItem oli : markDownOLIList) {
            Double standardListPrice = 0;
            if(oli.ListPrice == null && productXprice.containsKey(oli.Product2Id) && productXprice.get(oli.Product2Id).containsKey(oli.CurrencyIsoCode))
                standardListPrice = productXprice.get(oli.Product2Id).get(oli.CurrencyIsoCode);
            else
                standardListPrice = oli.ListPrice;

            oli.UnitPrice = oli.UnitPrice != null ? oli.UnitPrice - oli.MarkDown_Amount__c : standardListPrice - oli.MarkDown_Amount__c;
            Double customerPriceMD = 0;
            if(oli.UnitPrice > 0 && oli.UnitPrice < standardListPrice) {
                customerPriceMD = (((standardListPrice - oli.UnitPrice)/standardListPrice) * 100);
            }
            oli.Approval_Markdown__c = customerPriceMD;
        }
    }

    private Map<Id,Map<String,Double>> getStandardPrice(Set<Id> productIdSet, Set<String> requiredCurrencyCodeSet) {
        
        Map<Id,Map<String,Double>> productToCurrencyPrice = new Map<Id,Map<String,Double>>();
        List<PricebookEntry> priceEntries = [SELECT Id, Product2Id, UnitPrice, CurrencyIsoCode FROM PricebookEntry WHERE Product2Id IN :productIdSet AND CurrencyIsoCode IN :requiredCurrencyCodeSet AND Pricebook2.IsStandard = true];
        for(PricebookEntry pbe : priceEntries) {

            if(productToCurrencyPrice.containsKey(pbe.Product2Id)) {
                productToCurrencyPrice.get(pbe.Product2Id).put(pbe.CurrencyIsoCode, pbe.UnitPrice);
            }else {
                productToCurrencyPrice.put(pbe.Product2Id, new Map<String, Double> {pbe.CurrencyIsoCode => pbe.UnitPrice});
            }
        }
        return productToCurrencyPrice;
    }

    private void checkAndUpdateFERT(Map<Id,Id> opTooppMap, List<OpportunityLineItem> oppLineList, Set<Id> productIdSet) {

        System.debug('--- oppLineList '+ oppLineList);
        System.debug('--- productIdSet '+ productIdSet);

        Map<Id,Id> oppToaccMap = new Map<Id,Id>();
        Set<Id> customerIdSet = new Set<Id>();
        List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :opTooppMap.values()];
        for(Opportunity opp : oppList){
            oppToaccMap.put(opp.Id, opp.AccountId);
            customerIdSet.add(opp.AccountId);
        }
        if(!opTooppMap.isEmpty()) {
            System.debug('--- customerIdSet'+customerIdSet);
            List<OpportunityLineItem> opplineItemList = [SELECT Id, Product2Id, Opportunity.AccountId, FERT_Code__c, Packaging_Type__c, Packaging_Unit__c, Packaging_Quantity__c FROM OpportunityLineItem WHERE Opportunity.AccountId IN : customerIdSet AND Product2Id IN : productIdSet AND FERT_Code__c != null LIMIT 50000];

            System.debug('--- opplineItemList'+opplineItemList);
            //multi map to get the FERT based on packaging type.
            Map<Id, Map<Id, Map<String,String>>> cusToProductsMap = new Map<Id,Map<Id, Map<String,String>>>();
            for(OpportunityLineItem oli : opplineItemList) {
                if(!String.isBlank(oli.Packaging_Type__c) && !String.isBlank(oli.Packaging_Unit__c) && oli.Packaging_Quantity__c != null) {
                    if(cusToProductsMap.containsKey(oli.Opportunity.AccountId)) {

                        if(cusToProductsMap.get(oli.Opportunity.AccountId).containsKey(oli.Product2Id)) {
                            cusToProductsMap.get(oli.Opportunity.AccountId).get(oli.Product2Id).put(oli.Packaging_Type__c + oli.Packaging_Unit__c + Integer.valueOf(oli.Packaging_Quantity__c), oli.FERT_Code__c);
                        }else {
                            cusToProductsMap.get(oli.Opportunity.AccountId).put(oli.Product2Id, new Map<String,String>{oli.Packaging_Type__c + oli.Packaging_Unit__c + Integer.valueOf(oli.Packaging_Quantity__c) => oli.FERT_Code__c});
                        }
                    }
                    else {
                        cusToProductsMap.put(oli.Opportunity.AccountId, new Map<Id, Map<String, String>>{oli.Product2Id => new Map<String, String> { oli.Packaging_Type__c + oli.Packaging_Unit__c + oli.Packaging_Quantity__c => oli.FERT_Code__c}});
                    }
                }
            }

            System.debug('--- cusToProductsMap '+cusToProductsMap);
            System.debug('--- oppToaccMap '+oppToaccMap);
            System.debug('--- opTooppMap '+opTooppMap);


            if(!cusToProductsMap.isEmpty()) {
                List<OpportunityLineItem> lineItemToUpdate = new List<OpportunityLineItem>();
                for(OpportunityLineItem oli : oppLineList) { 
                    System.debug('--- checking for key:'+oli.Packaging_Type__c + oli.Packaging_Unit__c + Integer.valueOf(oli.Packaging_Quantity__c));
                    if(opTooppMap.containsKey(oli.Id) && oppToaccMap.containsKey(opTooppMap.get(oli.Id)) && cusToProductsMap.containsKey(oppToaccMap.get(opTooppMap.get(oli.Id))) && cusToProductsMap.get(oppToaccMap.get(opTooppMap.get(oli.Id))).containsKey(oli.Product2Id) && cusToProductsMap.get(oppToaccMap.get(opTooppMap.get(oli.Id))).get(oli.Product2Id).containsKey(oli.Packaging_Type__c + oli.Packaging_Unit__c + Integer.valueOf(oli.Packaging_Quantity__c))) {
                        System.debug('--- matching fert found');
                        lineItemToUpdate.add(new OpportunityLineItem(Id = oli.Id, FERT_Code__c = cusToProductsMap.get(oppToaccMap.get(opTooppMap.get(oli.Id))).get(oli.Product2Id).get(oli.Packaging_Type__c + oli.Packaging_Unit__c + Integer.valueOf(oli.Packaging_Quantity__c))));
                        System.debug('--- lineItemToUpdate: '+lineItemToUpdate);
                    }
                }
                if(!lineItemToUpdate.isEmpty()) {
                    try {
                        update lineItemToUpdate;
                    }catch(DMLException e) {
                        HandleBusinessException.captureError('OpportunityLineItemTriggerHandler', 'checkAndUpdateFERT', e);
                    }
                }
                    
            }
        }
    }


    public Decimal unitConversionHelper(Decimal perKgPrice, String conversionToUnit) {
        if(perKgPrice == null || perKgprice <= 0 || conversionToUnit == null)
            return perKgPrice;
        else {

            switch on conversionToUnit {
                when 'Gm','mL' {
                    return perKgPrice / 1000;
                }
                when 'Liter' {
                    return perKgPrice; //Since same
                }
                when 'Tonne' {
                    return perKgPrice * 1000;
                }
                when else {
                    return perKgPrice;
                }
            }
            
        }
    }

    private Decimal getKgPrice(Decimal currentPrice, String currentUnit) {

        if(currentPrice == null || currentPrice <= 0 || currentUnit == null)
            return currentPrice;
        else {
            switch on currentUnit {
                when 'Gm','mL' {
                    return currentPrice * 1000;
                }
                when 'Liter' {
                    return currentPrice; //Since same
                }
                when 'Tonne' {
                    return currentPrice / 1000;
                }
                when else {
                    return currentPrice;
                }
            }
        }
    }

    private void sapFertUpdateHelper(Map<String,OpportunityLineItem> fertXOliMap) {

        System.debug('sapFertUpdateHelper----'+fertXOliMap);
        Map<String,OpportunityLineItem> oldFertXOliMap = new Map<String,OpportunityLineItem>();
        Map<String,Map<Id,Id>> customerFertMap = new Map<String,Map<Id,Id>>();

        Set<Id> oppItemSetId = new Set<Id>();
        for(String s : fertXOliMap.keySet()){
            oppItemSetId.add(fertXOliMap.get(s).Id);
        }

        List<OpportunityLineItem> oldOppList = [Select Id,Fert_Code__c,UnitPrice,Customer_Code__c From OpportunityLineItem Where Fert_Code__c IN :fertXOliMap.keySet() AND Id NOT IN :oppItemSetId AND Is_Parent_Opportunity__c = true ORDER BY CreatedDate];

        for(OpportunityLineItem item : oldOppList){
            oldFertXOliMap.put(item.Fert_Code__c,item);
        }

        for(String s : fertXOliMap.keySet()){
            if(customerFertMap.containsKey(fertXOliMap.get(s).Customer_Code__c)){
                Map<Id,Id> exMap = customerFertMap.get(fertXOliMap.get(s).Customer_Code__c);
                exMap.put(fertXOliMap.get(s).Id,oldFertXOliMap.get(s)!=null?oldFertXOliMap.get(s).Id:null);

                customerFertMap.put(fertXOliMap.get(s).Customer_Code__c,exMap);
            }else{
                customerFertMap.put(fertXOliMap.get(s).Customer_Code__c,new Map<Id,Id>{fertXOliMap.get(s).Id=>oldFertXOliMap.get(s)!=null?oldFertXOliMap.get(s).Id:null});
            }
        }

        for(String csId : customerFertMap.keySet()){
            if(customerFertMap.get(csId)!=null && !customerFertMap.get(csId).isEmpty()){
                SAP_SubmitFertPrice.createBulkProdWrapper(csId,customerFertMap.get(csId));
            }
        }
    }

    //v1.1 product visibility validations
    private void checkProdCreationAcceptanceCriteria(List<OpportunityLineItem> oliList, Set<Id> productIdSet, Set<Id> customerIdSet) {
        System.debug('--- '+ oliList+ '--- productIdSet' + productIdSet + ' customerIdSet' +customerIdSet);
        Map<Id, Product2> pMasterMap = new Map<Id, Product2>([SELECT Id, ProductCode, Product_Visibility__c, To_Be_Sold_By__c, Product_Used_By__c, IsActive FROM Product2 WHERE Id IN : productIdSet]);
        System.debug('--- pMasterMap '+ pMasterMap);
        
        Set<Id> privateProductIdSet = new Set<Id>();
        Set<Id> publicProductIdSet = new Set<Id>();
        Set<Id> portfolioProductIdSet = new Set<Id>();
        Set<Id> tailormadeProductIdSet = new Set<Id>();
        Set<Id> foodServiceProductIdSet = new Set<Id>();
        Set<Id> restrictedProductIdSet = new Set<Id>();
        Set<Id> soldByChannelSales = new Set<Id>();
        Set<Id> soldByDirect = new Set<Id>();
        Set<Id> soldByFoodService = new Set<Id>();        
        
        for(Product2 product: pMasterMap.values()) {
            if(product.Product_Visibility__c != null && product.Product_Visibility__c.equalsIgnoreCase(Constants.PRODUCT_VISIBILITY_PUBLIC))
                publicProductIdSet.add(product.Id);
            
            if(product.Product_Visibility__c != null && product.Product_Visibility__c.equalsIgnoreCase(Constants.PRODUCT_VISIBILITY_PRIVATE))
                privateProductIdSet.add(product.Id);
            
            //Product used by
            if(product.Product_Used_By__c != null && product.Product_Used_By__c.equalsIgnoreCase(Constants.PRODUCT_USEDBY_PORTFOLIO_PRODUCT))
                portfolioProductIdSet.add(product.Id);

            if(product.Product_Used_By__c != null && product.Product_Used_By__c.equalsIgnoreCase(Constants.PRODUCT_USEDBY_TAILOR_MADE))
                tailormadeProductIdSet.add(product.Id);

            if(product.Product_Used_By__c != null && product.Product_Used_By__c.equalsIgnoreCase(Constants.PRODUCT_USEDBY_FOOD_SERVICE))
                foodServiceProductIdSet.add(product.Id);

            if(product.Product_Used_By__c != null && product.Product_Used_By__c.equalsIgnoreCase(Constants.PRODUCT_USEDBY_RESTRICTED))
                restrictedProductIdSet.add(product.Id);
            
            //To be sold by 
            if(product.To_Be_Sold_By__c != null && product.To_Be_Sold_By__c.equalsIgnoreCase(Constants.PRODUCT_SOLDBY_CS))
                soldByChannelSales.add(product.Id);

            if(product.To_Be_Sold_By__c != null && product.To_Be_Sold_By__c.equalsIgnoreCase(Constants.PRODUCT_SOLDBY_FS))
                soldByFoodService.add(product.Id);

            if(product.To_Be_Sold_By__c != null && product.To_Be_Sold_By__c.equalsIgnoreCase(Constants.PRODUCT_SOLDBY_DIRECT))
                soldByDirect.add(product.Id);

        }

        Map<Id, Set<String>> customerSSCCodesMap = new Map<Id, Set<String>>(); 
        
        if(!customerIdSet.isEmpty()) {
            List<Project_Quotient__c> proQuotientList = [SELECT Id, SSC_Code__c, Sample_Project_Application__r.Account__c FROM Project_Quotient__c WHERE Sample_Project_Application__r.Account__c IN: customerIdSet AND Stage__c = 'Won' AND SSC_Code__c != null];
            for(Project_Quotient__c pQuotient: proQuotientList) {
                if(customerSSCCodesMap.containsKey(pQuotient.Sample_Project_Application__r.Account__c)) {
                    customerSSCCodesMap.get(pQuotient.Sample_Project_Application__r.Account__c).add(pQuotient.SSC_Code__c.toLowerCase());
                }else {
                    customerSSCCodesMap.put(pQuotient.Sample_Project_Application__r.Account__c, new Set<String> { pQuotient.SSC_Code__c.toLowerCase() });
                }
            }
        }

        System.debug('--- customerSSCCodesMap '+ customerSSCCodesMap);
        //Validations
        String profileName = [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
        Set<String> adminProfileSet = Utility.getAdminProfileNameSet();
        Map<Id, Set<String>> memberToGroupMap = new Map<Id, Set<String>>();
        
        List<GroupMember> gmList = [SELECT Group.Name, UserOrGroupId FROM GroupMember WHERE Group.Name IN: Constants.SALES_GROUP_NAME_SET];
        
        for(GroupMember gm : gmList) {
            if(memberToGroupMap.containsKey(gm.UserOrGroupId)) {
                memberToGroupMap.get(gm.UserOrGroupId).add(gm.Group.Name.toLowerCase());
            }else {
                memberToGroupMap.put(gm.UserOrGroupId, new Set<String> { gm.Group.Name.toLowerCase() });
            }
        }

        System.debug('--- memberToGroupMap '+ memberToGroupMap);
        for(OpportunityLineItem oli: oliList) {
            /*
            * `--part of project quotient and only for that customer --only quotient that has won --before winning available for sample
            */
                        
            if(pMasterMap.containsKey(oli.Product2Id) && (pMasterMap.get(oli.Product2Id).Product_Visibility__c == null || pMasterMap.get(oli.Product2Id).To_Be_Sold_By__c == null || pMasterMap.get(oli.Product2Id).Product_Used_By__c == null )) {
                oli.addError(pMasterMap.get(oli.Product2Id).ProductCode + ': You cannot proceed with this operation. Either Product Visibility or To Be Sold By or Product Used By is not set');
            }
            
            if(pMasterMap.containsKey(oli.Product2Id) && (privateProductIdSet.contains(oli.Product2Id) || publicProductIdSet.contains(oli.Product2Id)) && tailormadeProductIdSet.contains(oli.Product2Id) && (!customerSSCCodesMap.containsKey(oli.Customer_SF_Id__c) || !customerSSCCodesMap.get(oli.Customer_SF_Id__c).contains(pMasterMap.get(oli.Product2Id).ProductCode.toLowerCase()))) {
                oli.addError(pMasterMap.get(oli.Product2Id).ProductCode + ': You cannot proceed with this operation. This is restricted product which is made available on certain conditions only.');
            }

            if(restrictedProductIdSet.contains(oli.Product2Id) && !adminProfileSet.contains(profileName)) {
                oli.addError(pMasterMap.get(oli.Product2Id).ProductCode + ': You cannot proceed with this operation. This product is restricted and has limited access.');
            }

            if(publicProductIdSet.contains(oli.Product2Id) && (portfolioProductIdSet.contains(oli.Product2Id) || foodServiceProductIdSet.contains(oli.Product2Id)) && pMasterMap.containsKey(oli.product2Id) && pMasterMap.get(oli.product2Id).Product_Used_By__c != null) {
                
                List<String> productUsersCategories = pMasterMap.get(oli.product2Id).To_Be_Sold_By__c != null ? pMasterMap.get(oli.product2Id).To_Be_Sold_By__c.split(';') : new List<String>();
                System.debug('--- productUsersCategories'+ productUsersCategories);
                if(memberToGroupMap.containsKey(UserInfo.getUserId())) { //TODO: change to Owner
                    Boolean isMember = false;
                    for(String category : productUsersCategories) {
                        category = category.toLowerCase();
                        if(memberToGroupMap.get(UserInfo.getUserId()).contains(category)) {
                            isMember = true;
                            break;
                        }
                    }
                    if(!isMember) {
                        oli.addError(pMasterMap.get(oli.Product2Id).ProductCode +': This product is accessible to only ' +pMasterMap.get(oli.product2Id).To_Be_Sold_By__c+ ' If you belong to this group and still cant proceed, please contact System Administrator.');
                    }
                }else if(!adminProfileSet.contains(profileName)){ //not admin then add error
                    oli.addError(pMasterMap.get(oli.Product2Id).ProductCode +': This product is accessible to only ' +pMasterMap.get(oli.product2Id).To_Be_Sold_By__c+ ' If you belong to this group and still cant proceed, please contact System Administrator.');
                }
            }
            

        }

    }

    //Not being used anywhere, please check once
    /* public void afterUpdate(Map<Id,OpportunityLineItem> oldMap, Map<Id,OpportunityLineItem> newMap){
        Set<Id> oppSet = new Set<Id>();
        for(OpportunityLineItem item : newMap.values()){
            if(item.FERT_Code__c!=null && item.FERT_Code__c != oldMap.get(item.Id).FERT_Code__c){
                oppSet.add(item.OpportunityId);
            }
        }

        for(Id oppId : oppSet){
            SAP_SubmitFertPrice.submitFertPrice(oppId);
        }
    } */
    
}