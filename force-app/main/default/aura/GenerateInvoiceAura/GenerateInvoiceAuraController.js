({
    getRecord : function(component, event, helper) {
        let record;
        var recordId = component.get('v.recordId');

        var action = component.get('c.getOppRecord'); 
        action.setParams({"id" : recordId});
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                record = a.getReturnValue();
                component.set("v.rec", record);

                console.log("Result-------",record);   

                if(record.CurrencyIsoCode && record.CurrencyIsoCode=='INR'){
                    if(!record.Proposed_Date_of_Dispatch__c){

                    }
                }else if(record.CurrencyIsoCode && record.CurrencyIsoCode!='INR'){
                    
                }
            }
        });
        $A.enqueueAction(action);
    },

    inrNextHandler :  function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var record = component.get('v.rec');
        let url = 'https://symegafood--symegadev--c.visualforce.com/apex/PerformaInvoicePDF'+'?id='+recordId;
        component.set("v.url", url);
        //component.set("v.recCopy",record);

        component.set("v.rec",null);
        component.set("v.showNext", true);
    },

    usaNextHandler :  function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var record = component.get('v.rec');

        let url = 'https://symegafood--symegadev--c.visualforce.com/apex/PerformaInvoicePDF'+'?id='+recordId;
        component.set("v.url", url);
        //component.set("v.recCopy",record);

        component.set("v.rec",null);
        component.set("v.showNext", true);
    }
})