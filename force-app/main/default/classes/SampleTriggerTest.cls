@isTest
public class SampleTriggerTest {
    @isTest(SeeAllData=true)
    private static void run(){
        Database.SaveResult dsr;
        Account acc = new Account();
        acc.Name = 'DUMMY ACCOUNT';
        Insert acc;
        
        Project__c ud = new Project__c();
        ud.Account__c = acc.Id;
        ud.Product_Family__c = 'CPD';
        ud.End_Use_Applications__c = 'Popcorn';
        ud.End_Use_category__c = 'Snacks';
        insert ud;
        ud.Application_Name__c = 'Test';
        update ud;
    }
}