/**
 * Author: DeaGle~
 * CreatedDate: May 2nd, 2023
 * Description: contains all parent account summary calculation
 */

public without sharing class ParentAccountRollupUtility {
    
    //@future
    public static void processSummaryCalculationFuture(Set<Id> parentAccIdSet) {

        Map<Id, Account> childAccountMap = new Map<Id,Account>([SELECT Id, ParentId, (SELECT Id, StageName, Color_Opportunity__c, CPD_Opportunity__c, Flavor_Opportunity__c, Plant_Based_Opportunity__c, SPD_Opportunity__c FROM Opportunities), Number_of_closed_opportunity__c, Number_of_open_opportunity__c, Number_of_Total_Opportunity__c, Number_Of_Won_Opportunity__c, Number_of_won_opportunity_partially_exec__c, Closed_Opportunity_Value__c, COLOR_Opportunity_Closed_Value__c, CPD_Opportunity_Closed_Value__c, FLAVOR_Opportunity_Closed_Value__c, PLANT_BASED_Opportunity_Closed_Value__c, SPD_Opportunity_Closed_Value__c FROM Account WHERE ParentId IN :parentAccIdSet OR Id IN :parentAccIdSet]);

        Map<Id, List<Account>> parentToChildAccMap = new Map<Id, List<Account>>();

        for(Account acc : childAccountMap.values()) {
            if(acc.ParentId != null) {
                if(parentToChildAccMap.containsKey(acc.ParentId)) 
                    parentToChildAccMap.get(acc.ParentId).add(acc);
                else
                    parentToChildAccMap.put(acc.ParentId, new List<Account> {acc});
            }
            
        }


        List<Account> parentAccountToUpdateList = new List<Account>();
        
        for(Id parentId : parentToChildAccMap.keySet()) {
            Account parentAcc = new Account(Id = parentId);
            parentAcc.Number_of_closed_opportunity_new__c = 0;
            parentAcc.Number_of_open_opportunity_new__c = 0;
            parentAcc.Number_of_Total_Opportunity_new__c = 0;
            parentAcc.Number_Of_Won_Opportunity_new__c = 0;
            parentAcc.Number_of_won_opportunity_partially_new__c = 0;
            parentAcc.Closed_Opportunity_Value_New__c = 0;
            parentAcc.COLOR_Opportunity_Closed_Value_New__c = 0;
            parentAcc.CPD_Opportunity_Closed_Value_New__c = 0;
            parentAcc.FLAVOR_Opportunity_Closed_Value_New__c = 0;
            parentAcc.PLANT_BASED_Opportunity_Closed_Value_New__c = 0;
            parentAcc.SPD_Opportunity_Closed_Value_New__c = 0;

            for(Account acc: parentToChildAccMap.get(parentId)) {
                parentAcc.Number_of_closed_opportunity_new__c += acc.Number_of_closed_opportunity__c;
                parentAcc.Number_of_open_opportunity_new__c += acc.Number_of_open_opportunity__c;
                parentAcc.Number_of_Total_Opportunity_new__c += acc.Number_of_Total_Opportunity__c;
                parentAcc.Number_Of_Won_Opportunity_new__c += acc.Number_Of_Won_Opportunity__c;
                parentAcc.Number_of_won_opportunity_partially_new__c += acc.Number_of_won_opportunity_partially_exec__c;
                parentAcc.Closed_Opportunity_Value_New__c += acc.Closed_Opportunity_Value__c;
                parentAcc.COLOR_Opportunity_Closed_Value_New__c += acc.COLOR_Opportunity_Closed_Value__c;
                parentAcc.CPD_Opportunity_Closed_Value_New__c += acc.CPD_Opportunity_Closed_Value__c;
                parentAcc.FLAVOR_Opportunity_Closed_Value_New__c += acc.FLAVOR_Opportunity_Closed_Value__c;
                parentAcc.PLANT_BASED_Opportunity_Closed_Value_New__c += acc.PLANT_BASED_Opportunity_Closed_Value__c;
                parentAcc.SPD_Opportunity_Closed_Value_New__c += acc.SPD_Opportunity_Closed_Value__c;
            }

            if(childAccountMap.containsKey(parentId)) {
                Account currentParent = childAccountMap.get(parentId);
                parentAcc.Number_of_closed_opportunity_new__c += currentParent.Number_of_closed_opportunity__c;
                parentAcc.Number_of_open_opportunity_new__c += currentParent.Number_of_open_opportunity__c;
                parentAcc.Number_of_Total_Opportunity_new__c += currentParent.Number_of_Total_Opportunity__c;
                parentAcc.Number_Of_Won_Opportunity_new__c += currentParent.Number_Of_Won_Opportunity__c;
                parentAcc.Number_of_won_opportunity_partially_new__c += currentParent.Number_of_won_opportunity_partially_exec__c;
                parentAcc.Closed_Opportunity_Value_New__c += currentParent.Closed_Opportunity_Value__c;
                parentAcc.COLOR_Opportunity_Closed_Value_New__c += currentParent.COLOR_Opportunity_Closed_Value__c;
                parentAcc.CPD_Opportunity_Closed_Value_New__c += currentParent.CPD_Opportunity_Closed_Value__c;
                parentAcc.FLAVOR_Opportunity_Closed_Value_New__c += currentParent.FLAVOR_Opportunity_Closed_Value__c;
                parentAcc.PLANT_BASED_Opportunity_Closed_Value_New__c += currentParent.PLANT_BASED_Opportunity_Closed_Value__c;
                parentAcc.SPD_Opportunity_Closed_Value_New__c += currentParent.SPD_Opportunity_Closed_Value__c;
            }

            parentAccountToUpdateList.add(parentAcc);
        }

        if(!parentAccountToUpdateList.isEmpty()) {
            try{
                System.debug(LoggingLevel.DEBUG, '--- parentAccountToUpdateList '+parentAccountToUpdateList);
                update parentAccountToUpdateList;
            }catch(DmlException e) {
                System.debug('--- error message'+e.getMessage());
                HandleBusinessException.captureError('ParentAccountRollupUtility', 'processSummaryCalculationFuture', e);
            }
        }


        /**
         *  Number_of_closed_opportunity_new__c
            Number_of_open_opportunity__new__c
            Number_of_Total_Opportunity_new__c
            Number_Of_Won_Opportunity_new__c
            Number_of_won_opportunity_partially_new__c
            Closed_Opportunity_Value_New__c
            COLOR_Opportunity_Closed_Value__New__c
            CPD_Opportunity_Closed_Value_New__c
            FLAVOR_Opportunity_Closed_Value_New__c
            PLANT_BASED_Opportunity_Closed_Value_New__cSPD_Opportunity_Closed_Value_New__c
         */

    }

    


}