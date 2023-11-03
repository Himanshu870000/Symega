({
    /*getMissingAccountData : function(component, event) {
        debugger;
        var action = component.get("c.getMissingAccountDetails");
        action.setParams({
            projId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() !=null){
                    var tempArray = [];
                    var data = response.getReturnValue();
                    if(data != null){
                        if(data.length>0){
                            component.set("v.ShowUpdateAccountPage",true);
                            component.set("v.MissingFieldList",data);   
                            component.set("v.accountId","0015j00000ryYzZAAU");
                        }else{
                            component.set("v.ShowUpdateAccountPage",false);
                        }
                    }
                }
            }else if(response.getState() === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }*/
    
    getMissingAccountData : function(component, event) {
        debugger;
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var action = component.get("c.getMissingAccountDetails");
                action.setParams({
                    projId : component.get("v.recordId")
                });
                action.setCallback(this,function(response){
                    if(response.getState() === "SUCCESS"){
                        if(response.getReturnValue() !=null){
                            return response.getReturnValue();
                        }
                    }
                });
                $A.enqueueAction(action);
            }));
    },
    
    callSAPCodeUpdate : function(component, userId, sapCode){
        debugger;
        console.log('Received parameters: ' + userId + ', ' + sapCode);
        
        var action = component.get("c.updateUser");
        action.setParams({
            "userId": userId,
            "userSAPcode": sapCode
        });
        action.setCallback(this, function(response) {
            var serverResponse = response.getReturnValue();
            if(response.getState() === "SUCCESS") {
                console.log('success');
            } 
            else{
                 console.log('error');
            }    
        });
        $A.enqueueAction(action);
    },
    
    callAccountUpdate : function(component, accId, deliveryPlant, CustomerType, AccSeg){
        debugger;
        console.log('Received parameters: ' + accId + ', ' + deliveryPlant + ', ' + CustomerType + ', ' + AccSeg);
        
        var action = component.get("c.updateAccount");
        action.setParams({
            "accId": accId,
            "dlvryPlant": deliveryPlant,
            "custType": CustomerType,
            "accSeg" : AccSeg
        });
        action.setCallback(this, function(response) {
            var serverResponse = response.getReturnValue();
            if(response.getState() === "SUCCESS") {
                console.log('success');
            } 
            else{
                 console.log('error');
            }    
        });
        $A.enqueueAction(action);
    }
})