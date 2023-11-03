public class UserTriggerHelper {
    public Static Void checkingManagerandTranferAccount(list<User> userList){
        try{
            
            set<Id> deactivatedUsersId = new Set<Id>();
            
            for(User userRec : userList){
                if(userRec.isActive == false ){
                    if(userRec.ManagerId == null){
                        system.debug('Error');
                        userRec.Id.addError('Please Tag Manager to TRANSFER ACCOUNTS');
                    }else{
                        system.debug('No Error');
                        deactivatedUsersId.add(userRec.ID);
                    }
                }
            }
            system.debug('deactivatedUsersId>>'+deactivatedUsersId);
            if(!deactivatedUsersId.isEmpty()){
                UpdateAccountOwnerOnUserDeactivation.changeAccountOwnerShip(deactivatedUsersId);
            }
        }catch(Exception ex){
            system.debug('Erro>>'+ex.getMessage());
            system.debug('Error@@@'+ex.getLineNumber());
        }
    }
}