public without sharing class DistributorDashboard_Helper {

    public static list<UserDocumentWrapper> getContactUserDoc(id parentId) {
        try{
            list<UserDocumentWrapper> udWrapperList = New List<UserDocumentWrapper>();
            map<string,ContentDocumentLink> userDocIdXcdLink = New map<string,ContentDocumentLink>();
            map<string,ContentDistribution> userDocIdXcDistrbtn = New map<string,ContentDistribution>();

            map<string,User_Document__c> idXUserDoc = New Map<string,User_Document__c>();
            map<string,ContentDocumentLink> udIdXcdLink = New Map<string,ContentDocumentLink>();
            list<User_Document__c> getUserDoc;
            if(parentId.getSObjectType().getDescribe().getName() == 'Account'){
                getUserDoc = [select name,id,Status__c,Description__c,Document_Expiry_Applicable__c,Required__c,Document_Expiry_Date__c from User_Document__c where Account__c =:parentId];
            }else{
                getUserDoc = [select name,id,Status__c,Description__c,Document_Expiry_Applicable__c,Required__c,Document_Expiry_Date__c from User_Document__c where  Account__c=:parentId];  //Job_Application__c
            }
            system.debug('getUserDoc----'+getUserDoc);
            set<string> userDocIdSet = New set<string>();
            for(User_Document__c userDoc:getUserDoc){
                userDocIdSet.add(userDoc.id);
                idXUserDoc.put(userDoc.Id,userDoc);
            }
          
           list<ContentDocumentLink> allDocuments = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
            ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId =:userDocIdSet];
            List<ContentDistribution> ContentDistrbtn = [SELECT DistributionPublicUrl,PdfDownloadUrl,RelatedRecordId FROM ContentDistribution where RelatedRecordId IN :userDocIdSet];
            system.debug('allDocuments---'+allDocuments);
            system.debug('ContentDistrbtn---'+ContentDistrbtn);
            set<string> allDocId = New set<string>();     
            for(ContentDocumentLink doc:allDocuments){
                system.debug('doc--'+doc.Id);
                userDocIdXcdLink.put(doc.LinkedEntityId,doc);
                allDocId.add(doc.ContentDocumentId);  
            }

            for(ContentDistribution doc:ContentDistrbtn){
                userDocIdXcDistrbtn.put(doc.RelatedRecordId,doc);
            }

            for(string userDocId:userDocIdSet ){
                udIdXcdLink.put(userDocId,userDocIdXcdLink.get(userDocId));
            }
            Map<string,ContentDocumentLink> docNameXcVersion = New Map<string,ContentDocumentLink>();
           
            Map<string,ContentVersion> cdocIdXcVersion = New Map<string,ContentVersion>();
            ContentVersion[] cvs = [SELECT Id, Title, ContentDocumentId from  contentversion where isLatest=true and ContentDocumentId IN :allDocId];
            system.debug('cvs--'+cvs);
            for(ContentVersion doc :cvs){
                cdocIdXcVersion.put(doc.ContentDocumentId,doc);
            }
            system.debug('cdocIdXcVersion--'+cdocIdXcVersion);
            for(string udId: userDocIdSet){
                system.debug('udId----------'+udId);
                UserDocumentWrapper udWrapper = New UserDocumentWrapper();
                udWrapper.userDocument = idXUserDoc.get(udId);
                System.debug('@@@@@'+userDocIdXcdLink.get(udId) );
                
                if(userDocIdXcdLink.get(udId) != null){
                    System.debug('@@@@@-----------'+cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId));
                    udWrapper.contentVersion = cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId) ;
                }
                if(userDocIdXcDistrbtn.get(udId) != null){
                    System.debug('@@@@@-----------'+userDocIdXcDistrbtn.get(udId));
                    udWrapper.ContentDistribution = userDocIdXcDistrbtn.get(udId) ;
                }
                udWrapperList.add(udWrapper);
            }
            return udWrapperList;
        }catch(Exception e){
            //HandleBusinessException.captureError('CandidateDashboard_Helper', 'getAllUserDoc', e);
            system.debug(e.getLineNumber()+'-----get Message----'+e.getMessage());
            return null;
        }
    }


    public static Pagereference authenticateUser(String hashCode) {
        PageReference pg   = new PageReference('/');        
        if(String.isBlank(hashCode))
            return pg;
        
        system.debug('hashCode===>'+hashCode);  
        
        Id currentUserId = getDistId(hashCode);
        System.debug('auth user id ---'+currentUserId);
        // If current user is not an authorized user 
        // then redirect to login page
        if(currentUserId == null) return pg;
        
        return null;
    }

    private static Id getDistId(String hashCode){
        try{
            list<Account> user = New List<Account> ();
            System.debug('--- hash '+hashCode);
            user =  [SELECT id,RecordTypeId,RecordType.developerName, Last_Hash_Code_Updated__c FROM Account 
                                WHERE Login_hash_Code__c =: hashCode AND Login_Hash_Code__c != null
                                AND RecordType.developerName = :Constants.DISTRIBUTOR ];
            system.debug('user--'+user);
            if(user.size() > 0 && user[0].Last_Hash_Code_Updated__c != null){
                system.debug('Last_Hash_Code_Updated__c not null--'+user[0].Last_Hash_Code_Updated__c);
                if(user[0].Last_Hash_Code_Updated__c.date().daysBetween(system.today()) > 0)
                    return null;
                Long milliseconds = DateTime.now().getTime() - user[0].Last_Hash_Code_Updated__c.getTime();
                Long hours = milliseconds / 1000 / 60 / 60;
                System.debug('---'+hours+'milliseconds---'+milliseconds);
                if(hours > 2) {
                    System.debug('token expired ---');
                    return null;
                }
                system.debug('user[0].Id--'+user[0].Id);
                return user[0].Id;  
            }
            return null;
        }catch(Exception e){
            //HandleBusinessException.captureError('MentorMenteeAuthHelper', 'getContactId', e);
            system.debug(e.getLineNumber()+'-----get Message----'+e.getMessage());
        }
        return null;
    }

    public static Account loginUser(string userName, string password){
        try{
            list<Account> accRec = [select Name,id,email__c,Phone,Login_Hash_Code__c from Account where email__c =:userName AND Password__c =:password limit 1];
            system.debug('conRec----'+accRec);
            if(accRec.size() > 0 ){
                accRec[0].Login_Hash_Code__c = Utility.generateRandomString();
                update accRec[0];
                return accRec[0];
            }else{
                return null;
            }
        }catch(exception e){
            system.debug(e.getLineNumber()+'---error Message---'+e.getMessage());
            HandleBusinessException.captureError('CandidateDashboard_Helper','loginUser',e);
            return null;
        }

    }  

    @RemoteAction
    public static String doUploadAttachment(string type, String attachmentBody, String attachmentName,string conId, String fileId, string userDocId) {
        system.debug('appId--'+attachmentName+'---attachmentId---'+userDocId+'---userDocId---');
        if(String.isBlank(fileId)) {
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'attachmentName'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = attachmentName; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(attachmentBody); // converting your binary string to Blog
            conVer.isMajorVersion = false;
            insert conVer;    //Insert ContentVersion
            
            ContentDistribution cdl = new ContentDistribution();
            cdl.ContentVersionId = conVer.Id;
            cdl.Name = 'PublicShare';
            cdl.RelatedRecordId = userDocId;
            insert cdl;
            system.debug('ContentDistribution----'+cdl);
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record 
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = userDocId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            insert conDocLink;
            System.debug('Uploaded doc----');
            if(type == 'profilePic' && String.isNotEmpty(conId)){
                System.debug('Uploaded Loda----');
                updateContactProfilepicId(conId,conVer.Id);
            }else{
                User_Document__c udoc = New User_Document__c(id=userDocId,Status__c='Uploaded',User_Document_Attachment_Id__c=conVer.Id);
                System.debug('Uploaded Thoka----');
                //update udoc;
            }
            return conVer.Id;
        }else{
            List<ContentVersion> cvList = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :fileId];
            if(!cvList.isEmpty()) {
                ContentVersion cVersion = cvList[0];
                if(cVersion.VersionData != null) {
                    String newBody = EncodingUtil.base64Encode(cVersion.VersionData);
                    newBody += attachmentBody;
                    cVersion.VersionData = EncodingUtil.base64Decode(newBody); // converting your binary string to Blog
                    update cVersion;
                    return cVersion.Id;
                } 
                return 'error';   
            }
            return 'error'; 
        }
    }

    public static void updateContactProfilepicId(string conId,string picAttId){
        Account conRec = new Account(id=conid,Profile_Pic_Id__c=picAttId);
        update conRec;
    }

    @RemoteAction
    public static String doCUploadAttachment(String attachmentBody, String attachmentName, string cvId, String udId) {
        system.debug('attachmentBody---'+attachmentName+'---attachmentId---'+cvId+'---cvId---'+udId);
        if(String.isBlank(attachmentBody) || String.isBlank(udId))
            return 'ERROR';
        if(String.isBlank(cvId)) {
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = '/'+System.now()+attachmentName;//'attachmentName';
            conVer.Title = attachmentName; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(attachmentBody); // converting your binary string to Blog
            conVer.isMajorVersion = false;
            insert conVer;    //Insert ContentVersion
            
            ContentDistribution cdl = new ContentDistribution();
            cdl.ContentVersionId = conVer.Id;
            cdl.Name = 'PublicShare';
            cdl.RelatedRecordId = udId;
            insert cdl;
            system.debug('ContentDistribution----'+cdl);
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record 
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = udId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            insert conDocLink;
            return conVer.Id;
        }else {
            List<ContentVersion> cvList = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :cvId];
            if(!cvList.isEmpty()) {
                ContentVersion cVersion = cvList[0];
                if(cVersion.VersionData != null) {
                    String newBody = EncodingUtil.base64Encode(cVersion.VersionData);
                    newBody += attachmentBody;
                    cVersion.VersionData = EncodingUtil.base64Decode(newBody); // converting your binary string to Blog
                    update cVersion;
                    return cVersion.Id;
                }   
            }
        }
        return 'ERROR';
    }

    public static String updateUserDoc(Id attId, Id contentVersionId) {
        try {
            update new User_Document__c(id=attId,Status__c='Uploaded',User_Document_Attachment_Id__c=contentVersionId);
            return 'success';
        }catch(DMLException e){
            HandleBusinessException.captureError('CandidateDashboard_Helper', 'updateUserDoc', e);
            return 'error';
        }
    }

    public static void updateUserDetails(Account candidateDetails) {
        update candidateDetails;
    }	
    
    @RemoteAction
    public static string updateAvailabllity(string candidateId, list<string> availableDays, integer strtMin,integer strtHour, integer endMin,integer endHour) {
        try{
            system.debug('availableDays--'+availableDays);
            string colenSepratedList = '';
            for(String str : availableDays){
            colenSepratedList += str.substring(0, 3) + ';' ;
            }
            system.debug('colenSepratedList--'+colenSepratedList);
            return 'success';
        }catch(exception e){
            system.debug(e.getLineNumber()+'-------'+e.getMessage());
            return null;
        }
    }  

    public static void updateDocExpirydate(integer day,integer month,integer year,string userDocId){
        user_document__c useDoc = New user_document__c(id=userDocId,Document_Expiry_Date__c=date.newInstance(year,month,day));
        update useDoc;
    }

    /*public class CandidateShiftWithSkills{
        public shift__c shift;
        public shift__c candidateShift;
        public List<string> skillList;
        public boolean haveShiftOnSameDay;
        public boolean shiftAlreadyAllocated;
    }*/

    public class ContactUserDocumentWrapper{
        public list<UserDocumentWrapper> userDocWrapper;
        public Contact userDetails;
        //public list<Job_Application__c> jobsToAcceptByCandidate;
    }

    public class UserDocumentWrapper{
        public User_Document__c userDocument;
        public ContentVersion contentVersion;
        public ContentDistribution ContentDistribution;
    }
    
    @RemoteAction
    public static String logoutCandidate(String candidateId){
        try{
            List<Account> accList = [SELECT Id,Login_Hash_Code__c FROM Account WHERE Id=: candidateId];
            for(Account acc : accList){
                if(acc.Login_Hash_Code__c !=null){
                    acc.Login_Hash_Code__c = Null;
                }
            }
            update accList;
            return 'SUCCESS'; 
        }catch(Exception e){
            return 'ERROR';
        }
    }
    
}