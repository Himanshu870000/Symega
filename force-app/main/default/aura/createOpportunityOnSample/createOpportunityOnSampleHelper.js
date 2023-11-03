({
    getRcType: function(component) {
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var action = component.get('c.getOppRecordTypeId'); 
                action.setParams({
                    "recordTypeName" : "Parent" 
                });
                action.setCallback(this, function(result){
                    var state = result.getState(); 
                    resolve(result.getReturnValue());
                    if(state == 'SUCCESS') {
                        console.log('RECTYPEHELPER----',result.getReturnValue());
                        return result.getReturnValue();
                    }
                });
                
                $A.enqueueAction(action);
            }));
    }
})