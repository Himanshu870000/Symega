public class SampleLineItemCreation_UI {
    
    @AuraEnabled
    public static string getsampleProdFamily(string sampleId){
        system.debug('sampleId ====>' + sampleId);
        String getsampleProdFamily = [SELECT Id, Name, Product_Family__c FROM Project__c WHERE Id =: sampleId].Product_Family__c;
        return getsampleProdFamily;
    }
    
    @AuraEnabled
    public static Map<String, String> SampleLineItemcreation (List<Sample_Line_Item__c> SLIRecords, List<Id> deleteIdSet, Id sampleId){
        system.debug('SLI Records ====>' + SLIRecords);
        Map<String, String> responseMap = new Map<String, String>();
        try{
            Boolean showError = false;
            if(!deleteIdSet.isEmpty()) {
                List<Sample_Line_Item__c> sliToDeleteList = new List<Sample_Line_Item__c>();
                for(Id delId : deleteIdSet) {
                    sliToDeleteList.add(new Sample_Line_Item__c(Id = delId));
                }
                delete sliToDeleteList;
            }
            
            if(!SLIRecords.isEmpty()) {
                Id customerId = [SELECT Id, Account__c FROM Project__c WHERE Id =: sampleId].Account__c;
                system.debug('customerId ====>' + customerId);
                
                responseMap = checkProdCreationAcceptanceCriteria(SLIRecords, customerId);
                if(responseMap.size() == 0){
                    upsert SLIRecords;
                }
            }
            return responseMap;
        }
        catch(Exception e){
            system.debug('Error :: ' + e.getMessage() + 'At Line No :: ' + e.getLineNumber());
            return responseMap;
        }
    }
    
    @AuraEnabled
    public static List<Sample_Line_Item__c> getSLIList(string sampleId){
        system.debug('sampleId ====>' + sampleId);
        List<Sample_Line_Item__c> lineItemList = [SELECT Id, Name, Product__c, Quantity__c, Quantity_Unit__c, Packaging_Quantity__c, Packaging_Unit__c, Product_Max_Qty__c, Formula_Packaging_Qty__c, Product__r.Regulatory__c, OPTIVA_Recipe__r.Regulatory__c, OPTIVA_Recipe__r.Shelf_Life__c,
                                                  Expected_Shelf_Life__c, Additional_Comments__c, Customer_Instructions__c, Sample__c, Project_Quotient__r.SSC_Code__c, Product__r.Sampling_Qty_UNIT__c, Product__r.Name, Product__r.Max_sampling_Qty__c, Product__r.ProductCode, Product__r.Current_Shelf_Life__c, OPTIVA_Recipe__r.SSC_Code__c
                                                  FROM Sample_Line_Item__c WHERE Sample__c =: sampleId];
        return lineItemList;
    }
    
    @AuraEnabled
    public static Integer SampleLineItemCount (String sampleRecordId){
        Integer totalRecords = [SELECT COUNT() FROM Sample_Line_Item__c where Sample__c =: sampleRecordId];
        return totalRecords;
    }
    
    @AuraEnabled
    public static map<String,Map<String,String>> GetPicklistvalue (){
        
        map<String,Map<String,String>> FinalMap = new map<String,Map<String,String>>();
        Map<String,String> PackUnitOptions = new Map<String, String>();
        Map<String,String> QtyUnitOptions = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResultforPackUnit = Sample_Line_Item__c.Packaging_Unit__c.getDescribe();
        Schema.DescribeFieldResult fieldResultforQtyUnit = Sample_Line_Item__c.Quantity_Unit__c.getDescribe();
        
        List<Schema.PicklistEntry> PackUnitValues = fieldResultforPackUnit.getPicklistValues();
        List<Schema.PicklistEntry> QtyUnitValues = fieldResultforQtyUnit.getPicklistValues();
        
        for (Schema.PicklistEntry p: PackUnitValues) {
            PackUnitOptions.put(p.getValue(), p.getLabel());
        }
        for (Schema.PicklistEntry p: QtyUnitValues) {
            QtyUnitOptions.put(p.getValue(), p.getLabel());
        }
        FinalMap.put('PackUnit',PackUnitOptions);
        FinalMap.put('QtyUnit',QtyUnitOptions);
        system.debug('FinalMap :: ' + FinalMap);
        return FinalMap;        
    }
    
    
    private static Map<String, String> checkProdCreationAcceptanceCriteria(List<Sample_Line_Item__c> sliList, String customerId) {
        
        Set<Id> productIdSet = new Set<Id>();
        for(Sample_Line_Item__c sli : sliList){
            productIdSet.add(sli.Product__c);            
        }
        System.debug('--- '+ sliList+ '--- productIdSet' + productIdSet + ' customerId' +customerId);

        Map<Id, Product2> pMasterMap = new Map<Id, Product2>([SELECT Id, ProductCode, Product_Visibility__c, To_Be_Sold_By__c, Product_Used_By__c FROM Product2 WHERE Id IN : productIdSet]);
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
        
        if(!String.isEmpty(customerId)) {
            List<Project_Quotient__c> proQuotientList = [SELECT Id, SSC_Code__c, Sample_Project_Application__r.Account__c FROM Project_Quotient__c WHERE Sample_Project_Application__r.Account__c =: customerId AND Stage__c = 'Won' AND SSC_Code__c != null];
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
        Map<String, String> prodCodeWithErrorMsgMap = new Map<String, String>();
        for(Sample_Line_Item__c sli: sliList) {
            
            if(pMasterMap.containsKey(sli.Product__c) && (pMasterMap.get(sli.Product__c).Product_Visibility__c == null || pMasterMap.get(sli.Product__c).To_Be_Sold_By__c == null || pMasterMap.get(sli.Product__c).Product_Used_By__c == null )) {
                prodCodeWithErrorMsgMap.put(pMasterMap.get(sli.Product__c).ProductCode, 'Product Visibility/ To Be Sold By/ Product Used By is not set');
            }
            
            if(pMasterMap.containsKey(sli.Product__c) && (privateProductIdSet.contains(sli.Product__c) || publicProductIdSet.contains(sli.Product__c)) && tailormadeProductIdSet.contains(sli.Product__c) && (!customerSSCCodesMap.containsKey(customerId) || !customerSSCCodesMap.get(customerId).contains(pMasterMap.get(sli.Product__c).ProductCode.toLowerCase()))) {
                //response = pMasterMap.get(sli.Product__c).ProductCode + ': You cannot proceed with this operation. This is restricted product which is made available on certain conditions only.';
                prodCodeWithErrorMsgMap.put(pMasterMap.get(sli.Product__c).ProductCode, 'Restricted product');
            }

            if(restrictedProductIdSet.contains(sli.Product__c) && !adminProfileSet.contains(profileName)) {
                //response = pMasterMap.get(sli.Product__c).ProductCode + ': You cannot proceed with this operation. This product is restricted and has limited access.';
                prodCodeWithErrorMsgMap.put(pMasterMap.get(sli.Product__c).ProductCode, 'Restricted and has Limited access');
            }

            if(publicProductIdSet.contains(sli.Product__c) && (portfolioProductIdSet.contains(sli.Product__c) || foodServiceProductIdSet.contains(sli.Product__c)) && pMasterMap.containsKey(sli.product__c) && pMasterMap.get(sli.product__c).Product_Used_By__c != null) {
               
                List<String> productUsersCategories = pMasterMap.get(sli.product__c).To_Be_Sold_By__c != null ? pMasterMap.get(sli.product__c).To_Be_Sold_By__c.split(';') : new List<String>();
                
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
                        //response = pMasterMap.get(sli.Product__c).ProductCode +': This product is accessible to only ' +pMasterMap.get(sli.product__c).To_Be_Sold_By__c+ ' If you belong to this group and still cant proceed, please contact System Administrator.';
                        prodCodeWithErrorMsgMap.put(pMasterMap.get(sli.Product__c).ProductCode, 'This product is accessible to only ' + pMasterMap.get(sli.product__c).To_Be_Sold_By__c + ' group');
                    }
                }
                else if(!adminProfileSet.contains(profileName)){ //not admin then add error
                    //response = pMasterMap.get(sli.Product__c).ProductCode +': This product is accessible to only ' +pMasterMap.get(sli.product__c).To_Be_Sold_By__c+ ' If you belong to this group and still cant proceed, please contact System Administrator.';
                    prodCodeWithErrorMsgMap.put(pMasterMap.get(sli.Product__c).ProductCode, 'This product is accessible to only ' + pMasterMap.get(sli.product__c).To_Be_Sold_By__c + ' group');
                }
            }
        }
        system.debug('prodCodeWithErrorMsgMap -- ' + prodCodeWithErrorMsgMap);
        return prodCodeWithErrorMsgMap;
    }

    
}