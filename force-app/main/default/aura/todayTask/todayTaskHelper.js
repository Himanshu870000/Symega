({
    getVisitRecs : function(component, event, helper) {
        debugger;
        var helper = this;
        var today = new Date();
        var selectedDate = component.get('v.selectedDate');        
        // Get the year, month, and day from the Date object
        var year = today.getFullYear();
        var month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
        var day = String(today.getDate()).padStart(2, '0');
        
        // Format the date in "YYYY-MM-DD" format
        var formattedDate = year + '-' + month + '-' + day;
        if(selectedDate != null && selectedDate != undefined){
            formattedDate = selectedDate;
        }
        component.set('v.SelectedVisitDateFromTaskComp', formattedDate);
        component.set('v.selectedDate', formattedDate);
        var action = component.get('c.getAllVisitTodays');
        action.setParams({
            visitDate :  formattedDate
        });

        // var action = component.get('c.GetCompletedVisitRecords');
        // action.setParams({
        //     visitDate :  formattedDate
        // });

        action.setCallback(this, function(response){ // AccountAddressList
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                var newVisitList;
                if(result != null){
                    if(result.visitList != undefined && result.visitList != null && result.visitList != ''){
                        if(result.isApproved == true){
                            /*for(var i in result.visitList){
                                 var address = result.visitList[i].Account__r.BillingStreet +','+ result.visitList[i].Account__r.BillingCity + ',' + result.visitList[i].Account__r.BillingState;
                                var endLat = searchLatAndLngByStreet(address).latitude;
                                var endLong = searchLatAndLngByStreet(address).longitude;
                            }*/
                            component.set('v.taskList', result.visitList);
                            component.set('v.completedVisit', result.completedVisit); 
                            component.set('v.pendingVisit', result.pendingVisit);
                            component.set("v.ShowEmptyPage",false);
                            component.set('v.disableVisitButtons', true);
                            component.set("v.ShowStartDay",!result.isApproved);
                            if(result.dvpList != undefined && result.dvpList.length != 0){
                                component.set("v.ShowStartDay",result.isApproved);
                                component.set("v.ShowEndDay",false);
                                component.set('v.disableVisitButtons', false);
                            }else{
                                component.set("v.ShowStartDay",false);
                                component.set("v.ShowEndDay",true);
                                component.set('v.disableVisitButtons', true);
                            } 
                        }else{
                            component.set('v.taskList', result.visitList);
                            component.set('v.completedVisit', result.completedVisit); 
                            component.set('v.pendingVisit', result.pendingVisit);
                            component.set("v.ShowEmptyPage",false);
                            component.set("v.ShowStartDay",true);
                            component.set("v.ShowEndDay",true)
                            component.set('v.disableVisitButtons', true);
                        }
                        
                        var objlocation = [];
                        var accountAddressOBj = [];
                        var  location = {Street : '',City:'',State:'',PostalCode : '',Country : ''}
                        for(var i=0;i<result.visitList.length;i++){
                            var dataccc = result.visitList[i].Account__r;
                            accountAddressOBj.push(dataccc);
                        }
                        component.set("v.AccountAddressList",accountAddressOBj);
                        var dataAddress = component.get("v.AccountAddressList");
                        for(var i=0;i<dataAddress.length;i++){
                            var tempLocat = {};
                            var LocationObj = {};
                            tempLocat.Street = dataAddress[i].BillingStreet;
                            tempLocat.City  = dataAddress[i].BillingCity;
                            tempLocat.State = dataAddress[i].BillingState;
                            tempLocat.PostalCode = dataAddress[i].BillingPostalCode;
                            tempLocat.Country = dataAddress[i].BillingCountry;
                            LocationObj.location = tempLocat;
                            objlocation.push(LocationObj);
                        }
                        component.set("v.AccountMapList",objlocation)
                        this.MapinitMethod(component, event, helper);
                    }
                    else{
                        //this.showError(component, event, helper);
                        //alert('No visit created for day.');
                        return;
                    }
                }
                else{
                    //alert('No Visits Scheduled for Today.');
                    component.set('v.taskList', []);
                    component.set('v.completedVisit', []); 
                    component.set('v.pendingVisit', []);
                    component.set("v.ShowStartDay",true);
                    component.set("v.ShowEndDay",true);
                    component.set("v.ShowEmptyPage",true);
                    return;
                }
            }else{
                console.log(JSON.stringify(response.getError()));
                this.showErrorMessage(component, event, helper);
                return;
            } 
        });
        $A.enqueueAction(action);
    },

    loadCompletedTasks: function (component, event, helper) {
        debugger;
            var today = new Date();
            var selectedDate = component.get('v.selectedDate');        
            var year = today.getFullYear();
            var month = String(today.getMonth() + 1).padStart(2, '0'); 
            var day = String(today.getDate()).padStart(2, '0');
            
            // Format the date in "YYYY-MM-DD" format
            var formattedDate = year + '-' + month + '-' + day;
            if(selectedDate != null && selectedDate != undefined){
                formattedDate = selectedDate;
            }
            component.set('v.SelectedVisitDateFromTaskComp', formattedDate);
            component.set('v.selectedDate', formattedDate);
            var action = component.get("c.GetCompletedVisitRecords");
            action.setParams({ visitDate: formattedDate });
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseValue = response.getReturnValue();
                    if (responseValue) {
                        component.set("v.completedTaskList", responseValue.completedVisitList);
                        // component.set("v.completedVisitCount", responseValue.completedVisit);
                    }
                } else {
                    // Handle errors or display a message
                    console.error("Error: " + state);
                }
            });
    
            $A.enqueueAction(action);
        },
    
    
    MapinitMethod: function (component, event, helper) {
        
        component.set('v.mapMarkers',component.get("v.AccountMapList") );
        component.set('v.zoomLevel', 12);
    },
    
    searchLatAndLngByStreet:function(adress) {
    const geocoder = new google.maps.Geocoder();
    geocoder.geocode({ 'address': adress }, (res, status) => {
      console.log(res, status)
      if (status == google.maps.GeocoderStatus.OK) {
        return {
          latitude: JSON.stringify(res[0].geometry.location.lat()),
          longitude: JSON.stringify(res[0].geometry.location.lng())
        }
      } 
    });
},
    showsuccessMessage : function (component, event, helper) {
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'SUCCESS',
            message: 'Your day has been successfully started !',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showErrorMessage : function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'ERROR',
            message:'Something went Wrong !',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    StartVisitDayhelper : function (component, lat, long){
        
        var taskrecords = component.get("v.taskList");
        var action = component.get("c.StartDayVisitForVistitRecord");
        action.setParams({
            startLat: lat,
            startLang: long,
            visitRecList: taskrecords
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue(); 
                if(data !=null){
                    component.set("v.ShowStartDay",true);
                    component.set("v.ShowEndDay",false);
                    component.set('v.disableVisitButtons', false);
                }
                //this.showsuccessMessage(component, event);
            } else if (state === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            } else if (state === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        })
        $A.enqueueAction(action);
    },
    EndVisitDayhelper : function (component, lat, long){
        
        var action = component.get("c.updateEndDayVisitRecord");
        action.setParams({
            endLat: lat,
            endLong: long
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() !=null){
                    alert("SUCCESS");
                }
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        });       
        $A.enqueueAction(action);
        /*
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                alert('Record is Created Successfully');
            } else if (state === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            } else if (state === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        })
        $A.enqueueAction(action);
        */
    },
    
    showInfo : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info',
            message: 'This is an information message.',
            duration:' 3000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Record created Successfully',
            duration:' 3000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:'No Records To Display',
            duration:' 3000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showWarning : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: 'This is a warning message.',
            duration:' 3000',
            key: 'info_alt',
            type: 'warning',
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    
    reloadPage: function(component, event, helper){
                
        var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var counter = component.get("v.nextCounter");
        //component.set("v.nextCounter",counter);
        let curr = new Date();
        var date = new Date();
        date.setDate(date.getDate() + (7 * counter));
        console.log(date);
        let week = []
        const dates = [];
        curr = date;
        for (let i = 1; i <= 7; i++) {
            let first = curr.getDate() - curr.getDay() + i;
            let weekDate = new Date(curr.setDate(first)).toISOString().slice(0, 10);
            week.push(weekDate);
            const newDate = new Date(weekDate);
            //newDate.setDate(weekDate.getDate() + i);
            var dateObj = {day:'', fullDate:'', month:''};
            dateObj.fullDate = newDate.toISOString().slice(0, 10);
            dateObj.day = newDate.toISOString().slice(8,10);
            var MonthName=monthNames[newDate.getMonth()].slice(0,3);
            dateObj.month = MonthName;
            dates.push(dateObj);
        }
        component.set("v.dates", dates);
    },
    callMapMethod : function(component, event, helper){
        debugger;
        var selectedVisitDateFromParentComp = component.get("v.SelectedVisitDate");
        var baseURL = 'https://symegafood--uat--c.sandbox.vf.force.com/apex/MultipleGeolocationVF?id='+selectedVisitDateFromParentComp;
        //console.log('baseURL === >'+baseURL);
        component.set("v.siteURL",baseURL);
    },
    callMapMethodFromController : function(component, dataFromCont, helper){
        
        var selectedVisitDateFromParentComp = dataFromCont;
        var baseURL = 'https://symegafood--uat--c.sandbox.vf.force.com/apex/MultipleGeolocationVF?id='+selectedVisitDateFromParentComp;
        //console.log('baseURL === >'+baseURL);
        component.set("v.siteURL",baseURL);
    },
    
})