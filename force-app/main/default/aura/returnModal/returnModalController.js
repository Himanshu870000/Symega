({
    handleReturn : function(component, event, helper) {
        var modalBody;
        var modalFooter;
        $A.createComponents([
            ["c:createReturnOnOppLineItem",{}]
        ],
         function(components, status){
             if (status === "SUCCESS") {
                 modalBody = components[0];
                 component.find('overlayLib').showCustomModal({
                     header: "Create Return",
                     body: modalBody,
                     footer: modalFooter,
                     showCloseButton: true,
                     cssClass: "my-modal,my-custom-class,my-other-class",
                     closeCallback: function() {
                     }
                 });
             }
         });
    }
})