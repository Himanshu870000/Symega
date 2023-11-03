public without sharing class Distributor_LoginPage_Controller {

    static String code;
    public Boolean isSignUp                 {get;set;}
    public Boolean isLogin                  {get;set;}
    public Boolean isCustomer               {get;set;}
    public Boolean isDistributor              {get;set;}
    public boolean isMentorExist            {get;set;}
    public string  name                     {get;set;}
    public string  FbId                     {get;set;}
    public string  gId                      {get;set;}
    public string  gFname                   {get;set;}
    public string hasCodeUpdate             {get;set;}
    public string Error                     {get;set;}
    public static final String SITE  =      'Login';
    public string currentUserId             {get;set;}
    public string hasCode                   {get;set;}
    public string currentDistributorId            {get;set;}
    public Boolean SignupDistributor          {get;set;}
    public Boolean SignupCustomer           {get;set;}
    public Boolean docUplaodCustomer        {get;set;}
    public string isFBcustomerSignup        {get;set;}
    public string isFBcandidateSignup       {get;set;}
    public string selfAssesmentQuestions    {get;set;}
    public string jobFuncList               {get;set;}
    public string asignmentStatusList       {get;set;}
    public string jobShiftTimings           {get;set;}
    public string jobShiftAvailiblity       {get;set;}
    public string industryType              {get;set;}
    public String candidateSiteURL          {get;set;}
    public String candidateHashcode         {get;set;}
    public static String candidateId        {get;set;}
    public string skillList                 {get;set;}
    public string staffList                 {get;set;}
    public String crownPicklistVal          {get;set;}
    public String imgeSoftwarePickVal       {get;set;}
    public string compSkillPickVal          {get;set;}
    public String pmsSkillPickVal           {get;set;}
    public string docCategoryName           {get;set;}

    Public Distributor_LoginPage_Controller(){
    }

   
    @RemoteAction
    public static Account loginUser(string userName, string password){
        try{
            list<Account> distributerAcc = [select Name,id,email__c,Phone,Login_Hash_Code__c,Status__c from Account where email__c =:userName AND Password__c =:password AND (Status__c = 'Document Submission' OR Status__c='Active' ) limit 1];//OR Status__c = 'Document Submission'
            system.debug('distributerAcc----'+distributerAcc);
            if(distributerAcc.size() > 0 ){
                distributerAcc[0].Login_Hash_Code__c = Utility.generateRandomString();
                update distributerAcc[0];
                return distributerAcc[0];
            }else{
                return null;
            }
        }catch(exception e){
            system.debug(e.getLineNumber()+'---error Message---'+e.getMessage());
            HandleBusinessException.captureError('CandidateDashboard_Helper','loginUser',e);
            return null;
        }

    }

    public PageReference redirectProfilePage(){
        system.debug('redirectProfilePage--');
        code                        = ApexPages.currentPage().getParameters().get('code');
        SignupDistributor            = ApexPages.currentPage().getParameters().get('m') == '2' ? true : false;
        SignupCustomer            = ApexPages.currentPage().getParameters().get('m') == '1' ? true : false;
        isLogin            = ApexPages.currentPage().getParameters().get('m') == '0' ? true : false;
        system.debug('ApexPages.currentPage().getParameters().get--'+ApexPages.currentPage().getParameters().get('m'));
        system.debug('code---'+code+'---SignupDistributor----'+SignupDistributor+'---SignupCustomer----'+SignupCustomer+'---isLogin----'+isLogin);
        Cookie cookieObj            = new Cookie('googleCode', code, null, 100, false);
        Cookie cookieLoginTypeObj   = new Cookie('loginType', 'googleLogin', null, 86400, false);
        Cookie isDistributor              = new Cookie('isSignupDistributor',SignupDistributor == true ? 'true' : 'false', null, 100, false);
        Cookie isCustomer               = new Cookie('isSignupCustomer',SignupCustomer == true ? 'true' : 'false', null, 100, false);
        Cookie isLogin                  = new Cookie('isLogin',isLogin == true ? 'true' : 'false', null, 100, false);
        PageReference MyNewPage     = Page.redirectProfilePage;

        MyNewPage.setCookies(new Cookie[]{cookieObj, cookieLoginTypeObj,isDistributor,isCustomer,isLogin});
        
        MyNewPage.setRedirect(true);
        return MyNewPage;
        
    }

    public void googleAuth(){
        try{
            system.debug('google auth');
            Cookie logType = ApexPages.currentPage().getCookies().get('loginType');
            system.debug('loginid::'+logType);
            system.debug('logType.getValue() -----'+logType.getValue());
            if(logType.getValue()   == 'googleLogin'){
                try{
                    //recordType = '';
                    Cookie candidate = ApexPages.currentPage().getCookies().get('isSignupDistributor');
                    Cookie customer = ApexPages.currentPage().getCookies().get('isSignupCustomer');
                    Cookie Login = ApexPages.currentPage().getCookies().get('isLogin');
                    system.debug('SignupDistributor----'+candidate.getValue());
                    system.debug('SignupCustomer----'+customer.getValue());
                    if(candidate.getValue() == 'True'){
                        SignupDistributor = True;
                        system.debug('SignupDistributor----');
                    }
                    if(customer.getValue() == 'True'){
                        SignupCustomer = True;
                        system.debug('SignupCustomer----');
                    }
                    if(Login.getValue() == 'True'){
                        islogin = True;
                    }
                    system.debug('registrationFromGoogle'); 
                    String authCode ;        
                    System.debug(Apexpages.currentPage().getParameters().get('code'));
                    Cookie lkcode = ApexPages.currentPage().getCookies().get('googleCode');
                    System.debug('CODE'+lkcode);
                    if(lkcode != null){
                        code = lkcode.getValue();
                        Cookie cookiegObj   = new Cookie('googleCode', '', null, 100, false);
                        ApexPages.currentPage().setCookies(new Cookie[]{cookiegObj});
                    }
                    if(String.isBlank(code)){
                        Cookie gSessId = ApexPages.currentPage().getCookies().get('googleSessionId');
                        if(gSessId != null){
                            authCode = gSessId.getValue();
                        }
                    }
                    System.debug('code'+code);
                    if(!String.isBlank(code)){
                        if(candidate.getValue() == 'True'){
                             System.debug('code @ 134');
                            authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,'candidate');
                        }
                        if(customer.getValue() == 'True'){
                            System.debug('code @ 138');
                            authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,'customer');
                        }
                        if(Login.getValue() == 'True'){
                            System.debug('code @ 142');
                            authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,'login');
                        }
                        authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,'login');
                        
                    }
                    System.debug('AUTHCODE'+AUTHCODE);
                    if(!String.isBlank(authCode)){
                        System.debug('AUTHCODE');
                        if(!authCode.equalsIgnoreCase('Error')){
                            GooglePublicDetailsClass.GoogleDetails gResp = LoginAuthentication_Helper.getGoogleEmail(authCode);
                            System.debug('gResp---'+gResp);
                            system.debug('gResp.email===='+gResp.email);
                            if(gResp != null && !String.isBlank(gResp.email)){
                                gId = gResp.email;
                                gFname = gResp.firstName;
                                System.debug('AUTHCODE');
                                try{
                                    list<Account> currentDistributor    = [Select id,name,Login_Hash_Code__c from Account where Email__c =:gResp.email];
                                    system.debug('currentDistributor------'+currentDistributor);
                                    if(currentDistributor.size() >0){
                                        if(currentDistributor[0].Status__c == 'Active'){
                                            currentDistributorId          = currentDistributor[0].Id;
                                            Account distributor = new Account();
                                            distributor.Login_Hash_Code__c=FacebookAuthHandler.generateRandomString();
                                            distributor.Id = currentDistributorId;
                                            hasCode=distributor.Login_Hash_Code__c;
                                            system.debug('inside if');
                                            update distributor;
                                        }else if(currentDistributor[0].Status__c == 'Document Submission'){
                                            docUplaodCustomer = true;
                                            currentDistributorId = currentDistributor[0].Id;
                                            Account distributor = new Account();
                                            distributor.Login_Hash_Code__c = FacebookAuthHandler.generateRandomString();
                                            distributor.Id = currentDistributorId;
                                            hasCode = distributor.Login_Hash_Code__c;
                                            system.debug('inside if');
                                            update distributor;
                                            system.debug('docUplaodCustomer---'+docUplaodCustomer);
                                        }
                                       
                                    }else{
                                        SignupDistributor = true;
                                    }
                                    
                                    Cookie cookieObj1 = new Cookie('googleSessionId', authCode, null, 3600, false);
                                    ApexPages.currentPage().setCookies(new Cookie[]{cookieObj1});
                                }catch(Exception e){
                                    system.debug(e.getMessage());
                                }
                            }
                        }
                    }
                    
                }catch(Exception e){
                    system.Debug('linenum------'+e.getLineNumber()+'error-------'+e.getMessage());
                }
            }  
        }catch(exception e){
            system.debug('get line---'+e.getLineNumber()+'--message--'+e.getMessage());
        }
    }

    public PageReference checkUserAuth(){
        isMentorExist=false;
        PageReference pg   = new PageReference('/'); 
        string encStudentId   = Apexpages.currentPage().getParameters().get('encStudentId');
        string hashCode     = Apexpages.currentPage().getParameters().get('d');  
        
        system.debug('hashCode===>'+hashCode + 'enc StudentId====>'+encStudentId);  
        
        if(encStudentId != null){
            currentUserId          = FacebookAuthHandler.decryptString(encStudentId, 'FFE12ORDER34KEY56QWERTY56QAXWSX');
            Cookie cookieEncStudent   = new Cookie('cookieEncStudent', currentUserId, null, 86400, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookieEncStudent});            
        }
        
        if(hashCode != null){
            Cookie cookiehashCode   = new Cookie('hashCodeLog', currentUserId, null, 1800, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookiehashCode});
        }
        
        if(currentUserId == null){
            Cookie encStd = ApexPages.currentPage().getCookies().get('cookieEncStudent');
            system.debug('encStd==>'+encStd);
            if(encStd != null) currentUserId = encStd.getValue();
            if(currentUserId != null){
                Cookie cookieEncDonor   = new Cookie('cookieEncStudent', currentUserId, null, 86400, false);
                ApexPages.currentPage().setCookies(new Cookie[]{cookieEncDonor}); 
            }            
        }
        
        
        if(currentUserId == null){
            Cookie chashcode = ApexPages.currentPage().getCookies().get('hashCodeLog');
            if(chashcode != null) currentUserId    = chashcode.getValue();
            if(currentUserId != null){
                Cookie cookiehashCode   = new Cookie('hashCodeLog', currentUserId, null, 1800, false);
                ApexPages.currentPage().setCookies(new Cookie[]{cookiehashCode});
            }          
        }
        System.debug('currentUserId'+currentUserId);
        if(currentUserId == null || currentUserId==''){
            Cookie logType = ApexPages.currentPage().getCookies().get('loginType');
            system.debug('loginid::'+logType);
            //system.debug('logTypetValue----'+logType.getValue());
            if(logType != null){
                if(logType.getValue()   == 'googleLogin'){
                    try{
                        Cookie candidate = ApexPages.currentPage().getCookies().get('isSignupDistributor');
                        Cookie customer = ApexPages.currentPage().getCookies().get('isSignupCustomer');
                        system.debug('SignupDistributor----'+candidate.getValue());
                        system.debug('SignupCustomer----'+customer.getValue());
                        if(candidate.getValue() == 'True'){
                            SignupDistributor = True;
                            system.debug('SignupDistributor----');
                        }
                        if(customer.getValue() == 'True'){
                            SignupCustomer = True;
                            system.debug('SignupCustomer----');
                        }
                        //recordType = '';
                        checkGoogleAuth();
                        system.debug('registrationFromGoogle');
                        //PageReference pageRef = new PageReference('https://testingv2-leadersinternational.cs18.force.com/login/redirectprofilepage');
                        
                    }catch(Exception e){
                        system.Debug('linenum------'+e.getLineNumber()+'error-------'+e.getMessage());
                        system.debug('pg'+pg);
                        return pg;
                    }
                }
                if(logType.getValue()   == 'fbLogin'){
                    try{
                        Cookie candidate = ApexPages.currentPage().getCookies().get('isSignupDistributor');
                        Cookie customer = ApexPages.currentPage().getCookies().get('isSignupCustomer');
                        system.debug('SignupDistributor----'+candidate.getValue());
                        isFBcustomerSignup = customer.getValue();
                        isFBcandidateSignup = candidate.getValue();
                        system.debug('SignupCustomer----'+customer.getValue());
                        system.debug('checkFacebookAuth----');
                        
                        checkFacebookAuth();  
                        if(ApexPages.currentPage().getCookies().get('signUp').getValue() == 'true') {
                            isSignUp = true;
                            System.debug('facebook signup');
                            return null;
                        }
                        if(ApexPages.currentPage().getCookies().get('Login').getValue() == 'true') {
                            isLogin = true;
                            System.debug('facebook login');
                            return null;
                        }
                        
                    }catch(Exception e){
                        system.debug('exception '+e.getMessage()+'line no '+e.getLineNumber());
                        return pg;
                    }
                }
                
            }else{
                return pg;
            }
        }
        
        // If current user is not an authorized user 
        // then redirect to login page
        if(currentUserId == null) return pg;
        
        return null;
    }
    
    public void checkGoogleAuth(){
        
        String authCode ;        
        System.debug(Apexpages.currentPage().getParameters().get('code'));
        Cookie lkcode = ApexPages.currentPage().getCookies().get('googleCode');
        System.debug('CODE'+lkcode);
        System.debug(ApexPages.currentPage().getCookies());
        if(lkcode != null){
            code = lkcode.getValue();
            Cookie cookiegObj   = new Cookie('googleCode', '', null, 100, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookiegObj});
        }
        
        if(String.isBlank(code)){
            Cookie gSessId = ApexPages.currentPage().getCookies().get('googleSessionId');
            if(gSessId != null){
                authCode = gSessId.getValue();
            }
        }
        System.debug('code'+code);
        if(!String.isBlank(code)){
            authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,LoginAuthentication_Helper.DONOR_STIE);
            System.debug('authCode'+authCode);
        }
        System.debug('AUTHCODE');
        if(!String.isBlank(authCode)){
            System.debug('AUTHCODE');
            if(!authCode.equalsIgnoreCase('Error')){
                GooglePublicDetailsClass.GoogleDetails gResp = LoginAuthentication_Helper.getGoogleEmail(authCode);
                System.debug('gResp---'+gResp);
                system.debug('gResp.email===='+gResp.email);
                if(gResp != null && !String.isBlank(gResp.email)){
                    gId = gResp.email;
                    System.debug('AUTHCODE');
                    try{
                        list<Account> currentDistributor    = [Select id,name,Login_Hash_Code__c from Account where Email__c =:gResp.email AND Status__c ='Active'];
                        if(currentDistributor.size() >0){
                            currentDistributorId          = currentDistributor[0].Id;
                            Account dist=new Account();
                            dist.Login_Hash_Code__c=FacebookAuthHandler.generateRandomString();
                            dist.Id=currentDistributorId;
                            hasCode=dist.Login_Hash_Code__c;
                            system.debug('inside if');
                            update dist;
                        }else{
                           /* Contact contact=new Contact();
                            contact.LastName = gResp.lastName;
                            contact.firstName = gResp.firstName;
                            contact.Email = gResp.email;
                            contact.Login_Hash_Code__c = FacebookAuthHandler.generateRandomString();
                            contact.Last_Hash_Code_Updated__c = System.now();
                            hasCodeUpdate = contact.Login_Hash_Code__c ;
                            system.debug('inside else');
                            insert contact;  */

                            SignupDistributor = true;
                        }
                        
                        
                        Cookie cookieObj1 = new Cookie('googleSessionId', authCode, null, 3600, false);
                        ApexPages.currentPage().setCookies(new Cookie[]{cookieObj1});
                    }catch(Exception e){
                        system.debug(e.getMessage());
                    }
                }
            }
        }
        
    }
    public void checkFacebookAuth(){
        String authCode ;        
        Cookie lkcode = ApexPages.currentPage().getCookies().get('facebookCode');
        
        string isSignup = ApexPages.currentPage().getCookies().get('signUp').getValue();
        string isLogin = ApexPages.currentPage().getCookies().get('Login').getValue();
        //string isDistributor = ApexPages.currentPage().getCookies().get('isDistributor').getValue();
        //string isCustomer = ApexPages.currentPage().getCookies().get('isCustomer').getValue();
        if(lkcode != null){
            code = lkcode.getValue();
            Cookie cookiefObj   = new Cookie('facebookCode', '', null, 100, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookiefObj});
        }
        if(String.isBlank(code)){
            Cookie gSessId = ApexPages.currentPage().getCookies().get('fbSessionId');   
            if(gSessId != null){
                authCode = gSessId.getValue();
            }
        }
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@code'+code);
        string token;
        if(!String.isBlank(code)){
            Facebook_API_Details__c fad = Facebook_API_Details__c.getInstance();
            if(isLogin == 'true' || isFBcandidateSignup == 'true' || isFBcustomerSignup == 'true'){
                token = FacebookAuthHandler.generateFBAuthCode(code,fad.Auth_Endpoint_URL__c,fad.login_Site_URL__c, fad.App_Id__c, fad.App_Secret__c);    
            }else{
                system.debug('is candiddate');
                token = FacebookAuthHandler.generateFBAuthCode(code,fad.Auth_Endpoint_URL__c,fad.distributor_login_site_url__c, fad.App_Id__c, fad.App_Secret__c);   
            }
            
            system.debug('is token---'+token);
        }
        
        if(!String.isBlank(token)){
            Facebook_API_Details__c fad = Facebook_API_Details__c.getInstance();
            String fbEmail  = FacebookAuthHandler.getFBPublicDetails(fad.Endpoint_URL__c, fad.App_Id__c, fad.App_Secret__c, token);
            FbId            = fbEmail;
            name            = FacebookAuthHandler.name;
            system.debug('fbEmail----------'+fbEmail);
            system.debug(name);
            if(!String.isBlank(fbEmail)){
                
                try{
                    if(isLogin == 'true'){
                        system.debug('login is true-----');
                    }
                    system.debug('isLogin------'+isLogin);
                    system.debug('fbEmail------'+fbEmail);
                    
                    Account[] currentUser;
                    currentUser     = [Select id,name,Status__c,Login_Hash_Code__c from Account where Email__c =:fbEmail]; 
                    system.debug('currentUser--'+currentUser);
                    
                    string recordType;
                    Boolean isSignupFromFb;
                    if (currentUser.size() > 0){
                        
                        if(currentUser[0].Status__c == 'Active' || currentUser[0].Status__c == 'Document Submission'){
                            currentUserId           = currentUser[0].Id;
                            System.debug('FBEMAIL  '+fbEmail);
                            Account dist=new Account();
                            dist.Login_Hash_Code__c=FacebookAuthHandler.generateRandomString();
                            hasCodeUpdate = dist.Login_Hash_Code__c;
                            dist.id=currentUser[0].id;
                            update dist;
                            System.debug('LOGIN HASHCODE===>'+dist.Login_Hash_Code__c);
                            if( currentUser[0].Status__c == 'Document Submission'){
                                docUplaodCustomer = true;
                            }
                        }
                        
                        
                        Cookie cookieObj1 = new Cookie('fbSessionId', authCode, null, 3600, false);
                        ApexPages.currentPage().setCookies(new Cookie[]{cookieObj1});
                        return ;
                    }
                    else{
                            isSignupFromFb = true;
                            System.debug('isSignupFromFb'+isSignupFromFb);
                            Cookie cookieObj1 = new Cookie('fbSessionId', authCode, null, 3600, false);
                            ApexPages.currentPage().setCookies(new Cookie[]{cookieObj1});
                    }
                    
                }
                catch(Exception e){
                    system.debug(e.getMessage());
                }
            }
        }
    } 

    public PageReference redirectProfilePagefoFB() {
        isSignUp            = false;
        isLogin         = false;
        system.debug('redirectProfilePagefoFB cookiessssssssssssss');
        system.debug('ApexPages.currentPage().getParameters().get(m)------'+ApexPages.currentPage().getParameters().get('m'));
        code                        = ApexPages.currentPage().getParameters().get('code');
        isSignUp            = ApexPages.currentPage().getParameters().get('m') == '1' ? true : false;
        string mValue = ApexPages.currentPage().getParameters().get('m');
        system.debug('code----'+code);
        if(mValue == '1'|| mValue == '2'){
            isSignUp = True;
            system.debug('isSignUp---'+isSignUp);
        }
        isLogin             = ApexPages.currentPage().getParameters().get('m') == '0' ? true : false;
        isCustomer          = ApexPages.currentPage().getParameters().get('m') == '1' ? true : false;
        isDistributor         = ApexPages.currentPage().getParameters().get('m') == '2' ? true : false;
        Cookie cookieObj            = new Cookie('facebookCode', code, null, 100, false);
        Cookie cookieLoginTypeObj   = new Cookie('loginType', 'fbLogin', null, 86400, false);
        Cookie mSite                = new Cookie('signUp',isSignUp == true ? 'true' : 'false', null, 100, false);
        Cookie aSite                = new Cookie('Login',isLogin == true ? 'true' : 'false', null, 100, false);
        Cookie isDistributor              = new Cookie('isSignupDistributor',isDistributor == true ? 'true' : 'false', null, 100, false);
        Cookie isCustomer               = new Cookie('isSignupCustomer',isCustomer == true ? 'true' : 'false', null, 100, false);
        system.debug('code'+code);
        system.debug('isSignUp'+isSignUp);
        Facebook_API_Details__c fad = Facebook_API_Details__c.getInstance();
     
        PageReference MyNewPage     = Page.RedirectToFBProfilePage;
        
        MyNewPage.setCookies(new Cookie[]{cookieObj, cookieLoginTypeObj, mSite,aSite,isDistributor,isCustomer});
        
        MyNewPage.setRedirect(true);
        return MyNewPage;
    }
    
    @RemoteAction
    public static string registerFromFacebook(string name,string email, string password, string signUpType){
        try{
                system.debug('name--'+name+'email----'+email+'----password'+password);
                //Document_Category__c candDocCategry = [select name,id from Document_Category__c where Name =:System.Label.CandidateOnboardingDocCategoryName];
                Id distributorRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
                Account acc = New Account();
                acc.Name = name;
                acc.Email__c = email;
                acc.password__c = password;
                acc.login_hash_code__c = Utility.generateRandomString();
                acc.recordTypeId  = distributorRTID;
                //con.Document_Category__c = candDocCategry.Id;
                insert acc;
                return acc.login_hash_code__c;
        }catch(exception e){
            system.debug(e.getLineNumber()+'----------'+e.getMessage());
            return null;
        }
    }

    @RemoteAction
    public static string registerCandidate(Account acc) {
        Savepoint sp = Database.setSavepoint();
        try{
            if(acc.Email__c != null){
                List<Account> candidateRec = [select id from Account where email__c =:acc.Email__c];
                if(candidateRec.size() > 0){
                    return 'recexists';
                }
            }
            Id accCandidateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
            system.debug('acc---------'+acc);
            acc.Status__c = 'New';
            acc.recordTypeId  = accCandidateRecordTypeId;
            acc.login_hash_code__c = Utility.generateRandomString();
            insert acc;
            system.debug('acc.Id--'+acc.Id);
            return acc.login_hash_code__c;
            
        }Catch(Exception e){
            Database.rollback(sp);
            HandleBusinessException.captureError('Distributor_LoginPage_Controller','registerCandidate',e);
            System.debug(e.getMessage());
            return 'Error';
        }
    }

    @RemoteAction
    public static string verifyEmail(string emailId) {
        list<Account> distRec = [select name,id from Account where Email__c=:emailId AND Status__c ='Active' AND RecordType.developerName = :Constants.DISTRIBUTOR];
        system.debug('distRec---'+distRec);
        if(distRec.size() > 0){
            Account distToUpdate = new Account(Id=distRec[0].Id,login_Hash_code__c =utility.generateRandomString());
            update distToUpdate;
            EmailTemplate et = [SELECT Id,Name FROM EmailTemplate where Name = 'Reset Password Link' limit 1];
            system.debug('et.Id---'+et.Id);
            Utility.sendEmailWithTemplate(distToUpdate.Id,et.Id);
            return distToUpdate.login_hash_code__c;
        }else{
            return null;
        }
    }

    @RemoteAction
    Public static string resetPassword(string email,string password,string hashcode){
        Account distToUpdate = [select name,id from Account where Email__c =:email AND Login_Hash_code__c =:hashcode limit 1];
        distToUpdate.Password__c = password;
        distToUpdate.login_hash_code__c = utility.generateRandomString();
        update distToUpdate;
        return distToUpdate.login_hash_code__c;
    }

    @RemoteAction
    public static Account getUserDetails(string hashcode) {
        List<Account> conRec = [select name,id,email__c from Account where Login_Hash_code__c =:hashcode];
        System.debug(conRec);
        system.debug('conRec----'+conRec);
        if(conRec.size() > 0){
            return conRec[0];
        }else{
            return null;
        }
    }
    
}