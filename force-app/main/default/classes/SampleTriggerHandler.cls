/**
 * Author: DeaGle
 */
public without sharing class SampleTriggerHandler {
    
    private SampleTriggerHandler() {}
    static SampleTriggerHandler handlerInstance;

    static final String PROJECT_STATUS_PRD = 'Project Ready to Dispatch';
    static final Set<String> PROJECT_SAP_FAMILY_SET = new Set<String> {Constants.FAMILY_CPD, Constants.FAMILY_SPD, Constants.FAMILY_PLANT_BASED};
    static final Set<String> PROJECT_OPTIVA_FAMILY_SET = new Set<String> {Constants.FLAVOUR_API_NAME, Constants.COLOR_API_NAME};

    public static SampleTriggerHandler getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new SampleTriggerHandler();
        return handlerInstance;
    }

    public void onBeforeInsert(List<Project__c> sampleList) {
        Set<Id> accountIdSet = new Set<Id>();
        for(Project__c newSample : sampleList) {
            if(newSample.Account__c != null)
                accountIdSet.add(newSample.Account__c);
        }

        if(!accountIdSet.isEmpty())
            validateSample(sampleList, accountIdSet);
    }

    //Baski


    public void onBeforeUpdate(Map<Id,Project__c> oldMap,Map<Id,Project__c> newMap){

        Set<Id> projectIds = new Set<Id>();
        Set<Id> applicationIds = new Set<Id>();

        String projectRecId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        String applicationRecId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        
        for(Project__c proj : newMap.values()){
            if(proj.Product_Family__c != null && ((PROJECT_SAP_FAMILY_SET.contains(proj.Product_Family__c) && proj.Status__c == PROJECT_STATUS_PRD) || (PROJECT_OPTIVA_FAMILY_SET.contains(proj.Product_Family__c))) && proj.Total_Project_Quotient__c > 0 && proj.Total_Project_Quotient__c != oldMap.get(proj.Id).Total_Project_Quotient__c && proj.RecordTypeId==projectRecId){
                projectIds.add(proj.Id);
            }else if(proj.Total_Project_Quotient__c > 0 && proj.Total_Project_Quotient__c!=oldMap.get(proj.Id).Total_Project_Quotient__c && proj.RecordTypeId==applicationRecId){
                applicationIds.add(proj.Id);
            }
        }
        if(!projectIds.isEmpty()){
            createSampleAndSampleLineItem(projectIds);
        }
        if(!applicationIds.isEmpty()){
            createSampleAndSampleLineItem(applicationIds);
        }
    }

    public void onAfterUpdate(Map<Id,Project__c> oldMap, Map<Id,Project__c> newMap){

        Set<Id> projectIds = new Set<Id>();
        Set<Id> applicationIds = new Set<Id>();
        for(Project__c proj : newMap.values()){
            if(proj.Approval_Status__c == 'Accepted by Business Head' && proj.Approval_Status__c != oldMap.get(proj.Id).Approval_Status__c){
                system.debug('proj.Record_Type_Name__c -- ' + proj.Record_Type_Name__c);
                call_OPTIVA_API(proj.Id, proj.Record_Type_Name__c);
            }
        }
    }

    @future(callout=true)
    private static void call_OPTIVA_API(String recId, String recType){
        Optiva_LWC_NPD_Controller.syncSample(recId, recType);
    }


    private void validateSample(List<Project__c> sampleList, Set<Id> accountIdSet) {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Potential_Opportunity__c, Total_Team_Members__c FROM Account WHERE Id IN:accountIdSet AND Run_Validation_Rule__c = true AND RecordType.DeveloperName = 'Direct_Customer']);
        for(Project__c sRec : sampleList) {
            if(accountMap.containsKey(sRec.Account__c) && (accountMap.get(sRec.Account__c).Total_Team_Members__c == null || accountMap.get(sRec.Account__c).Potential_Opportunity__c > accountMap.get(sRec.Account__c).Total_Team_Members__c)) {
                sRec.addError(Constants.OPP_ACC_TEAM_MEMBER_VALIDATION_MSG);
            }
        }
    }

    @future(callout=true)
    public static void submitToOptivaFuture(String id){
        System.debug('RESPONSE-----'+Optiva_Callout.sampleCreation(id));
    }


    private static void createSampleAndSampleLineItem(Set<Id> projectIds){
        //TODO:- Map missing fields on sample after confirmation;

        String projectRecId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Sample').getRecordTypeId();
        Map<String,Boolean> checkValues = new Map<String,Boolean>();
        Map<Id,Project__c> samples = new Map<Id,Project__c>();
        Map<Id,Project__c> projects = new Map<Id,Project__c>([Select Id,Name,Opportunity__c,Sampling_Quantity_Unit__c,Parent_Project__c,Auto_Submit_Sample__c,Opportunity__r.Account.OwnerId,Expected_Annual_Value__c,End_Use_category__c,End_Use_Applications__c,Account__c,Opportunity_Close_Date__c,Sampling_Quantity_details__c ,CurrencyIsoCode, Opportunity__r.Account.Customer_Contact__r.MailingCity, Opportunity__r.Account.Customer_Contact__r.MailingState, Opportunity__r.Account.Customer_Contact__r.MailingCountry, Opportunity__r.Account.Customer_Contact__r.MailingPostalCode, Opportunity__r.Account.Customer_Contact__r.MailingStreet, Opportunity__r.Account.ShippingCity, Opportunity__r.Account.ShippingState, Opportunity__r.Account.ShippingCountry, Opportunity__r.Account.ShippingPostalCode, Opportunity__r.Account.ShippingStreet, Opportunity__r.Account.Customer_Contact__r.MailingAddress, (Select Id,Product_Name__c,Name,SSC_Code__c,Description__c From Project_Quotients__r) From Project__c Where Id In :projectIds]);
        Map<Id,List<Sample_Line_Item__c>> projSampleLineItemMap = new Map<Id,List<Sample_Line_Item__c>>();

        for(Project__c proj : projects.values()){
            
            Project__c sample = new Project__c();
            sample.RecordTypeId = projectRecId;
            sample.Account__c = !String.isEmpty(proj.Account__c)?proj.Account__c:null;
            sample.Opportunity__c = !String.isEmpty(proj.Opportunity__c)?proj.Opportunity__c:null;
            sample.Sample_Name__c = proj.Name + ' - Sample';
            sample.CurrencyIsoCode = proj.CurrencyIsoCode;
            sample.Opportunity_Close_Date__c = proj.Opportunity_Close_Date__c;
            sample.End_Use_category__c = !String.isEmpty(proj.End_Use_category__c)?proj.End_Use_category__c : '';
            sample.End_Use_Applications__c = !String.isEmpty(proj.End_Use_Applications__c)?proj.End_Use_Applications__c : '';
            sample.Expected_Annual_Value__c = proj.Expected_Annual_Value__c ;
            sample.Sample_Project__c = proj.Id;
            sample.OwnerId = proj.Opportunity__r.Account.OwnerId;
            //Add address fields here.
            if(proj.Opportunity__r.Account.Customer_Contact__c != null && proj.Opportunity__r.Account.Customer_Contact__r.MailingAddress != null) {
                sample.City__c = proj.Opportunity__r.Account.Customer_Contact__r.MailingCity;
                sample.State__c = proj.Opportunity__r.Account.Customer_Contact__r.MailingState;
                sample.Country__c = proj.Opportunity__r.Account.Customer_Contact__r.MailingCountry;
                sample.Postal_Code__c = proj.Opportunity__r.Account.Customer_Contact__r.MailingPostalCode;
                sample.Street__c = proj.Opportunity__r.Account.Customer_Contact__r.MailingStreet; 
            }
            else {
                sample.City__c = proj.Opportunity__r.Shipping_City__c;
                sample.State__c = proj.Opportunity__r.Shipping_State__c;
                sample.Country__c = proj.Opportunity__r.Shipping_Country__c;
                sample.Postal_Code__c = proj.Opportunity__r.Shipping_Postal_Code__c;
                sample.Street__c = proj.Opportunity__r.Shipping_Street__c;
            }
            
            sample.Billing_City__c = proj.Opportunity__r.Billing_City__c;
            sample.Billing_State__c = proj.Opportunity__r.Billing_State__c;
            sample.Billing_Country__c = proj.Opportunity__r.Billing_Country__c;
            sample.Billing_Postal_Code__c = proj.Opportunity__r.Billing_Postal_Code__c;
            sample.Billing_Street__c = proj.Opportunity__r.Billing_Street__c; 
            
            samples.put(proj.Id,sample);
            checkValues.put(proj.Id,proj.Auto_Submit_Sample__c); 
            for(Project_Quotient__c pq :proj.Project_Quotients__r){

                Sample_Line_Item__c sli = new Sample_Line_Item__c();
                sli.Project_Quotient__c = pq.Id;
                sli.Quantity_Unit__c = proj.Sampling_Quantity_Unit__c;
                sli.Quantity__c = proj.Sampling_Quantity_details__c;
                sli.Additional_Comments__c = pq.Description__c;
                sli.Packaging_Unit__c = proj.Sampling_Quantity_Unit__c;

                if(projSampleLineItemMap.containsKey(proj.Id)){
                    projSampleLineItemMap.get(proj.Id).add(sli);
                }else{
                    projSampleLineItemMap.put(proj.Id,new List<Sample_Line_Item__c>{sli});
                }
            }
        }

        insert samples.values();

        List<Sample_Line_Item__c> sampleLineItems = new List<Sample_Line_Item__c>();
        Set<Id> samplesId = new Set<Id>();

        for(Project__c sample : samples.values()){
            if(projSampleLineItemMap.containsKey(sample.Sample_Project__c)){
                for(Sample_Line_Item__c sli : projSampleLineItemMap.get(sample.Sample_Project__c)){
                    sli.Sample__c = sample.Id;
                    sampleLineItems.add(sli);
                }
                samplesId.add(sample.Id);
            }
        }

        insert sampleLineItems;

        
        for(Project__c p : samples.values()){   
            if(checkValues.containsKey(p.Sample_Project__c) && checkValues.get(p.Sample_Project__c ))
            {
                if(Limits.getLimitFutureCalls()>Limits.getFutureCalls()){
                    submitToOptivaFuture(p.Id);        
                }
            }
        }
            
    }


}