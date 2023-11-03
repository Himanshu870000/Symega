@isTest
private class UserDocumentTriggerTest{
    @isTest(SeeAllData=true)
    private static void run(){
        Database.SaveResult dsr;
        Category_Template__c categoryTemp = new Category_Template__c(Name='ABC');
        insert categoryTemp;
        User_Document__c ud = new User_Document__c();
        ud.Name = 'Test';
        ud.Category_Template__c = categoryTemp.Id;
        insert ud;
        ud.Display_On_Portal__c = true;
        update ud;
    }
}