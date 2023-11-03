public without sharing class OpportunityTriggerHandler {
    static OpportunityTriggerHandler handlerInstance;
    public static OpportunityTriggerHandler getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new OpportunityTriggerHandler();
        return handlerInstance;
    }
    
    public void onBeforeInsert(List<Opportunity> opportunityList) {
        Set<Id> accountIdSet = new Set<Id>();
        for(Opportunity newOpp : opportunityList) {
            if(newOpp.accountId != null)
                accountIdSet.add(newOpp.accountId);
        }
        
        if(!accountIdSet.isEmpty())
            validateOpportunity(opportunityList, accountIdSet);
    }
    
    private void validateOpportunity(List<Opportunity> oppList, Set<Id> accIdSet) {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Potential_Opportunity__c, Total_Team_Members__c FROM Account WHERE Id IN:accIdSet AND Run_Validation_Rule__c = true AND RecordType.DeveloperName = 'Direct_Customer']);
        
        for(Opportunity opp : oppList) {
            System.debug(accountMap.get(opp.AccountId));
            if(accountMap.containsKey(opp.accountId) && (accountMap.get(opp.accountId).Total_Team_Members__c == null || accountMap.get(opp.accountId).Potential_Opportunity__c > accountMap.get(opp.accountId).Total_Team_Members__c)) {
                opp.addError(Constants.OPP_ACC_TEAM_MEMBER_VALIDATION_MSG);
            }
        }
    }
    
    public void intiateApprovalProcess(list<opportunity> newOppList,Map<id,Opportunity> oldOppMap){
        Savepoint sp = Database.setSavepoint();
        try{
            Map<Id,Opportunity> freshOppMap = new Map<Id,Opportunity>([SELECT Id, Approver_Name__c, RecordType.DeveloperName, Owner.UserRole.Name, Approved_by_Manager__c, Approved_by_MD__c, Approved_by_Business_Head__c, Owner.ManagerId, Owner.UserRoleId FROM Opportunity WHERE Id IN:oldOppMap.keySet()]);
            Map<Id, Approval.ProcessSubmitRequest> oppToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>([SELECT Id, ParentRoleId, Name FROM UserRole]);
            Map<Id,Id> oppTomdApprovalRoleIdMap = new Map<Id,Id>();
            Map<Id, User> userByIdMap = new Map<Id, User>([SELECT Id, Name FROM User]);
            
            List<ProcessInstance> recordUnderApprovalList = [Select ID, Status,TargetObjectID, TargetObject.Name From ProcessInstance Where Status =: Constants.PENDING AND TargetObjectID IN :oldOppMap.keySet()];
            Set<Id> underApprovalOppSet = new Set<Id>();
            for(ProcessInstance approvalOpp : recordUnderApprovalList) {
                underApprovalOppSet.add(approvalOpp.TargetObjectID);
            }
            LeadApprovalUtility.OpportunityApprovalWrapper approvalBHWrapper = LeadApprovalUtility.getUserBHMap(); //Has all User -> BH
            LeadApprovalUtility.OpportunityApprovalWrapper approvalMDWrapper = LeadApprovalUtility.getUserMDMap(); //Has all User -> MD
            
            Map<Id, ApprovalWrapper> mdApprovalMap = new Map<Id, ApprovalWrapper>();
            List<ApprovalWrapper> managerApprovalOppList = new List<ApprovalWrapper>();
            List<ApprovalWrapper> bhApprovalOppList = new List<ApprovalWrapper>();
            Map<Id, ApprovalWrapper> bhApprovalFutureOppMap = new Map<Id, ApprovalWrapper>();
            List<Opportunity> oppUpdateList = new List<Opportunity>();
            List<Opportunity> oppUpdateList2 = new List<Opportunity>();
            
            List<ApprovalWrapper> bhApprovalOppListAnnual = new List<ApprovalWrapper>();
            
            if(!newOppList.isEmpty()) {
                for(opportunity opp : newOppList) {
                    if(freshOppMap.get(opp.Id).RecordType.DeveloperName != 'Parent')
                        continue;
                    if(underApprovalOppSet.contains(opp.Id)) {
                        opp.addError(Constants.OPP_UNDER_APPROVAL_PROCESS_ERR_MSG); 
                        continue;
                    }
                    Id oppOwnersRoleId = freshOppMap.get(opp.Id).Owner.UserRoleId;
                    Id managerId = freshOppMap.get(opp.Id).Owner.ManagerId;
                    Id businessHeadId = approvalBHWrapper.smToManagerMap.containsKey(oppOwnersRoleId) && approvalBHWrapper.managerRoleToUserIdMap.containsKey(approvalBHWrapper.smToManagerMap.get(oppOwnersRoleId)) ? approvalBHWrapper.managerRoleToUserIdMap.get(approvalBHWrapper.smToManagerMap.get(oppOwnersRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                    Id mdId = approvalMDWrapper.smToManagerMap.containsKey(oppOwnersRoleId) && approvalMDWrapper.managerRoleToUserIdMap.containsKey(approvalMDWrapper.smToManagerMap.get(oppOwnersRoleId)) ? approvalMDWrapper.managerRoleToUserIdMap.get(approvalMDWrapper.smToManagerMap.get(oppOwnersRoleId)) : null; //getUserMDMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                    
                    system.debug('businessHeadId: ' + businessHeadId);
                    if(oppOwnersRoleId == null || businessHeadId == null) {
                        System.debug('couldnt find this opp owner\'s / BH role Id');
                        //continue;
                    }
                    //2nd is second level approval
                    //if required third level approval
                    
                    //1st use case is initial submission
                    System.debug('--- Testing : :  ');
                    if(opp.Total_Unit_Price__c != null && ( (opp.Total_Unit_Price__c != oldOppMap.get(opp.Id).Total_Unit_Price__c) || (opp.Total_List_Price__c != null && opp.Total_List_Price__c != oldOppMap.get(opp.Id).Total_List_Price__c) ) && opp.Total_Unit_Price__c < opp.Total_List_Price__c && opp.Total_Unit_Price__c > 0 && opp.Total_List_Price__c > 0 && opp.Approved_by_Business_Head__c == false && opp.Approved_By_Manager__c == false && opp.Approved_By_MD__c == false) {
                        //calculate %
                        Double difference = opp.Total_List_Price__c - opp.Total_Unit_Price__c;
                        System.debug('--- difference '+ difference);
                        Double markDownPercentage = (difference / opp.Total_List_Price__c) * 100;
                        System.debug('--- markDownPercentage '+ markDownPercentage);		
                        //unchecking checkboxes because of re-add/update scenarios.
                        oppUpdateList.add(new Opportunity(Id = opp.Id, Markdown__c = markDownPercentage, Approved_by_Manager__c = false, Approved_by_Business_Head__c = false, Approved_By_MD__c = false));
                        
                        
                        if(markDownPercentage > 0) {
                            if((managerId != null && managerId != businessHeadId && !freshOppMap.get(opp.Id).Owner.UserRole.Name.contains('Business Head')) || (managerId != null && freshOppMap.get(opp.Id).Owner.UserRole.Name.contains('Business Head'))) {
                                oppUpdateList2.add(new Opportunity(Id = opp.Id, Approver_Name__c = userByIdMap.get(managerId).Name));
                                managerApprovalOppList.add(new ApprovalWrapper(opp, managerId));
                            }else {
                                oppUpdateList2.add(new Opportunity(Id = opp.Id, Approver_Name__c = userByIdMap.get(businessHeadId).Name));
                                bhApprovalOppList.add(new ApprovalWrapper(opp, businessHeadId));
                            }
                        }
                        
                    }else if(businessHeadId != null && opp.Approved_by_Business_Head__c == false && opp.Approved_by_Manager__c == true && opp.Approved_by_Manager__c != oldOppMap.get(opp.Id).Approved_by_Manager__c) {
                        oppUpdateList2.add(new Opportunity(Id = opp.Id, Approver_Name__c = userByIdMap.get(businessHeadId).Name));
                        bhApprovalFutureOppMap.put(opp.Id, new ApprovalWrapper(opp, businessHeadId));
                    }else if(mdId != null && opp.Approved_by_Business_Head__c == true && opp.Approved_by_Business_Head__c != oldOppMap.get(opp.Id).Approved_by_Business_Head__c && opp.Markdown__c > 6) {
                        oppUpdateList2.add(new Opportunity(Id = opp.Id, Approver_Name__c = userByIdMap.get(mdId).Name));
                        mdApprovalMap.put(opp.Id, new ApprovalWrapper(opp, mdId));
                    }
                    
                    
                    //Annual Value change 
                    if(businessHeadId != Null && opp.Annual_Value_Approval_Status__c != 'Rejected'){
                        if(opp.Annual_Potential_Value__c != oldOppMap.get(opp.Id).Annual_Potential_Value__c && opp.Annual_Potential_Value__c > 0 && opp.Actual_Annual_Potential_Value__c > 0){
                            
                            Integer considerablePercent = Integer.valueOf(System.Label.Percent_for_Annual_Val_consideration);
                            system.debug('considerablePercent -- ' + considerablePercent);
                            system.debug('opp.considerablePercent -- ' + opp.Actual_Annual_Potential_Value__c);
                            
                            Decimal PercentOfActualValue = 0.5*opp.Actual_Annual_Potential_Value__c.setScale(2);
                            system.debug('PercentOfActualValue -- ' + PercentOfActualValue);
                            
                            if(opp.Annual_Potential_Value__c > opp.Actual_Annual_Potential_Value__c){
                                Decimal newAddedValue = opp.Actual_Annual_Potential_Value__c + PercentOfActualValue;
                                if(newAddedValue == opp.Annual_Potential_Value__c){
                                    bhApprovalOppListAnnual.add(new ApprovalWrapper(opp, businessHeadId));
                                }
                            }
                            
                            if(opp.Annual_Potential_Value__c < opp.Actual_Annual_Potential_Value__c){
                                Decimal newSubValue = opp.Actual_Annual_Potential_Value__c - PercentOfActualValue;
                                if(newSubValue == opp.Annual_Potential_Value__c){
                                    bhApprovalOppListAnnual.add(new ApprovalWrapper(opp, businessHeadId));
                                }
                            }
                        }
                    }
                }
                
                if(!oppUpdateList.isEmpty() && !oppUpdateList2.isEmpty())
                    update oppUpdateList;
                    update oppUpdateList2;
                
                if(!managerApprovalOppList.isEmpty()) {
                    initiateManagerApproval(managerApprovalOppList, oppToapprovalRequestMap);
                }
                
                if(!bhApprovalOppList.isEmpty()) {
                    initiateBHApproval(bhApprovalOppList, oppToapprovalRequestMap);
                }
                
                if(!bhApprovalFutureOppMap.isEmpty()) {
                    initiateBHApprovalFuture(bhApprovalFutureOppMap.keySet());
                }
                
                if(!mdApprovalMap.isEmpty()) {
                    initiateMDApprovalFuture(mdApprovalMap.keySet());
                }
                
                //Added
                if(!bhApprovalOppListAnnual.isEmpty()) {
                    initiateBHApprovalForAnnualValChange(bhApprovalOppListAnnual, oppToapprovalRequestMap);
                }                
                
            }
        }
        catch(exception ex){
            //Database.rollback(sp);
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error>>><<'+ex.getLineNumber());
            HandleBusinessException.captureError('OppTriggerHandler', 'initiateApprovalProcess', ex);
        }
    }
    
    //Added By Anjali
    private void initiateBHApprovalForAnnualValChange(List<ApprovalWrapper> oppWrpList, Map<Id, Approval.ProcessSubmitRequest> oppToapprovalRequestMap) {
        for(ApprovalWrapper oppWrp: oppWrpList){
            
            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
            approvalReq.setComments('Submitting for Business Head Annual Value Approval.');
            approvalReq.setObjectId(oppWrp.opp.Id);
            approvalReq.setProcessDefinitionNameOrId('Annual_Potential_Value_Updates_Approval');
            approvalReq.setNextApproverIds(new List<Id> {oppWrp.approverId});
            oppToapprovalRequestMap.put(oppWrp.opp.Id, approvalReq);
        }
        if(!oppToapprovalRequestMap.isEmpty())
            approvalInitiator(oppToapprovalRequestMap);
    }
    
    private void initiateManagerApproval(List<ApprovalWrapper> oppWrpList, Map<Id, Approval.ProcessSubmitRequest> oppToapprovalRequestMap) {
        
        for(ApprovalWrapper oppWrp: oppWrpList){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting for Manager price Approval.');
            req.setObjectId(oppWrp.opp.Id);
            req.setProcessDefinitionNameOrId('Manager_Approval');
            system.debug('opp.Owner.ManagerId----->'+oppWrp.approverId);
            
            req.setNextApproverIds(new List<Id> { oppWrp.approverId });
            oppToapprovalRequestMap.put(oppWrp.opp.Id, req);   
            
        }
        if(!oppToapprovalRequestMap.isEmpty())
            approvalInitiator(oppToapprovalRequestMap);
    }
    
    
    private void initiateBHApproval(List<ApprovalWrapper> oppWrpList, Map<Id, Approval.ProcessSubmitRequest> oppToapprovalRequestMap) {
        for(ApprovalWrapper oppWrp: oppWrpList){
            
            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
            approvalReq.setComments('Submitting for Business Head Price Approval.');
            approvalReq.setObjectId(oppWrp.opp.Id);
            approvalReq.setProcessDefinitionNameOrId('Business_Head_Approval');
            approvalReq.setNextApproverIds(new List<Id> {oppWrp.approverId});
            oppToapprovalRequestMap.put(oppWrp.opp.Id, approvalReq);
        }
        if(!oppToapprovalRequestMap.isEmpty())
            approvalInitiator(oppToapprovalRequestMap);
    }
    
    @Future
    public static void initiateBHApprovalFuture(Set<Id> oppIdList) {
        Map<Id, Approval.ProcessSubmitRequest> oppToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
        List<Opportunity> oppList = [SELECT Id, Owner.UserRoleId, Markdown__c, Initial_Discount_Approved__c, Approved_by_Business_Head__c, Approved_by_Manager__c FROM Opportunity WHERE Id IN: oppIdList];
        LeadApprovalUtility.OpportunityApprovalWrapper approvalBHWrapper = LeadApprovalUtility.getUserBHMap(); //Has all User -> BH
        for(opportunity opp : oppList) {
            if(opp.Markdown__c > 0 && opp.Approved_by_Manager__c == true) {
                Id oppOwnersRoleId = opp.Owner.UserRoleId;
                Id businessHeadId = approvalBHWrapper.smToManagerMap.containsKey(oppOwnersRoleId) && approvalBHWrapper.managerRoleToUserIdMap.containsKey(approvalBHWrapper.smToManagerMap.get(oppOwnersRoleId)) ? approvalBHWrapper.managerRoleToUserIdMap.get(approvalBHWrapper.smToManagerMap.get(oppOwnersRoleId)) : null;
                
                system.debug('businessHeadId: ' + businessHeadId);
                if(oppOwnersRoleId == null || businessHeadId == null) {
                    System.debug('couldnt find this opp owner\'s / BH role Id');
                    continue;
                }
                
                Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                approvalReq.setComments('Submitting for Business Head Price Approval.');
                approvalReq.setObjectId(opp.Id);
                approvalReq.setProcessDefinitionNameOrId('Business_Head_Approval');
                approvalReq.setNextApproverIds(new List<Id> {businessHeadId});
                oppToapprovalRequestMap.put(opp.Id, approvalReq);
            }            
        }
        if(!oppToapprovalRequestMap.isEmpty())
            approvalInitiator(oppToapprovalRequestMap);
    }
    
    @future
    public static void initiateMDApprovalFuture(Set<Id> oppIdList) {
        Map<Id, Approval.ProcessSubmitRequest> oppToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
        List<Opportunity> oppList = [SELECT Id, Owner.UserRoleId, Markdown__c, Initial_Discount_Approved__c, Approved_by_Business_Head__c, Approved_by_Manager__c FROM Opportunity WHERE Id IN: oppIdList];
        LeadApprovalUtility.OpportunityApprovalWrapper approvalMDWrapper = LeadApprovalUtility.getUserMDMap(); //Has all User -> MD
        for(opportunity opp : oppList) {
            if(opp.Markdown__c > 6 && opp.Approved_by_Business_Head__c == true) {
                Id oppOwnersRoleId = opp.Owner.UserRoleId;
                Id mdId = approvalMDWrapper.smToManagerMap.containsKey(oppOwnersRoleId) && approvalMDWrapper.managerRoleToUserIdMap.containsKey(approvalMDWrapper.smToManagerMap.get(oppOwnersRoleId)) ? approvalMDWrapper.managerRoleToUserIdMap.get(approvalMDWrapper.smToManagerMap.get(oppOwnersRoleId)) : null;
                
                system.debug('mdId: ' + mdId);
                if(oppOwnersRoleId == null || mdId == null) {
                    System.debug('couldnt find this opp owner\'s / MD role Id');
                    continue;
                }
                
                Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                approvalReq.setComments('Submitting for Managing Director Price Approval.');
                approvalReq.setObjectId(opp.Id);
                approvalReq.setNextApproverIds(new List<Id> {mdId});
                approvalReq.setProcessDefinitionNameOrId('Managing_Directors_Approval');
                oppToapprovalRequestMap.put(opp.Id, approvalReq);
            }
            
            
        }
        if(!oppToapprovalRequestMap.isEmpty())
            approvalInitiator(oppToapprovalRequestMap);
    }
    
    /*private static void initiateThirdPricingApproval(Id oppId) {
    if(!String.isBlank(oppId)) {
    try{
    Opportunity opp = [SELECT Id, Markdown__c, Initial_Discount_Approved__c, Approved_by_Business_Head__c, Approved_by_Manager__c, Owner.UserRoleId FROM Opportunity WHERE Id =:oppId];
    if(opp.Owner.UserRoleId != null && opp.Markdown__c != null && opp.Markdown__c > 6 && opp.Approved_by_Manager__c && opp.Approved_by_Business_Head__c) {
    Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>([SELECT Id, ParentRoleId, Name FROM UserRole]);
    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setComments('Submitting for Managing Director Price MarkDown Approval.');
    req.setObjectId(opp.Id);
    req.setProcessDefinitionNameOrId('Managing_Directors_Approval');
    Id mdRoleId = LeadApprovalUtility.getMDIdRecursive(userRoleMap, userRoleMap.get(opp.Owner.UserRoleId));
    if(mdRoleId != null) {
    List<User> mdUserList = [SELECT Id FROM User WHERE UserRoleId =:mdRoleId];
    if(!mdUserList.isEmpty()) {
    req.setNextApproverIds(new List<Id> {mdUserList[0].Id});
    Approval.ProcessResult result = Approval.process(req);
    }
    }
    }
    }catch(Exception ex) {
    System.debug('--- Message'+ex.getMessage());
    System.debug('--- Line NO:'+ex.getLineNumber());
    HandleBusinessException.captureError('OpportunityTriggerHandler', 'initiateSecondPricingApproval', ex);
    }
    }
    }*/
        
    
    private static void approvalInitiator(Map<Id, Approval.ProcessSubmitRequest> oppToapprovalRequestMap) {
        if(!oppToapprovalRequestMap.isEmpty()) {
            try{
                List<Approval.ProcessResult> result = Approval.process(oppToapprovalRequestMap.values());
            }catch(Exception ex) {
                System.debug('--- Message'+ex.getMessage());
                System.debug('--- Line NO:'+ex.getLineNumber());
                HandleBusinessException.captureError('OpportunityTriggerHandler', 'initiateSecondPricingApproval', ex);
            }
        }
    }
    
    class ApprovalWrapper {
        public Opportunity opp;
        public Id approverId;
        
        public ApprovalWrapper(Opportunity opp, Id approverId) {
            this.opp = opp;
            this.approverId = approverId;
        }
    }
}