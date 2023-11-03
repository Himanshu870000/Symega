public without sharing class OpportunityTeamHelper {
    @AuraEnabled
    public static List<Opportunity_Team_Member__c> getOpportunityteamMaster(){
        List<Opportunity_Team_Member__c> oppTeamMemberList = new List<Opportunity_Team_Member__c>();
        
        oppTeamMemberList = [Select Id,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Opportunity_Team_Master__c,Opportunity_Team_Master__r.Name,isActive__c From Opportunity_Team_Member__c Where isActive__c = TRUE AND Opportunity_Team_Master__c != NULL ORDER BY Opportunity_Team_Master__r.Name ASC ];
        return oppTeamMemberList;
    }
    
    @AuraEnabled
    public static void createOppTeam(string oppTeamMasterId, Id recordId, List<String> contactIds){
        try{
            system.debug('oppTeamMasterId>>'+oppTeamMasterId);
            system.debug('recordId>>'+recordId);
            system.debug('contactIds>>'+contactIds);
            List<Opportunity_Team__c> oppTeamToBeInserted = new List<Opportunity_Team__c>();
            String teamName='';
            Account customerAccount;
            if(!String.isBlank(recordId)){
                if(String.valueOf(recordId.getsobjecttype()) == 'Opportunity')
                    teamName = [Select Id,Name from Opportunity Where Id = :recordId].Name;
                if(String.valueOf(recordId.getsobjecttype()) == 'Project__c')
                    teamName = [Select Id,Name from Project__c Where Id = :recordId].Name;
                if(String.valueOf(recordId.getsobjecttype()) == 'Account') {
                    customerAccount =  [Select Id,Name from Account Where Id = :recordId];
                    teamName = customerAccount.Name;
                }
            }
            
            if(!String.isBlank(oppTeamMasterId)){
                if(!contactIds.isEmpty()){
                    Map<Id, Contact> ContactBYId = new Map<Id,Contact>([Select Name, Email From Contact Where Id in : contactIds]);
                    for(String contactId : contactIds){
                        Opportunity_Team__c oppTeamRec = new Opportunity_Team__c();
                        oppTeamRec.Contact__c = contactId;
                        
                        if(!String.isBlank(recordId)){
                            if(String.valueOf(recordId.getsobjecttype()) == 'Opportunity'){
                                oppTeamRec.Name = teamName+' - '+ ContactBYId.get(contactId).Name;
                                oppTeamRec.Opportunity__c = recordId;
                            }                               
                            if(String.valueOf(recordId.getsobjecttype()) == 'Project__c'){
                                oppTeamRec.Sample__c = recordId;
                                oppTeamRec.Name = teamName+' - '+ ContactBYId.get(contactId).Name;
                            }
                            if(String.valueOf(recordId.getsobjecttype()) == 'Account'){
                                oppTeamRec.Account__c = recordId;
                                oppTeamRec.Name = teamName+' - '+ ContactBYId.get(contactId).Name;
                            }   
                        }
                         oppTeamToBeInserted.add(oppTeamRec);
                    }
                    if(!oppTeamToBeInserted.isEmpty()){
                        insert oppTeamToBeInserted;
                        if(customerAccount != null) {
                            customerAccount.Total_Team_Members__c = [SELECT Id FROM Opportunity_Team__c WHERE Account__c =:recordId].size();
                            update customerAccount;
                        }
                    }
                }    
            }
        }catch(exception ex){
            system.debug('Error>>'+ex.getMessage());
            system.debug('Error==>'+ex.getLineNumber());
        }
    }
}