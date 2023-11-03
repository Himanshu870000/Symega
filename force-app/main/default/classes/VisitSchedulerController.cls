/**
 * Author :
 */
public without sharing class VisitSchedulerController {
    
    @RemoteAction
    public static Map<String,Object> fetchPageData() {
        try {

            Boolean isAllowedProfile = false;

            Map<String, Object> pageData = new Map<String,Object>();
            pageData.put('salesRepList', [SELECT Id, FirstName, LastName, UserName FROM User]);

            Id currentUserProfileId = UserInfo.getProfileId();
            String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;

            List<Beat_Plan_Configuration__c> bpcs = Beat_Plan_Configuration__c.getall().values();
         
            for(Beat_Plan_Configuration__c bpc: bpcs){
                if(bpc.Name.equalsIgnoreCase(profileName)){
                    isAllowedProfile = true;
                }
            }

            pageData.put('allowedProfiles',isAllowedProfile);
            pageData.put('currentUserId',UserInfo.getUserId());
            system.debug('--- pageData '+ pageData);
            return pageData;
        } catch (Exception e) {
            printError(e);
        }
        return null;
    }

    @RemoteAction
    public static String createVisits(List<Visit__c> visitList) {
        try{
            System.debug('--- visitList '+visitList);
            upsert visitList;
            return 'visits created successfully.';
        }catch(Exception e){
            HandleBusinessException.captureError('VisitSchedularController','CreateVisits',e);
            printError(e);
        }
        return 'something went wrong.';
    }

    @RemoteAction
    public static Map<String,Object> getUserVisits(String userId) {
        Map<String, Object> pageData = new Map<String,Object>();
        if(!String.isBlank(userId)) {
            pageData.put('accountList', [SELECT Id,Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, (SELECT Address__City__s, toLabel(Address__CountryCode__s), Address__PostalCode__s, toLabel(Address__StateCode__s), Address__Street__s, Geo_Location__c FROM Dispatch_Address__r) FROM Account WHERE OwnerId = :userId LIMIT 15]);
            pageData.put('visitList', [Select Id, Name, Account__c, Account__r.Name,Lead__r.Name, Planned_visit_date__c, CheckIn__c, Check_Out__c, Status__c FROM Visit__c WHERE /* Actual_Visit_Date__c >= TODAY AND  */(Account__c != null OR Lead__c!=null) AND Assigned_User__c = :userId AND Actual_Visit_Date__c = null]);
        }
        return pageData;
    }

    @RemoteAction
    public static void deleteEvent(String eventID) {
        if(!String.isBlank(eventID))
            delete new Visit__c(Id = eventID);
    }

    @RemoteAction
    public static List<Account> getRepAccounts(String repId, String searchString,String selectedTab) {
        String searchPattern = '%'+String.escapeSingleQuotes(searchString)+'%';
        return [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude,(SELECT Address__City__s, toLabel(Address__CountryCode__s), Address__PostalCode__s, toLabel(Address__StateCode__s), Address__Street__s, Geo_Location__c FROM Dispatch_Address__r) FROM Account WHERE OwnerId = :repId AND Name LIKE :searchPattern LIMIT 15];
    }

    @RemoteAction
    public static List<Lead> getRepLeads(String repId, String searchString) {
        String searchPattern = '%'+String.escapeSingleQuotes(searchString)+'%';
        return [SELECT Id, Name, Street, City, State, PostalCode, Country, Latitude, Longitude FROM Lead WHERE OwnerId = :repId AND Name LIKE :searchPattern LIMIT 15];
    }

    static void printError(Exception e) {
        System.debug('--- ErrorMsg :'+e.getMessage());
        System.debug('--- ErrorLineNo :'+e.getMessage());
    }

}