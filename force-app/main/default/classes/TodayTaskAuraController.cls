public class TodayTaskAuraController {


    @AuraEnabled
    public static void createVisitActivity(Id opportunityId, Id visitId) {
        System.debug('opportunityId------>'+opportunityId);
        System.debug('visitId----->'+visitId);
        if (opportunityId != null && visitId != null) {
            Visit_Activity__c visitActivity = new Visit_Activity__c();
            visitActivity.Opportunity__c = opportunityId;
            visitActivity.Visit__c = visitId;
    
            try {
                insert visitActivity;
                System.debug('Visit_Activity__c record created successfully.');
            } catch (Exception e) {
                System.debug('Error creating Visit_Activity__c record: ' + e.getMessage());
            }
        } else {
            System.debug('Opportunity Id and/or Visit Id is null. Visit_Activity__c record not created.');
        }
    }
    
    //method for getting all visit records based on date passed
    @AuraEnabled
    public static todaytaskWrapper getAllVisitTodays(String visitDate){
        System.debug('visitDate-------->'+visitDate);
        List<Visit__c> visitListToShow = new List<Visit__c>();
        try{
            if(String.isNotBlank(visitDate)){
                String[] arrTest = visitDate.split('T');
                string[] dateArray = arrTest[0].split('-');
                Integer year = Integer.valueOf(dateArray[0]);
                Integer month = Integer.valueOf(dateArray[1]);
                Integer day = Integer.valueOf(dateArray[2]);
                date VisitFormatedDate = date.newInstance(year, month, day);
                Id currentUserId = UserInfo.getUserId();
                visitListToShow = [SELECT Id, Name, Status__c, Account__c, Duration__c, Account__r.Name, Account__r.Website, Account__r.Email__c, Account__r.Phone,  Visit_Time__c,Visit_Status__c,Check_In_Time__c,
                                   Planned_visit_date__c, Weekly_Beat_Plan__c, KPI_Target__c, KPI_Target__r.KPI_Target_Name__c,Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,
                                   Account__r.BillingPostalCode,Account__r.BillingCountry,Geo_Location__latitude__s, Geo_Location__longitude__s, Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c,Expected_Start_Time__c FROM Visit__c 
                                   WHERE Planned_visit_date__c=:VisitFormatedDate AND Account__r.BillingStreet !=null AND Account__r.BillingCity !=null AND Assigned_User__c=: currentUserId AND Status__c != 'Completed'];
                if(visitListToShow.size()>0){
                    integer compVisitCount=0;
                    integer pendingVisitCount =0;
                    boolean approved = false;
                    for(Visit__c vs : visitListToShow){
                        System.debug('Approval Status-->'+ vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c);
                        if(vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c != null && vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c == 'Approved'){
                        approved = true;
                    }
                        if(vs.Status__c == 'PENDING'){
                            compVisitCount =  compVisitCount + 1;
                        }
                        if(vs.Status__c == 'COMPLETED'){
                            pendingVisitCount = pendingVisitCount + 1;
                        }
                    }
                    String userId = userInfo.getUserId();
                    system.debug('userId::'+userId);
                    List<Day_Visit_Plan__c> dayVisitList = [SELECT Id FROM Day_Visit_Plan__c WHERE Start_Date__c=today AND Service_Executive__c =: userId];
                    System.debug('dayVisitList === >'+dayVisitList);
                    System.debug('compVisitCount === >'+compVisitCount);
                    System.debug('pendingVisitCount === >'+pendingVisitCount);
                    todaytaskWrapper wrap = new todaytaskWrapper();
                    wrap.isApproved = approved;
                    wrap.visitList = visitListToShow;
                    wrap.completedVisit = compVisitCount;
                    wrap.pendingVisit = pendingVisitCount;
                    if(!dayVisitList.isEmpty()){
                        wrap.dvpList = dayVisitList;
                    }
                    System.debug('wrap Data === >'+wrap);
                    return wrap;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }



    @AuraEnabled
    public static todaysCompletedTaskWrapper GetCompletedVisitRecords(String visitDate){
        System.debug('visitDate------>'+visitDate);
        List<Visit__c> visitListToShow = new List<Visit__c>();
        try{
            if(String.isNotBlank(visitDate)){
                String[] arrTest = visitDate.split('T');
                string[] dateArray = arrTest[0].split('-');
                Integer year = Integer.valueOf(dateArray[0]);
                Integer month = Integer.valueOf(dateArray[1]);
                Integer day = Integer.valueOf(dateArray[2]);
                date VisitFormatedDate = date.newInstance(year, month, day);
                Id currentUserId = UserInfo.getUserId();
                visitListToShow = [SELECT Id, Name, Status__c, Account__c, Duration__c,District__c,Actual_visit_date__c, Visit_Objective__c, Taluk__c, Night_stay__c, Account__r.Name, Account__r.Website, Account__r.Email__c, Account__r.Phone,  Visit_Time__c,Visit_Status__c,Check_In_Time__c,
                                   Planned_visit_date__c, Weekly_Beat_Plan__c, KPI_Target__c, KPI_Target__r.KPI_Target_Name__c,Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,
                                   Account__r.BillingPostalCode,Account__r.BillingCountry,Geo_Location__latitude__s, Geo_Location__longitude__s, Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c FROM Visit__c 
                                   WHERE Planned_visit_date__c=:VisitFormatedDate AND Account__r.BillingStreet !=null AND Account__r.BillingCity !=null AND Assigned_User__c=: currentUserId AND Status__c = 'Completed'];

                System.debug('visitListToShow----->'+visitListToShow);

                if(visitListToShow.size()>0){
                    integer compVisitCount=0;
                    integer pendingVisitCount =0;
                    boolean approved = false;
                    for(Visit__c vs : visitListToShow){
                        System.debug('Approval Status-->'+ vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c);
                        if(vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c != null && vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c == 'Approved'){
                        approved = true;
                    }
                        if(vs.Status__c == 'PENDING'){
                            compVisitCount =  compVisitCount + 1;
                        }
                        if(vs.Status__c == 'COMPLETED'){
                            pendingVisitCount = pendingVisitCount + 1;
                        }
                    }
                    String userId = userInfo.getUserId();
                    system.debug('userId::'+userId);
                    List<Day_Visit_Plan__c> dayVisitList = [SELECT Id FROM Day_Visit_Plan__c WHERE Start_Date__c=today AND Service_Executive__c =: userId];
                    System.debug('dayVisitList === >'+dayVisitList);
                    System.debug('compVisitCount === >'+compVisitCount);
                    System.debug('pendingVisitCount === >'+pendingVisitCount);
                    todaysCompletedTaskWrapper wrap = new todaysCompletedTaskWrapper();
                    wrap.isApproved = approved;
                    wrap.completedVisitList = visitListToShow;
                    wrap.completedVisit = compVisitCount;
                    wrap.pendingVisit = pendingVisitCount;
                    if(!dayVisitList.isEmpty()){
                        wrap.dvpList = dayVisitList;
                    }
                    System.debug('wrap Data === >'+wrap);
                    return wrap;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }

    public class todaysCompletedTaskWrapper{
        @AuraEnabled
        public Integer completedVisit;
        @AuraEnabled
        public Integer pendingVisit;
        @AuraEnabled
        public List<Visit__c> visitList;
        @AuraEnabled
        public List<Visit__c> completedVisitList;
        @AuraEnabled
        public List<Day_Visit_Plan__c> dvpList;
        @AuraEnabled
        public boolean isApproved;
    }
    
    
    // ==========================================================================================================================================================================================================
    // Method get Selected Vist Recor Details
    @AuraEnabled
    public static Visit__c getSelectedVisitDetails(String visitId){
        Visit__c visitRec = new Visit__c();
        try{
            if(String.isNotBlank(visitId)){
                visitRec = [SELECT Id, Name, Status__c, Account__c, Duration__c, Account__r.Name, Account__r.Website, Account__r.Email__c, Account__r.Phone,  
                            CheckIn__Latitude__s, Check_Out__Latitude__s, Visit_Time__c, Planned_visit_date__c, Weekly_Beat_Plan__c, KPI_Target__c, KPI_Target__r.KPI_Target_Name__c,Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,Account__r.BillingPostalCode,Account__r.BillingCountry FROM Visit__c WHERE Id=:visitId LIMIT 1];
                if(visitRec !=null){
                    System.debug('visitRec === >'+visitRec);
                    return visitRec;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    public class todaytaskWrapper{
        @AuraEnabled
        public Integer completedVisit;
        @AuraEnabled
        public Integer pendingVisit;
        @AuraEnabled
        public List<Visit__c> visitList;
        @AuraEnabled
        public List<Day_Visit_Plan__c> dvpList;
        @AuraEnabled
        public boolean isApproved;
    }
    
    // ==========================================================================================================================================================================================================
    // Method for Creating Day Visit Plan on Start Day Button Click
    @AuraEnabled
    public static Day_Visit_Plan__c StartDayVisitForVistitRecord(String startLat,String startLang,List<Visit__c> visitRecList){
        System.debug('startLat == >'+startLat + ' && startLang === >'+startLang + ' && visitRecList === >'+visitRecList);
        List<Visit__c> visitListToUpdate = new List<Visit__c>();
        DateTime todayDate = system.now();
        String monthName = todayDate.format('MMMMM');
        Date todayDate2 = system.today();
        //monthName = '\'%' + monthName + '%\'';
        String yearName = String.valueOf(todayDate.Year());
        Id currUserId = UserInfo.getUserId();
        System.debug('monthName-->'+ monthName);
        System.debug('yearName-->'+ yearName);
        Monthly_Travel_Expense__c mte;
        List<Monthly_Travel_Expense__c> mteList = [select id from Monthly_Travel_Expense__c WHERE Month_Name__c =:monthName AND Expense_Year__c =:yearName AND Sales_User__c =:currUserId limit 1];
        //Monthly_Travel_Expense__c mte = [select id from Monthly_Travel_Expense__c WHERE Month_Name__c =:monthName AND Expense_Year__c =:yearName AND Sales_User__c =:currUserId limit 1];
        System.debug('mteList-->' + mteList);
        if(mteList.size()==0){
           mte = new Monthly_Travel_Expense__c();
            String mteName = 'MTE - ' + monthName;
            mte.Name = mteName;
            mte.Sales_User__c = currUserId;
            mte.Start_Date__c = todayDate2.toStartOfMonth();
            mte.End_Date__c = todayDate2.addMonths(1).toStartofMonth().addDays(-1);
            insert mte;
        }else{
            mte = mteList[0];
        }
       
        try{
            if(String.isNotBlank(startLat) && string.isNotBlank(startLang)){
                Day_Visit_Plan__c vstPlan = new Day_Visit_Plan__c();
                vstPlan.Start_Location__Latitude__s =Decimal.valueOf(startLat);
                vstPlan.Start_Location__Longitude__s = Decimal.valueOf(startLang);
                vstPlan.Service_Executive__c = Userinfo.getUserId();
                vstPlan.Monthly_Travel_Expense__c = mte.Id;
                vstPlan.Start_Date__c = system.now();
                insert vstPlan;
                if(String.isNotBlank(vstPlan.Id)){
                    for(Visit__c vs : visitRecList){ 
                        vs.Visit_Plan__c = vstPlan.id;
                        visitListToUpdate.add(vs);
                    }
                    if(visitListToUpdate.size()>0){
                        update visitListToUpdate;
                        System.debug('Updated Visit Record ==== >'+visitListToUpdate);
                        if(visitListToUpdate.size()>0){
                            System.debug('Day Visit Plan Record ==>'+vstPlan);
                            return vstPlan;
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // ==========================================================================================================================================================================================================
    // Method for End Day Visit / Update End Location Update
    @AuraEnabled
    public static Day_Visit_Plan__c updateEndDayVisitRecord(String endLat,String endLong){
        Day_Visit_Plan__c  vstPlan = new Day_Visit_Plan__c();
        vstPlan = [select id from Day_Visit_Plan__c where Service_Executive__c =:UserInfo.getUserId() and Start_Date__c = today LIMIT 1];
        try{
            if(vstPlan != null){
                vstPlan.Id = vstPlan.Id;
                if(endLat != null)
                vstPlan.End_Location__Latitude__s = Decimal.valueOf(endLat);
                if(endLong != null)
                vstPlan.End_Location__Longitude__s = Decimal.valueOf(endLong);
                vstplan.End_Date__c = system.now();
                update vstPlan;
                System.debug('Updated Day Visit Plan Record ==== >'+vstPlan);
                return vstPlan;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // ==========================================================================================================================================================================================================
    // Method for Ahmed Visit Update
    @AuraEnabled
    public static Visit__c updateAmendVisitRecord(Visit__c visitRec){
        Visit__c vsRec = new Visit__c();
        try{
            if(visitRec != null){
                update visitRec;
            }
            System.debug('visitRec === >'+visitRec);
            return visitRec;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }

    //==========================================================================================================================================================================================================
    @AuraEnabled
    public static void saveTask(Task taskRec){
        try{
            if(taskRec !=null){
                System.debug('taskRec === >'+taskRec);
                taskRec.OwnerId = userInfo.getUserId();
                insert taskRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }

    //==========================================================================================================================================================================================================
    @AuraEnabled
    public static void LogCall(Task taskRec){
        try{
            if(taskRec !=null){
                System.debug('taskRec === >'+taskRec);
                taskRec.OwnerId = userInfo.getUserId();
                /*DateTime dt = System.Now();
                Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                taskRec.ActivityDate = myDate;*/
                insert taskRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    //==========================================================================================================================================================================================================
    @AuraEnabled
    public static void saveOpportunity(Opportunity oppRec){
        try{
            if(oppRec !=null){
                System.debug('oppRec === >'+oppRec);
                insert oppRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    //==========================================================================================================================================================================================================
    @AuraEnabled
    public static void saveCase(Case caseRec){
        String userId = userInfo.getUserId();
        try{
            if(caseRec !=null){
                System.debug('caseRec === >'+caseRec);
                caseRec.OwnerId = userId;
                insert caseRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }

    //==========================================================================================================================================================================================================
    // Method for Check in on Visit Record
    @AuraEnabled
    public static Visit__c  checkInUpdateVisit(String checkInLat,String checkInLang, String recId){
        System.debug('checkInLat--> ' + checkInLat + 'checkInLang--> '+ checkInLang + 'recId--> '+ recId);
        Visit__c visRec = [SELECT Id,Name,Actual_visit_date__c,CheckIn__Latitude__s,CheckIn__Longitude__s, Check_Out__Latitude__s, Check_Out__Longitude__s, Visit_Status__c FROM Visit__c WHERE Id=:recId];
        System.debug('visRec--> ' + visRec);
        try{
            if(String.isNotBlank(checkInLat) && String.isNotBlank(checkInLang)){
                visRec.CheckIn__Latitude__s = Decimal.valueOf(checkInLat);
                visRec.CheckIn__Longitude__s =  Decimal.valueOf(checkInLang);
                visRec.Visit_Status__c = 'In Progress';
                visRec.Check_In_Time__c = System.now();
                update visRec;
                System.debug('Check In Visit Update Record === >'+visRec);
                return visRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
       return null;
    }

    //==========================================================================================================================================================================================================
    // Method for Check Out in Visit Record
    @AuraEnabled
    public static Visit__c checkOutUpdateVisit(String checkOutLat,string checkOutLong, String recId){
        System.debug('checkOutLat--> ' + checkOutLat + 'checkOutLong--> '+ checkOutLong + 'recId--> '+ recId);
        Visit__c visRec =[SELECT Id,Name,Actual_visit_date__c,CheckIn__Latitude__s,CheckIn__Longitude__s, Check_Out__Latitude__s, Check_Out__Longitude__s, Visit_Status__c FROM Visit__c WHERE Id=:recId];
        System.debug('visRec--> ' + visRec);
        try{
            if(String.isNotBlank(checkOutLat) && String.isNotBlank(checkOutLong)){
                visRec.Check_Out__Latitude__s = Decimal.valueOf(checkOutLat);
                visRec.Check_Out__Longitude__s =  Decimal.valueOf(checkOutLong);
                visRec.Visit_Status__c = 'COMPLETED';
                visRec.Check_Out_Time__c = System.now();
                update visRec;
                System.debug('Check Out Visit Update Record === >'+visRec);
                return visRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    
    //==========================================================================================================================================================================================================
    // Method for getting Past Visit Records
     @AuraEnabled
    public static List<Visit__c> getPastVisitDetails(String accId){
        String userId = UserInfo.getUserId();
        List<Visit__c> pastVisitList = new List<Visit__c>();
        try{
            if(String.isNotBlank(userId)){
                pastVisitList = [SELECT Id, Name, Status__c, Account__c, Duration__c, Account__r.Name, Account__r.Website, Account__r.Email__c, Account__r.Phone,  
                                 Visit_Time__c, Planned_visit_date__c, Weekly_Beat_Plan__c, KPI_Target__c, KPI_Target__r.KPI_Target_Name__c,Account__r.BillingStreet, 
                                 Account__r.BillingCity, Account__r.BillingState,Account__r.BillingPostalCode, Check_In_Time__c, Visit_Status__c, Account__r.BillingCountry, Actual_visit_date__c,
                                 KPI_Target_Name__c FROM Visit__c WHERE Assigned_User__c=:userId AND Actual_visit_date__c < today AND Account__c =: accId];
                if(pastVisitList !=null){
                    System.debug('pastVisitList === >'+pastVisitList);
                    return pastVisitList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
        //==========================================================================================================================================================================================================
    // Method for getting Related Opportunities List
    
    @AuraEnabled
    public static List<Opportunity> getRelOppList(String accId){
        List<Opportunity> oppList = new List<Opportunity>();
        try{
            if(String.isNotBlank(accId)){
                oppList = [SELECT Id, Name, StageName, CloseDate, LeadSource FROM Opportunity WHERE AccountId=:accId LIMIT 10];
                if(oppList !=null){
                    System.debug('oppList === >'+oppList);
                    return oppList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Invoices__c> getRelInvoiceList(String accId){
        List<Invoices__c> invList = new List<Invoices__c>();
        String userId = userInfo.getUserId();
        try{
            if(String.isNotBlank(accId)){
                invList = [SELECT Id, Name, Amount__c, Status__c, Initiated_Amount__c, Realized_Amount__c, Invoice_Date__c, Account__c FROM Invoices__c WHERE Account__c=:accId AND OwnerId=:userId LIMIT 10];
                if(invList !=null){
                    System.debug('invList === >'+invList);
                    return invList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
        @AuraEnabled
    public static List<Case> getRelCaseList(String accId){
        List<Case> caseList = new List<Case>();
        String userId = userInfo.getUserId();
        try{
            if(String.isNotBlank(accId)){
                caseList = [SELECT Id, CaseNumber, Origin, Case_Status__c, Status, Description, Reason, AccountId FROM Case WHERE AccountId=:accId AND OwnerId=:userId LIMIT 10];
                if(caseList !=null){
                    System.debug('caseList === >'+caseList);
                    return caseList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Task> getRelTaskList(String accId){
        List<Task> taskList = new List<Task>();
        String userId = userInfo.getUserId();
        try{
            if(String.isNotBlank(accId)){
                taskList = [SELECT Id, OwnerId, ActivityDate, Priority, Status, Subject, Type FROM Task WHERE WhatId=:accId AND OwnerId=:userId LIMIT 10];
                if(taskList !=null){
                    System.debug('taskList === >'+taskList);
                    return taskList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    
}