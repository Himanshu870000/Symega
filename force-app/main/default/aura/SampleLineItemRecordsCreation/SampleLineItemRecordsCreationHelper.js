({
    
    getSLIExistingRecords : function(component, event, helper) {
        debugger;
        var action = component.get("c.getSLIList");
        action.setParams({
            "sampleId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {   
                
                response.getReturnValue().forEach(function(product) {
                    if(product.Product__c && product.Product__r.Sampling_Qty_UNIT__c) {
                        let units = [];
                        product.Product__r.Sampling_Qty_UNIT__c.split(';').forEach(function(unit) {
                            if(product.Quantity_Unit__c == unit)
                                units.push({ value: unit, label: unit, selected: true });
                            else
                                units.push({ value: unit, label: unit, selected: false });
                        });
                        product.samplingQuantity = units;
                    }else {
                        product.samplingQuantity = undefined;
                    }
                });
                component.set("v.SampleLineItemList", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " , state);
            } 
        });
        $A.enqueueAction(action);        
    },
    
    addRecord: function(component, event) {
        debugger;
        
        var recordList = component.get("v.SampleLineItemList");        
        var maxQty = 0;
        var QtySum = 0;
        var indiviQty = 0;
        var EmptySamplecount = 0;
        
        for(var i=0; i<recordList.length; i++){
            let obj = recordList[i];
            
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
            
            if((obj.Product__c == '' && obj.OPTIVA_Recipe__c == '' && obj.Project_Quotient__c == '') || recordList[i].Quantity__c == '' || recordList[i].Quantity_Unit__c == '' || recordList[i].Packaging_Quantity__c == '' ){
                EmptySamplecount++;
            }
        }
        
        if(recordList.length< 6 && EmptySamplecount == 0 ){
            recordList.push({
                'Product__c': '',
                'OPTIVA_Recipe__c': '',
                'Project_Quotient__c' : '',
                'Quantity__c': '',
                'Quantity_Unit__c': 'GM',
                'Packaging_Quantity__c': '',
                'maxSampleQnty' : '',
                'Product_Max_Qty__c':'',
                'Current_Shelf_Life__c': '',
                'Expected_Shelf_Life__c': '',
                'Additional_Comments__c': '',
                'Customer_Instructions__c': '',
                'Regulatory_Requirements__c': '',
                "lookupObj":{
                    'Product__r' : '' }
            });
        }
        else if(recordList.length == 6 ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Warning',
                message: 'You can add maximum 6 Sample Line Items to a sample.',
                duration:' 5000',
                key: 'info_alt',
                type: 'warning',
                mode: 'dismissible'
            });
            toastEvent.fire();
            return;
        }   
        
        if(EmptySamplecount !== 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Warning',
                message: 'One or more column in rows is/are empty!!!!!',
                duration:' 5000',
                key: 'info_alt',
                type: 'warning',
                mode: 'dismissible'
            });
            toastEvent.fire();
            return;
        }  
        component.set("v.SampleLineItemList", recordList);
    },
    
    getPicklistValues: function(component, event) {
        debugger;
        var action = component.get("c.GetPicklistvalue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMapPackUnit = [];
                var fieldMapQtyUnit = [];
                for(var key in result){
                    debugger;
                    if(key == 'PackUnit'){
                        for(var pickVal in result[key]){
                            fieldMapPackUnit.push({key: pickVal, value: result[key][pickVal]});    
                        }
                    }
                    else if(key == 'QtyUnit'){
                        for(var pickVal in result[key]){
                            fieldMapQtyUnit.push({key: pickVal, value: result[key][pickVal]});    
                        }
                    }
                }
                component.set("v.PickUnitOptions", fieldMapPackUnit);
                component.set("v.QtyUnitOptions", fieldMapQtyUnit);                
            }
        });
        $A.enqueueAction(action);
    }
})