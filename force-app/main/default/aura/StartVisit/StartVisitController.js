({
    doInit : function(component, event, helper) { 
        debugger;
        var lat;
        var long;
        var userLocation = navigator.geolocation;
        if (userLocation) {
            userLocation.getCurrentPosition(function (position) {
                // lat = position.coords.latitude;
                // long = position.coords.longitude;
                component.set("v.currentLatitude",position.coords.latitude);
                component.set("v.currentLongitude",position.coords.longitude);
            });
        } 
        
        
        helper.getVisitRecord(component, event, helper);
        helper.getPastVisitRecord(component, event, helper);
        helper.getAccRelatedOppList(component, event, helper);
        helper.getRelatedInvoiceList(component, event, helper);
        helper.getRelatedCaseList(component, event, helper);
        helper.getRelatedActivityList(component, event, helper);
        
       
    },
    
    handleOppClick: function(component, event, helper){
        debugger;
        var url = $A.get("$Label.c.orgDefaultURL");
        var oppId = event.target.dataset.id; 
        var oppUrl = url + oppId;
        window.open(oppUrl, '_blank');
    },
    
    
    
    createTaskHanlde :  function(component, event, helper) {
        debugger;
        component.set("v.showCreateTask",true);
    },
    closeActivityCreate : function(component, event, helper) {
        debugger;
        component.set("v.showCreateTask",false);
    },
    closeBtn : function(component, event, helper) {
        debugger;
        component.set("v.showCreateTask",false);
        component.set("v.showCreateCallLogTask",false);
        component.set("v.showCreateCase",false);
        component.set("v.showOpportunityCreate",false);
    },
    onChangeHandlerStatus : function(component, event, helper) {
        debugger;
        var selPick = component.find('fieldStatus').get('v.value');
    },
    onChangeHandlerPriority : function(component, event, helper) {
        debugger;
        var selPick = component.find('fieldPrority').get('v.value');
    },
    onChangeHandlerCaseStatus : function(component, event, helper) {
        debugger;
        var selPick = component.find('fieldCaseStatus').get('v.value');
    },
    onChangeHandlerOppStage : function(component, event, helper) {
        debugger;
        var selPick = component.find('fieldOppStage').get('v.value');
    },
    createLogCallHanlde : function(component, event, helper) {
        debugger;
        component.set("v.showCreateCallLogTask",true);
    },
    closeCallLogCreate : function(component, event, helper) {
        debugger;
        component.set("v.showCreateCallLogTask",false);
    },
    createCaseHanlde : function(component, event, helper) {
        debugger;
        component.set("v.showCreateCase",true);
    },
    closeCaseHanlde : function(component, event, helper) {
        debugger;
        component.set("v.showCreateCase",false);
    },
    createOpportunityHandle : function(component, event, helper) {
        debugger;
        component.set("v.showOpportunityCreate",true);
    },
    closeOpportunityHandle : function(component, event, helper) {
        debugger;
        component.set("v.showOpportunityCreate",false);
    },
    saveTaskHandler : function(component, event, helper) {
        debugger;
        component.set('v.spinner', true);
        component.set("v.showCreateTask",false);
        var taskRecord = component.get('v.taskRec');
        var accId = component.get('v.accID');
        taskRecord.WhatId = accId;
        var action = component.get('c.saveTask');
        action.setParams({
            taskRec :  taskRecord
        });
        action.setCallback(this, function(response){
            if(response.getState() ==='SUCCESS'){
                component.set('v.spinner', false);
                //alert('record Saved Successfully');
                helper.getRelatedActivityList(component, event, helper);
                helper.showSuccess(component, event, helper);
                component.set("v.showCreateTask",false);
            }else{
                component.set('v.spinner', false);
                alert(JSON.stringify(response.getError()));
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action);
    },
    saveLogCall : function(component, event, helper) {
        debugger;
        component.set('v.spinner', true);
        component.set("v.showCreateCallLogTask",false);
        var today = new Date();
        var formattedDate = today.toISOString().slice(0, 10);
        var taskRecord = component.get('v.callRec');
        var accId = component.get('v.accID');
        taskRecord.WhatId = accId;
        taskRecord.Priority = 'Normal';
        taskRecord.ActivityDate = formattedDate;
        taskRecord.Status = 'Completed';
        var action = component.get('c.LogCall');
        action.setParams({
            taskRec :  taskRecord
        });
        action.setCallback(this, function(response){
            if(response.getState() ==='SUCCESS'){
                component.set('v.spinner', false);
                helper.getRelatedActivityList(component, event, helper);
                helper.showSuccess(component, event, helper);
                //alert('record Saved Successfully');
            }else{
                alert(JSON.stringify(response.getError()));
                component.set('v.spinner', false);
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action);
    },
    createOppHandle : function(component, event, helper) {
        debugger;
        component.set("v.showOpportunityCreate",false);
        component.set('v.spinner', true);
        var oppRecord = component.get('v.oppRec');
        if(oppRecord.Name == '' || oppRecord.Name == undefined || oppRecord.Name == null){
            helper.showErrorOpp(component, event, helper);
            component.set('v.spinner', false);
        }
        else if(oppRecord.StageName == '--None-' || oppRecord.StageName == undefined || oppRecord.StageName == null || oppRecord.StageName == ''){
            helper.showErrorOpp(component, event, helper);
            component.set('v.spinner', false);
        }
        else if(oppRecord.CloseDate == '' || oppRecord.CloseDate == undefined || oppRecord.CloseDate == null){
            helper.showErrorOpp(component, event, helper);
            component.set('v.spinner', false);
        }else{
            component.set('v.spinner', true);
            var accId = component.get('v.accID');
        oppRecord.AccountId = accId;
        var action = component.get('c.saveOpportunity');
        action.setParams({
            oppRec :  oppRecord
        });
        action.setCallback(this, function(response){
            if(response.getState() ==='SUCCESS'){
                component.set('v.spinner', false);
                //alert('record Saved Successfully');
                helper.showSuccess(component, event, helper);
                helper.getAccRelatedOppList(component, event, helper);
                
            }else{
                alert(JSON.stringify(response.getError()));
                component.set('v.spinner', false);
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action);
        }
        
    },
    createCaseHandle : function(component, event, helper) {
        debugger;
        component.set('v.spinner', true);
        var caseRecord = component.get('v.caseRec');
        var accId = component.get('v.accID');
        caseRecord.AccountId = accId;
        caseRecord.Origin = 'Web';
        var action = component.get('c.saveCase');
        action.setParams({
            caseRec :  caseRecord
        });
        action.setCallback(this, function(response){
            if(response.getState() ==='SUCCESS'){
                component.set('v.spinner', false);
                helper.showSuccess(component, event, helper);
                //alert('record Saved Successfully');
                helper.getRelatedCaseList(component, event, helper);
            }else{
                alert(JSON.stringify(response.getError()));
                component.set('v.spinner', false);
            }
            component.set("v.showCreateCase",false);
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action);
    },
    
    checkInHandler : function(component, event, helper) {
        debugger;
        var lat;
        var long;
        var userLocation = navigator.geolocation;
        if (userLocation) {
            userLocation.getCurrentPosition(function (position) {
                lat = position.coords.latitude;
                long = position.coords.longitude;
                if ((lat != null && lat != undefined && lat != '') && (long != null && long != undefined && long != '')) {
                    component.set('v.spinner', true);
                    helper.CheckInVisithelper(component,lat, long);
                    // component.set("v.currentLatitude", lat);
                    // component.set("v.currentLongitude", long);
                }
            });
        } 
        
    },
    
    checkOutHandler: function(component, event, helper) {
        debugger;
        var lat;
        var long;
        var userLocation = navigator.geolocation;
        if (userLocation) {
            userLocation.getCurrentPosition(function (position) {
                lat = position.coords.latitude;
                long = position.coords.longitude;
                if ((lat != null && lat != undefined && lat != '') && (long != null && long != undefined && long != '')) {
                    component.set('v.spinner', true);
                    helper.CheckOutVisithelper(component,lat, long);
                    // component.set("v.currentLatitude", lat);
                    // component.set("v.currentLongitude", long);
                }
            });
        } 
        
    },
    /*handleComponentEvent:function(component, event, helper){
        debugger;
        alert('event fired');
        var visitId = event.getParam("visitId"); 
        var accId = event.getParam("accId"); 
        component.set("v.visitId", visitId);
        var visitRecId = component.get('v.visitId');
        var action = component.get('c.getSelectedVisitDetails');
        action.setParams({
            visitId :  visitRecId
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.visitRec', result);
                //component.set('v.accID', result.Account__c);
                var street = result.Account__r.BillingStreet;
                var city = result.Account__r.BillingCity;
                var state = result.Account__r.BillingState;
                var zipCode = result.Account__r.BillingPostalCode;
                var fullAddress = street + ', ' + city + ', ' + state+ '- ' + zipCode;
                component.set('v.accountAddress', fullAddress);
                window.setTimeout(
                    $A.getCallback(function() {
                       helper.callNavigation(component, event, helper,accId);
                    }),1000     
                );
            } 
            
        });
        $A.enqueueAction(action);
    },*/
    
    goBackOnePage : function(component, event, helper){
        debugger;
        //location.replace("https://sales-production--mfgcloud.sandbox.lightning.force.com/lightning/n/Field_Visit");
        //component.set('v.showTodaysTaskComponent',true);
        //component.set('v.showStartVisitComponent',false);
        
        var fieldVisitComponentEvent = component.getEvent("fieldVisitComponentEvent"); 
        
        fieldVisitComponentEvent.setParams({
            "showTodaysTaskComponent" : true,
            "showStartVisitComponent" : false
        }); 
        
        fieldVisitComponentEvent.fire(); 
    }
})