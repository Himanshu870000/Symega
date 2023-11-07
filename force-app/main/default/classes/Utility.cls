Global without sharing class Utility {
    @AuraEnabled(Cacheable = true)
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
        
        List<String> lstPickvals                        = new List<String>();
        Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name                             = targetType.newSObject();
        Schema.sObjectType sobject_type                 = Object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values     = field_map.get(Field_name).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            
            lstPickvals.add(String.ValueOf(a.getLabel()).trim());  
        }
        return lstPickvals;
    }
    
    public static List<String> getPicklistValuesWithNone(String ObjectApi_name,String Field_name) {
        List<String> pickList = new List<String>{'--None--'};
            pickList.addAll(getPicklistValues(objectApi_name, field_name));
        return pickList;
    }
    
    @AuraEnabled
    public static String generateRandomString(){
        Integer len = 10;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr+string.ValueOf(system.now().getTime()); 
    }
    
    
    public static string sendEmailWithTemplate(string targetRecordId, String templateId){
        try{
            List<Account> accRecordList = new List<Account>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> recipients = new List<String>();
            
            EmailTemplate et=[Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where Id =: templateId limit 1];
            accRecordList = [Select Id,Name,Email__c From Account Where Id =: targetRecordId limit 1];//Account_Email__c
            system.debug('et::'+et);
            system.debug('accRecordList::'+accRecordList);
            recipients.add(accRecordList[0].Email__c);
            
            mail.setToAddresses(recipients);
            
            Symega_Configuration__c symegaConfig = getSymegaConfig();
            if(symegaConfig.Symega_Email_Id__c != null)
                mail.setReplyTo(symegaConfig.Symega_Email_Id__c);
            mail.setSenderDisplayName('Ondonte');
            String subject = et.Subject;
            String htmlBody = et.HtmlValue;
            String plainTextBody = et.body;
            htmlBody = htmlBody.replace('{!Account.Name}', accRecordList[0].Name);
            htmlBody = htmlBody.replace('{!Account.Id}', accRecordList[0].Id); 
            htmlBody = htmlBody.replace('{!$Label.ClientSiteURL}', System.Label.SymegaSiteURL);
            plainTextBody = plainTextBody.replace('{!Account.Name}', accRecordList[0].Name);
            plainTextBody = plainTextBody.replace('{!Account.Id}', accRecordList[0].Id);
            plainTextBody = plainTextBody.replace('{!$Label.ClientSiteURL}', System.Label.SymegaSiteURL);
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(plainTextBody);
            mails.add(mail);
            system.debug('mails::'+mails);
            if(!mails.isEmpty()){
                system.debug('Sending Email');
                Messaging.sendEmail(mails);
            }
            
            return Constants.TEMP_URL_SENT_CONFIRMATION;
            
        }catch(Exception ex){
            system.debug('e==='+ex);
            return Constants.ERROR_MSG;
        }
    }
    
    public static void sendWelcomeEmailWithTemplate(string targetRecordId, String templateId){
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
            mail.setTargetObjectId(targetRecordId); 
            /*List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
owa =[select id,displayName,Address from OrgWideEmailAddress Limit 1];
if(owa.size()>0)
mail.setOrgWideEmailAddressId(owa[0].id);
else*/
            
            mail.setSenderDisplayName('Symega Food');
            mail.setTemplateId(templateId); 
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
        catch (Exception e){
            system.debug('Error :: ' + e.getMessage()+ 'At Line No :: ' + e.getLineNumber() );
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    // @InvocableMethod (label='Send Jobrequisition Form' description='Sends Email' category='Account')
    @auraEnabled
    public static void sendReqForm(string accountId){
        try{
            if(!String.isBlank(accountId)){
                
                List<EmailTemplate> emailTemplateList = [SELECT id FROM EmailTemplate WHERE Developername = 'Job_Requisition_Form'];  
                system.debug('emailTemplateList::'+emailTemplateList);
                system.debug('accountId:'+accountId);
                sendEmailWithTemplate(accountId, emailTemplateList[0].Id);
            }
        }catch(exception ex){
            system.debug('error'+ex.getMessage());
            system.debug('Error::>'+ex.getLineNumber());
        }
        
    }
    
    public static void sendSONotification(String salesOrderId){
        
        try{
            List<OpportunityLineItem> oppProdsList = [SELECT Id, Product2.Family, Opportunity.OwnerId, Opportunity.Owner.Email FROM OpportunityLineItem WHERE Sales_Order__c =: salesOrderId];
            system.debug('oppProdsList :: ' + oppProdsList);
            Map <string, List<OpportunityLineItem>> prodFamilyByOppProdsMap = new Map <string, List<OpportunityLineItem>>();
            
            for (OpportunityLineItem prod : oppProdsList) {
                if(prod.Product2.Family != null){
                    if (prodFamilyByOppProdsMap.containsKey(prod.Product2.Family)) {
                        prodFamilyByOppProdsMap.get(prod.Product2.Family).add(prod); 
                    }
                    else{
                        prodFamilyByOppProdsMap.put(formatCustomMetadat(prod.Product2.Family), new List<OpportunityLineItem> {prod});
                    }  
                }  
            }
            
            Id saleUserId = !oppProdsList.isEmpty() ? oppProdsList[0].Opportunity.OwnerId : UserInfo.getUserId();
            String replyToEmail = !oppProdsList.isEmpty() ? oppProdsList[0].Opportunity.Owner.Email : UserInfo.getUserEmail();
            
            Map<string, Sale_Order_Notification__mdt> getMDTByMap = new Map<string, Sale_Order_Notification__mdt>();
            list<Sale_Order_Notification__mdt> mdtList = Sale_Order_Notification__mdt.getAll().values();
            System.debug('--mdtList->'+mdtList);
            
            for (Sale_Order_Notification__mdt MDT : mdtList) {
                getMDTByMap.put(formatCustomMetadat(MDT.Label), MDT);
            }  
            
            System.debug('GETMDTBYMAP------'+getMDTByMap.keySet());
            System.debug('prodFamilyByOppProdsMap------'+prodFamilyByOppProdsMap.keySet());

            if(prodFamilyByOppProdsMap.size()>0){
                List<ContentDocumentLink> docLinks  = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: salesOrderId ]; 
                system.debug('docLinks -- ' + docLinks);
                system.debug('docLinks.size() -- ' + docLinks.size());
                
                set<id> cdIdSet = new set<id>();
                for(ContentDocumentLink cdl : docLinks){
                    cdIdSet.add(cdl.ContentDocumentId);
                }
                system.debug('cdIdSet -- ' + cdIdSet);
                List<ContentVersion> cVerList = [SELECT ContentDocumentId, VersionData, FileExtension, FileType, Id, Title FROM ContentVersion WHERE ContentDocumentId IN: cdIdSet AND Title LIKE '%Purchase Order%'];
                system.debug('cVerList -- ' + cVerList);
                system.debug('cVerList.size() -- ' + cVerList.size());
                
                
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                for (ContentVersion cVer: cVerList) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(cVer.Title + '.' + cVer.FileExtension);
                    efa.setBody(cVer.VersionData);
                    //efa.setContentType(cVer.ContentType);
                    attachments.add(efa);
                }
            
                for(String prodFamily : prodFamilyByOppProdsMap.keyset()){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(saleUserId);
                    message.setSenderDisplayName('Symega Foods');
                    message.setReplyTo(replyToEmail);
                    message.setUseSignature(false);
                    message.setBccSender(false);
                    message.setSaveAsActivity(false);
                    EmailTemplate sOrderTemplate = [Select Id,Subject,Description,
                                                    HtmlValue,DeveloperName,Body
                                                    from EmailTemplate where name = 'Sales Order Email'];
                    
                    system.debug('sOrderTemplate :: ' + sOrderTemplate);
                    system.debug('prodFamily :: ' + prodFamily);
                    message.setTemplateID(sOrderTemplate.Id);
                    message.setWhatId(salesOrderId);
                    
                    
                    String emails = getMDTByMap.get(formatCustomMetadat(prodFamily)).User_Emails__c;
                    List <String> emailRecipients = emails.split(',');
                    
                    String cC_Emails = getMDTByMap.get(formatCustomMetadat(prodFamily)).cC_Email_Ids__c;
                    
                    List <String> cC_EmailRecipients = new List<String>();
                    if(cC_Emails != null)
                        cC_EmailRecipients = cC_Emails.split(',');
                    
                    message.setToAddresses(emailRecipients);
                    if(!cC_EmailRecipients.isEmpty()){
                        message.setCcAddresses(cC_EmailRecipients);
                    }

                    if(attachments.size()>0)
                        message.setFileAttachments(attachments);
                    
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                    if (results[0].success)
                    {
                        System.debug('The email was sent successfully.');
                    }
                    else
                    {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                    }
                }
            }
        }
        catch(Exception ex){
            System.debug('Exception-----'+ex.getMessage());
            System.debug('Line No -----'+ex.getLineNumber());
        }
    }
    
    public class SOWRAPPER{
        public String soId;
        public String replyToEmail;
        public Id senderID;
        public List<OpportunityLineItem> oppProdsList;
    }
    
    
    public static String formatCustomMetadat(String s){
        if(s != null){
            s = s.replaceAll(' ','_');
            return s.toLowerCase();
        }
        else{
            return null;
        }
    }
    
    
    public static void sendBulkSONotification(List<SOWRAPPER> sWrappers){
        
        try{
            EmailTemplate sOrderTemplate = [Select Id,Subject,Description,
                                            HtmlValue,DeveloperName,Body
                                            from EmailTemplate where name = 'Sales Order Email'];
            
            Map<string, Sale_Order_Notification__mdt> getMDTByMap = new Map<string, Sale_Order_Notification__mdt>();
            list<Sale_Order_Notification__mdt> mdtList = Sale_Order_Notification__mdt.getAll().values();
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            
            
            for (Sale_Order_Notification__mdt MDT : mdtList) {getMDTByMap.put(formatCustomMetadat(MDT.Label), MDT);}  
            
            for(SOWRAPPER sWrapper : sWrappers){
                Map <string, List<OpportunityLineItem>> prodFamilyByOppProdsMap = new Map <string, List<OpportunityLineItem>>();
                
                for (OpportunityLineItem prod : sWrapper.oppProdsList) {
                    if (prodFamilyByOppProdsMap.containsKey(prod.Product2.Family)) {
                        prodFamilyByOppProdsMap.get(prod.Product2.Family).add(prod); 
                    }
                    else{
                        prodFamilyByOppProdsMap.put(prod.Product2.Family, new List<OpportunityLineItem> {prod});
                    }    
                }   
                
                System.debug('--mdtList->'+mdtList);
                
                
                for(String prodFamily : prodFamilyByOppProdsMap.keyset()){
                    
                    String emails = getMDTByMap.get(formatCustomMetadat(prodFamily)).User_Emails__c;
                    List <String> emailRecipients = emails.split(',');
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(sWrapper.senderID);
                    message.setSenderDisplayName('Symega Foods');
                    message.setReplyTo(sWrapper.replyToEmail);
                    message.setUseSignature(false);
                    message.setBccSender(false);
                    message.setSaveAsActivity(false);
                    message.setTemplateID(sOrderTemplate.Id);
                    message.setWhatId(sWrapper.soId);
                    message.setToAddresses(emailRecipients);
                    
                    system.debug('emailRecipients :: '+ emailRecipients);
                    
                    messages.add(message);
                }
            }
            
            if(!messages.isEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success)
                {
                    System.debug('The email was sent successfully.');
                }
                else
                {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        }
        catch(Exception ex){
            System.debug('Exception-----'+ex.getMessage());
        }
    }
    
    @auraEnabled
    public static void sendPLPriceReqEmailNotificaiton(string oppId) {
        //TODO: Anjali use this method to send notification, this method should be called from button on parent opportunity.
        try{
            Opportunity opp = [SELECT Id, OwnerId, Owner.Email FROM Opportunity WHERE Id =: oppId];
            Symega_Configuration__c orgConfig = Symega_Configuration__c.getValues('Symega Configuration');
            
            if(orgConfig==null){return;}
            
            String emails = orgConfig.Pvt_Label_Email_Ids__c;
            String replyTo =  orgConfig.Symega_Email_Id__c == null ? opp.Owner.Email : orgConfig.Symega_Email_Id__c;    
            if(emails == null){return;}
            List<String> emailList = emails.split(',');
            
            Messaging.SingleEmailMessage message = new        
                Messaging.SingleEmailMessage();
            message.setTargetObjectId(opp.OwnerId);
            message.setSenderDisplayName('Symega');
            message.setReplyTo(replyTo);
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            EmailTemplate pvtLabelTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where name = 'Req Pvt Label Price'];
            system.debug('pvtLabelTemplate :: ' + pvtLabelTemplate);
            message.setTemplateID(pvtLabelTemplate.Id);
            message.setWhatId(oppId);
            message.toAddresses = emailList;
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success){
                System.debug('The email was sent successfully.');
            }
            else{
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
        catch (Exception e){
            system.debug('Error :: ' + e.getMessage()+ 'At Line No :: ' + e.getLineNumber() );
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static void sendPFERTCodeReqEmailNotificaiton(string oppId) {
        //TODO: Anjali use this method to send notification, this method should be called from button on parent opportunity.
        try{
            Opportunity opp = [SELECT Id, OwnerId, Owner.Email FROM Opportunity WHERE Id =: oppId];
            Symega_Configuration__c orgConfig = Symega_Configuration__c.getValues('Symega Configuration');
            
            if(orgConfig==null){return;}
            
            String emails = orgConfig.FERT_Code_Email_Ids__c;
            String replyTo =  orgConfig.Symega_Email_Id__c == null ? opp.Owner.Email : orgConfig.Symega_Email_Id__c;
            if(emails == null){return;}        
            List<String> emailList = emails.split(',');
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(opp.OwnerId);
            message.setSenderDisplayName('Symega');
            message.setReplyTo(replyTo);
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            EmailTemplate FERTCodeTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Request for Fert Code'];
            message.setTemplateID(FERTCodeTemplate.Id);
            message.setWhatId(oppId);
            message.toAddresses = emailList;
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success){
                System.debug('The email was sent successfully.');
            }
            else{
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
        catch (exception e){
            system.debug('Error :: ' + e.getMessage()+ 'At Line No :: ' + e.getLineNumber() );
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static string sendReturnDetailsNotificaiton(string saleOrderId) {
        try{
            Sales_Order__c soRec = [SELECT Id, OwnerId, Owner.Email FROM Sales_Order__c WHERE Id =: saleOrderId];
            Symega_Configuration__c orgConfig = Symega_Configuration__c.getValues('Symega Configuration');
            
            String emails = orgConfig.Return_Notification_Email_Id__c;
            String replyTo =  orgConfig.Symega_Email_Id__c == null ? soRec.Owner.Email : orgConfig.Symega_Email_Id__c;
            if(emails==null){return null;}
            List<String> emailList = emails.split(',');
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            
            message.setTargetObjectId(soRec.OwnerId);
            message.setSenderDisplayName('Symega');
            message.setReplyTo(replyTo);
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            EmailTemplate pvtLabelTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Return Detail Notification'];
            message.setTemplateID(pvtLabelTemplate.Id);
            message.setWhatId(saleOrderId);
            
            message.toAddresses = emailList;
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            System.debug('The email was sent successfully.');
            return 'SUCCESS';
        }
        catch(Exception ex){
            system.debug('Error :: ' + ex.getMessage()+ 'At Line No :: ' + ex.getLineNumber() );
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @auraEnabled
    public static void sendTempReqForm(string jobReqId){
        try{
            /* System.debug('--- jobReqId'+jobReqId);
if(!String.isBlank(jobReqId)) {
List<Job_Requisition__c> tempReqList = [SELECT Id, Client__c, Client__r.Name, Client__r.Id, Client__r.Account_Email__c FROM Job_Requisition__c WHERE Id = :jobReqId AND Client__c != null];
if(!tempReqList.isEmpty()) {

List<EmailTemplate> emailTemplateList = [SELECT id, Subject, htmlValue, body FROM EmailTemplate WHERE Developername = 'Job_Temp_Requisition_Form'];  
system.debug('emailTemplateList::'+emailTemplateList);
system.debug('accountId:'+tempReqList[0].Client__c);
if(!emailTemplateList.isEmpty())
sendTempReqEmail(tempReqList[0].Id,tempReqList[0].Client__r, emailTemplateList[0]);
}

}*/
        }catch(exception ex){
            system.debug('error'+ex.getMessage());
            system.debug('Error::>'+ex.getLineNumber());
        }
        
    }
    
    static void sendTempReqEmail(Id targetObjId, Account client, EmailTemplate et) {
        try{
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> recipients = new List<String>();
            //recipients.add(client.Account_Email__c);
            recipients.add(client.Email__c);
            
            mail.setToAddresses(recipients);
            Symega_Configuration__c symegaConfig = getSymegaConfig();
            if(symegaConfig.Symega_Email_Id__c != null)
                mail.setReplyTo(symegaConfig.Symega_Email_Id__c);
            mail.setSenderDisplayName('Symega');
            //mail.setTemplateId(et.Id);
            String subject = et.Subject;
            String htmlBody = et.HtmlValue;
            htmlBody = htmlBody.replace('{!Account.Name}', client.Name);
            htmlBody = htmlBody.replace('{!Account.Id}', client.Id);
            htmlBody = htmlBody.replace('{!Job_Requisition__c.Id}', targetObjId);
            mails.add(mail);
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(et.body);
            system.debug('mails::'+mails);
            if(!mails.isEmpty()){
                system.debug('Sending Email');
                Messaging.sendEmail(mails);
            }
        }
        catch (Exception e){
            system.debug('Error :: ' + e.getMessage()+ 'At Line No :: ' + e.getLineNumber() );
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Map<string,string> getAllFields(string objName, List<string> skillsToDisplay ){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        Map<string,string> apiNameXLabel = New Map<string,string>();
        for (String fieldName: fieldMap.keySet()) {
            system.debug('fieldName---------'+fieldName);
            system.debug('skillsToDisplay.contains(fieldName)'+skillsToDisplay.contains(fieldName));
            for(string skill:skillsToDisplay){
                system.debug('skill------'+skill);
                system.debug('fieldName------'+fieldName);
                system.debug(fieldName.equalsIgnoreCase(skill));
                if(fieldName.equalsIgnoreCase(skill)){
                    system.debug('inside If--------');
                    apiNameXLabel.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
                }
            }
            
        }
        return apiNameXLabel;
    }
    
    
    public static Symega_Configuration__c getSymegaConfig() {
        Symega_Configuration__c symegaConfig = Symega_Configuration__c.getOrgDefaults();
        if(symegaConfig == null)
            throw new ConfigException('Error: Couldn\'t find Symega configuration.');
        return symegaConfig;
    }
    
    public static void scheduleAutoSyncSampleToOptiva(){
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().addMinutes(Integer.valueOf(getSymegaConfig().Optiva_Syncing_Scheduler_Delay__c)).minute()); 
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        ScheduleAutoSyncToOptiva s = new ScheduleAutoSyncToOptiva(); 
        System.schedule('ScheduleAutoSyncToOptiva  ' + String.valueOf(Datetime.now()), nextFireTime, s);
    }
    
    public class ConfigException extends Exception {}
    
    public static boolean isOptivaSyncingEnable(){
        Symega_Configuration__c orgConfig = Symega_Configuration__c.getValues('Symega Configuration');
        return orgConfig.Optiva_Syncing_Enable__c;
    }
    
    public static void handlerErrorException(String recId, String errorMsg){
        Project__c proj = new Project__c(Id=recId,Error_Message_On_Submitting_To_Optiva__c = errorMsg, Error_Occured_On_Submitting_To_Optiva__c = true);
        update proj;
    }
    
    
    public static Map<String,String> getPickVal(String objName, String fName){
        Map<String,String> respMap = new Map<String,String>();
        Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(objName);
        Sobject Object_name                             = targetType.newSObject();
        Schema.sObjectType sobject_type                 = Object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values     = field_map.get(fName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            respMap.put(a.getLabel(),a.getValue());
        }
        system.debug('respMap -- ' + respMap);
        return respMap;
    }
    
    public static Date parseDate(String stringDate){
        // convert ‘dd-mm-yyy' to date;
        List<String> s = stringDate.split('-');
        String sDate = s[2]+'-'+s[1]+'-'+s[0];
        return Date.ValueOf(sDate);
    }
    
    public static String parseDateIntoSlash(String stringDate){
        // convert ‘dd/mm/yyy' to date;
        List<String> s = stringDate.split('-');
        String sDate = s[2]+'/'+s[1]+'/'+s[0];
        return sDate;
    }
    
    
    
    //NUMBER TO WORD CONVERSION                    
    // convert a value < 100 to English.    
    
    static String[] to_19 = new string[]{ 'Zero', 'One',  'Two', 'Three', 'Four',  'Five',  'Six',  
        'Seven', 'Eight', 'Nine', 'Ten',  'Eleven', 'Twelve', 'Thirteen',  
        'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen' };  
            static String[] tens = new string[]{ 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};  
                static String[] denom = new string[]{ '',  
                    'Thousand',   'Million',     'Billion',    'Trillion',    'Quadrillion',  
                    'Quintillion', 'Sixtillion',   'Septillion',  'Octillion',   'Nonillion',  
                    'Decillion',  'Undecillion',   'Duodecillion', 'Tredecillion',  'Quattuordecillion',  
                    'Sixdecillion', 'Septendecillion', 'Octodecillion', 'Novemdecillion', 'Vigintillion' };  
                        
                        public static String convert_2_digitNo(integer val) {  
                            if (val < 20)  
                                return to_19[val];  
                            if(val == 100)  
                                return 'One Hundred';  
                            for (integer v = 0; v < tens.size(); v++) {  
                                String dcap = tens[v];  
                                integer dval = 20 + 10 * v;  
                                if (dval + 10 > val) {  
                                    if (Math.Mod(val,10) != 0)  
                                        return dcap + ' ' + to_19[Math.Mod(val,10)];  
                                    return dcap;  
                                }      
                            }  
                            return 'Should never get here, less than 100 failure';  
                        }  
    
    public static String convert_3_digitNo(integer val) {  
        String word = '';  
        integer rem = val / 100;  
        integer mod = Math.mod(val,100);  
        if (rem > 0) {  
            word = to_19[rem] + ' Hundred';  
            if (mod > 0) {  
                word += ' ';  
            }  
        }  
        if (mod > 0) {  
            word += convert_2_digitNo(mod);  
        }  
        return word;  
    }  
    public static String english_number(long val) {  
        if (val < 100) {  
            system.debug('convert_2_digitNo(val.intValue())' + convert_2_digitNo(val.intValue()));
            return convert_2_digitNo(val.intValue());  
        }  
        if (val < 1000) {  
            system.debug('convert_3_digitNo(val.intValue())' + convert_3_digitNo(val.intValue()));
            return convert_3_digitNo(val.intValue());  
        }  
        for (integer v = 0; v < denom.size(); v++) {  
            integer didx = v - 1;  
            integer dval = (integer)Math.pow(1000, v);  
            if (dval > val) {  
                integer mod = (integer)Math.pow(1000, didx);  
                integer l = (integer) val / mod;  
                integer r = (integer) val - (l * mod);  
                String ret = convert_3_digitNo(l) + ' ' + denom[didx];  
                if (r > 0) {  
                    ret += ' ' + english_number(r);  
                } 
                system.debug('ret' + ret);
                return ret;  
            }  
        }  
        return 'Should never get here, bottomed out in english_number';  
    }  
    
    
    //Decimal to Words 
    
    public static String getNumberTOWordConvertion(Decimal num) {
        
        Decimal junkVal = num;
        Decimal junkValPaisa = junkVal - Math.floor(junkVal);
        junkVal = Math.floor(junkVal);
        
        String obStr = junkVal.toPlainString();
        String[] numReversed = obStr.split('');
        String[] actnumber = reverse(numReversed);
        String firstHalf = convertInWords(numReversed, actnumber);
        
        Integer tmp = Math.round(junkValPaisa * 100);
        junkValPaisa = (Decimal)tmp / 100; System.debug('jj :' + junkValPaisa);
        String paisaStr = junkValPaisa.toPlainString();
        String secondHalf;
        if (paisaStr == '0') {
            secondHalf = '';
        } else if (paisaStr.length() != 4) {
            paisaStr = paisaStr + '0';
            paisaStr = paisaStr.substring(2);
            String [] numReversedPaisa = paisaStr.split('');
            String[] actnumberPaisa = reverse(numReversedPaisa);
            secondHalf = convertInWords(numReversedPaisa, actnumberPaisa);
        } else {
            paisaStr = paisaStr.substring(2);
            String [] numReversedPaisa = paisaStr.split('');
            String[] actnumberPaisa = reverse(numReversedPaisa);
            secondHalf = convertInWords(numReversedPaisa, actnumberPaisa);
        }
        
        String SumOFHalves = '';
        
        if (secondHalf.length() > 4) {
            firstHalf = firstHalf.replace('Only', 'Rupess And ');
            secondHalf = secondHalf.replace('Only', 'Paisa Only');
            SumOFHalves = firstHalf + secondHalf;
        } else {
            firstHalf = firstHalf.replace('Only', 'Rupess Only');
            SumOFHalves = firstHalf;
        }
        
        // IF amount has any value
        if (SumOFHalves.length() > 5) {
            system.debug('SumOFHalves :: ' + SumOFHalves);
            return SumOFHalves;
        } else {
            return '';
        }
    }
    // Method reverse the number
    public static List<String> reverse(List<String> strToRev) {
        List<String> revList = new List<String>();
        for (Integer i = strToRev.size() - 1; i >= 0; i--) {
            revList.add(strToRev.get(i));
        }
        revList.add('');
        return revList;
    }
    
    public static String convertInWords(String[] numRev, String[] actnum) {
        List<String> iWords = new List<String> {'Zero', ' One', ' Two', ' Three', ' Four', ' Five', ' Six', ' Seven', ' Eight', ' Nine'};
            List<String> ePlace = new List<String> {' Ten', ' Eleven', ' Twelve', ' Thirteen', ' Fourteen', ' Fifteen', ' Sixteen', ' Seventeen', ' Eighteen', ' Nineteen'};
                List<String> tensPlace = new List<String> {'dummy', ' Ten', ' Twenty', ' Thirty', ' Forty', ' Fifty', ' Sixty', ' Seventy', ' Eighty', ' Ninety' };
                    
                    Integer iWordsLength = numRev.size();
        String totalWords = '';
        List<String> inWords = new List<String>();
        for (Integer k = 0; k < iWordsLength; k++) {
            inWords.add('');
        }
        String finalWord = '';
        Integer j = 0;
        
        // Main For loop
        for (Integer i = 0; i < iWordsLength; i++) {
            
            if (i == 0) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                inWords[j] = inWords[j] + ' Only';
            } else if (i == 1) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
            } else if (i == 2) {
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i - 1] != '0' && actnum[i - 2] != '0') {
                    inWords[j] = iWords[Integer.valueof(actnum[i])] + ' Hundred and';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])] + ' Hundred';
                }
            } else if (i == 3) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                if (actnum[i + 1] != '0' || Integer.valueof(actnum[i]) > 0) {
                    inWords[j] = inWords[j] + ' Thousand';
                }
            } else if (i == 4) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
                
            } else if (i == 5) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                if (actnum[i + 1] != '0' || Integer.valueof(actnum[i]) > 0) {
                    inWords[j] = inWords[j] + ' Lakh';
                }
            } else if (i == 6) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
                
            } else if (i == 7) {
                if (actnum[i] == '0' || actnum[i + 1] == '1' ) {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                inWords[j] = inWords[j] + ' Crore';
            } else if (i == 8) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
                
            }
            
            j++;
        }
        // End of For loop
        
        // Reverse the List
        inWords = reverse(inWords);
        
        for (Integer i = 0; i < inWords.size(); i++) {
            finalWord += inWords[i];
        }
        
        return finalWord;
    }
    
    public static boolean isFutureDate(Date cDate){
        return cDate<System.today();
    }
    
    
    public static String checkSAPProjectRqField(Project__c proj){
        String missingFields = '';
        
        
        
        return missingFields;
    }
    
    public static String checkSAPApplicatonRqField(Project__c proj){
        String missingFields = '';
        
        return missingFields;
    }
    
    public static String checkSAPSampleRqField(Project__c proj){
        String missingFields = '';
        
        return missingFields;
    }
    
    public static String checkOptivaProjectRqField(Project__c proj){
        String missingFields = '';
        
        return missingFields;
    }
    
    public static String checkOptivaApplicatonRqField(Project__c proj){
        String missingFields = '';
        
        return missingFields;
    }
    
    public static String checkOptivaSampleRqField(Project__c proj){
        String missingFields = '';
        
        return missingFields;
    }
    
    public static String checkForInitialSubmission(String accId){
        Account acc = [	Select Id, Name, Customer_Type__c, Customer_Contact__c,
                       BillingCountry, BillingPostalCode, BillingState, BillingCity, BillingStreet, 
                       ShippingCountry, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet,
                       RecordType.Name, Owner.SAP_USER_CODE__c, User__r.SAP_USER_CODE__c, Account_Segment__c,
                       CurrencyIsoCode, Delivery_Plant__c, Owner.Email
                       From Account Where Id =:accId];
        return sapForInitialFieldsCheck(acc);
    }
    
    public static String sapForInitialFieldsCheck(Account acc) {
        String missingFields = '';
        
        if(String.isBlank(acc.Name)){
            missingFields +='Customer Name,';
        }
        
        if(String.isBlank(acc.Customer_Contact__c)){
            missingFields +='Customer Contact,';
        }
        
        if(String.isBlank(acc.BillingCity)){
            missingFields +='BillingCity,';
        }
        if(String.isBlank(acc.BillingStreet)){
            missingFields +='BillingStreet,';
        }
        if(String.isBlank(acc.BillingState) && acc.Customer_Type__c!='Export'){
            missingFields += ' BillingState, ';
        }
        if(String.isBlank(acc.BillingCountry)){
            missingFields +=' BillingCountry,';
        }
        if(String.isBlank(acc.BillingPostalCode)){
            missingFields += ' BillingPostalCode, ';
        }
        
        // if(String.isBlank(acc.ShippingCity)){
        //     missingFields +='ShippingCity,';
        // }
        // if(String.isBlank(acc.ShippingStreet)){
        //     missingFields +='ShippingStreet,';
        // }
        // if(String.isBlank(acc.ShippingState) && acc.Customer_Type__c!='Export'){
        //     missingFields += ' ShippingState, ';
        // }
        // if(String.isBlank(acc.ShippingCountry)){
        //     missingFields +=' ShippingCountry,';
        // }
        // if(String.isBlank(acc.ShippingPostalCode)){
        //     missingFields += ' ShippingPostalCode, ';
        // }
        
        
        if(String.isBlank(acc.Owner.SAP_USER_CODE__c)){
            missingFields += ' Owner SAP Code, ';
        }
        if(String.isBlank(acc.RecordType.Name)){
            missingFields += ' Record Type Name, ';
        }
        if(String.isBlank(acc.User__r.SAP_USER_CODE__c)){
            missingFields += ' BH SAP Code, ';
        }
        if(String.isBlank(acc.Account_Segment__c)){
            missingFields += ' Account Segment, ';
        }
        if(String.isBlank(acc.CurrencyIsoCode)){
            missingFields += ' CurrencyIsoCode, ';
        }
        if(String.isBlank(acc.Delivery_Plant__c)){
            missingFields += ' Delivery Plant, ';
        }
        if(String.isBlank(acc.Customer_Type__c)){
            missingFields += 'Customer Type,';
        }
        if(String.isBlank(acc.Owner.Email)){
            missingFields += ' Owner Email,';
        }
        
        
        if(missingFields.contains(',')){
            missingFields = missingFields.removeEnd(',');
            missingFields += ' are required fields';
        }
        
        if(String.isBlank(missingFields)){
            missingFields = 'Success';
        }
        return missingFields;
    }
    
    public static String checkForInitialSubmissionAddress(String addressId){
        Dispatch_Address__c addressRec = [	Select Id, Name, Account__c, Company_Legal_Name__c, Contact__c, GST_Number__c, Type__c, CurrencyIsoCode, Address__Street__s, Address__PostalCode__s, Address__City__s, Address__StateCode__s, Address__CountryCode__s, 
                                          Account__r.Tax_Type__c, Account__r.PAN_Number__c, Account__r.Account_Segment__c, Account__r.Delivery_Plant__c, Account__r.Customer_Type__c, Account__r.Payment_terms__c,Account__r.Owner.Email,
                                          Account__r.Tax_Collected_At_Source__c, Account__r.FSSAI__c, Account__r.Transportation_Terms__c,Account__r.RecordType.Name,Account__r.User__r.SAP_USER_CODE__c From Dispatch_Address__c Where Id =: addressId];
        return sapForInitialFieldsCheckAddress(addressRec);
    }
    
    public static String sapForInitialFieldsCheckAddress(Dispatch_Address__c accRec) {
        String missingFields = '';
        
        if(String.isBlank(accRec.Name)){
            missingFields +='Customer Name,';
        }
        
        if(String.isBlank(accRec.Contact__c)){
            missingFields +=' Customer Contact,';
        }
        
        if(String.isBlank(accRec.Address__City__s)){
            missingFields +=' City,';
        }
        if(String.isBlank(accRec.Address__Street__s)){
            missingFields +=' Street,';
        }
        if(String.isBlank(accRec.Address__StateCode__s) && accRec.Account__r.Customer_Type__c!='Export'){
            missingFields += '  State, ';
        }
        if(String.isBlank(accRec.Address__CountryCode__s)){
            missingFields +=' Country,';
        }
        if(String.isBlank(accRec.Address__PostalCode__s)){
            missingFields += ' PostalCode, ';
        }
        
        /*if(String.isBlank(accRec.Owner.SAP_USER_CODE__c)){
missingFields += ' Owner SAP Code, ';
}*/
        if(String.isBlank(accRec.Account__r.RecordType.Name)){
            missingFields += ' Record Type Name, ';
        }
        if(String.isBlank(accRec.Account__r.User__r.SAP_USER_CODE__c)){
            missingFields += ' BH SAP Code, ';
        }
        if(String.isBlank(accRec.Account__r.Account_Segment__c)){
            missingFields += ' Account Segment, ';
        }
        if(String.isBlank(accRec.CurrencyIsoCode)){
            missingFields += ' CurrencyIsoCode, ';
        }
        if(String.isBlank(accRec.Account__r.Delivery_Plant__c)){
            missingFields += ' Delivery Plant, ';
        }
        if(String.isBlank(accRec.Account__r.Customer_Type__c)){
            missingFields += 'Customer Type,';
        }
        if(String.isBlank(accRec.Account__r.Owner.Email)){
            missingFields += ' Owner Email,';
        }
        
        
        if(missingFields.contains(',')){
            missingFields = missingFields.removeEnd(',');
            missingFields += ' are required fields';
        }
        
        if(String.isBlank(missingFields)){
            missingFields = 'Success';
        }
        return missingFields;
    }
    
    
    public static String checkSAPCustomerReqFieldAddress(String addressId){
        Dispatch_Address__c addressRec = [Select Id, Account__r.User__r.SAP_USER_CODE__c, Account__r.RecordType.Name, Initial_SAP_Update__c, Name, Account__c, Company_Legal_Name__c, Contact__c, GST_Number__c, Type__c, CurrencyIsoCode, Address__Street__s, Address__PostalCode__s, Address__City__s, Address__StateCode__s, Address__CountryCode__s, 
                                          Account__r.Tax_Type__c, Account__r.PAN_Number__c, Account__r.Account_Segment__c, Account__r.Delivery_Plant__c, Account__r.Customer_Type__c, Account__r.Payment_terms__c, Account__r.Owner.Email,
                                          Account__r.Tax_Collected_At_Source__c, Account__r.FSSAI__c, Account__r.Transportation_Terms__c From Dispatch_Address__c Where Id =: addressId];
        return sapAccountMFieldsCheckAddress(addressRec);
    }
    
    public static String sapAccountMFieldsCheckAddress(Dispatch_Address__c accRec) {
        String missingFields = '';
        
        if(!accRec.Initial_SAP_Update__c){
            
            if(String.isBlank(accRec.Name)){
                missingFields +='Customer Name,';
            }
            
            if(String.isBlank(accRec.Contact__c)){
                missingFields +=' Customer Contact,';
            }
            
            if(String.isBlank(accRec.Address__City__s)){
                missingFields +=' City,';
            }
            if(String.isBlank(accRec.Address__Street__s)){
                missingFields +=' Street,';
            }
            if(String.isBlank(accRec.Address__StateCode__s) && accRec.Account__r.Customer_Type__c!='Export'){
                missingFields += '  State, ';
            }
            if(String.isBlank(accRec.Address__CountryCode__s)){
                missingFields +=' Country,';
            }
            if(String.isBlank(accRec.Address__PostalCode__s)){
                missingFields += ' PostalCode, ';
            }
            
            /*if(String.isBlank(accRec.Owner.SAP_USER_CODE__c)){
            missingFields += ' Owner SAP Code, ';
            }*/
            if(String.isBlank(accRec.Account__r.RecordType.Name)){
                missingFields += ' Record Type Name, ';
            }
            if(String.isBlank(accRec.Account__r.User__r.SAP_USER_CODE__c)){
                missingFields += ' BH SAP Code, ';
            }
            if(String.isBlank(accRec.Account__r.Account_Segment__c)){
                missingFields += ' Account Segment, ';
            }
            if(String.isBlank(accRec.CurrencyIsoCode)){
                missingFields += ' CurrencyIsoCode, ';
            }
            if(String.isBlank(accRec.Account__r.Delivery_Plant__c)){
                missingFields += ' Delivery Plant, ';
            }
            if(String.isBlank(accRec.Account__r.Customer_Type__c)){
                missingFields += 'Customer Type,';
            }
            if(String.isBlank(accRec.Account__r.Owner.Email)){
                missingFields += ' Owner Email,';
            }
        }
        
        if(String.isBlank(accRec.Account__r.Tax_Type__c)){
            missingFields += ' Tax Type, ';
        }
        if(!String.isBlank(accRec.Address__CountryCode__s) && accRec.Address__CountryCode__s.equalsIgnoreCase('India') && (String.isBlank(accRec.Account__r.PAN_Number__c) || String.isBlank(accRec.GST_number__c))){
            if(String.isBlank(accRec.Account__r.PAN_Number__c)){
                missingFields += ' Pan Number, ';
            }
            if(String.isBlank(accRec.GST_number__c)){
                missingFields += ' GST Number, ';
            }
        }
        if(String.isBlank(accRec.Account__r.Payment_terms__c)){
            missingFields += ' Payment Terms, ';
        }
        if(String.isBlank(accRec.Account__r.Tax_Collected_At_Source__c)){
            missingFields += ' TCS, ';
        }
        if(accRec.Account__r.FSSAI__c == null || accRec.Account__r.FSSAI__c == 0){
            missingFields += ' FSSAI, ';
        }
        if(String.isBlank(accRec.Account__r.Transportation_Terms__c)){
            missingFields += ' Transportation Terms, ';
        }
        
        
        if(missingFields.contains(',')){
            missingFields = missingFields.removeEnd(',');
            missingFields += ' are required fields';
        }
        
        if(String.isBlank(missingFields)){
            missingFields = 'Success';
        }
        return missingFields;
    }
    
    
    public static String checkSAPCustomerReqField(String accId){
        Account acc = [Select Id,Initial_SAP_Update__c,Tax_Type__c,Payment_terms__c,Tax_Collected_At_Source__c,FSSAI__c,Customer_Type__c,BillingCountry,BillingPostalCode,BillingState,Delivery_Plant__c,Account_Segment__c,Transportation_Terms__c,PAN_Number__c,GST_number__c From Account Where Id =:accId];
        return sapAccountMFieldsCheck(acc);
    }
    
    public static String sapAccountMFieldsCheck(Account acc) {
        String missingFields = '';
        
        if(!acc.Initial_SAP_Update__c){
            
            if(String.isBlank(acc.Name)){
                missingFields +='Customer Name,';
            }
            if(String.isBlank(acc.Customer_Contact__c)){
                missingFields +='Customer Contact,';
            }
            if(String.isBlank(acc.BillingCity)){
                missingFields +='BillingCity,';
            }
            if(String.isBlank(acc.BillingStreet)){
                missingFields +='BillingStreet,';
            }
            if(String.isBlank(acc.BillingState) && acc.Customer_Type__c!='Export'){
                missingFields += ' BillingState, ';
            }
            if(String.isBlank(acc.BillingCountry)){
                missingFields +=' BillingCountry,';
            }
            if(String.isBlank(acc.BillingPostalCode)){
                missingFields += ' BillingPostalCode, ';
            }
            if(String.isBlank(acc.Owner.SAP_USER_CODE__c)){
                missingFields += ' Owner SAP Code, ';
            }
            if(String.isBlank(acc.RecordType.Name)){
                missingFields += ' Record Type Name, ';
            }
            if(String.isBlank(acc.User__r.SAP_USER_CODE__c)){
                missingFields += ' BH SAP Code, ';
            }
            if(String.isBlank(acc.Account_Segment__c)){
                missingFields += ' Account Segment, ';
            }
            if(String.isBlank(acc.CurrencyIsoCode)){
                missingFields += ' CurrencyIsoCode, ';
            }
            if(String.isBlank(acc.Delivery_Plant__c)){
                missingFields += ' Delivery Plant, ';
            }
            if(String.isBlank(acc.Customer_Type__c)){
                missingFields += 'Customer Type,';
            }
            if(String.isBlank(acc.Owner.Email)){
                missingFields += ' Owner Email,';
            }
        }
        
        if(String.isBlank(acc.Tax_Type__c)){
            missingFields += ' Tax Type, ';
        }
        if(!String.isBlank(acc.BillingCountry) && acc.BillingCountry.equalsIgnoreCase('India') && (String.isBlank(acc.PAN_Number__c) || String.isBlank(acc.GST_number__c))){
            if(String.isBlank(acc.PAN_Number__c)){
                missingFields += ' Pan Number, ';
            }
            if(String.isBlank(acc.GST_number__c)){
                missingFields += ' GST Number, ';
            }
        }
        if(String.isBlank(acc.Payment_terms__c)){
            missingFields += ' Payment Terms, ';
        }
        if(String.isBlank(acc.Tax_Collected_At_Source__c)){
            missingFields += ' TCS, ';
        }
        if(acc.FSSAI__c == null || acc.FSSAI__c == 0){
            missingFields += ' FSSAI, ';
        }
        if(String.isBlank(acc.Transportation_Terms__c)){
            missingFields += ' Transportation Terms, ';
        }
        
        
        if(missingFields.contains(',')){
            missingFields = missingFields.removeEnd(',');
            missingFields += ' are required fields';
        }
        
        if(String.isBlank(missingFields)){
            missingFields = 'Success';
        }
        return missingFields;
    }
    
    public static Set<String> getAdminProfileNameSet() {
        return Admin_Profiles__c.getAll().keySet();
    }
    
    @AuraEnabled
    public static string getUserDocUrl(string udId){
        return [SELECT Id, Document_Link__c FROM User_Document__c WHERE Id =: udId].Document_Link__c;
    }
    
    public static string capitalizeString(String name){
        try{
            if(name != null && !string.IsEmpty(name)){
                String capitalLetters = name.toUppercase();
                System.debug('capitalLetters--->'+capitalLetters);
                return capitalLetters;
            }
            return null;
        }catch(Exception e){
            System.debug('Exception Message--->'+e.getMessage());
            System.debug('Exception Line NUmber-->'+e.getLineNumber());
            return e.getMessage();
        }
    }
    
    public static void sendEmailOnApproval(String oppName, String oppOwnerEmail, String ownerName, Decimal prvsVal, Decimal newVal, String bhEmailId, String bhName){
        String replyToEmail = !string.isEmpty(bhEmailId) ? bhEmailId : oppOwnerEmail;
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSenderDisplayName('Symega Foods');
        message.setSubject('Annual value change Approval');
        message.setReplyTo(replyToEmail);
        message.setToAddresses(new List<String> {bhEmailId});
        message.setCcAddresses(new List<String> {oppOwnerEmail});
        
        String emailBody = 'Dear ,' + bhName;
        emailBody += '<br><br> Annual value for the following Opportunity has been updated. Following is the details :<br><br>';
        emailBody += 'Opportunity Name : ' + oppName;
        emailBody += '<br>Previous Annual Value : ' + prvsVal;
        emailBody += '<br>Updated Annual Value : ' + newVal;
        emailBody += '<br><br> Thanks & Regards';
        emailBody += '<br> Symega Foods';
        
        message.setHtmlBody(emailBody);
        emailsList.add(message);
        
        if(!emailsList.isEmpty()) {
            Messaging.sendEmail(emailsList);     
        }        
    }
    
    
}