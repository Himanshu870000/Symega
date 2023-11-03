public without sharing class SendEmailHandlerFromAccount {
    
    @AuraEnabled
    public static string processEmail(boolean checkEmail,String email, String Subject, String Message, list<String> DepartmemberList){
        String sMessage='';
        try{
            
            //List<Department_Member__c> EmailMemberList = [Select Contact_Email__c From Department_Member__c Where Contact_First_Name__c LIKE Name];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {}; 
            if(email !=null & checkEmail == true ) 
            {
             // Email != null and checkbox should be true then only add the email field
                toAddresses.add(email);
            }
               // toAddresses.addAll(DepartmemberList);
            mail.setToAddresses(toAddresses);
            
            mail.setSubject(Subject);
            String htmlBody = Message;
            mail.setHtmlBody(htmlBody);
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            sMessage='Success';
            
        }
        catch(Exception ex){
            sMessage=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
        }
        return sMessage;
    }
    @auraEnabled
    public static emailAndEmailTemp fetchAccountDetails(Id AccId){
        emailAndEmailTemp wrap;
        List<Sobject> sObjectList= new List<Sobject>();
        try{
            string emailId;
            List<String> templateNames = new List<String>();
            List<Email_template_Name__c> emailTemplateName = new List<Email_template_Name__c>();
            List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
            List<Account> accList = New List<Account>();
            List<Department__c> DepartWithMemberList = [Select id, Name,isActive__c,
                                                        (Select id, Contact__c, Contact_Email__c, Contact_First_Name__c, Contact_Last_Name__c, Department__c From Department_Members__r where Contact_Email__c !=null limit 25) 
                                                        From Department__c where isActive__c = true];
            List<Department__c> DepartmentListOnly = new List<Department__c>();
            List<Department_Member__c> DepartmentMemberListOnly = new List<Department_Member__c>();
            
            if(!DepartWithMemberList.isEmpty()){
                for(Department__c DWML : DepartWithMemberList){
                    DepartmentListOnly.add(DWML);
                    for(Department_Member__c DMs : DWML.Department_Members__r)
                        DepartmentMemberListOnly.add(DMs);
                }
            }
            
            String userEmailId = UserInfo.getUserEmail();
            if(!string.isBlank(AccId)){
                
                Schema.SObjectType sObjNameAPI = AccId.getsobjecttype();
                system.debug('sObjName::'+sObjNameAPI);
                string QueryString = 'Select id, Name, Email__c, OwnerEmail__c From ' + sObjNameAPI + ' Where id =: AccId';
                if(String.valueOf(sObjNameAPI) == 'Account'){
                    sObjectList = Database.query(QueryString);
                    system.debug('sObjectList :: ' + sObjectList);
                    if(sObjectList[0].get('Email__c') != Null){
                        emailId = String.valueOf(sObjectList[0].get('Email__c')) ;
                        system.debug(' Emails id :: ' +emailId);
                    }
                    else{
                        emailId = String.valueOf(sObjectList[0].get('OwnerEmail__c'));
                        system.debug('Owner Email id :: ' +emailId);
                    }
                }
                else if(String.valueOf(sObjNameAPI) == 'Lead'){
                    sObjectList = Database.query(QueryString);
                    system.debug('sObjectList :: ' + sObjectList);
                    if(sObjectList[0].get('Email__c') != Null){
                        emailId = String.valueOf(sObjectList[0].get('Email__c')) ;
                    }
                    else {
                        emailId = String.valueOf(sObjectList[0].get('OwnerEmail__c'));
                    }
                }
                else if(String.valueOf(sObjNameAPI) == 'Opportunity'){
                  sObjectList = Database.query(QueryString);
                    system.debug('sObjectList :: ' + sObjectList);
                    if(sObjectList[0].get('Email__c') != Null){
                        emailId = String.valueOf(sObjectList[0].get('Email__c')) ;
                    }
                    else{
                        emailId = String.valueOf(sObjectList[0].get('OwnerEmail__c'));
                    }
                }
                
                // ========================================= for Parsing Email Template Body and Subject =============================
                string foldername = String.valueOf(sObjNameAPI);
                emailTemplates = [SELECT Body,Description,DeveloperName,HtmlValue,Name,Subject FROM EmailTemplate WHERE Folder.Name =: foldername];
                
                if(!emailTemplates.isEmpty()){
                    for(EmailTemplate em : emailTemplates){
                        templateNames.add(em.Name);
                    }
                }
                system.debug('emailTemplates :: ' + emailTemplates);
                
                List<EmailTemplate> UpdatedEmailTemplates = new List<EmailTemplate>();
                
                for(EmailTemplate EmTemp : emailTemplates){
                    EmailTemplate UpdatedemailTemp = new EmailTemplate();
                    String updatedEmailTempBody = DynamicEmailTempBody.ParseDynamicEmailTempBody(EmTemp.HtmlValue, AccId);
                    UpdatedemailTemp.Body = updatedEmailTempBody;
                    String updatedSubject = DynamicEmailTempBody.ParseDynamicEmailTempBody(EmTemp.Subject, AccId);
                    UpdatedemailTemp.Subject = updatedSubject;
                    UpdatedemailTemp.Name = EmTemp.Name;
                    UpdatedemailTemp.Description = EmTemp.Description;
                    UpdatedemailTemp.DeveloperName = EmTemp.DeveloperName;
                    UpdatedemailTemp.HtmlValue = EmTemp.HtmlValue;
                    UpdatedEmailTemplates.add(UpdatedemailTemp);
                }
                
                system.debug('UpdatedEmailTemplates ::' + UpdatedEmailTemplates);
                wrap = new emailAndEmailTemp(emailId, UpdatedEmailTemplates, templateNames, sObjectList[0], DepartmentListOnly, DepartmentMemberListOnly);
                system.debug('wrap :: ' + wrap);
                return wrap;
            }
        }
        catch(Exception ex){
            system.debug('The following exception has occurred: ' + ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString());
            return null;
        }
        return wrap;
    }
    
    public class emailAndEmailTemp{
        @auraEnabled
        public String Email;
        @auraEnabled 
        public List<EmailTemplate> emailTemplateList;
        @auraEnabled
        public List<String> emailTemplateName;
        @auraEnabled
        public Sobject AccRec;
        @auraEnabled
        public List<Department__c> DepartDetails;
        @auraEnabled
        public List<Department_Member__c> DepartMemberdetails;
        
        public emailAndEmailTemp(String Email, List<EmailTemplate> emailTemplateList,List<String> emailTemplateName, Sobject AccRec, List<Department__c> DepartDetails, List<Department_Member__c> DepartMemberdetails){
            this.Email = Email;
            this.emailTemplateList = emailTemplateList;
            this.emailTemplateName = emailTemplateName;
            this.AccRec = AccRec;
            this.DepartDetails = DepartDetails;
            this.DepartMemberdetails = DepartMemberdetails;
        }
        
    }
    
}