public class SearchProductSOSL {
    
    @AuraEnabled
    public static void UpdateProjectRec( string recordId ,string productId, string instruction){
        try{
            String code = '';
            if(!String.isEmpty(productId)){
                List<Product2> prodList = [SELECT Id, ProductCode FROM Product2 WHERE Id=: productId LIMIT 1];
                if(prodList.size()>0){
                    code = prodList[0].ProductCode;
                }
                
                List<OPTIVA_Recipe__c> recipeList = [SELECT Id, SSC_Code__c FROM OPTIVA_Recipe__c WHERE Id=: productId LIMIT 1];
                if(recipeList.size()>0){
                    code = recipeList[0].SSC_Code__c;
                }                
            }
            
            Project__c proRec = new Project__c();
            proRec.id = recordId;
            proRec.Product_ID__c = productId;
            proRec.Product_Code__c = code;
            proRec.Product_Instruction__c = instruction;
            update proRec;
        }catch(Exception e){
            System.debug('ERROR ::'+e.getMessage() +' LINE ::'+e.getLineNumber());
        }
        
    }
    
    @AuraEnabled
    public static prWrapper getprojectData(string proId){
        List<Project__c>  prolist = [Select Id, Product_ID__c, Product_Instruction__c from Project__c where  ID =: proId LIMIT 1];
        
        String name = '';
        if(!String.isEmpty(prolist[0].Product_ID__c)){
            List<Product2> prodList = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id=: prolist[0].Product_ID__c LIMIT 1];
            if(prodList.size()>0){
                name = prodList[0].Name;
            }
            
            List<OPTIVA_Recipe__c> recipeList = [SELECT Id, Name, SSC_Code__c FROM OPTIVA_Recipe__c WHERE Id=: prolist[0].Product_ID__c LIMIT 1];
            if(recipeList.size()>0){
                name = recipeList[0].Name;
            }                
        }
        
        prWrapper wrap = new prWrapper();
        wrap.prodInst = prolist[0].Product_Instruction__c;
        wrap.prodName = name;
        return wrap;
        
    }
    
    Public Class prWrapper{
        @AuraEnabled Public String prodInst;
        @AuraEnabled Public String prodName;
    }
    
}