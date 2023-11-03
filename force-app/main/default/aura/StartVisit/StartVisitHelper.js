({
    getVisitRecord : function(component, event, helper){
        debugger;
        var visitRecId = component.get('v.visitId');
        var baseURL = 'https://sales-production--mfgcloud--c.sandbox.vf.force.com/apex/docCategories?id='+visitRecId;
        //console.log('baseURL === >'+baseURL);
        component.set("v.siteURL",baseURL);
        var action = component.get('c.getSelectedVisitDetails');
        action.setParams({
            visitId :  visitRecId
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.visitRec', result);
                component.set('v.accID', result.Account__c);
                var street = result.Account__r.BillingStreet;
                var city = result.Account__r.BillingCity;
                var state = result.Account__r.BillingState;
                var zipCode = result.Account__r.BillingPostalCode;
                var fullAddress = street + ', ' + city + ', ' + state+ '- ' + zipCode;
                component.set('v.accountAddress', fullAddress);
                if(result.Check_Out__Latitude__s != null && result.Check_Out__Latitude__s != undefined && result.Check_Out__Latitude__s != ''){
                    component.set("v.ShowCheckInButton",true);
                    component.set("v.ShowCheckOutButton",true);
                }
                if((result.CheckIn__Latitude__s != null && result.CheckIn__Latitude__s != undefined && result.CheckIn__Latitude__s != '')&&(result.Check_Out__Latitude__s == null || result.Check_Out__Latitude__s == undefined || result.Check_Out__Latitude__s == '')){
                    component.set("v.ShowCheckInButton",true);
                    component.set("v.ShowCheckOutButton",false);
                }
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    getPastVisitRecord : function(component, event, helper){
        debugger;
        var accountId = component.get('v.accID');
        var action = component.get('c.getPastVisitDetails');
        action.setParams({
            accId : accountId 
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.pastVisitList', result);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    getAccRelatedOppList : function(component, event, helper){
        debugger;
        var accountId = component.get('v.accID');
        var action = component.get('c.getRelOppList');
        action.setParams({
            accId : accountId
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.relOppList', result);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    getRelatedActivityList : function(component, event, helper){
        debugger;
        var accountId = component.get('v.accID');
        var action = component.get('c.getRelTaskList');
        action.setParams({
            accId : accountId
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.relActivityList', result);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    getRelatedInvoiceList : function(component, event, helper){
        debugger;
        var accountId = component.get('v.accID');
        var action = component.get('c.getRelInvoiceList');
        action.setParams({
            accId : accountId
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.relInvoicesList', result);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    getRelatedCaseList : function(component, event, helper){
        debugger;
        var accountId = component.get('v.accID');
        var action = component.get('c.getRelCaseList');
        action.setParams({
            accId : accountId
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.relCaseList', result);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    CheckInVisithelper : function(component,lat,long){
        debugger;
        var toastEvent = $A.get("e.force:showToast");
        var visitRecId = component.get('v.visitId');
        var action = component.get("c.checkInUpdateVisit");
        action.setParams({
            checkInLat: lat,
            checkInLang: long,
            recId: visitRecId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner', false);
                var data = response.getReturnValue(); 
                if(data !=null){
                    component.set("v.ShowCheckInButton",true);
                    component.set("v.ShowCheckOutButton",false);
                }
                //alert('Check In Done Successfully');
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Checked In Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
            } else if (state === "ERROR") {
                component.set('v.spinner', false);
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            } else if (state === "INCOMPLETE") {
                component.set('v.spinner', false);
                alert('No response from server or client is offline.');
            }
            component.set('v.spinner', false);
            toastEvent.fire();
        })
        $A.enqueueAction(action);
    },
    
    CheckOutVisithelper: function(component,lat,long){
        debugger;
        var toastEvent = $A.get("e.force:showToast");
        var visitRecId = component.get('v.visitId');
        var action = component.get("c.checkOutUpdateVisit");
        action.setParams({
            checkOutLat: lat,
            checkOutLong: long,
            recId: visitRecId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner', false);
                var data = response.getReturnValue(); 
                if(data !=null){
                    component.set("v.ShowCheckInButton",true);
                    component.set("v.ShowCheckOutButton",true);
                }
                //alert('Check Out Done Successfully');
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Checked Out Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });            } else if (state === "ERROR") {
                    component.set('v.spinner', false);
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        }
                    }
                } else if (state === "INCOMPLETE") {
                    component.set('v.spinner', false);
                    alert('No response from server or client is offline.');
                }
            component.set('v.spinner', false);
            toastEvent.fire();
            
        })
        $A.enqueueAction(action);
    },
    
    
    callNavigation:function(component,event,helper,accId){
        debugger;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": accId,
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    
    showSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Record Saved Successfully',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
        showErrorOpp : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: 'Please fill all the required fields',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },

    
});