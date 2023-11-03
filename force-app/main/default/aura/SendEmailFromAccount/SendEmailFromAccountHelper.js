({
	SendEmail : function(component) {
        debugger;
        // ===================== To show Spinner ================================
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        
        // ===================== To Send Email ================================
       // var emailChecked = component.find("inpsummary").get("v.value");
        var emailChecked =  component.get('v.checkEmail');
        var email = component.get("v.emailId"); 
        var Subject=this._e('txtSubject').value;
        var Message=component.get("v.myMessage"); 
        var AccRec = component.get("v.AccRecord");
        var selectedValues = component.get("v.selectedMemberList");
        
        var action=component.get("c.processEmail");
        action.setParams({
            checkEmail:emailChecked,
            email:email,
            Subject:Subject,
            Message:Message,
            DepartmemberList : component.get("v.selectedMemberList")
        })
        action.setCallback(this,function(e){
            if(e.getState()=='SUCCESS'){
                            
     // ===================== To Hide Spinner ================================ 
                var spinner = component.find("mySpinner");
                $A.util.addClass(spinner, "slds-hide"); 
                
     // ===================== To Fire Toast ================================           
                var result=e.getReturnValue();
                if(result=='Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Email Sent Successfully!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire();
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
    
    showSpinner: function(component, event, helper) {        
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component,event,helper){        
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})