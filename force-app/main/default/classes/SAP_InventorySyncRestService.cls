@RestResource(urlMapping='/inventoryupdateapi/*')
global class SAP_InventorySyncRestService {
    @HttpPost
    global static void updateInventorydata(){
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String resBody = req.requestBody.toString();
        try{           
          
            System.debug('resBody  ::'+resBody);
            String resp = handleRequest(resBody);
            
            String responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Success', 'Inventory updated successfully'));
            RestContext.response.responseBody = Blob.valueOf(responseBody);

            HTTPUtility.getInstance().createServiceLogger(resBody,responseBody,'/inventoryupdateapi','POST',200,processingStartTime,System.now());

        }catch(Exception e){
            String responseBody = JSON.serialize(new SAPIntegrationWrappers.APIResponseWrapper('Failure', e.getMessage()));
            RestContext.response.responseBody = Blob.valueOf(responseBody);

            HTTPUtility.getInstance().createServiceLogger(resBody,responseBody,'/inventoryupdateapi','POST',400,processingStartTime,System.now());

            System.debug('Error ::'+e.getMessage() + ' && Error Line No :'+e.getLineNumber());
        }
    }

    public static String handleRequest(String resBody){
        InventorySyncRestServiceWrapper req = (InventorySyncRestServiceWrapper)JSON.deserialize(resBody,InventorySyncRestServiceWrapper.class);

        Map<String,RestProdWrapper> restProdMap = new Map<String,RestProdWrapper>();

        for(RestProdWrapper prod : req.STOCK){
            restProdMap.put(prod.PRODUCT_CODE,prod);
        }

        Map<Id,Product2> reqProduct = new Map<Id,Product2>([Select Id,ProductCode,Inventory_UOM__c,Inventory__c FROM Product2 WHERE ProductCode IN: restProdMap.keySet()]);

        for(Product2 prod : reqProduct.values()){
            prod.Inventory__c = restProdMap.get(prod.ProductCode).INVENTORY;
            prod.Inventory_UOM__c = restProdMap.get(prod.ProductCode).UOM;
        }

        update reqProduct.values();
        return 'Success';

    }
 
    public class InventorySyncRestServiceWrapper {
        public List<RestProdWrapper> STOCK;
    }
    class RestProdWrapper{
        public string PRODUCT_CODE;
        public Decimal INVENTORY;
        public String UOM;
    }
    
}