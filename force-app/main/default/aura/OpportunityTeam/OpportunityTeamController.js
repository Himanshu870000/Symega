({
    
    close : function(component, event, helper) {
        debugger;
        let baseUrl  = window.location.origin;
        window.open(baseUrl+'/lightning/r/Opportunity/'+component.get("v.recordId")+'/view','_top')
    },
    doInit : function(component, event) {
        debugger;
        var ObjecttypeName = component.get("v.sObjectName");
        var recID = component.get("v.recordId");
        var param = window.location.href;
        var action = component.get("c.getOpportunityteamMaster");
        debugger;
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                component.set("v.OppTeamMemberList",response.getReturnValue());
                var OppTeamMemberList = response.getReturnValue();
                var oppTeamMasterList = [];
                
               for(var i =0;i<OppTeamMemberList.length;i++){
                   if(oppTeamMasterList.find(val=> val.Opportunity_Team_Master__c == OppTeamMemberList[i].Opportunity_Team_Master__c)){

                    }else{
                        oppTeamMasterList.push(OppTeamMemberList[i]);
                    }
                }
                component.set("v.oppTeamMasterList",oppTeamMasterList);
            } else{
                debugger;
            }
        });
        $A.enqueueAction(action);
    },  
    onchange : function(component, event) {
        debugger;
        var selectedId = component.find('select').get('v.value');
        var OppTeamMemberList = component.get("v.OppTeamMemberList");
        var oppMemberToBeAdded =[];
        
        for(var i =0;i<OppTeamMemberList.length;i++){
            if(OppTeamMemberList[i].Opportunity_Team_Master__c == selectedId){
                oppMemberToBeAdded.push(OppTeamMemberList[i]);
                 
            }
        }
        if(oppMemberToBeAdded.length >0){
            component.set("v.showMember", true);
        }else{
            
        }
        component.set("v.oppMemberToBeAdded", oppMemberToBeAdded);
        component.set("v.oppTeamMasterId", selectedId);
    },
    handleSelectAllContact: function(component, event, helper) {
        debugger;
        var getID = component.get("v.oppMemberToBeAdded");
        var checkvalue = component.find("selectAll").get("v.value");
        var checkContact = component.find("checkContact"); 
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
        }
    },
     
    //Process the selected contacts
    handleSelectedContacts: function(component, event, helper) {
        debugger;
        var selectedContacts = [];
        var checkvalue = component.find("checkContact");
         
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedContacts.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedContacts.push(checkvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedContacts-' + selectedContacts);
        
        var action = component.get("c.createOppTeam");
        debugger;
        action.setParams({
            oppTeamMasterId : component.get("v.oppTeamMasterId"),
            recordId : component.get("v.recordId"),
            contactIds : selectedContacts
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                //component.set("v.oppTeamMaster",response.getReturnValue());
            } else{
                debugger;
            }
            let baseUrl  = window.location.origin;
            window.open(baseUrl+'/lightning/r/Opportunity/'+component.get("v.recordId")+'/view','_top')
            
        });
        $A.enqueueAction(action);
    },
    handleSave : function(component, event) {
        debugger;
        var action = component.get("c.createOppTeam");
        debugger;
        action.setParams({
            oppTeamMasterId : component.get("v.oppTeamMasterId"),
            opportunityId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                //component.set("v.oppTeamMaster",response.getReturnValue());
            } else{
                debugger;
            }
            let baseUrl  = window.location.origin;
            window.open(baseUrl+'/lightning/r/Opportunity/'+component.get("v.recordId")+'/view','_top')
            
        });
        $A.enqueueAction(action);
    },
    
    selectAll: function(component, event, helper) { 
        
        debugger;
        //get the header checkbox value  
        var selectedHeaderCheck = event.getSource().get("v.value");
        
        // get all checkbox on table with "checkContact" aura id (all iterate value have same Id)
        // return the List of all checkboxs element 
        
        var getAllId = component.find("checkContact");
        // If the local ID is unique[in single record case], find() returns the component. not array   
        if(! Array.isArray(getAllId)){
            if(selectedHeaderCheck == true){ 
                component.find("checkContact").set("v.value", true);
            }else{
                component.find("checkContact").set("v.value", false);
            }
        }else{
            // check if select all (header checkbox) is true then true all checkboxes on table in a for loop  
            // and set the all selected checkbox length in selectedCount attribute.
            // if value is false then make all checkboxes false in else part with play for loop 
            // and select count as 0 
            if (selectedHeaderCheck == true) {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("checkContact")[i].set("v.value", true);
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("checkContact")[i].set("v.value", false);
                }
            } 
        }  
        
    }
})