//@RestResource(urlMapping='/sale_order_create')

global without sharing class SAP_RepeatSaleOrderService {
    /* @HttpPost

    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
 
        String resBody = body.toString();
        System.debug('--- resBody'+ resBody);

        String resp = responseHandler(resBody);
        if(resp=='Success'){
            String responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', Constants.SO_CREATION_SUCCESS_RESPONSE));
            RestContext.response.responseBody = Blob.valueOf(responseBody);

            HTTPUtility.getInstance().createServiceLogger(resBody,responseBody,'/sale_order_create','POST',200,processingStartTime,System.now());
        }else{
            String responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', resp));
            HTTPUtility.getInstance().createServiceLogger(resBody,responseBody,'/sale_order_create','POST',400,processingStartTime,System.now());
            RestContext.response.responseBody = Blob.valueOf(responseBody);
        }
    }

    private static String responseHandler(String reqBody){
        try {
            SAP_SaleOrderCreationRestHandler soCreationHandler = SAP_SaleOrderCreationRestHandler.getInstance();
            SAP_SO_Creation_Wrapper sw = (SAP_SO_Creation_Wrapper)JSON.deserialize(reqBody,SAP_SO_Creation_Wrapper.class);

            Set<String> customerCodeSet = new Set<String>();
            Set<String> setOfProdCode = new Set<String>();

            Map<String,List<SAP_SO_Creation_Wrapper.cls_shipping_address>> shippingAddress = new Map<String,List<SAP_SO_Creation_Wrapper.cls_shipping_address>>();
            Map<String,Map<String,SAP_SO_Creation_Wrapper.cls_products>> productCustomerCodeMap = new Map<String,Map<String,SAP_SO_Creation_Wrapper.cls_products>>();


            for(SAP_SO_Creation_Wrapper.SOWrapper so : sw.SALE_ORDERS){

                if(String.isBlank(so.CUSTOMER_CODE)) return Constants.CUSTOMER_CODE_EMPTY_ERROR;
            
                customerCodeSet.add(so.CUSTOMER_CODE);
                if(so.PRODUCTS!=null && !so.PRODUCTS.isEmpty()){
                    // saving all requested product under one customer
                    for(SAP_SO_Creation_Wrapper.cls_products prod : so.PRODUCTS){
                        setOfProdCode.add(prod.PRODUCT_CODE);
                        if(productCustomerCodeMap.containsKey(so.CUSTOMER_CODE)){
                            productCustomerCodeMap.get(so.CUSTOMER_CODE).put(prod.PRODUCT_CODE,prod);
                        }else{
                            Map<String,SAP_SO_Creation_Wrapper.cls_products> prodMap = new Map<String,SAP_SO_Creation_Wrapper.cls_products>();
                            prodMap.put(prod.PRODUCT_CODE,prod);
                            productCustomerCodeMap.put(so.CUSTOMER_CODE,prodMap);
                        }
                    }   
                }
            }

            Map<String,Account> customerMap = soCreationHandler.getCustomerMap(customerCodeSet);

            for(SAP_SO_Creation_Wrapper.SOWrapper so : sw.SALE_ORDERS){
                if(!String.isBlank(so.CUSTOMER_CODE) && customerMap.containsKey(so.CUSTOMER_CODE)){
                    if(shippingAddress.containsKey(customerMap.get(so.CUSTOMER_CODE).Id)){
                        shippingAddress.get(customerMap.get(so.CUSTOMER_CODE).Id).add(so.SHIPPING_ADDRESS);
                    }else{
                        shippingAddress.put(customerMap.get(so.CUSTOMER_CODE).Id,new List<SAP_SO_Creation_Wrapper.cls_shipping_address>{so.SHIPPING_ADDRESS});
                    }
                }
            }

            if(customerCodeSet.size()!=customerMap.size()) return 'SAP Customer code not found';

            //checking fert code empty

            Map<String,OpportunityLineItem> reuqestedProducts = soCreationHandler.getRequestedProducts(setOfProdCode,customerMap.keySet());

            if(reuqestedProducts.isEmpty()){
                return 'Requested products not found';
            }
            System.debug('reuqestedProducts----'+reuqestedProducts);
    
            for(String fertCode : setOfProdCode){
                if(!reuqestedProducts.containsKey(fertCode)){
                    return Constants.FERT_CODE_NOT_FOUND_ERROR+ ' for product '+fertCode;
                }
            }

            // end checking fert code empty

            Map<String,List<OpportunityLineItem>> requestedProductBasedOnCustomer = new Map<String,List<OpportunityLineItem>>();
            Set<Id> oppSet = new Set<Id>();

            for(OpportunityLineItem oli : reuqestedProducts.values()){
                if(!oppSet.contains(oli.OpportunityId)) oppSet.add(oli.OpportunityId);

                if(requestedProductBasedOnCustomer.containsKey(oli.Opportunity.Account.Customer_Code_SAP__c)){
                    requestedProductBasedOnCustomer.get(oli.Opportunity.Account.Customer_Code_SAP__c).add(oli);
                }else{
                    requestedProductBasedOnCustomer.put(oli.Opportunity.Account.Customer_Code_SAP__c,new List<OpportunityLineItem>{oli});
                }
            }

            System.debug('RequestedProductBasedOnCustomer--'+requestedProductBasedOnCustomer);

            Map<Integer,Opportunity> oppToInsert = new Map<Integer,Opportunity>();
            Map<Integer,Sales_Order__c> soToInsert = new Map<Integer,Sales_Order__c>();
            Map<Integer,List<OpportunityLineItem>> oliToInsert = new Map<Integer,List<OpportunityLineItem>>();

            System.debug('oppSet------'+oppSet);
            System.debug('customerMap------'+customerMap);

            //Map<String,List<OpportunityLineItem>> oppLineItemsBasedOnCustomerx = soCreationHandler.getOppLineItemsBasedOnCustomer(setOfProdCode,customerMap.keySet());
            Map<String,List<OpportunityLineItem>> oppLineItemsBasedOnCustomer = soCreationHandler.getAllOppLineItemsBasedOnCustomer(oppSet,customerMap.keySet());

            System.debug('Existing Product---'+oppLineItemsBasedOnCustomer);


            Integer i = 0;

            Map<String,Opportunity> newopptoCreateMap = new Map<String,Opportunity>();
            Map<String,List<OpportunityLineItem>> refToProdMap = new Map<String,List<OpportunityLineItem>>();
            Map<String,Sales_Order__c> soMapToInsert = new Map<String,Sales_Order__c>();
            List<Opportunity> oppToUpdate = new List<Opportunity>();
            List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
            List<OpportunityLineItem> oppLineItemsToDelete = new List<OpportunityLineItem>();

            for(SAP_SO_Creation_Wrapper.SOWrapper so : sw.SALE_ORDERS){
                if(!oppLineItemsBasedOnCustomer.containsKey(so.CUSTOMER_CODE)){
                    System.debug('IFBLOCK');
                    Opportunity opp = soCreationHandler.createOpp(customerMap.get(so.CUSTOMER_CODE),'Closed Won'); //TODO: there is no check for existing opp
                    opp.Repeat_Order_Created__c = true;

                    Sales_Order__c sOrder = soCreationHandler.createSO(customerMap.get(so.CUSTOMER_CODE), so.REF_CODE);

                    sOrder.SAP_Reference_Code__c = so.REF_CODE;
                    sOrder.Customer_PO_Ref_no__c = so.CUSTOMER_PO_REF_NO;
                    sOrder.Expected_Delivery_Date__c = Date.valueOf(so.EXPECTED_DELIVERY_DATE);
                    sOrder.Remarks__c = so.REMARKS;
                    sOrder.Order_quantity__c = so.GROSS_WEIGHT;

                    oppToInsert.put(i,opp);
                    soToInsert.put(i,sOrder);

                    List<OpportunityLineItem> reqProduct = requestedProductBasedOnCustomer.get(so.CUSTOMER_CODE);

                    if(reqProduct!=null && !reqProduct.isEmpty()){

                        Map<String,SAP_SO_Creation_Wrapper.cls_products> customerProduct = productCustomerCodeMap.get(so.CUSTOMER_CODE);
                        
                        for(OpportunityLineItem oli : reqProduct){
                            SAP_SO_Creation_Wrapper.cls_products prod = customerProduct.get(oli.ProductCode); //TODO: Handle null check here.
            
                            OpportunityLineItem newOli = soCreationHandler.createOppLineItem(oli);
                            System.debug('--- oli'+newOli);
                            System.debug('--- prod'+prod);
                            newOli.Quantity = prod.QUANTITY;
                            newOli.Quantity_Unit__c = prod.QUANTITY_UNIT;
                            newOli.Plant__c = prod.PLANT;

                            if(!String.isBlank(prod.PLANNED_DELIVERY_DATE)){
                                newOli.Planned_Delivery_Date__c = parseDate(prod.PLANNED_DELIVERY_DATE);
                            }

                            if(!String.isBlank(prod.SERVICE_RENDERING_DATE)){
                                newOli.Service_Rendering_Date__c = parseDate(prod.SERVICE_RENDERING_DATE);
                            }

                            if(!String.isBlank(prod.SERVICE_RENDERING_DATE_REASON)){
                                newOli.Service_Rendering_Date_Reason__c = prod.SERVICE_RENDERING_DATE_REASON;
                            }
            
                            newOli.UnitPrice = oli.UnitPrice;
                            newOli.PricebookEntryId = oli.PricebookEntryId;

                            if(oliToInsert.containsKey(i)){
                                oliToInsert.get(i).add(newOli);
                            }else{
                                oliToInsert.put(i,new List<OpportunityLineItem>{newOli});
                            }
                        }
                    }
                }else{
                    System.debug('ELSEBLOCK');
                    Map<Id,List<OpportunityLineItem>> oppProdMap = new Map<Id,List<OpportunityLineItem>>();
                    for(OpportunityLineItem oli : oppLineItemsBasedOnCustomer.get(so.CUSTOMER_CODE)){
                        if(oppProdMap.containsKey(oli.OpportunityId)){
                            oppProdMap.get(oli.OpportunityId).add(oli);
                        }else{
                            oppProdMap.put(oli.OpportunityId,new List<OpportunityLineItem>{oli});
                        }
                    }

                    String firstIndexKey = (new List<Id>(oppProdMap.keySet())[0]);

                    List<OpportunityLineItem> oppLineItems = oppProdMap.get(firstIndexKey);
                    System.debug('oppLineItems---'+oppLineItems);


                    Map<String,OpportunityLineItem> xOpCodeMap = new Map<String,OpportunityLineItem>();

                    for(OpportunityLineItem oli : oppLineItems){
                        xOpCodeMap.put(oli.FERT_Code__c,oli);
                    }


                    Sales_Order__c sOrder = soCreationHandler.createSO(customerMap.get(so.CUSTOMER_CODE), so.REF_CODE);
                    sOrder.Opportunity__c = firstIndexKey;
                    sOrder.Amount__c = 0;
                    sOrder.SAP_Reference_Code__c = so.REF_CODE;
                    sOrder.Customer_PO_Ref_no__c = so.CUSTOMER_PO_REF_NO;
                    sOrder.Expected_Delivery_Date__c = Date.valueOf(so.EXPECTED_DELIVERY_DATE);
                    sOrder.Remarks__c = so.REMARKS;
                    sOrder.Order_quantity__c = so.GROSS_WEIGHT;

                    oppToUpdate.add(new Opportunity(Id=firstIndexKey,Repeat_Order_Created__c=true));


                    Set<String> reqProdSet = new Set<String>();

                    for(SAP_SO_Creation_Wrapper.cls_products upProd : so.PRODUCTS){

                        reqProdSet.add(upProd.PRODUCT_CODE);

                        OpportunityLineItem oli = xOpCodeMap.get(upProd.PRODUCT_CODE);



                        if(oli.Quantity > upProd.quantity){
                            if(!newopptoCreateMap.containsKey(so.REF_CODE)){
                                newopptoCreateMap.put(so.REF_CODE,soCreationHandler.createOpp(customerMap.get(so.CUSTOMER_CODE),'New'));
                            }

                            OpportunityLineItem newOppLineItem = soCreationHandler.createOppLineItem(oli);
                            newOppLineItem.Quantity = oli.Quantity - upProd.quantity;
                            newOppLineItem.Quantity_Unit__c = upProd.quantity_unit;
                            newOppLineItem.Plant__c = upProd.plant;
                            newOppLineItem.PricebookEntryId = oli.PricebookEntryId;

                            if(!String.isBlank(upProd.PLANNED_DELIVERY_DATE)){
                                newOppLineItem.Planned_Delivery_Date__c = parseDate(upProd.PLANNED_DELIVERY_DATE);
                            }

                            if(!String.isBlank(upProd.SERVICE_RENDERING_DATE)){
                                newOppLineItem.Service_Rendering_Date__c = parseDate(upProd.SERVICE_RENDERING_DATE);
                            }

                            if(!String.isBlank(upProd.SERVICE_RENDERING_DATE_REASON)){
                                newOppLineItem.Service_Rendering_Date_Reason__c = upProd.SERVICE_RENDERING_DATE_REASON;
                            }

                            if(!oli.Quantity_Unit__c.equalsIgnoreCase(upProd.QUANTITY_UNIT)){
                                newOppLineItem.UnitPrice = convertAmountIntoReqUnitBySAP(oli.UnitPrice,oli.Quantity_Unit__c,upProd.QUANTITY_UNIT);
                            }else{
                                newOppLineItem.UnitPrice = oli.UnitPrice;
                            }

                            if(refToProdMap.containsKey(so.REF_CODE)){
                                refToProdMap.get(so.REF_CODE).add(newOppLineItem);
                            }else{
                                refToProdMap.put(so.REF_CODE,new List<OpportunityLineItem>{newOppLineItem});
                            }

                            oli.Quantity = upProd.quantity;
                            sOrder.Amount__c = sOrder.Amount__c + (oli.Quantity * oli.UnitPrice);
                        }

                        if(oli.Quantity <= upProd.quantity){
                            oli.Quantity = upProd.quantity;

                            if(!oli.Quantity_Unit__c.equalsIgnoreCase(upProd.QUANTITY_UNIT)){
                            // newOppLineItem.UnitPrice = convertAmountIntoReqUnitBySAP(oli.UnitPrice,oli.Quantity_Unit__c,upProd.QUANTITY_UNIT);
                                oli.Quantity_Unit__c = upProd.QUANTITY_UNIT;
                            }

                            sOrder.Amount__c = sOrder.Amount__c + (oli.Quantity * oli.UnitPrice);
                        }

                        oppLineItemsToUpdate.add(oli);
                    }


                    for(OpportunityLineItem oli : oppLineItems){
                        if(!reqProdSet.contains(oli.FERT_Code__c)){
                            oppLineItemsToDelete.add(oli);
                            
                            OpportunityLineItem newOli = oli.Clone();
                            newOli.OpportunityId = null;
                            newOli.Id = null;

                            if(!refToProdMap.isEmpty() && refToProdMap.containsKey(so.REF_CODE)){
                                refToProdMap.get(so.REF_CODE).add(newOli);
                            }else{
                                if(!newopptoCreateMap.containsKey(so.REF_CODE)){
                                    newopptoCreateMap.put(so.REF_CODE,soCreationHandler.createOpp(customerMap.get(so.CUSTOMER_CODE),'New'));
                                }
                                refToProdMap.put(so.REF_CODE,new List<OpportunityLineItem>{newOli});
                            }
                        }
                    }
                    soMapToInsert.put(so.REF_CODE,sOrder);
                }
                i++;
            }

            try{

                System.debug('oppListToUpdate----'+oppLineItemsToUpdate);

                if(!oppLineItemsToUpdate.isEmpty()){
                    update oppLineItemsToUpdate; //lineitmes
                }

                if(!oppToUpdate.isEmpty()){
                    update oppToUpdate; //opportunity
                }            

                if(!oppToInsert.isEmpty()){

                    System.debug('oppToInsert--'+oppToInsert);
                    insert oppToInsert.values();

                    Integer j = 0;
                    for(Sales_Order__c sOrder : soToInsert.values()){
                        sOrder.Opportunity__c = oppToInsert.get(j).Id;
                        j++;
                    }

                    insert soToInsert.values();

                    j = 0;

                    List<OpportunityLineItem> opListToInsert = new List<OpportunityLineItem>();

                    for(List<OpportunityLineItem> opl : oliToInsert.values()){
                        String oppId = oppToInsert.get(j).Id;
                        String soId = soToInsert.get(j).Id;

                        for(OpportunityLineItem oli : opl){
                            oli.OpportunityId = oppId;
                            oli.Sales_Order__c = soId;
                            opListToInsert.add(oli);
                        }
                        j++;
                    }

                    insert opListToInsert;
                }

            

                if(!newopptoCreateMap.isEmpty()){
                    insert newopptoCreateMap.values();

                    List<OpportunityLineItem> olis = new List<OpportunityLineItem>();

                    for(String soKey : refToProdMap.keySet()){
                        for(OpportunityLineItem oli : refToProdMap.get(soKey)){
                            oli.OpportunityId = newopptoCreateMap.get(soKey).Id;
                            olis.add(oli);
                        }
                    }

                    if(!oppLineItemsToDelete.isEmpty()){
                       // delete oppLineItemsToDelete;
                    }

                    insert olis;
                }

                if(!soMapToInsert.isEmpty()){
                    insert soMapToInsert.values();
                }

            soCreationHandler.updateCustomerAddress(shippingAddress);
                return 'Success';
            }catch(DMLException e){
                HandleBusinessException.captureError('SAP_SaleOrderCreationRestService', 'responseHandler', e);
                return e.getMessage();
            }   
        } catch (Exception e) {
            HandleBusinessException.captureError('SAP_SaleOrderCreationRestService', 'responseHandler', e);
            return e.getMessage();
        }
    }

    private static Date parseDate(String d){
        String[] dSplit = d.split('-');
        String cDate = dSplit[1]+'/'+dSplit[2]+'/'+dSplit[0];
        return Date.parse(cDate);
    }

    private static Decimal convertAmountIntoReqUnitBySAP(Decimal currentAmount, String currentUnit, String convertUnitInto){
        switch on convertUnitInto {
            when 'Kg' {
                return convertUnitToKg(currentAmount,currentUnit);
            }
            when 'Gm' {
                return convertUnitToGm(currentAmount,currentUnit);
            }
            when 'Liter' {
                return convertUnitToLiter(currentAmount,currentUnit);
            }
            when 'mL' {
                return convertUnitToML(currentAmount,currentUnit);
            }
            when else {
                return convertUnitToTonne(currentAmount,currentUnit);
            }
        }
    }

    private static Decimal convertUnitToKg(Decimal currentAmount,String currentUnit){
        switch on currentUnit {
            when 'Kg' {
                return currentAmount;
            }
            when 'Gm' {
                return currentAmount / 1000;
            }
            when 'Liter' {
                return currentAmount;
            }
            when 'mL' {
                return currentAmount / 1000;
            }
            when else {
                return currentAmount * 1000;
            }
        }
    }

    private static Decimal convertUnitToGm(Decimal currentAmount,String currentUnit){
        switch on currentUnit {
            when 'Kg' {
                return currentAmount/1000;
            }
            when 'Gm' {
                return currentAmount;
            }
            when 'Liter' {
                return currentAmount/1000;
            }
            when 'mL' {
                return currentAmount;
            }
            when else {
                return currentAmount/1000000;
            }
        }
    }

    private static Decimal convertUnitToLiter(Decimal currentAmount,String currentUnit){
        switch on currentUnit {
            when 'Kg' {
                return currentAmount;
            }
            when 'Gm' {
                return currentAmount / 1000;
            }
            when 'Liter' {
                return currentAmount;
            }
            when 'mL' {
                return currentAmount / 1000;
            }
            when else {
                return currentAmount * 1000;
            }
        }
    }

    private static Decimal convertUnitToML(Decimal currentAmount,String currentUnit){
        //convert into ML;
        switch on currentUnit {
            when 'Kg' {
                return currentAmount/1000;
            }
            when 'Gm' {
                return currentAmount;
            }
            when 'Liter' {
                return currentAmount/1000;
            }
            when 'mL' {
                return currentAmount;
            }
            when else {
                return currentAmount/1000000;
            }
        }
    }

    private static Decimal convertUnitToTonne(Decimal currentAmount,String currentUnit){
        //convert into tonne;
        switch on currentUnit {
            when 'Kg' {
                return currentAmount / 1000;
            }
            when 'Gm' {
                return currentAmount * 1000 * 1000;
            }
            when 'Liter' {
                return currentAmount / 1000;
            }
            when 'mL' {
                return currentAmount * 1000 * 1000;
            }
            when else {
                return currentAmount;
            }
        }
    } */

}