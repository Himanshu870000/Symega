({
    /*doInit : function(component, event, helper) {
        debugger;
        
        /* helper.getMissingAccountData(component, event).then(missingFields =>{
            console.log('missingFields -- ',missingFields);
            component.set("v.ShowSpinner",false);
           if(missingFields > 0){
                component.set("v.ShowUpdateAccountPage",true);
                component.set("v.MissingFieldList",data);   
                component.set("v.accountId","0015j00000ryYzZAAU");
            }
            else{
                component.set("v.ShowUpdateAccountPage",false);
                var action = component.get('c.callApprovalMethod');
                $A.enqueueAction(action);
            }
        });*
        
        
        var action = component.get("c.getMissingAccountDetails");
        action.setParams({
            projId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() !=null){
                    var data = response.getReturnValue();
                    component.set("v.ShowSpinner",false);
                    if(data != null && data != undefined){
                        component.set("v.missingCode", data.missingCode);
                        
                        if(data.missingFieldsList.length > 0){
                            component.set("v.MissingFieldList",data.missingFieldsList); 
                            component.set("v.Show1stPage",true);
                            component.set("v.ShowUpdateAccountPage",true);
                            component.set("v.userId", data.userId);
                            if(data.userId != undefined && data.userId != '' && data.userId != null){
                                //component.set("v.showUserField", true);
                            }
                            component.set("v.bhId", data.bhId);
                            if(data.bhId != undefined && data.bhId != '' && data.bhId != null){
                                //component.set('v.showBHfield', true);
                            }
                            
                           /* if(data.onlyAccMissingFieldList!=undefined && data.onlyAccMissingFieldList.length>0){
                         component.set("v.ShowUpdateAccountPage",true);
                         if(data.onlyAccMissingFieldList.includes('Delivery_Plant__c')){
                              component.set("v.showDlvryPlantField",true);
                         }
                         if(data.onlyAccMissingFieldList.includes('Customer_Type__c')){
                             component.set("v.showCustTypeField",true);
                         }
                         if(data.onlyAccMissingFieldList.includes('Account_Segment__c')){
                             component.set("v.showAccSegField",true);
                         }*
                    }
                            
                            
                            if(data.isAccount == true){
                                component.set("v.ShowUpdateAccountPage",true);
                                component.set("v.accountId",data.projectRec.Opportunity__r.AccountId);
                                if(data.accountFieldsMissing){
                                component.set('v.accFieldMissing', true);
                                    component.set('v.conFieldMissing', false);
                            }
                            }
                            else{
                                component.set("v.ShowUpdateAccountPage",true);
                                component.set("v.customerId",data.projectRec.Opportunity__r.Customer_Billing_Address__c);
                                if(data.contactAddressFieldsMissing){
                                component.set('v.conFieldMissing', true);
                                    component.set('v.accFieldMissing', false);
                            }
                            }
                        }
                        else{
                            component.set("v.ShowUpdateAccountPage",false);
                            var action = component.get('c.callApprovalMethod');
                            $A.enqueueAction(action);
                        }
                    }
                }
            }
            else if(response.getState() === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }, */
    
    doInit : function(component, event, helper) {
        debugger;
        
        var action = component.get("c.getMissingAccountDetails");
        action.setParams({
            projId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() !=null){
                    var data = response.getReturnValue();
                    component.set("v.ShowSpinner",false);
                    if(data != null && data != undefined){
                        if(data.missingFields == true){
                            component.set("v.Show1stPage",true);
                            component.set("v.ShowUpdateAccountPage",true);
                            component.set("v.MissingFieldList",data.missingFieldsList);   
                            component.set("v.accountId",data.projectRec.Opportunity__r.AccountId);
                            component.set("v.userId", data.userId);
                            component.set("v.bhId", data.bhId);
                            
                            if(data.missingFieldsList.length > 0){
                                if(data.isAccount == true){
                                    component.set("v.accFieldsMissing",true);
                                }
                                else{
                                    component.set("v.custFieldsMissing",true);
                                }
                            }
                                                        
                            if(data.onlyAccMissingFieldList.length>0){
                                
                                var picklistResult = data.picklistValues;
                                var fieldMapCustType = [];
                                var fieldMapAccSeg = [];
                                var fieldMapDlvryPlant = [];
                                for(var key in result){
                                    debugger;
                                    if(key == 'CustType'){
                                        for(var pickVal in result[key]){
                                            fieldMapCustType.push({key: pickVal, value: result[key][pickVal]});    
                                        }
                                    }
                                    else if(key == 'AccSegm'){
                                        for(var pickVal in result[key]){
                                            fieldMapAccSeg.push({key: pickVal, value: result[key][pickVal]});    
                                        }
                                    }
                                    else if(key == 'DlvryPlant'){
                                        for(var pickVal in result[key]){
                                            fieldMapDlvryPlant.push({key: pickVal, value: result[key][pickVal]});    
                                        }
                                    }
                                }
                                component.set("v.custTypOptions", fieldMapCustType);
                                component.set("v.accSegOptions", fieldMapAccSeg);
                                component.set("v.dlvryPlantOptions", fieldMapDlvryPlant);                                   
                                
                                if(data.onlyAccMissingFieldList.includes('Delivery_Plant__c')){
                                    component.set("v.showDlvryPlantField",true);
                                }
                                if(data.onlyAccMissingFieldList.includes('Customer_Type__c')){
                                    component.set("v.showCustTypeField",true);
                                }
                                if(data.onlyAccMissingFieldList.includes('Account_Segment__c')){
                                    component.set("v.showAccSegField",true);
                                }
                            }
                                                        
                        }
                        else{
                            component.set("v.ShowUpdateAccountPage",false);
                            var action = component.get('c.callApprovalMethod');
                            $A.enqueueAction(action);
                        }
                    }
                }
            }
            else if(response.getState() === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    callApprovalMethod : function(component, event, helper) {
        debugger;
        var action = component.get("c.submitProjectBHApproval");
        var missingCode = component.get("v.missingCode");
        action.setParams({
            "projectId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var serverResponse = response.getReturnValue();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");    
            if (response.getState() === "SUCCESS") {
                if(serverResponse === "SUCCESS"){
                    if(missingCode == true){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Submitted for BH Approval and Customer Creation will be In-Progress after approving.',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    else if(missingCode == false){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Submitted for BH Approval',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
            } 
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: serverResponse,
                    duration: '5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }    
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    
    handleUpdate : function(component, event, helper) {
        debugger;
        
        /*var action = component.get('c.callApprovalMethod');
        $A.enqueueAction(action);*/
        
        var userSapCode = component.get("v.userSapCode");
        var userId = component.get("v.userId");
        if(userId != null && userSapCode != null && userSapCode != undefined && userSapCode != ''){
            helper.callSAPCodeUpdate(component, userId, userSapCode);
        }
        
        var bhSapCode = component.get("v.bhSapCode");
        var bhId = component.get("v.bhId");
        if(bhId != null && bhSapCode != null && bhSapCode != undefined && bhSapCode != ''){
            helper.callSAPCodeUpdate(component, bhId, bhSapCode);
        }
        
        var accId = component.get("v.accountId");
        var deliveryPlant = component.get("v.deliveryPlant");
        var CustomerType = component.get("v.CustomerType");
        var AccSeg = component.get("v.AccSeg");
        
        if(accId != null && accId != undefined && accId != ''){
            if((deliveryPlant != null && deliveryPlant != undefined && deliveryPlant != '') || (CustomerType != null && CustomerType != undefined && CustomerType != '') || (AccSeg != null && AccSeg != undefined && AccSeg != '')){
                helper.callAccountUpdate(component, accId, deliveryPlant, CustomerType, AccSeg);
            }
        }
        
        var action = component.get("c.submitProjectBHApproval");
        action.setParams({
            "projectId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var serverResponse = response.getReturnValue();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");    
            if (response.getState() === "SUCCESS" && serverResponse === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Record Updated Successfully and submitted for BH Approval...',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            } 
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: serverResponse,
                    duration: '5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }    
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
        component.set('v.ShowUpdateAccountPage', false);
        component.set('v.Show1stPage', false);
    },
    
    closeModal  : function(component, event) {
        debugger;           
        var dismissActionPanel = $A.get("e.force:closeQuickAction");    
        dismissActionPanel.fire();
    },
    
    handleError  : function(component, event) {
        debugger;
        var errors = event.getParams();
        console.log("response", JSON.stringify(errors));
    },
    
    handleChange: function(component, event, helper) {
        debugger;
        var userInput = component.get("v.userSapCode");
        console.log("User entered: " + userInput);
    }    
    
})