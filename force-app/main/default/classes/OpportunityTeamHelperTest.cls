@isTest
private class OpportunityTeamHelperTest {
    @isTest 
    static void test() 
    {
        Test.startTest();
        
        Opportunity oppRecType = new Opportunity();
        oppRecType.Name = 'Dummy';
        oppRecType.StageName = 'New';
        oppRecType.CloseDate = System.TODAY();
        oppRecType.End_Use_Application__c = 'Popcorn';
        oppRecType.End_Use_category__c = 'Snacks';
        insert oppRecType;
        
        Opportunity_Team_Master__c obj = new Opportunity_Team_Master__c();
        insert obj;
        
        Account acc = new Account();
        acc.name = 'TEST ACCOUNT';
        Insert acc;
        
        Project__c recordType = new Project__c();
        recordType.Account__c = acc.Id;
        recordType.Product_Family__c = 'CPD';
        recordType.End_Use_Applications__c = 'Popcorn';
        recordType.End_Use_category__c = 'Snacks';
        insert recordType;
        
        list<Contact> conList = new list<Contact>();
        for(Integer i =0; i<10; i++){
            Contact con = new Contact();
            con.FirstName = 'FIRSTNAME- '+ i;
            con.LastName = 'LASTNAME- ' + i;
            conList.add(con);
        }
        insert conList;
        
        list<String> contactIDList =  new list<String>();
        for(Contact con: conList){
            contactIDList.add(con.Id);
        }
        
        OpportunityTeamHelper.getOpportunityteamMaster();
        
        OpportunityTeamHelper.createOppTeam(obj.id, recordType.id , contactIDList);
        
        Test.stopTest();
    }
}