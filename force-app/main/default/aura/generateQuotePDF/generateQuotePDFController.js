({    
    doInit : function(component, event, helper){
        debugger;
        var action = component.get("c.getQtDetails");
        action.setParams
        ({ 
            "recId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var storeResponse = response.getReturnValue();
            console.log("SUCCESS RESULT: ", storeResponse);
            if(state === 'SUCCESS') {
                component.set("v.freightChrg", storeResponse);
            }
        }, 'ALL' );
        $A.enqueueAction(action);
    },
    
    handleSave: function(component, event, helper) {
        debugger;
        var action = component.get("c.savePDF");
        action.setParams
        ({ 
            "id": component.get("v.recordId"),
            "url" : component.get("v.QuoteLink") + component.get("v.recordId"),
            "fileName" : 'Quote FILE',
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                var storeResponse = response.getReturnValue();
                console.log("SUCCESS RESULT: ", storeResponse);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Quote PDF Saved Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            }
            else if(state ==='ERROR') {
                var errors= response.getError();
                console.log("Save ERROR: ", errors);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Save Error',
                    message: errors[0].message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'sticky'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        }, 'ALL' );
        $A.enqueueAction(action);
    }, 
    
    emailToClient: function(component, event, helper) {
        debugger;
        var action = component.get("c.quoteEmailToClient");
        action.setParams
        ({ 
            "quoteId": component.get("v.recordId"),
            "url" : component.get("v.QuoteLink") + component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                var storeResponse = response.getReturnValue();
                console.log("SUCCESS RESULT: ", storeResponse);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Quote PDF Sent Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            }
            else if(state ==='ERROR') {
                var errors= response.getError();
                console.log("Save ERROR: ", errors);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Email Sent Error',
                    message: errors[0].message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'sticky'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        }, 'ALL' );
        $A.enqueueAction(action);
    }, 
    
    handleChange: function(component, event, helper) {
        debugger;
        var checked = component.find("checkbox").get("v.value");
        component.set("v.showField", checked);
    },
    
    handleNext: function(component, event, helper) {
        debugger;    
        
        var checkedVal = component.find("checkbox").get("v.value");
        var frChrg = component.get("v.freightChrg");
        
        var action = component.get("c.updateOnQuote");
        action.setParams
        ({ 
            "recId": component.get("v.recordId"),
            "check" : checkedVal,
            "frChrge" : frChrg,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("state", state);
            if(state === 'SUCCESS') {
                component.set("v.showPDF", true);
            }
        }, 'ALL' );
        $A.enqueueAction(action);
        
    },
    
    handleCancel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})