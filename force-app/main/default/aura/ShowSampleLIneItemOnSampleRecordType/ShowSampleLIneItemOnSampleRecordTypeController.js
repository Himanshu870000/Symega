({
	doinit : function(component, event, helper) {
		 helper.getstatusPicklist(component, event, helper);
        var recordid = component.get('v.recordId');
        var action = component.get("c.showSamplelineRec");
        action.setParams({
            "proRecId": recordid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var data = response.getReturnValue();
                if(data != null){
                     component.set("v.samplelineItemList",data);
                }
            }
        });
        $A.enqueueAction(action);
    },
     handleSelectChange : function(component, event, helper) {
        debugger;
        var selectedValue = event.getSource().get("v.value");
        var recId = event.target.dataset.id;
        var oldlist =  component.get("v.samplelineItemList");
     },
     handleSave: function(component, event, helper){
        debugger;
        var action = component.get("c.updateSamplelineItemValues");
        var recordList =component.get("v.samplelineItemList")
        action.setParams({
            "samplelineIemlist": recordList
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var response = response.getReturnValue();
                if(response == 'success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Stages updated successfully!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: response,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModal  : function(component, event) {
        debugger;           
        var dismissActionPanel = $A.get("e.force:closeQuickAction");    
        dismissActionPanel.fire();
    }
    
	
})