({
    init : function(cmp, event, helper) {
        debugger;
        var navService = cmp.find("navService");
        var encodedCmp = cmp.find("encoded");
        
        
        
        helper.getRcType(cmp).then(recTypeId =>{
            const defaultValues = encodedCmp.encodeDefaultFieldValues({
            Application_Name__c: 'Trinidad Family'
        });
        
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Project__c',
                actionName: 'new'
            }
        };
        
        
        let isMobile = localStorage.mobile || window.navigator.maxTouchPoints > 1;
        alert(isMobile)
        if(!isMobile){
            pageReference.state = {defaultFieldValues : defaultValues,recordTypeId: recTypeId}
        }
        
        cmp.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            debugger;
            cmp.set("v.url", url ? url : defaultUrl);
            
            var urlEvent = $A.get("e.force:navigateToURL");
            var hUrl = window.location.origin+cmp.get('v.url');
            
            console.log("URL-----",hUrl);
            urlEvent.setParams({
                "url": hUrl
            });
            urlEvent.fire();
        }), $A.getCallback(function(error) {
            cmp.set("v.url", defaultUrl);
        }));
    });
}  /*,
 
 
 getProjectRecord : function(cmp, event, helper) {
    debugger;
    var action = component.get("c.getProjectRecord");
        action.setParams({
            projectId : component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState(); 
            if(state === 'SUCCESS') {
                var projectRec = [];
                var responseValue = result.getReturnValue();
                for (var key in responseValue)
                {
                    projectRec.push({
                        Id: key,
                        name : responseValue[key].Name,
                        proposedEmail: responseValue[key].Proposed_Email__c,
                        proposedPhone: responseValue[key].Proposed_Phone__c,
                        proposedPhoneType: responseValue[key].Proposed_Phone_Type__c,
                        active: responseValue[key].Active__c,
                        accountNumber: responseValue[key].Account_Number__c
                    });
                }
                var name = royAcct[0].name;
                var pe = royAcct[0].proposedEmail;
                var pp = royAcct[0].proposedPhone;
                var ppt = royAcct[0].proposedPhoneType;
                var act = royAcct[0].active;
                var an = royAcct[0].accountNumber;
                
            }});
        $A.enqueueAction(action);
    
    
}*/
})