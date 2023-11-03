({
    init : function(cmp, event, helper) {
        debugger;            
        var action = cmp.get("c.getOppRecord");
        action.setParams({
            "id": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.oppList", response.getReturnValue());                
            }
        });
        
        $A.enqueueAction(action);    
    },
    
    handleSubmit: function(component, event, helper) {
        component.find('recordEditForm').submit();
    },
    
     handleCancel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }, 
    
    handleSuccess : function(component, event, helper) {
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