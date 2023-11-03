({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.createOneTimeOppRec");
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('>>>>> state'+ state );
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'One Time Opportunity Record without Splitting has been created',
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                
            }else{
                var errors= response.getError();
                component.set("v.showModal",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:errors[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'sticky'
                });
                toastEvent.fire();
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
        })
        $A.enqueueAction(action);
    },
    
    hideModel: function(component, event, helper) {
        component.set("v.showModal", false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire()
    },
})