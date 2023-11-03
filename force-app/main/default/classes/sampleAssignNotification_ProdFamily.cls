public without sharing class sampleAssignNotification_ProdFamily {
    static final String SLI_SUBMITTED = 'Submitted for Sampling';
    static final String OWA_NAME = 'Symega Food Ingredients Limited';
    
    
    //NEW
    public static void notifyWithoutRecipeSLI(list<string> sliIdsList){
        try{
            if(sliIdsList != NULL){
                List<Sample_Line_Item__c> slis = [SELECT Id, Name, Product__r.Family, Project_Quotient__r.Sample_Project_Application__r.Product_Family__c, OwnerId FROM Sample_Line_Item__c WHERE Id IN :sliIdsList];
                system.debug('slis :: ' + slis);
                
                Map<String, String> sampleTeamByProdFamily = returnEmailByProdFamilyMap();
                List<Sample_Assignment_Team__c> smTeamList = [SELECT Id, Name, Team_Type__c FROM Sample_Assignment_Team__c WHERE Team_Type__c != null ];
                
                for(Sample_Assignment_Team__c sTeam : smTeamList){
                    sampleTeamByProdFamily.put(sTeam.Team_Type__c, sTeam.Id);
                }
                
                for (Sample_Line_Item__c sliRecord : slis) {
                    string family = '';
                    Id teamId;
                    
                    if(sliRecord.Product__r.Family != null){
                        teamId = sampleTeamByProdFamily.containsKey(sliRecord.Product__r.Family) ? sampleTeamByProdFamily.get(sliRecord.Product__r.Family) : null;
                    }
                    else if( sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c != null){
                        teamId = sampleTeamByProdFamily.containsKey(sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c) ? sampleTeamByProdFamily.get(sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c) : null;
                    }
                    if(teamId != null)
                        sliRecord.Sample_Assignment_Team__c = teamId;
                    sliRecord.Submitted__c = true;
                    sliRecord.Sample_Request_Status__c = SLI_SUBMITTED;
                }
                Update slis;
                
                Map <string, List<string>> mapOfEmailIdsByFamily = new Map <string, List<string>>();
                List<Sample_Allocation_Team__c> sampleAllocationTeamList = [SELECT Id, Contact__c, Contact__r.Email, Sample_Assignment_Team__c, Sample_Assignment_Team__r.Team_Type__c FROM Sample_Allocation_Team__c];
                for(Sample_Allocation_Team__c sAllTeam : sampleAllocationTeamList){
                    if (mapOfEmailIdsByFamily.containsKey(sAllTeam.Sample_Assignment_Team__r.Team_Type__c)) {
                        mapOfEmailIdsByFamily.get(sAllTeam.Sample_Assignment_Team__r.Team_Type__c).add(sAllTeam.Contact__r.Email); 
                    }
                    else{
                        mapOfEmailIdsByFamily.put(sAllTeam.Sample_Assignment_Team__r.Team_Type__c, new List<string> {sAllTeam.Contact__r.Email});
                    } 
                }

                system.debug('mapOfEmailIdsByFamily -- ' + mapOfEmailIdsByFamily);

                Map <string, List<Sample_Line_Item__c>> prodFamilyBySLIMap = new Map <string, List<Sample_Line_Item__c>>();
                
                for (Sample_Line_Item__c sliRecord : slis) {
                    String prodFamily = '';
                    if(!String.isEmpty(sliRecord.Product__r.Family)){
                        prodFamily = sliRecord.Product__r.Family;
                    }
                    else if(!String.isEmpty(sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c)){
                        prodFamily = sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c;
                    }
                    
                    if (prodFamilyBySLIMap.containsKey(prodFamily)) {
                        prodFamilyBySLIMap.get(prodFamily).add(sliRecord); 
                    }
                    else{
                        prodFamilyBySLIMap.put(prodFamily, new List<Sample_Line_Item__c> {sliRecord});
                    }    
                }   
                
                List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
                for (String prodFmly : prodFamilyBySLIMap.keyset()) {
                    Messaging.SingleEmailMessage sliEmail = new Messaging.SingleEmailMessage();
                    List <String> emailRecipients = mapOfEmailIdsByFamily.get(prodFmly);
                        system.debug('emailRecipients'+emailRecipients);
                    
                    sliEmail.setToAddresses(emailRecipients);
                    sliEmail.setSubject('Sample request has been assigned to you.');
                    sliEmail.setReplyTo(UserInfo.getUserEmail());
                    
                    String emailBody = 'Dear ' + prodFmly + ' Team,';
                    emailBody += ' <br> <br> The following products has been assigned to you for sampling.<br> Total no of products: ' + prodFamilyBySLIMap.get(prodFmly).size() + '<br>';
                    emailBody += ' Below is the link to access: <br> <br>';
                    
                    String recordOwnerList = '';
                    List <Sample_Line_Item__c> relatedOwnerRec = prodFamilyBySLIMap.get(prodFmly);
                    
                    for (Integer i = 0; i < relatedOwnerRec.size(); i++) {
                        emailBody += '<a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+relatedOwnerRec[i].Id+'">'+ relatedOwnerRec[i].Name +'</a><br>' ;    
                    }
                    
                    emailBody += '<br> Thank You';
                    sliEmail.setHtmlBody(emailBody);
                    emailsList.add(sliEmail);
                } 
                if(!emailsList.isEmpty()) {
                    Messaging.sendEmail(emailsList);     
                }


                
                                
            }
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + ' At Line No :: ' + e.getLineNumber());
            HandleBusinessException.captureError('Sample_submission_class', 'notifyWithoutRecepieSLI', e);
        }
    }
    
    
    
    //@future
    public static void notifyWithoutRecipeSLI_Prvs(list<string> sliIdsList){
        try{
            if(sliIdsList != NULL){
                List<Sample_Line_Item__c> slis = [SELECT Id, Name, Product__r.Family, Project_Quotient__r.Sample_Project_Application__r.Product_Family__c, OwnerId FROM Sample_Line_Item__c WHERE Id IN :sliIdsList];
                system.debug('slis :: ' + slis);
                
                Map<String, string> getEmailByProductFamilyMap = returnEmailByProdFamilyMap();
                Map<String, String> getUserIdByUsernameMap = returnUserIdByUNMap();
                
                Date dueDate = Date.today()+7;
                system.debug('dueDate'+dueDate);
                list<task> taskList = new list<task>();
                
                for (Sample_Line_Item__c sliRecord : slis) {
                    string userId = '';
                    
                    if(getEmailByProductFamilyMap.containsKey(sliRecord.Product__r.Family) && sliRecord.Product__r.Family != null){
                        userId = getUserIdByUsernameMap.get(getEmailByProductFamilyMap.get(sliRecord.Product__r.Family));
                        system.debug('userId : ' + userId);
                    }
                    else if(getEmailByProductFamilyMap.containsKey(sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c) && sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c != null){
                        userId = getUserIdByUsernameMap.get(getEmailByProductFamilyMap.get(sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c));
                    }
                    sliRecord.OwnerId = userId;
                    sliRecord.Submitted__c = true;
                    sliRecord.Sample_Request_Status__c = SLI_SUBMITTED;
                    Task tsk = createTask(sliRecord.id, userId, dueDate, 'Sample requested has been assigned to you.');
                    taskList.add(tsk); 
                }
                Update slis;
                insert taskList;
                
                Map <Id,User> userMap = new Map <Id, User>([SELECT FirstName, Email FROM User]);                        
                Map <string, List<Sample_Line_Item__c>> prodFamilyBySLIMap = new Map <string, List<Sample_Line_Item__c>>();
                
                for (Sample_Line_Item__c sliRecord : slis) {
                    String prodFamily = '';
                    if(!String.isEmpty(sliRecord.Product__r.Family)){
                        prodFamily = sliRecord.Product__r.Family;
                    }
                    else if(!String.isEmpty(sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c)){
                        prodFamily = sliRecord.Project_Quotient__r.Sample_Project_Application__r.Product_Family__c;
                    }
                    
                    if (prodFamilyBySLIMap.containsKey(prodFamily)) {
                        prodFamilyBySLIMap.get(prodFamily).add(sliRecord); 
                    }
                    else{
                        prodFamilyBySLIMap.put(prodFamily, new List<Sample_Line_Item__c> {sliRecord});
                    }    
                }   
                
                List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
                for (String prodFmly : prodFamilyBySLIMap.keyset()) {
                    Messaging.SingleEmailMessage sliEmail = new Messaging.SingleEmailMessage();
                    List <String> emailRecipients = new List <String>{userMap.get(getUserIdByUsernameMap.get(getEmailByProductFamilyMap.get(prodFmly))).Email};
                        system.debug('emailRecipients'+emailRecipients);
                    
                    sliEmail.setToAddresses(emailRecipients);
                    sliEmail.setSubject('Sample request has been assigned to you.');
                    sliEmail.setReplyTo(UserInfo.getUserEmail());
                    
                    String emailBody = 'Dear ' + userMap.get(getUserIdByUsernameMap.get(getEmailByProductFamilyMap.get(prodFmly))).FirstName + ',';
                    emailBody += ' <br> <br> The following products has been assigned to you for sampling.<br> Total no of products: ' + prodFamilyBySLIMap.get(prodFmly).size() + '<br>';
                    emailBody += ' Below is the link to access: <br> <br>';
                    
                    String recordOwnerList = '';
                    List <Sample_Line_Item__c> relatedOwnerRec = prodFamilyBySLIMap.get(prodFmly);
                    
                    for (Integer i = 0; i < relatedOwnerRec.size(); i++) {
                        emailBody += '<a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+relatedOwnerRec[i].Id+'">'+ relatedOwnerRec[i].Name +'</a><br>' ;    
                    }
                    
                    emailBody += '<br> Thank You';
                    sliEmail.setHtmlBody(emailBody);
                    emailsList.add(sliEmail);
                } 
                if(!emailsList.isEmpty()) {
                    Messaging.sendEmail(emailsList);     
                }
            }
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + ' At Line No :: ' + e.getLineNumber());
            HandleBusinessException.captureError('Sample_submission_class', 'notifyWithoutRecepieSLI', e);
        }
    }
    
    
    
    private static Task createTask(String recId, Id userId, Date dueDate, String Subject){
        try{
            Task tsk = New Task();
            tsk.whatid = recId;
            tsk.OwnerId = userId;
            tsk.Subject = Subject;
            tsk.ActivityDate = dueDate;
            return tsk;
        }
        catch(Exception e){
            system.debug('createTask ERROR :: ' + e.getMessage() + ' At Line No :: ' + e.getLineNumber());
            HandleBusinessException.captureError('sampleAssignNotification_ProdFamily', 'createTask', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static Map<String, String> returnEmailByProdFamilyMap(){
        Map<String, string> getEmailByProductFamilyMap = New Map<String, String>() ;
        list<Sample_Assignee__mdt> mdtList = Sample_Assignee__mdt.getAll().values();
        System.debug('--mdtList->'+mdtList);
        
        for (Sample_Assignee__mdt MDT : mdtList) {
            getEmailByProductFamilyMap.put(MDT.MasterLabel, MDT.Username__c);
        }  
        return getEmailByProductFamilyMap;
    }
    
    private static Map<String, String> returnUserIdByUNMap(){
        Map<String, String> getUserIdByUsernameMap = new Map<String, String>();
        Map<String, String> emailByProdFamilyMap = returnEmailByProdFamilyMap();
        List<user> userList = [ SELECT Id, Username, FirstName, Email FROM User WHERE Username =: emailByProdFamilyMap.values()];
        for(User u : userList){
            getUserIdByUsernameMap.put(u.Username, u.id);
        }
        return getUserIdByUsernameMap;
    }
    
}