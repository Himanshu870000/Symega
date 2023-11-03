({
    updateOLI : function(component) {
        debugger;
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var action = component.get("c.OppLineItemUpdate");
                action.setParams({  
                    'OLIRecords': component.get("v.OppLineItemList")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        resolve(response.getReturnValue());
                    }    
                    if(state === "ERROR"){
                        reject(response.getError());
                    }
                });
                $A.enqueueAction(action);
            }));
    },
    
    getSymegaPicklistValues: function(component, event) 
    {
        debugger;
        var action = component.get("c.getPicklistValues");
        action.setParams
        ({ 
            "ObjectApi_name": 'OpportunityLineItem',
            "Field_name": 'Symega_Logo__c'
        });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var Options = [];
                                   for(var key in result)
                                   {
                                       Options.push({key: key, value: result[key]});
                                   }
                                   component.set("v.symLogoOptions", Options);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getMtrlSecPicklistValues: function(component, event) 
    {
        debugger;
        var action = component.get("c.getPicklistValues");
        action.setParams
        ({ 
            "ObjectApi_name": 'OpportunityLineItem',
            "Field_name": 'Material_Sector__c'
        });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var Options = [];
                                   for(var key in result)
                                   {
                                       Options.push({key: key, value: result[key]});
                                   }
                                   component.set("v.mtrlSecOptions", Options);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getPlantPicklistValues: function(component, event) 
    {
        debugger;
        var action = component.get("c.getPicklistValues");
        action.setParams
        ({ 
            "ObjectApi_name": 'OpportunityLineItem',
            "Field_name": 'Plant__c'
        });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var Options = [];
                                   for(var key in result)
                                   {
                                       Options.push({key: key, value: result[key]});
                                   }
                                   console.log('Plant Options:: ', Options);
                                   component.set("v.plantOptions", Options);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getOppRelatedAccountData : function(component, event) {
        debugger;
        var action = component.get("c.getOppRelatedAccountDetails");
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() !=null){
                    var tempArray = [];
                    var missingFields = response.getReturnValue();
                    if(missingFields == true){
                        component.set("v.ShowUpdateAccountPage",true);
                        //component.set("v.MissingFieldList",data);   
                    }
                    else{
                        component.set("v.ShowUpdateAccountPage",false);
                    }
                }
            }else if(response.getState() === "ERROR"){
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
    
})