/**
* @author [Dinesh B]
* @email dinesh.b@utilitarianLab.com
* @create date 2023-03-20 18:27:29
* @modify date 2023-03-20 18:27:29
* @desc [description]
*/

global class MonthlyVisitViewerController {
    
    public boolean displayPopup {get;set;} 
    public void closePopup() 
    {
        displayPopup = false; 
    } 
    public void showPopup() 
    {
        displayPopup = true; 
    } 
    
    global MonthlyVisitViewerController(){
        
    }
    
    
    
    
    @RemoteAction
    global static List<Visit__c> fetchPageData(string formatteddate) {
        system.debug('formatteddate------'+formatteddate);
        List<string> mtdList=formatteddate.split('-');
        string monthName=mtdList[1];
        String yearName=mtdList[0];
        List<Monthly_Beat_Plan__c> MBPlist=[SELECT id,Year__c,Status__c,Start_Date__c,OwnerId,Sales_User__c,Name,Month__c,End_Date__c,Month_Name__c,(SELECT id,Year__c,Name,Week_Identifier__c,Start_Day_of_Week__c,End_Day_of_Week__c,OwnerId,Monthly_Beat_Plan__c,Week_Number__c FROM Weekly_Beat_Plans__r) FROM Monthly_Beat_Plan__c WHERE Month_year__c=:yearName AND Month_Name__c=:monthName limit 1];
 		String mbpID =MBPlist[0].Id;
       	List<Visit__c> getAllvisitRecordList = [Select Id,KPI_Target__r.Name,Account__c,Account__r.Name,Lead__c,Lead__r.Name,Start_Date_Time__c,Route__c,Route__r.Name,Visit_Status__c,Actual_visit_date__c,KPI_Target_Name__c,KPI_Target__c From Visit__c Where (Account__c!=NUll or Lead__c !=Null) and MBPID__c =:mbpID];

        
        /*try{
            Map<String, Object> pageData = new Map<String,Object>();
            pageData.put('salesRepList', [SELECT Id, FirstName, LastName, UserName FROM User]);
            system.debug('--- pageData '+ pageData);
            return pageData;
        } catch (Exception e) {
            printError(e);
        }*/
        return getAllvisitRecordList;
    }
    
    // SELECT Id,Name,Assignment_Group__r.Name,Group_Member__r.Name FROM Assignment_Group_Member__c
    @RemoteAction
    global Static List<User> fetchGroupmemeber(String AssignementGropLocation){
        System.debug('AssignementGropLocation :'+AssignementGropLocation);
        try{
            List<User> getUserList = new List<User>();
            
            List<Assignment_Group_Member__c> getGMemList = [SELECT Id,Name,Assignment_Group__r.Name,Group_Member__r.Name FROM Assignment_Group_Member__c WHERE Assignment_Group__r.Name =: AssignementGropLocation];
            Set<String> gorupNameSet = new Set<String>();
            for(Assignment_Group_Member__c agm : getGMemList){
                gorupNameSet.add(agm.Group_Member__r.Name);
            }
            System.debug('gorupNameSet ->>>>>'+gorupNameSet);
            List<User> userList = [SELECT Id, FirstName, LastName, UserName FROM User WHERE Name IN: gorupNameSet];
            for(User use : userList){
                System.debug('use == >'+use);
                getUserList.add(use);
            }
            // getUserList.add( userList);
            System.debug('getUserList ::'+getUserList);
            return getUserList;
        }catch(Exception e){
            System.debug('The Error '+e.getMessage());
            System.debug('Erron Line '+e.getLineNumber());
        }
        return null;
    }
    
    // Showing Lead & Account in dropdown
    @RemoteAction
    global Static List<String> getcurrentUserRoutes(){
        try{
            List<String> routeList = new List<String>();
            for(Route__c route : [SELECT Id,Name,Route_Name_del__c,Sales_User__c FROM Route__c WHERE Sales_User__c=:UserInfo.getUserId()]){
                routeList.add(route.Route_Name_del__c);
            }
            if(routeList.size()>0){
                return routeList;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // Show Selected Location Record
    @RemoteAction
    global Static list<Location__c> getAllLocationRecords(){
        List<Location__c> getLocationList = [SELECT Id,Name FROM Location__c];
        System.debug('Location Record :'+getLocationList);
        return getLocationList;
    }
    
    // Show Record of Lead Based on Object & Location
    @RemoteAction
    global Static List<Lead> getSelectedObjectRecord(String objectName, String location){
        List<Lead> ledList = new List<Lead>();
        if(objectName == 'Lead'){
            ledList =[ SELECT Id,Name,Location__c FROM Lead Where   Location__c =: location];
        }
        System.debug('ledList Size ::'+ledList.Size()); 
        System.debug('ledList Record ::'+ledList);
        
        // if(objectName == 'Account'){
        //     System.debug('Account Method called');
        //     VisitSchedulerController.getSelectedAccountRecords(objectName,location); 
        // }
        return ledList;
    }
    
    // Show Record of Account Based on Object & Location
    @RemoteAction
    global Static List<Account> getSelectedAccountRecords(String objectName, string location){
        System.debug('location ::'+location);
        List<Account> accList = new List<Account>();
        if(objectName == 'Account'){
            accList= [SELECT Id,Name,Location__r.Name FROM Account WHERE Location__r.Name =:  location];
            System.debug('Account size :'+accList.size());
            System.debug('Account Record :'+accList);
        }
        return accList;
    }
    
    @RemoteAction
    global static String createVisits(List<Visit__c> visitList) {
        try{
            List<Visit__c> visitListt = new  List<Visit__c>();
            System.debug('--- visitList '+visitList);
            for(Visit__c vst: visitList){
                vst.Actual_visit_date__c=vst.Planned_visit_date__c;
                visitListt.add(vst);                  
            }
            
            upsert visitListt;
            return 'visits created successfully.';
        }catch(Exception e){
            printError(e);
        }
        return 'something went wrong.';
    }
    
    @RemoteAction
    global static Map<String,Object> getUserVisits(String routeName) {
        try{
            Map<String, Object> pageData = new Map<String,Object>();
            System.debug('routeName ===> '+routeName);
            if(!String.isBlank(routeName)) {
                String query = '%' +routeName +'%';
                System.debug('query ===> '+query);
                pageData.put('accountList', [SELECT Id,Name,BillingStreet,Geo_Location__latitude__s,Geo_Location__longitude__s,Geo_Location__c,ShippingCountry,ShippingState,ShippingStreet,ShippingPostalCode,ShippingCity,BillingCity,BillingCountry,BillingPostalCode,BillingState,(SELECT Id,Address__City__s, Address__CountryCode__s, Address__PostalCode__s, Address__StateCode__s, Address__Street__s, Geo_Location__c FROM Dispatch_Address__r) FROM Account WHERE BillingStreet LIKE : query LIMIT 10]);
                pageData.put('leadList', [Select Id, Name,Street FROM Lead WHERE Street LIKE : query ]);
                System.debug('User Data ::'+pageData);
                return pageData;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;   
    }
    
    @RemoteAction
    global static void deleteEvent(String eventID) {
        if(!String.isBlank(eventID))
            delete new Visit__c(Id = eventID);
    }
    
    // Get Search Result as Account
    @RemoteAction
    global static List<Account> getRepAccounts(String repId, String location) {
        List<Account> accList = new List<Account>();
        System.debug('repId ::'+repId);
        //System.debug('searchString ::'+searchString);
        //  String searchPattern = '%'+String.escapeSingleQuotes(searchString)+'%';
        accList = [SELECT Id, Name,Location__r.Name,owner.name,ShippingCountry,ShippingState,ShippingStreet,ShippingPostalCode,(SELECT Id,Address__City__s, Address__CountryCode__s, Address__PostalCode__s, Address__StateCode__s, Address__Street__s, Geo_Location__c FROM Dispatch_Address__r) FROM Account WHERE owner.name = :repId AND  Location__r.Name =: location AND owner.name !='jain'  LIMIT 15];
        System.debug('accList ::'+accList);
        return accList;
    }
    
    // Get Search Result as Lead
    @RemoteAction
    global Static List<Lead> getRepLeads(String repId,  String location){
        System.debug('repId ::'+repId);
        
        System.debug('location ::'+location);
        List<Lead> ledList = new List<Lead>();
        
        ledList = [SELECT Id,Name,Location__c,owner.LastName FROM Lead WHERE owner.LastName =: repId AND Location__c =:location  LIMIT 10];
        System.debug('leadList ::'+ledList);
        return ledList;
    }
    
    
    // Creare Visit Record on Account & Lead Drag
    @RemoteAction
    global Static String createVisitObjectType(Id SobjectId, string datestring, String geolatitude, String geolongitude){
        
        System.debug('datestring =====> ' + datestring);
        System.debug('SobjectId :'+SobjectId);
        String sObjName = SobjectId.getSObjectType().getDescribe().getName();
        System.debug('Object Name ::'+sObjName);
        if(sObjName == 'Lead'){
            Visit__c vs = new Visit__c();
            vs.Lead__c = SobjectId;
            vs.Assigned_User__c = UserInfo.getUserId();
            vs.Planned_visit_date__c = Date.valueOf(datestring);
            vs.Geo_Location__Latitude__s = Decimal.valueOf(geolatitude);
            vs.Geo_Location__Longitude__s =  Decimal.valueOf(geolongitude);
            insert vs;
            System.debug('Visit Record  for Lead ::'+vs);
            
        }else if(sObjName == 'Account'){
            Visit__c vs = new Visit__c();
            vs.Account__c = SobjectId;
            vs.Assigned_User__c = UserInfo.getUserId();
            vs.Planned_visit_date__c = Date.valueOf(datestring);
            vs.Geo_Location__Latitude__s = Decimal.valueOf(geolatitude);
            vs.Geo_Location__Longitude__s =  Decimal.valueOf(geolongitude);
            insert vs;
            System.debug('Visit Record  for Account ::'+vs);
        }       
        return 'SUCCESS';
    }
    
    @RemoteAction
    global Static String createVisitObjectTypev1(Id SobjectId, string datestring, String geolatitude, String geolongitude,String StartTime,String EndTime){
        List<Weekly_Beat_Plan__c> WBPRec=new List<Weekly_Beat_Plan__c>();
        System.debug('datestring =====> ' + datestring);
        System.debug('SobjectId :'+SobjectId);
        String sObjName = SobjectId.getSObjectType().getDescribe().getName();
        System.debug('Object Name ::'+sObjName);
        if(datestring!=null){
            Date selectedDate=Date.valueOf(datestring);
            Date weekStart = (selectedDate.toStartofWeek()).addDays(1);
            Date WeekEndDate=weekStart.addDays(6);
            system.debug('selectedDate--'+selectedDate);
            system.debug('weekStart--'+weekStart);
            system.debug('WeekEndDate--'+WeekEndDate);
            Id currentUserId = UserInfo.getUserId();
            if(weekStart!=null || WeekEndDate!=null){
                WBPRec=[Select Id,Start_Day_of_Week__c,End_Day_of_Week__c From Weekly_Beat_Plan__c Where Start_Day_of_Week__c>=:weekStart AND End_Day_of_Week__c<=:WeekEndDate AND OwnerId =: currentUserId];
                system.debug('WBPRec--'+WBPRec);
            }
        }
        Visit__c vs = new Visit__c();
        if(sObjName == 'Lead'){
            vs.Lead__c = SobjectId;
            vs.Assigned_User__c = UserInfo.getUserId();
            vs.Planned_visit_date__c = Date.valueOf(datestring);
            vs.Actual_visit_date__c = Date.valueOf(datestring);
            if(WBPRec[0].Id!=null){
                vs.Weekly_Beat_Plan__c=WBPRec[0].Id; 
            }
            String[] strStartTimeTimeSplit = StartTime.split(':');
            vs.Expected_Start_Time__c=Time.newInstance(Integer.valueOf(strStartTimeTimeSplit[0]),Integer.valueOf(strStartTimeTimeSplit[1]),0 ,0);
            String[] strEndTimeTimeSplit = EndTime.split(':');
            vs.Expected_End_Time__c=Time.newInstance(Integer.valueOf(strEndTimeTimeSplit[0]),Integer.valueOf(strEndTimeTimeSplit[1]),0 ,0);
            vs.Geo_Location__Latitude__s = Decimal.valueOf(geolatitude);
            vs.Geo_Location__Longitude__s =  Decimal.valueOf(geolongitude);
            insert vs;
            System.debug('Visit Record  for Lead ::'+vs);
            
        }else if(sObjName == 'Account'){
            
            vs.Account__c = SobjectId;
            vs.Assigned_User__c = UserInfo.getUserId();
            vs.Planned_visit_date__c = Date.valueOf(datestring);
            vs.Actual_visit_date__c = Date.valueOf(datestring);
            if(WBPRec[0].Id!=null){
                vs.Weekly_Beat_Plan__c=WBPRec[0].Id; 
            }
            String[] strStartTimeTimeSplit = StartTime.split(':');
            vs.Expected_Start_Time__c=Time.newInstance(Integer.valueOf(strStartTimeTimeSplit[0]),Integer.valueOf(strStartTimeTimeSplit[1]),0 ,0);
            String[] strEndTimeTimeSplit = EndTime.split(':');
            vs.Expected_End_Time__c=Time.newInstance(Integer.valueOf(strEndTimeTimeSplit[0]),Integer.valueOf(strEndTimeTimeSplit[1]),0 ,0);
            vs.Geo_Location__Latitude__s = Decimal.valueOf(geolatitude);
            vs.Geo_Location__Longitude__s =  Decimal.valueOf(geolongitude);
            insert vs;
            System.debug('Visit Record  for Account ::'+vs);
        }       
        return String.isBlank(vs.Id)?NULL:vs.Id;
    }
    
    
    static void printError(Exception e) {
        System.debug('--- ErrorMsg :'+e.getMessage());
        System.debug('--- ErrorLineNo :'+e.getMessage());
    }
    
    
    @RemoteAction
    global static Sobject getCurrentRecordGeoLocation(String recordId){
        if(!String.isBlank(recordId)){
            Id myId = Id.valueOf(recordId);
            String sObjName = myId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Lead'){
                System.debug('Lead Found');
                Lead led = [SELECT Id,Name,Geolocation__Latitude__s,Geolocation__Longitude__s FROM Lead WHERE Id =: recordId];
                System.debug('Lead Record :::'+led);
                return led;
            }else if(sObjName == 'Account'){
                System.debug('Account Found'); 
                Account acc = [SELECT Id,Name,Geo_Location__Latitude__s,Geo_Location__Longitude__s,ShippingCountry,ShippingState,ShippingStreet,ShippingPostalCode FROM Account WHERE Id =: recordId];
                System.debug('Account Record :::'+acc);
                return acc;
            }
            return null;
            
        }else{
            return null;
        }
    }

    @RemoteAction
    global static List<KPI_Target__c> showKpi(String visitId){
    List<KPI_Target__c> allKpiTargetRecList  = [Select Id,KPI_Target_Name__c,Monthly_Beat_Plan__c,Roles_and_KPI__c from KPI_Target__c where KPI_Target_Name__c!=null AND Monthly_Beat_Plan__c=:[Select MBPID__c,KPI_Target__c From Visit__c Where  Id =:visitId].MBPID__c];
   
  	return allKpiTargetRecList;
    }
    
    
    @RemoteAction
    global static String tagKIPToVisit(String visitId, String kPIId){
        Visit__c visit = new Visit__c(Id=visitId,KPI_Target__c=kPIId);
        update visit;
        return 'Success';
    }
}