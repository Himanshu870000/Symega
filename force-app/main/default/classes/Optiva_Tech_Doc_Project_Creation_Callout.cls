public without sharing class Optiva_Tech_Doc_Project_Creation_Callout {
    
    public static Map<String,String> submitProject(Project__c pro){
        try{
            Map<String,String> responseMap = new Map<String,String>();
            String reqBody = getReqBody(pro);

            System.debug('Body---'+reqBody);

            DateTime startDate = System.now();
    
           // Map<String,String> respMap = HTTPUtility.getInstance().httpReqHelper(headerMap,'POST',reqBody,'');
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
    
            req.setEndpoint('callout:Optiva/CreateNewProject');
            req.setHeader('content-type', 'application/json');
            req.setHeader('x-functions-key', Constants.OPTIVA_AUTH_HEADER);
            req.setBody(reqBody);
            req.setHeader('Content-length', String.valueOf(reqBody.length()));
            req.setTimeout(60 * 1000);
            HttpResponse resp = http.send(req);

            DateTime endDate = System.now();
    
            if(resp.getStatusCode()==200 || resp.getStatusCode()==201){
                responseMap.put('status','Success');
                responseMap.put('code',String.valueOf(resp.getStatusCode()));
                responseMap.put('message',resp.getBody());
                return responseMap;
            }else{
                HandleBusinessException.captureCalloutError('Optiva_NPDCreationCallout','createProject',reqBody,resp.getStatusCode(),resp.getBody());    
            }
    
            HttpUtility.createLog(req,resp,startDate,endDate);
            responseMap.put('status','Failure');
            responseMap.put('code',String.valueOf(resp.getStatusCode()));
            responseMap.put('message',resp.getBody());
            
            System.debug('Response-----' + resp.getBody());
            return responseMap;
        }catch(Exception e){
            System.debug('Error ----'+e);
            return null;
        }
    }

    public static String getReqBody(Project__c pro){
        try{
            Optiva_Project_Creation_Wrapper opWrapper = new Optiva_Project_Creation_Wrapper();

            String sscCode = '';

            try{
                String objName = Id.valueOf(pro.Product_ID__c).getSObjectType().getDescribe().getName();
                if(objName=='Product2'){
                    sscCode = [Select ProductCode From Product2 Where Id=:pro.Product_ID__c].ProductCode;
                }else if(objName=='OPTIVA_Recipe__c'){
                    sscCode = [Select SSC_Code__c From OPTIVA_Recipe__c Where Id=:pro.Product_ID__c].SSC_Code__c;
                }else{
                    sscCode = pro.Product_ID__c;
                }
            }catch(Exception e){
                sscCode = pro.Product_ID__c;
            }
            
            // 21/10/2022
            opWrapper.project_sf_code = pro.Id;
            opWrapper.project_title = pro.Project_Name__c;
            opWrapper.project_type = 'External';
            opWrapper.project_category = 'Flavour';
            opWrapper.opp_type_int = 'Sales';
            opWrapper.opp_sub_type_sales = 'Tech_Doc';
            opWrapper.prod_spec = convertBooleanToInteger(pro.Product_Spec__c);
            opWrapper.msds = convertBooleanToInteger(pro.MSDS__c);
            opWrapper.country_comp = convertBooleanToInteger(pro.Country_of_Compliance__c);
            opWrapper.allergen = convertBooleanToInteger(pro.Allergen__c);
            opWrapper.nutritional = convertBooleanToInteger(pro.Nutritional__c);
            opWrapper.other = convertBooleanToInteger(pro.Other__c);
            opWrapper.prod_code_dev = sscCode;
            opWrapper.target_date = pro.Target_Date__c!=null?Utility.parseDateIntoSlash(String.valueOf(pro.Target_Date__c)):'';
            
            //NEW ADDITIONS
            opWrapper.cust_code = pro.Opportunity__r.Account_Billing_Address__c ? pro.Opportunity__r.Account.Customer_Code_SAP__c : pro.Opportunity__r.Customer_Billing_Address__r.Customer_Code_SAP__c;
            opWrapper.created_by = pro.CreatedBy.Name;
    
            return JSON.serialize(opWrapper);    
        }catch(Exception e){
            System.debug('Error to create wrapper---'+e.getMessage());
            return null;
        }
    }   

    public static String convertBooleanToInteger(boolean res){
        return res?'1':'0';//String.isBlank(res)?'0':res=='Yes'?'1':'0';
    }

}