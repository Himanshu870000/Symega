({
    doinit : function(component ,event ,helper){
        /*const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        var selectedMonnth = component.get("v.month");
        //var selectedYear = component.get("v.year");
        const formattedDate = `${year}-${selectedMonnth}-${day}`;
       	component.set("v.formattedDate",formattedDate);*/
        
    },
    afterScriptsLoaded: function(component,event ,helper){
        
        //var events = component.get("v.events");
        //console.log('events--------IN',events);
        //if(!events.length)
        
        // helper.fetchEvents(component,event);
        // /
    },
    
    afterRender: function(component, helper) {
        
        this.superAfterRender();
        helper.setupDraggableEvents(component);
        
        
    },
    
    parentComponentEvent:function(component ,event ,helper) {
        debugger;
        const today = new Date();
        // const year = today.getFullYear();
        //const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        //var selectedMonnth = component.get("v.month");
        //var selectedYear = component.get("v.year");
        
        //component.set("v.formattedDate",formattedDate);
        
        
        var wrappdata;
        var mbl=[];
        var visitList=[];
        var Month = event.getParam("Month");
        var Year = event.getParam("Year"); 
        component.set("v.selectedMonth",Month);
        component.set("v.selectedYear",Year);
        const formattedDate = `${Year}-${Month}-${day}`;
        component.set("v.ShowToCreateMonthlyBeatPlan",false);
        //Set the handler attributes based on event data 
        var action = component.get("c.BeetplannerDatareturn");
        action.setParams({ 
            month : Month,
            year:Year
        });
        
        // Create a callback that is executed after 
        // the server-side action returns
        var monthYear=Month+'-'+Year;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                wrappdata=response.getReturnValue();
                if(Object.keys(wrappdata).length > 0){
                    component.set("v.ShowMonthlyBeatPlan",true);
                    // wrappdata.visitRecList[0].Visit__r
                    component.set("v.Weeklybp",wrappdata.MBPlist.Weekly_Beat_Plans__r);
                    //if(!wrappdata.MBPlist.Weekly_Beat_Plans__r.length > 0)
                    component.set("v.weeklyWrapper",wrappdata.weeklyWrapper);
                    component.set("v.kpiTargetsName",wrappdata.MBPlist.KPI_Targets__r)
                    component.set("v.recordId",wrappdata.MBPlist.Id);
                    component.set("v.mbpName",wrappdata.MBPlist.Name);
                    component.set("v.month",wrappdata.MBPlist.Month_Name__c);
                    component.set("v.mbpStatus",wrappdata.MBPlist.Status__c);
                    component.set("v.showApprovalButton",wrappdata.showApprovalButton);
                    var tempKPIList=wrappdata.weeklyWrapper;
                    for(let j=0;j<wrappdata.weeklyWrapper.length;j++){
                        let TempArray=wrappdata.weeklyWrapper[j].kpiList;
                        for (let i = 0; i <TempArray.length; i++) {
                            if (i % 2 === 0) {
                                TempArray[i].dynamicClass='slds-badge slds-theme_success';
                                console.log(i + " is even");
                            } else {
                                TempArray[i].dynamicClass='slds-badge slds-badge_inverse';
                                console.log(i + " is odd");
                            }
                            
                        }
                        console.log('TempArray---'+JSON.stringify(TempArray));
                        wrappdata.weeklyWrapper[j].kpiList=TempArray;
                    }
                    console.log('wrappdata.weeklyWrappe---'+JSON.stringify(wrappdata.weeklyWrapper));
                    console.log('visitList---',visitList);
                    component.set("v.Visits",visitList);
                    if(wrappdata.MBPlist.Status__c=='Approved'){
                        component.set("v.showApprovedCal",true);
                        let isShowpageCally=component.get("v.showApprovedCal")
                        if(isShowpageCally==true){
                            component.set("v.showUnapprovedCal",false);
                            component.set("v.showApprovedCal",true);
                        }
                        else if(isShowpageCally==false){
                            component.set("v.showApprovedCal",false);
                            component.set("v.showUnapprovedCal",true);
                        }
                        
                    }
                    else{
                        component.set("v.showApprovedCal",false);
                        
                    }
                    if(wrappdata.MBPlist.Status__c!='Approved'){
                        component.set("v.showUnapprovedCal",true);
                    }
                    helper.fetchEvents(component,event);
                    //var formatted=component.get("v.formattedDate");
                    var baseURL = 'https://symegafood--uat--c.sandbox.vf.force.com/apex/MonthlyVisitViewer?id='+formattedDate;
                    component.set("v.siteURL",baseURL);
                }else{
                    component.set("v.ShowMonthlyBeatPlan",false);
                    component.set("v.ShowToCreateMonthlyBeatPlan",true);
                }
                
                
            }
            else if (state === "INCOMPLETE") {
                // do something
                
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    
    sendForApp: function (component, event, helper) {
        debugger;
        
        var recId=event.target.Id;
        var action = component.get("c.initiateApprovalProcess");
        action.setParams({
            recordId: component.get("v.recordId") // Pass the relevant record Id to the Apex method
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Successfully Send for Approval',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                //$A.get('e.force:refreshView').fire();     
                //alert('Successfully Sent');
                // Handle success, e.g., display a toast message or refresh the page
            } else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'This is an error message',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                var errors = response.getError();
               // alert('Error,');
                // Handle errors, e.g., display error messages
            }
        });
        
        $A.enqueueAction(action);
    },
    
    closeModel:function(component ,event ,helper){
        debugger;
        component.set("v.isShowDaskDesComp",false);
    }
    
    
})