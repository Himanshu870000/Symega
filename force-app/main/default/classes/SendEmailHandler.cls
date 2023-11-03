public class SendEmailHandler {
    @AuraEnabled
    public static string processEmail(boolean checkEmail, string email, String Subject, String Message, list<String> DepartmemberList){
        String sMessage='';
        try{
            
            //List<Department_Member__c> EmailMemberList = [Select Contact_Email__c From Department_Member__c Where Contact_First_Name__c LIKE Name];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         //   String[] toAddresses = new String[] {email}; 
         String[] toAddresses = new String[] {};
           if(email !=null & checkEmail == true ) 
           {
            // Email != null and checkbox should be true then only add the email field
            toAddresses.add(email);
           }
            toAddresses.addAll(DepartmemberList);
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
    public static emailAndEmailTemp fetchOpportunityDetails(String OppId){
        try{
            emailAndEmailTemp wrap;
            string emailId ='';
            List<String> templateNames = new List<String>();
            List<Email_template_Name__c> emailTemplateName = new List<Email_template_Name__c>();
            List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
            List<Opportunity> oppList = New List<Opportunity>();
            List<Department__c> DepartWithMemberList = [Select id, Name,isActive__c,
                                                        (Select id, Contact__c, Contact_Email__c, Contact_First_Name__c, Contact_Last_Name__c, Department__c From Department_Members__r where Contact_Email__c !=null limit 25 ) 
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
            
            system.debug('DepartmentMemberListOnly :: ' + DepartmentMemberListOnly);
            if(!string.isBlank(OppId)){
                oppList = [Select id,AccountId,Amount, Primary_Contact__c, CloseDate,StageName, Type From opportunity Where id =: OppId limit 1 ];
               
            }
            if(oppList[0].Primary_Contact__c != NUll){
                Contact con = [Select FirstName, LastName, Email from Contact where id =: oppList[0].Primary_Contact__c ];
                if(con.Email != Null){
                    	emailId = con.Email;
                }else{
                    	emailId ='';		 }
            }
            else {
                		emailId ='';		}
             
            system.debug('oppList :: ' + oppList);
             
            
            emailTemplateName = [select Template_Name__c From Email_template_Name__c];
            
            if(!emailTemplateName.isEmpty()){
                for(Email_template_Name__c tempName : emailTemplateName){
                    templateNames.add(tempName.Template_Name__c);
                    system.debug(' templateNames :: '+ templateNames);
                }  
                if(!templateNames.isEmpty()){
                    emailTemplates = [SELECT Body,Description,DeveloperName,HtmlValue,Name,Subject FROM EmailTemplate WHERE Name in : templateNames];
                    system.debug(' emailTemplates :: '+ emailTemplates);
                    
                }
            }
            
            if(emailId != NULL){
                
                wrap = new emailAndEmailTemp(emailId, emailTemplates, templateNames, oppList[0], DepartmentListOnly, DepartmentMemberListOnly);
            }
            system.debug('WRAP ::' + wrap);
            return wrap;
        }
        catch(Exception ex){
            system.debug(ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString());
            return null;
        }
        
    }
    
    public class emailAndEmailTemp{
        @auraEnabled
        public String Email;
        @auraEnabled 
        public List<EmailTemplate> emailTemplateList;
        @auraEnabled
        public List<String> emailTemplateName;
        @auraEnabled
        public opportunity OppRec;
        @auraEnabled
        public List<Department__c> DepartDetails;
        @auraEnabled
        public List<Department_Member__c> DepartMemberdetails;
        
        public emailAndEmailTemp(String Email, List<EmailTemplate> emailTemplateList,List<String> emailTemplateName, opportunity OppRec, List<Department__c> DepartDetails, List<Department_Member__c> DepartMemberdetails){
            this.Email = Email;
            this.emailTemplateList = emailTemplateList;
            this.emailTemplateName = emailTemplateName;
            this.OppRec = OppRec;
            this.DepartDetails = DepartDetails;
            this.DepartMemberdetails = DepartMemberdetails;
        }
        
    }
}