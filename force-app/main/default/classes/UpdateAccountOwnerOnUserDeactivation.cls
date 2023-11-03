public class UpdateAccountOwnerOnUserDeactivation {
    
    @future
    public static void changeAccountOwnerShip(Set<Id> deactivatedUsersId){
        try{
            
            List<Account> accountsToBeReassigned = new List<Account>();
            List<Account> accountsToBeUpdated = new List<Account>();
            system.debug('deactivatedUsersId>>' + deactivatedUsersId);
            
            accountsToBeReassigned = [Select Id, OwnerId, Owner.ManagerId From Account Where OwnerId in : deactivatedUsersId];
            system.debug('accountsToBeReassigned>>'+accountsToBeReassigned);
            
            if(!accountsToBeReassigned.isEmpty()) {
                for(Account accRec : accountsToBeReassigned){
                    accRec.OwnerId = accRec.owner.ManagerId;
                    accountsToBeUpdated.add(accRec);
                }
                if(!accountsToBeUpdated.isEmpty()){
                    update accountsToBeUpdated;
                }
            } 
        }
        
        catch(Exception ex){
            system.debug('Erro>>'+ex.getMessage());
            system.debug('Error@@@'+ex.getLineNumber());
        }
    }
}