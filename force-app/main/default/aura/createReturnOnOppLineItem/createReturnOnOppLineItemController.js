({
    init : function(cmp, event, helper) {
        debugger;            
        var action = cmp.get("c.getOppProductRecord");
        action.setParams({
            "lineItemId": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.lineItemList", response.getReturnValue());                
            }
        });
        $A.enqueueAction(action);    
    },
    
    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    
    handleSubmit: function(component, event, helper) {
        debugger;
        component.find('recordEditForm').submit();
    },
    
    handleRditFormShowHide: function(component, event, helper) {
        debugger;
    },
    
    handleCancel: function(component, event, helper) {
        debugger;
        component.set("v.isModalOpen", false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
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
        component.set("v.isModalOpen", false);
        $A.get('e.force:refreshView').fire();
    },
    handleError : function(component, event, helper) {
        debugger;
        var message = component[0];
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'sticky'
        });
        toastEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    }
    
})