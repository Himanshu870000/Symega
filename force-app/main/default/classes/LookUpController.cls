public class LookUpController {
    
    @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        system.debug('fieldName-->'+fieldName);
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        for(sObject so : Database.Query('Select Id,Name,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\'')) {
            String fieldvalue = (String)so.get(fieldName);
            system.debug('so-->'+so);
            string name = (String)so.get('Name');
            system.debug('name-->'+name);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id, name));
        }
        string  tempObjectname = 'OPTIVA_Recipe__c';
        string  tempFieldname = 'SSC_Code__c';
        for(sObject so : Database.Query('Select Id,Name,'+tempFieldname+' FROM '+tempObjectname+' WHERE '+tempFieldname+' LIKE \'%' + value + '%\'')) {
            String fieldvalue = (String)so.get(tempFieldname);
            system.debug('so-->'+so);
            string name = (String)so.get('Name');
            system.debug('name-->'+name);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id, name));
        }
        system.debug('sObjectResultList-->'+sObjectResultList);
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public String recordName;
        
        public SObJectResult(String recNameTemp, Id recIdTemp, string Name) {
            this.recName = recNameTemp;
            this.recId = recIdTemp;
            this.recordName = Name;
        }
    }    
}