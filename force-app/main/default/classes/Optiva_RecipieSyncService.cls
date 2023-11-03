@RESTResource(urlMapping='/syncoptivarecipie/*')
global without sharing class Optiva_RecipieSyncService {
    @HttpPost
    global static String syncOptivaRecipie(){
        try{
            DateTime processingStartTime = System.now();
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            
            String body = req.requestBody.toString();
            System.debug('REQUEST----'+body);

            if(String.isBlank(body))
                return 'Failed, Please provide optiva code';

            List<Object> mList = (List<Object>)JSON.deserializeUntyped(body);

            if(mList.isEmpty())
                return 'Failed, request body not found';

            String result = updateOptivaRecipie(mList);
            if(result == 'success') {
                HttpUtility.getInstance().createServiceLogger(body, result, '/syncoptivarecipie/*', 'POST', 200, processingStartTime, System.now()); //Log this request
            }else {
                RestContext.response.statusCode = 400;
                HttpUtility.getInstance().createServiceLogger(body, result, '/syncoptivarecipie/*', 'POST', 400, processingStartTime, System.now()); //Log this request
            }
            return result;
        }catch(Exception e){
            HandleBusinessException.captureError('Optiva_RecipieSyncService','syncOptivaRecipie', e);
            RestContext.response.statusCode = 400;
            return 'Failed, '+e.getMessage();
        }
    }

    private static String updateOptivaRecipie(List<Object> mList){
        try{
            List<OPTIVA_Recipe__c> recipeList = new List<OPTIVA_Recipe__c>();
            for(Object obj : mList){
                Map<String,Object> objMap = (Map<String,Object>) obj;
                OPTIVA_Recipe__c opRp = new OPTIVA_Recipe__c();

                if(objMap.containsKey('active')){
                    String [] s = objMap.get('active').toString().split(':');

                    //create a new field Picklist called 
                    opRp.Active__c = s[1]=='true';
                    opRp.Product_Visibility__c = Utility.capitalizeString(s[0]);
                }
                
                if(objMap.containsKey('ssc_code')){
                    //opRp.SSC_Code__c = (String) objMap.get('ssc_code');
                    opRp.SSC_Code__c = Utility.capitalizeString((String) objMap.get('ssc_code'));
                }
                if(objMap.containsKey('SSC_CODE')){
                    opRp.SSC_Code__c = Utility.capitalizeString((String) objMap.get('SSC_CODE'));
                }
                if(objMap.containsKey('created_by')){
                    opRp.Receipe_Created_By__c = Utility.capitalizeString((String) objMap.get('created_by'));
                }
                if(objMap.containsKey('last_modified_by')){
                    opRp.Receipe_Last_Modify_By__c = Utility.capitalizeString((String) objMap.get('last_modified_by'));
                }
                if(objMap.containsKey('recepie_currency')){
                    opRp.CurrencyIsoCode = Utility.capitalizeString((String) objMap.get('recepie_currency'));
                }
                if(objMap.containsKey('recepie_description')){
                    opRp.Recipe_Description__c = Utility.capitalizeString((String) objMap.get('recepie_description'));
                }
                if(objMap.containsKey('recepie_family')){
                    opRp.Recipe_Family__c = Utility.capitalizeString((String) objMap.get('recepie_family'));
                }
                if(objMap.containsKey('recepie_name')){
                    opRp.Name = Utility.capitalizeString((String) objMap.get('recepie_name'));
                }
                if(objMap.containsKey('quantity_unit_of_measure')){
                    opRp.Quantity_Unit_Of_Measure__c = Utility.capitalizeString((String) objMap.get('quantity_unit_of_measure'));
                }
                if(objMap.containsKey('allergen_status_required')){
                   //opRp.Allergen_Status_Required__c = (String) objMap.get('allergen_status_required');
                }
                if(objMap.containsKey('dosage_guideline')){
                    opRp.Dosage_Guidelines__c = Utility.capitalizeString((String) objMap.get('dosage_guideline'));
                }
                if(objMap.containsKey('end_application')){
                    opRp.End_Application__c = Utility.capitalizeString((String) objMap.get('end_application'));
                }
                if(objMap.containsKey('end_use_category')){
                    opRp.End_Use_Category__c = Utility.capitalizeString((String) objMap.get('end_use_category'));
                }
                if(objMap.containsKey('legacy_code')){
                    opRp.LEGACYCODE__c = Utility.capitalizeString((String) objMap.get('legacy_code'));
                }
                if(objMap.containsKey('legal_status')){
                    opRp.Legal_status__c = Utility.capitalizeString((String) objMap.get('legal_status'));
                }
                if(objMap.containsKey('moq')){
                    opRp.MOQ__c = Utility.capitalizeString((String) objMap.get('moq'));
                }
                if(objMap.containsKey('physical_form')){
                    opRp.PHYSICAL_FORM__c = Utility.capitalizeString((String) objMap.get('physical_form'));
                }
                if(objMap.containsKey('plant')){
                    opRp.Plant__c = Utility.capitalizeString((String) objMap.get('plant'));
                }
                if(objMap.containsKey('region')){
                    opRp.Region__c = Utility.capitalizeString((String) objMap.get('region'));
                }
                if(objMap.containsKey('regulatory')){
                    opRp.Regulatory__c = Utility.capitalizeString((String) objMap.get('regulatory'));
                }
                if(objMap.containsKey('sales_code')){
                    opRp.SALES_CODE__c = Utility.capitalizeString((String) objMap.get('sales_code'));
                }
                if(objMap.containsKey('shelf_life')){
                    opRp.Shelf_Life__c	 = Utility.capitalizeString((String) objMap.get('shelf_life'));
                }
                if(objMap.containsKey('solubility')){
                    opRp.SOLUBILITY__c = Utility.capitalizeString((String) objMap.get('solubility'));
                }
                recipeList.add(opRp);
            }

            if(!recipeList.isEmpty()){
                upsert recipeList SSC_Code__c;
            }
            return 'success';
        }catch(Exception e){
            HandleBusinessException.captureError('Optiva_RecipieSyncService','updateOptivaRecipie', e);
            return e.getMessage();
        }
    }
}