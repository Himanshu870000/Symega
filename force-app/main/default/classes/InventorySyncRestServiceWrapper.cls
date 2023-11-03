public without sharing class InventorySyncRestServiceWrapper {
    public List<RestProdWrapper> productOrder;
    public class RestProdWrapper{
        public string HALB;
        public integer Inventory;
        public String UOM;
    }
    
    public static List<InventorySyncRestServiceWrapper> parse(String json){
        return (List<InventorySyncRestServiceWrapper>) System.JSON.deserialize(json, List<InventorySyncRestServiceWrapper>.class);
    }
}