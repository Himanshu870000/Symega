public class LeadTriggerHandler {
    static LeadTriggerHandler handlerInstance;
    public static LeadTriggerHandler getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new LeadTriggerHandler();
        return handlerInstance;
    }
    
    public void onBeforeInsert(List<Lead> newLeadList) {
        system.debug('Lead List:: ' + newLeadList);
        set<Id> leadIdSet = new set<Id>();   
        for(Lead leadRec : newLeadList ) {
            leadIdSet.add(leadRec.Id);
        }
        
        
        list<Lead> leadListToBeInserted = new list<Lead>();
        String roleId = System.userInfo.getUserRoleId();
        LeadApprovalUtility.OpportunityApprovalWrapper approvalBHWrapper = LeadApprovalUtility.getUserBHMap();
        for(Lead leadRec : newLeadList){
            leadRec.Assigned_To__c = leadRec.OwnerId;
            system.debug('User Role Id '+roleId);
            
            //Id businessHeadId = approvalBHWrapper.smToManagerMap.containsKey(roleId) && approvalBHWrapper.managerRoleToUserIdMap.containsKey(approvalBHWrapper.smToManagerMap.get(roleId)) ? approvalBHWrapper.managerRoleToUserIdMap.get(approvalBHWrapper.smToManagerMap.get(roleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
            Id businessHeadId = LeadApprovalUtility.getBusinessHeadApproverId(roleId);
            
            system.debug('BH ID ' + businessHeadId);
            if(!string.isBlank(roleId))
                leadRec.Business_Head__c = businessHeadId;
        }
    }
    
    
    public void onAfterUpdate(Map<Id,Lead> oldLeadMap, Map<Id,Lead> newLeadMap) {
        system.debug('After Update Helper');
        Map<Id,Lead> freshLeadMap = new Map<Id,Lead>([SELECT Id, Owner.UserRole.Name FROM Lead WHERE Id IN:oldLeadMap.keySet()]);

        for(Lead leadRec : newLeadMap.values()){
            //MH_approved should be true and changed, Stage should be approved by MH and changed
            if(leadRec.Marketing_Head_Approved__c == true && leadRec.Marketing_Head_Approved__c != oldLeadMap.get(leadRec.id).Marketing_Head_Approved__c && leadRec.Lead_Substage__c == Constants.LEAD_APPROVAL_STATUS_MH_APPROVED && leadRec.Lead_Substage__c != oldLeadMap.get(leadRec.id).Lead_Substage__c){
                system.debug('Business head approval');
                
                system.debug('LeadRec.Business_Head__c -- ' + LeadRec.Business_Head__c);
                system.debug('LeadRec.UserRole -- ' + freshLeadMap.get(LeadRec.Id).Owner.UserRole.Name);
                system.debug('LeadRec.Lead_Segment__c -- ' + LeadRec.Lead_Segment__c);
                system.debug('LeadRec.of_potential_opportunities__c -- ' + LeadRec.of_potential_opportunities__c);
                system.debug('LeadRec.Total_Addressable_Market__c -- ' + LeadRec.Total_Addressable_Market__c);
                
                if(freshLeadMap.get(LeadRec.Id).Owner.UserRole.Name != null && (LeadRec.Business_Head__c != null && !freshLeadMap.get(LeadRec.Id).Owner.UserRole.Name.contains('Business Head') || freshLeadMap.get(LeadRec.Id).Owner.UserRole.Name.contains('Business Head')) && LeadRec.Lead_Segment__c != null && LeadRec.of_potential_opportunities__c != null && LeadRec.of_potential_opportunities__c != '0' && LeadRec.Total_Addressable_Market__c != 0) {
                    LeadApprovalUtility.submitForApprovalToBusinessHead(leadRec.Id);    
                }else if( (LeadRec.Business_Head__c == null && !freshLeadMap.get(LeadRec.Id).Owner.UserRole.Name.contains('Business Head')) ){
                    LeadRec.Business_Head__c.addError(Constants.LEAD_BUSINESS_HEAD_REQ_ERROR_MSG);
                }else if(LeadRec.Lead_Segment__c == null) {
                    LeadRec.Lead_Segment__c.addError(Constants.LEAD_SEGMENT_REQ_BY_MH_ERROR_MSG);
                }else if(LeadRec.of_potential_opportunities__c == null || LeadRec.of_potential_opportunities__c == '0') {
                    LeadRec.of_potential_opportunities__c.addError('Please provide "# of potential opportunities - Marketing" value inorder to proceed.');
                }else if(LeadRec.Total_Addressable_Market__c == null || LeadRec.Total_Addressable_Market__c == 0) {
                    LeadRec.of_potential_opportunities__c.addError('Please provide "Total Addressable Market" value inorder to proceed.');
                }
                
            }else if(leadRec.Marketing_Head_Approved__c == true && leadRec.Business_Head_Approved__c == true && leadRec.Business_Head_Approved__c != oldLeadMap.get(leadRec.id).Business_Head_Approved__c && leadRec.Lead_Substage__c == Constants.LEAD_APPROVAL_STATUS_BH_APPROVED && leadRec.Lead_Substage__c != oldLeadMap.get(leadRec.id).Lead_Substage__c) {
                if(LeadRec.Assigned_To__c == null){
                    LeadRec.addError('Please provide "Assigned To" value to whom the Account should be assigned to when the Lead is converted.');
                }else if(LeadRec.of_potential_opportunities_Business__c == null || LeadRec.of_potential_opportunities_Business__c == '0') {
                    LeadRec.addError('Please provide "# of potential opportunities - Business" value inorder to proceed.');
                }
            }
        }
    }
    public void updateApprovalMemberApprovedDate(Map<Id,Lead> oldLeadMap, Map<Id,Lead> newLeadMap){
        for(Lead leadRec : newLeadMap.values()){
            
            if(leadRec.Status != oldLeadMap.get(leadRec.Id).Status){
                if(leadRec.Status == Constants.ACCEPTED_BY_BH_STATUS || leadRec.Status == Constants.REJECTED_STAGE){
                    LeadApprovalUtility.updateApprovedDate(Constants.BH_APPROVAL_GROUP);
                }
                else if(leadRec.Status == Constants.ACCEPTED_BY_MH_STATUS || leadRec.Status == Constants.REJECTED_STAGE){
                    LeadApprovalUtility.updateApprovedDate(Constants.MH_APPROVAL_GROUP);
                }
            }   
        }
    }
    public void addValidation(Map<Id,Lead> oldLeadMap, Map<Id,Lead> newLeadMap){
        for(Lead leadRec : oldLeadMap.values()){
            system.debug('leadRec.st'+leadRec.Status);
            system.debug('Leadrec.status>>'+newLeadMap.get(leadRec.Id).Status);
            if(leadRec.Status != newLeadMap.get(leadRec.id).Status && leadRec.Status == Constants.LEAD_STAGE_UNDER_APPROVAL){
                newLeadMap.get(leadRec.Id).addError('Lead cannot be Edited While under approval!!');
            }
            if(newLeadMap.get(leadRec.Id).Status == Constants.LEAD_STATUS_QUALIFIED ){
                if(newLeadMap.get(leadRec.Id).Business_Head_Approved__c == False || newLeadMap.get(leadRec.Id).Marketing_Head_Approved__c == False){
                    newLeadMap.get(leadRec.Id).addError('Lead cannot be converted, Not verified by Either Business or Marketing Head!!');
                }
            }
        }
    }
}