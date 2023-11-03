/*
* DeaGle~ : Monster version : https://www.youtube.com/watch?v=bZBqSRIKk5E
**/
@RestResource(urlMapping='/sale_order_create')
global without sharing class SAP_RepeatOrderService {
    
    static final Set<String> ALLOWED_UOM_SET = new Set<String>{'kg', 'gm', 'liter', 'ml', 'tonne'};

    @HttpPost
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
            RestContext.response.statusCode = 200;
            HTTPUtility.getInstance().createServiceLogger(resBody,responseBody,'/sale_order_create','POST',200,processingStartTime,System.now());
        }else{
            String responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Error', resp));
            HTTPUtility.getInstance().createServiceLogger(resBody,responseBody,'/sale_order_create','POST',400,processingStartTime,System.now());
            RestContext.response.responseBody = Blob.valueOf(responseBody);
            RestContext.response.statusCode = 400;
        }
    }

    private static String responseHandler(String reqBody){

        try{
            SAP_SaleOrderCreationRestHandler soCreationHandler = SAP_SaleOrderCreationRestHandler.getInstance();
            SAP_SO_Creation_Wrapper sw = (SAP_SO_Creation_Wrapper)JSON.deserialize(reqBody,SAP_SO_Creation_Wrapper.class);
            if(sw == null)
                return 'ERROR: Bad Request, please send the right format!';

            Set<String> customerCodeSet = new Set<String>();
            Set<String> fertCodeSet = new Set<String>();
            Map<String, SAP_SO_Creation_Wrapper.SOWrapper> sapSaleOrderMap = new Map<String, SAP_SO_Creation_Wrapper.SOWrapper>(); 

            for(SAP_SO_Creation_Wrapper.SOWrapper so : sw.SALE_ORDERS){

                if(String.isBlank(so.CUSTOMER_CODE)) return Constants.CUSTOMER_CODE_EMPTY_ERROR;
                
                if(String.isBlank(so.REF_CODE)) return 'ERROR: REF_CODE Number cannot be blank';
                if(sapSaleOrderMap.containsKey(so.REF_CODE))
                    return 'ERROR: Duplicate order found. REF_CODE should be unique:'+so.REF_CODE;
                
                sapSaleOrderMap.put(so.REF_CODE, so);
                customerCodeSet.add(so.CUSTOMER_CODE);
                if(so.PRODUCTS!=null && !so.PRODUCTS.isEmpty()){
                    // saving all requested product under one customer
                    for(SAP_SO_Creation_Wrapper.cls_products prod : so.PRODUCTS){
                        if(String.isBlank(prod.QUANTITY_UNIT) || !ALLOWED_UOM_SET.contains(prod.QUANTITY_UNIT.toLowerCase())) {
                            return 'ERROR: Invalid UOM';
                        }
                        fertCodeSet.add(prod.PRODUCT_CODE);
                    }   
                }
            }

            String soDupes = soCreationHandler.checkIfOrderExists(sapSaleOrderMap.keySet());
            if(!String.isBlank(soDupes)){
                return soDupes;
            }

            Map<String,Account> customerMap = soCreationHandler.getCustomerMap(customerCodeSet);

            if(customerCodeSet.size() != customerMap.size()) return 'ERROR: SAP Customer code not found';
            
            //checking fert code empty
            Map<String,OpportunityLineItem> requestedProducts = soCreationHandler.getRequestedProducts(fertCodeSet,customerMap.keySet());

            if(requestedProducts.isEmpty()){
                return 'ERROR: Requested products not found.';
            }
            System.debug('requestedProducts----'+requestedProducts);
            // end checking fert code empty
            for(String fertCode : fertCodeSet){
                if(!requestedProducts.containsKey(fertCode)){
                    return Constants.FERT_CODE_NOT_FOUND_ERROR+ ' for product '+fertCode;
                }
            }

            //Submit job here
            if(!sapSaleOrderMap.isEmpty())
                RepeatOrderProcessorQueueable.initiateQueueable(sapSaleOrderMap);
            return 'Success'; 
        }catch(Exception e) {
            System.debug('--- e.message'+e.getMessage());
            System.debug('--- e.lineno'+e.getLineNumber());
            System.debug('--- e.message'+e.getMessage());
            return 'ERROR: Something went wrong, please check the request body';
        }
        
    }
}