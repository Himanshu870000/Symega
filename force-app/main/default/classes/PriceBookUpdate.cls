global class PriceBookUpdate implements Database.Batchable<sObject>, Database.Stateful{
    global database.querylocator start(Database.BatchableContext BC)
    {
        String QueryString = 'SELECT Id,UnitPrice FROM PricebookEntry where UnitPrice != null and UnitPrice > 0';
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext BC, List<PricebookEntry> pbeList)
    {
        List<PricebookEntry> pbeListToUpdate = new List<PricebookEntry>();
        
        if(!pbeList.isEmpty()){
            for(PricebookEntry pbe : pbeList){
                pbe.UnitPrice = Math.round(pbe.UnitPrice * 100) / 100;
                pbeListToUpdate.add(pbe);
            }
            if(!pbeListToUpdate.isEmpty()){
                update pbeListToUpdate;
            }
        }        
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}