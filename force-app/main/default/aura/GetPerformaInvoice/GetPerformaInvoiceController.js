({
    doInit : function(component, event, helper) {
        component.set("v.showModal",true);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showModal", false);
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire()
            }), 3000
        );
    },
    
   hideModel: function(component, event, helper) {
      component.set("v.showModal", false);
       var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire()
   },
    
})