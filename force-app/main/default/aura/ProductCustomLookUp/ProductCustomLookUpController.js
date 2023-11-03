({
    doInit : function(component, event, helper){
        debugger;

        let sscCode = component.get("v.sscCode");
        let prodCode = component.get("v.prodCode");
        let qntSSC_Code = component.get("v.qntSSC_Code");

        if(sscCode) {
            component.set("v.searchKeyword", sscCode);
            component.set("v.filled",true);
        }

        if(prodCode) {
            component.set("v.searchKeyword", prodCode);
            component.set("v.filled",true);
        }
        
        if(qntSSC_Code) {
            component.set("v.searchKeyword", qntSSC_Code);
            component.set("v.filled",true);
        }
        /* if(component.get("v.searchKeyword"))
            component.set("v.filled",true); */
    },
    
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    createNewCompany: function(component,event,helper){   
    	
        component.set("v.displayNewCandidate",true);
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.searchKeyword");
        
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 1 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        debugger;
        
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        //component.set("v.selectedRecord.lookupObj" , {});
        component.set("v.searchKeyword",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );  
        
        var mainList = component.get("v.mainList");
        
        var parentId = component.get("v.parentId");
        mainList.forEach(function(item,index){
            if(parentId == index){
                item.lookupObj = {};
                //component.set("v.displayLabel",selectedAccountGetFromEvent.Name);
                component.set("v.searchKeyword","");
                component.set("v.filled",false);
                // no need to break here since we are using forEach which is more efficient than for
            }
        });
        component.set("v.mainList",mainList);
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        debugger;
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        
        var mainList = component.get("v.mainList");
        
        var parentId = component.get("v.parentId");

        let eventData = {};
        mainList.forEach(function(item,index){
            if(parentId == index){
                item.lookupObj = JSON.parse(JSON.stringify(selectedAccountGetFromEvent));
                component.set("v.displayLabel",selectedAccountGetFromEvent.name);
                component.set("v.searchKeyword",selectedAccountGetFromEvent.name);
                component.set("v.filled",true);

                var opts = [
                    { value: "MG", label: "MG" },
                    { value: "GM", label: "GM"},
                    { value: "KG", label: "KG" },
                    { value: "TONNE", label: "TONNE" },
                    { value: "MT", label: "MT" },
                    { value: "ML", label: "ML" }
                ];
                if(item.lookupObj.type === "product2" && item.lookupObj.samplingQuantityUnit) {
                    let units = [];
                    item.lookupObj.samplingQuantityUnit.split(';').forEach(function(unit) {
                        units.push({ value: unit, label: unit, selected: false });
                    });
                    eventData.productUnits = {units : units, index: parentId, pid: item.lookupObj.id};
                }
                eventData.product = {lkp: item.lookupObj, index: parentId, pid: item.lookupObj.id};
                // no need to break here since we are using forEach which is more efficient than for
            }
        });


        //TODO:
        //update parent
        if(eventData) {
            // get the selected record from list  
            // call the event   
            var compEvent = component.getEvent("newProductAddition");
            // set the Selected sObject Record to the event attribute.  
            compEvent.setParams(eventData);  
            // fire the event  
            compEvent.fire();
        }
        
        component.set("v.mainList",mainList);
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        
        
    },
})