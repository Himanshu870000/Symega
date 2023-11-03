({
    doInit: function(component, event, helper){
        debugger;
        var action = component.get("c.getprojectData");
        action.setParams({
            "proId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var data = response.getReturnValue();
                component.set("v.selectedProductName", data.prodName);
                component.set("v.selectedProductdesciption", data.prodInst);
            }
        });
        $A.enqueueAction(action);
    },           
    
    handleUpdate :function(component, event, helper){
        debugger;
        var action = component.get("c.UpdateProjectRec");
        var prodId = component.get("v.selectedProduct");
        var inst =  component.get("v.selectedProductdesciption");
        var recId = component.get("v.recordId");
        
        action.setParams({
            "recordId" : recId,
            "productId" : prodId,
            "instruction" : inst
        })
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state ==="SUCCESS"){
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Record get Updated successfully.",
                    'duration':' 5000',
                    'key': 'info_alt',
                    'type': 'success',
                    'mode': 'pester'
                });
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
            }else {
                alert(result.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    }
})