({
    SendEmail : function(component) {
        debugger;
        var email = component.find("inpsummary").get("v.value");
        //var email=this._e('txtEmail').value;
        var Subject=this._e('txtSubject').value;
        var Message=component.get("v.myMessage"); 
        var OppRec = component.get("v.OppRecord");
        var selectedValues = component.get("v.selectedMemberList");
        
        //var ArrayNameList = event.getParam("ArrayName"); 
        // set the handler attributes based on event data 
        //cmp.set("v.ArrayNameListFromEvent", ArrayNameList); 
        
        
        
        var action=component.get("c.processEmail");
        action.setParams({
            email:email,
            Subject:Subject,
            Message:Message,
            DepartmemberList : component.get("v.selectedMemberList")
        })
        action.setCallback(this,function(e){
            if(e.getState()=='SUCCESS'){
                var result=e.getReturnValue();
                if(result=='Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Email Send Successfully!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire(); 
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:JSON.stringify(result),
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire(); 
                }
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:JSON.stringify(e.getError()),
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    _e:function(ele){
        return document.getElementById(ele);
    },
})