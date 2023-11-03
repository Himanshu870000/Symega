({
    loadOptions: function (component, event, helper) {
        debugger;
        helper.getPicklistValues(component, event);
        helper.getSLIExistingRecords(component, event);
        
        var action = component.get("c.SampleLineItemCount");
        var currentRecordId = component.get("v.recordId");
        action.setParams({
            'sampleRecordId': currentRecordId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse == 6){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Warning',
                        message: 'You can Add 6 Sample Line Items at one time.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                else if(storeResponse <6){
                    component.set("v.SamplelineItemSize", storeResponse);
                    
                    var existingListsize = component.get("v.SamplelineItemSize");
                    console.log('Existing List Size:: ', existingListsize);
                    
                    if(existingListsize == 0){
                        component.set("v.SampleLineItemList",[{
                            'Product__c': '',
                            'OPTIVA_Recipe__c': '',
                            'Project_Quotient__c' : '',
                            'Quantity__c': '',
                            'Quantity_Unit__c': '',
                            'Packaging_Quantity__c': '',
                            'Product_Max_Qty__c' : '',
                            'Current_Shelf_Life__c': '',
                            'Expected_Shelf_Life__c': '',
                            'Additional_Comments__c': '',
                            'Customer_Instructions__c': '',
                            'Regulatory_Requirements__c': '',
                            "lookupObj":{
                                'Product__r' : '' }                                                    
                        }]);
                    }
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    
    addRow: function(component, event, helper) {
        helper.addRecord(component, event);
    },
    
    update: function(component, event, helper) {
        let lineItemList = component.get("v.SampleLineItemList");
        debugger;
        let index = event.getSource().get("v.name");
    },
    
    removeRow: function(component, event, helper) {
        
        debugger;
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var idtoDelete = selectedItem.dataset.recid;
        var recordList = component.get("v.SampleLineItemList");    
        
        if(recordList.length>1){
            recordList.splice(index, 1);
            component.set("v.SampleLineItemList", recordList);
        }else{
            component.set("v.SampleLineItemList",[{"record":{
                'Product__c': '',
                'OPTIVA_Recipe__c': '',
                'Project_Quotient__c' : '',
                'Quantity__c': '',
                'Quantity_Unit__c': '',
                'Packaging_Quantity__c': '',
                'Product_Max_Qty__c' : '',
                'Current_Shelf_Life__c': '',
                'Expected_Shelf_Life__c': '',
                'Additional_Comments__c': '',
                'Customer_Instructions__c': '',
                'Regulatory_Requirements__c': ''
            },"lookupObj":{
                'Product__r' : ''
            }}]
                         );
        }
        
        if(idtoDelete != undefined){
            let recsToDelete = component.get("v.recsToDelete");
            recsToDelete.push(idtoDelete);
            component.set("v.recsToDelete",recsToDelete);
            /* var deleteEvent = component.getEvent("deleteEvent");
            deleteEvent.setParams({"IdsTodelete" : idtoDelete });
            deleteEvent.fire(); */
            //TODO: add records to delete list
            
        }
    },
    
    SaveSampleDetails : function(Component, helper, event){
        debugger;
        var SampleLineItemDetails = Component.get("v.SampleLineItemList");
        console.log('SampleLineItemDetails', SampleLineItemDetails);
        var CurrentRecId = Component.get("v.recordId");
        
        var allRecords = [];
        var NotEmptySLI = 0;
        var maxQtySum = 0;
        var QtySum = 0;
        var indiviQty = 0;
        var qtyNeg = false;
        for(var i=0; i<SampleLineItemDetails.length; i++){
            debugger;
            let obj = SampleLineItemDetails[i];
            
            if(obj.Product__c=='' && obj.lookupObj && obj.lookupObj.id){
                if(obj.lookupObj.type === 'recepie'){
                    obj.OPTIVA_Recipe__c = obj.lookupObj.id;   
                }
                else if(obj.lookupObj.type === 'quotient'){
                    obj.Project_Quotient__c = obj.lookupObj.id;
                }
                else{
                    obj.Product__c = obj.lookupObj.id;
                }
            }
            
            if(obj.lookupObj && obj.lookupObj.id){
                if(obj.lookupObj.type === 'recepie'){
                    obj.OPTIVA_Recipe__c = obj.lookupObj.id;   
                }
                else if(obj.lookupObj.type === 'quotient'){
                    obj.Project_Quotient__c = obj.lookupObj.id;
                }
                else{
                    obj.Product__c = obj.lookupObj.id;
                }
            }
            
            if((obj.Quantity__c <= 0) || (obj.Packaging_Quantity__c <= 0)){
                qtyNeg = true;
            }
            
            if( (obj.Product__c !== '' || obj.OPTIVA_Recipe__c !== '' || obj.Project_Quotient__c !== '') && obj.Quantity__c !== '' && obj.Quantity_Unit__c !== '' && obj.Packaging_Quantity__c !== ''){
                var tempVal = obj;
                
                tempVal.Sample__c = CurrentRecId;
                if(obj.Product__r && obj.Product__r.Id){
                    tempVal.Product__c = obj.Product__r.Id; 
                }
                
                if(obj.OPTIVA_Recipe__r && obj.OPTIVA_Recipe__r.Id){
                    tempVal.OPTIVA_Recipe__c = obj.OPTIVA_Recipe__r.Id; 
                }
                
                if(obj.Project_Quotient__r && obj.Project_Quotient__r.Id){
                    tempVal.Project_Quotient__c = obj.Project_Quotient__r.Id; 
                }
                
                if(obj.lookupObj && obj.lookupObj.id){
                    if(obj.lookupObj.type === 'product2' && (obj.OPTIVA_Recipe__c || obj.Project_Quotient__c)){
                        obj.OPTIVA_Recipe__c = ''; 
                        obj.Project_Quotient__c = ''; 
                    }
                    if(obj.lookupObj.type === 'recepie' && (obj.Product__c|| obj.Project_Quotient__c)){
                        obj.Product__c = '';   
                        obj.Project_Quotient__c = '';
                    }
                    if(obj.lookupObj.type === 'quotient' && (obj.Product__c|| obj.OPTIVA_Recipe__c)){
                        obj.Product__c = '';   
                        obj.OPTIVA_Recipe__c = '';
                    }
                }
                
                delete tempVal.Product_Max_Qty__c;
                delete tempVal.Product__r;
                delete tempVal.OPTIVA_Recipe__r;
                delete tempVal.Project_Quotient__r;
                delete tempVal.lookupObj;
                allRecords.push(tempVal);
                NotEmptySLI++;  
            }  
        }        
        
        var action = Component.get("c.SampleLineItemcreation");
        
        if(qtyNeg){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Quantity or Packaging Quantity cannot be negative',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'sticky'
            });
            toastEvent.fire();
        }
        else if(allRecords.length>0 && NotEmptySLI == SampleLineItemDetails.length){
            action.setParams({
                'SLIRecords': allRecords,
                'deleteIdSet': Component.get("v.recsToDelete"),
                'sampleId' : Component.get("v.recordId")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var storeResponseMap = response.getReturnValue();
                console.log("storeResponseMap.length", Object.keys(storeResponseMap).length);
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    if(Object.keys(storeResponseMap).length === 0){
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Sample Line Item(s) have been saved successfully',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        
                        toastEvent.fire();
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        $A.get('e.force:refreshView').fire();
                    }
                    else{
                        var warningMsg = '';
                        for(var key in storeResponseMap){
                            debugger;
                            warningMsg += 'Product Code - ' + key + ' : Error - "' + storeResponseMap[key] + '"      \n';    
                        }
                        toastEvent.setParams({
                            title : 'Warning',
                            message: warningMsg,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'warning',
                            mode: 'sticky'
                        });
                        toastEvent.fire();
                    }
                    
                    if (storeResponseMap.length == 0) {
                        Component.set("v.Message", 'No Result Found...');
                    } else {
                        Component.set("v.Message", '');
                    }
                }        
                if(state === "ERROR"){
                    var errors= response.getError();
                    console.log("ERROR: ", errors);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Saving Error',
                        message: errors[0].message,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            });
            $A.enqueueAction(action);
        }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message: 'One or more record(s) column is/are Empty',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'warning',
                    mode: 'sticky'
                });
                toastEvent.fire();
            }
    },
    
    CloseQuickAction : function(Component, helper, event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    handleNewProductUnitEvent : function(component, event, helper){
        debugger;
        let productUnits = event.getParam("productUnits");
        let selectedProduct = event.getParam("product");
        let sliList = component.get("v.SampleLineItemList");
        
        if(sliList && sliList.length > 0) {
            let sli = sliList[productUnits.index];
            if(productUnits) {
                sli.samplingQuantity = productUnits.units;
                sli.Product__c = productUnits.pid;
            }
            console.log('selectedProduct :: ' , selectedProduct);
            sli.regRequirement = selectedProduct.lkp.regulatoryReq;
            sli.cShelfLife = selectedProduct.lkp.currentShelfLife;
            sli.maxSampleQnty = selectedProduct.lkp.maxSampleQty;
            console.log('cShelfLife :: ' , cShelfLife);
            console.log('regRequirement :: ' , regRequirement);
            component.set("v.SampleLineItemList", sliList);
        }
    }
})