({
	getstagePicklist : function(component, event, helper) {
        debugger;
        var action = component.get("c.getStagePicklistValues");
         action.setCallback(this, function(response) {
           var state = response.getState();
            if(state === "SUCCESS"){
                var data = response.getReturnValue();
                if(data != null){
                  //  var datarec = JSON.stringify(data);
                    component.set("v.stagepicklist",data);
                }
            }
        });
        $A.enqueueAction(action);
	
	}
})