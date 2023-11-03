({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.notifySLIAssignee");
        action.setParams({
            "sampleId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log("SUCCESS RESULT: ", storeResponse);
                if(storeResponse === 'SUCCESS'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Notification Sent successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Warning',
                        message: 'Owner has been changed already',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'pester'
                    });
                }
                
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
                if (storeResponse.length == 0) {
                    Component.set("v.Message", 'No Result Found...');
                } else {
                    Component.set("v.Message", '');
                }
                resolve(storeResponse);
            }    
            if(state === "ERROR"){
                var errors= response.getError();
                console.log("ERROR: ", errors);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: errors[0].message,
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
        });
        $A.enqueueAction(action);
    },
})