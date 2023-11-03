@RestResource(urlMapping='/products')
global without sharing class SAP_ProductMasterSyncRestService {
    
    /**
     * {
        "PRODUCT_DATA": [
            {
                "ACTIVE": "NO", 
                "PRODUCTCODE": "22642V3",
                "PRODUCT_DESCRIPTION": "HOMOGENISED PREMIX FOR TATA 1.",
                "PRODUCTFAMILY": "",
                "PRODUCTTYPE": "HALB", - Ignore as all records will be HALB
                "TARGET_DISH": "",
                "UNITOFMEASURE": "KG",
                "APPLICATION": "",
                "PRODUCT_USED_BY": "",
                "LEGALSTATUS": "",
                "LISTPRICE": 0, - this will go to standard pricebook entry to
                "HSN_TAX": "0",
                "TARGETCOUNTRY": "",
                "ALLERGEN_STATUS": "TRUE",
                "DIETARYINFO": "",
                "PRODUCT_PROFILE": "",
                "MAXIMUM_SAMPLING_QUANTITY": "00000",
                "SAMPLING_QTY_UNIT": "",
                "RAD_APPLICATION": "",
                "PRODUCTSUBCATEGORY": "",
                "ENDAPPLICATION": "",
                "PLANT":"CORPORATE - 1000;CORPORATE - 1000"
            }
        ]
        }
     */
    @HttpPost
    global static void doPost() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        //Now as you have the request string You can parse it in APex   
        System.debug('--- rquestString'+ requestString);
        SAP_ProductMasterWrapper rWrapper = (SAP_ProductMasterWrapper)JSON.deserialize(requestString, SAP_ProductMasterWrapper.class);
        String responseBody;
        if(rWrapper != null && rWrapper.PRODUCT_DATA != null) {
            system.debug('updateProduct :: ' + updateProduct(rWrapper.PRODUCT_DATA));
            if(updateProduct(rWrapper.PRODUCT_DATA)) {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Products synced successfully'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/products', 'POST', 200, processingStartTime, System.now()); //Log 
            }
            else {
                responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', 'Something went wrong'));
                RestContext.response.responseBody = Blob.valueOf(responseBody);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/products', 'POST', 400, processingStartTime, System.now()); //Log 
            }
        }
    }

    private static Boolean updateProduct(List<SAP_ProductMasterWrapper.ProductMasterSyncWrapper> sapProductList){
        try{
            
            Map<String, SAP_ProductMasterWrapper.ProductMasterSyncWrapper> sapReqProductMap = new Map<String, SAP_ProductMasterWrapper.ProductMasterSyncWrapper>();
            for(SAP_ProductMasterWrapper.ProductMasterSyncWrapper sapProduct : sapProductList) {
                if(!String.isBlank(sapProduct.PRODUCTCODE))
                    sapReqProductMap.put(sapProduct.PRODUCTCODE, sapProduct);
            }

            System.debug('sapReqProductMap '+ sapReqProductMap);

            if(!sapReqProductMap.isEmpty()) {

                Set<String> pvtProductCodeSet = new Set<String>();
                List<Project_Quotient__c> pqList = [SELECT Id, SSC_Code__c FROM Project_Quotient__c WHERE SSC_Code__c IN: sapReqProductMap.keySet()];
                for(Project_Quotient__c quotient: pqList) {
                    pvtProductCodeSet.add(quotient.SSC_Code__c);
                }
                
                List<Product2> existingProductList = [SELECT Id, Name, Product_Visibility__c, To_Be_Sold_By__c, IsActive, ProductCode, Description, Family, Target_Dish__c, QuantityUnitOfMeasure, Product_Sub_Category__c,
                                                      Application__c, Product_Used_By__c, Legal_status__c, List_Price__c, HSN_TAX__c, Target_Country__c, End_Application__c, 
                                                      Allergen_Status_Required__c, Product_Profile__c, Max_sampling_Qty__c, Sampling_Qty_UNIT__c, RAD_Application__c
                                                      FROM Product2 WHERE ProductCode IN: sapReqProductMap.keySet()];
                Map<String, Product2> codeToProductMap = new Map<String, Product2>();

                for(Product2 p2 : existingProductList) {
                    codeToProductMap.put(p2.ProductCode, p2);
                }
                
                System.debug('codeToProductMap '+ codeToProductMap);

                //TODO: map json data with product fields and list price to price book entry for INR as of now.
                for(SAP_ProductMasterWrapper.ProductMasterSyncWrapper sapProduct : sapProductList) {
                    if(!String.isBlank(sapProduct.PRODUCTCODE)) {
                        if(codeToProductMap.containsKey(sapProduct.PRODUCTCODE)) {
                            Product2 extPro = codeToProductMap.get(sapProduct.PRODUCTCODE);
                            //Map all fields here
                            productFieldMapping(sapProduct, extPro, pvtProductCodeSet);
                        }else{
                            Product2 newP2 = new Product2();
                            //Map all fields here
                            codeToProductMap.put(sapProduct.PRODUCTCODE, newP2);
                            productFieldMapping(sapProduct, newP2, pvtProductCodeSet);
                        }
                    }
                }

                System.debug('codeToProductMap '+ codeToProductMap);

                if(!codeToProductMap.isEmpty()){
                    upsert codeToProductMap.values();
                    //You will get id here
                    Id priceBookId = [SELECT id, name FROM Pricebook2 WHERE isStandard = true].Id;
                    
                    List<PricebookEntry> inrEntries = [SELECT Id,ProductCode FROM PriceBookEntry WHERE Product2.ProductCode IN : codeToProductMap.keySet() AND CurrencyIsoCode = 'INR'];

                    Map<String, PricebookEntry> pInrToPBEMap = new Map<String, PricebookEntry>();
                    for(PriceBookEntry pbe : inrEntries) {
                        pInrToPBEMap.put(pbe.ProductCode, pbe);
                    }

                    for(String pCode : codeToProductMap.keySet()) {
                        if(pInrToPBEMap.containsKey(pCode)) {
                            pInrToPBEMap.get(pCode).UnitPrice = sapReqProductMap.containsKey(pCode) && sapReqProductMap.get(pCode).LISTPRICE != null && sapReqProductMap.get(pCode).LISTPRICE > 0 ? sapReqProductMap.get(pCode).LISTPRICE : pInrToPBEMap.get(pCode).UnitPrice;
                        }else {
                            Double unitPrice = sapReqProductMap.containsKey(pCode) && sapReqProductMap.get(pCode).LISTPRICE != null && sapReqProductMap.get(pCode).LISTPRICE > 0 ? sapReqProductMap.get(pCode).LISTPRICE : 0;

                            if(unitPrice != 0)
                                pInrToPBEMap.put(pCode, new PricebookEntry(UnitPrice = unitPrice,Pricebook2Id = priceBookId, CurrencyIsoCode = 'INR', IsActive = true, Product2Id = codeToProductMap.get(pCode).Id));
                        }
                    }
                    if(!pInrToPBEMap.isEmpty())
                        upsert pInrToPBEMap.values();
                }
            }
            return true;
        }catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
            HandleBusinessException.captureError('SAP_ProductMasterSyncRestService','updateProduct', e);
            return false;
        }
    }


    private static void productFieldMapping(SAP_ProductMasterWrapper.ProductMasterSyncWrapper sapWrapper, Product2 extPro, Set<String> pvtProductCodeSet) {
        // mapping here
        extPro.Name =  !String.isBlank(sapWrapper.PRODUCT_DESCRIPTION) ? (String)sapWrapper.PRODUCT_DESCRIPTION : extPro.Name;
        extPro.IsActive = sapWrapper.ACTIVE == 'YES' ? true : false ; 
        extPro.ProductCode =  !String.isBlank(sapWrapper.PRODUCTCODE) ? (String)sapWrapper.PRODUCTCODE : extPro.ProductCode;
        extPro.Description =  !String.isBlank(sapWrapper.PRODUCT_DESCRIPTION) ? (String)sapWrapper.PRODUCT_DESCRIPTION : extPro.Description;
        extPro.Family =  !String.isBlank(sapWrapper.PRODUCTFAMILY) ? (String)sapWrapper.PRODUCTFAMILY : extPro.Family;
        extPro.Target_Dish__c =  !String.isBlank(sapWrapper.TARGET_DISH) ? (String)sapWrapper.TARGET_DISH : extPro.Target_Dish__c;
        extPro.QuantityUnitOfMeasure =  !String.isBlank(sapWrapper.UNITOFMEASURE) ? (String)sapWrapper.UNITOFMEASURE : extPro.QuantityUnitOfMeasure;
        extPro.Application__c = !String.isBlank(sapWrapper.APPLICATION) ? (String)sapWrapper.APPLICATION : extPro.Application__c;
        extPro.Product_Used_By__c =  !String.isBlank(sapWrapper.PRODUCT_USED_BY) ? (String)sapWrapper.PRODUCT_USED_BY : extPro.Product_Used_By__c;
        extPro.Legal_status__c = !String.isBlank(sapWrapper.LEGALSTATUS) ? (String)sapWrapper.LEGALSTATUS : extPro.Legal_status__c;
        //extPro.List_Price__c =  (Double) sapWrapper.LISTPRICE;
        extPro.HSN_TAX__c =  (Double) sapWrapper.HSN_TAX;
        extPro.Target_Country__c = !String.isBlank(sapWrapper.TARGETCOUNTRY) ? (String)sapWrapper.TARGETCOUNTRY : extPro.Target_Country__c;
		extPro.Allergen_Status_Required__c = sapWrapper.ALLERGEN_STATUS == 'TRUE' ? true : false;	
		extPro.Product_Profile__c = !String.isBlank(sapWrapper.PRODUCT_PROFILE) ? (String)sapWrapper.PRODUCT_PROFILE : extPro.Product_Profile__c;
		extPro.Max_sampling_Qty__c = integer.valueOf (sapWrapper.MAXIMUM_SAMPLING_QUANTITY );	
		extPro.Sampling_Qty_UNIT__c = !String.isBlank(sapWrapper.SAMPLING_QTY_UNIT) ? getMultiPickvalFromString(extPro.Sampling_Qty_UNIT__c, sapWrapper.SAMPLING_QTY_UNIT.split(';')) : extPro.Sampling_Qty_UNIT__c;
		extPro.RAD_Application__c = !String.isBlank(sapWrapper.RAD_APPLICATION) ? (String)sapWrapper.RAD_APPLICATION : extPro.RAD_Application__c;
		extPro.Product_Sub_Category__c = !String.isBlank(sapWrapper.PRODUCTSUBCATEGORY) ? (String)sapWrapper.PRODUCTSUBCATEGORY : extPro.Product_Sub_Category__c;
		extPro.End_Application__c = !String.isBlank(sapWrapper.ENDAPPLICATION) ? (String)sapWrapper.ENDAPPLICATION : extPro.End_Application__c;
		extPro.Plant__c = !String.isBlank(sapWrapper.PLANT) ? (String)sapWrapper.PLANT : extPro.Plant__c;
        //extPro.Product_Visibility__c = pvtProductCodeSet.contains(extPro.ProductCode) ? 'Private' : 'Public';
        extPro.To_Be_Sold_By__c = !String.isBlank(sapWrapper.TO_BE_SOLD_BY) ? (String)sapWrapper.TO_BE_SOLD_BY : extPro.To_Be_Sold_By__c;
        extPro.Product_Visibility__c = !String.isBlank(sapWrapper.VISIBILITY) ? (String)sapWrapper.VISIBILITY : extPro.Product_Visibility__c;        
    }

    private static String getMultiPickvalFromString(String currentVal, List<String> newValuesList) {
        if(newValuesList == null || newValuesList.isEmpty())
            return currentVal;
        else
            return String.join(newValuesList, ';');
    }

    
}