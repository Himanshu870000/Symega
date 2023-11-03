({
    init : function(cmp, event, helper) {
        debugger;
        helper.getRcType(cmp).then(recTypeId =>{
            console.log('recTypeId',recTypeId);
            var action = cmp.get("c.getOppRecord");
            action.setParams({
            "id": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.oppRecList", response.getReturnValue());
                var nameFieldValue = cmp.find("recType").set("v.value", recTypeId);
            }
        });
        
        $A.enqueueAction(action);
    });
},
 
 handleSubmit: function(component, event, helper) {
    debugger;
    component.find('recordEditForm').submit();
}, 
    
    handleCancel: function(component, event, helper) {
        debugger;
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },   
        handleSuccess : function(component, event, helper) {
            debugger;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Success',
                message: 'Record Saved Successfully',
                duration:' 3000',
                key: 'info_alt',
                type: 'success',
                mode: 'pester'
            });
            toastEvent.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        },
            handleError : function(component, event, helper) {
                debugger;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'This is an error message',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'sticky'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }

})