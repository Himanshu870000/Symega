({
    doinit: function(component, event, helper){
        debugger;
        helper.getstagePicklist(component, event, helper);
        var recordid = component.get('v.recordId');
        var action = component.get("c.showProjectQuotientRec");
        action.setParams({
            "proRecId": recordid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var data = response.getReturnValue();
                if(data != null){
                    var newField = "isInputDisable";
                    data.forEach(function(item) {
                        if(item.Stage__c == 'Lost'){
                            item[newField] = false;
                        }
                        else{
                            item[newField] = true;
                        }                        
                    });
                    component.set("v.qntList",data);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSelectChange : function(cmp, event, helper) {
        debugger;
        var index = event.getSource().get('v.name');
        var value = event.getSource().get('v.value');
        var recordsList = cmp.get('v.qntList');
        
        //var updatedRecordsList = [...recordsList];
        for (var i = 0; i < recordsList.length; i++) {
            if(recordsList[i].Id == index ){
                if (value === "Lost" ) {
                    recordsList[i].isInputDisable = false;
                }
                else{
                    recordsList[i].isInputDisable = true;
                }
            }
        }
        
        cmp.set("v.qntList", recordsList);
        
        //component.set("v.projectQuatientlist", recordsList);        
        //var recId = event.target.dataset.id;
        //var oldlist =  component.get("v.qntList");       
        
    },
    handleSave: function(component, event, helper){
        debugger;
        var action = component.get("c.updateProjectQuotientValues");
        var recordList =component.get("v.qntList")
        action.setParams({
            "projectlist": recordList
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