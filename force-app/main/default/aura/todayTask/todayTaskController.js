({
    doInit: function (component, event, helper) {
        
        
        helper.getVisitRecs(component, event, helper); 
        helper.loadCompletedTasks(component, event, helper);
        helper.callMapMethod(component, event, helper); 
        var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
       	var today = new Date;
        var dateYear = today.toLocaleTimeString('en-us', { year: 'numeric' }).split(' ')[0].replaceAll(',', '');
        var dateMonth = today.toLocaleTimeString('en-us', { month: 'long' }).split(' ')[0].replaceAll(',', '');
        var dateDay = today.toLocaleTimeString('en-us', { day: 'numeric' }).split(' ')[0].replaceAll(',', '');
        var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false };
        var prnDt = today.toLocaleTimeString('en-us', { weekday: 'long' }).split(' ')[0].replaceAll(',', '');
        var MonthName=monthNames[today.getMonth()].slice(0,3);
        
        component.set('v.dateDay', dateDay);
        component.set('v.dateYear', dateYear);
        component.set('v.dateMonth', dateMonth);
        component.set('v.day', prnDt);
        
        var counter = component.get("v.nextCounter");
        component.set("v.nextCounter",counter);
        let curr = new Date();
        var date = new Date();
        let week = []
        const dates = [];
        const mql = window.matchMedia('(max-width: 820px)');
        let mobileView = mql.matches;
        if(mobileView){
            date.setDate(date.getDate() + (3 * counter));
            console.log(date);
            curr = date;
            for (let i = 0; i < 3; i++) {
                let first = curr.getDate();
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
                curr.setDate(curr.getDate() + 1);
            }
            component.set("v.mobileDates", dates); 
        }else{
            date.setDate(date.getDate() + (7 * counter));
            console.log(date);
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
        }
    },
    
    handleComponentEvent : function (component, event, helper) {
        
        //alert('fired!');
        var showStartVisitComponent = event.getParam("showStartVisitComponent"); 
        var showTodaysTaskComponent = event.getParam("showTodaysTaskComponent");
        component.set('v.showTodaysTaskComponent', showTodaysTaskComponent);
        component.set('v.showStartVisitComponent', showStartVisitComponent);
        
    },
    
    handleDateSelect: function (component, event, helper) {
        
        const selectedDate = event.currentTarget.dataset.date;
        component.set("v.selectedDate", selectedDate);
        component.set("v.SelectedVisitDate", selectedDate);
        var dateToPass = selectedDate;
        console.log('first execution::==>'+dateToPass);
        helper.callMapMethodFromController(component, dateToPass, helper); 
        console.log('second execution::==>');
        if(selectedDate != null && selectedDate != undefined){
            var dateNew = new Date();
            if(selectedDate != dateNew.toISOString().slice(0, 10)){
                component.set('v.disableVisitButtons', true);
            }
            dateNew.setFullYear(selectedDate.slice(0,4));
            dateNew.setDate(selectedDate.slice(8,10));
            dateNew.setMonth(selectedDate.slice(5,7)-1);
            var today = dateNew;
        }
        var dateYear = today.toLocaleTimeString('en-us', { year: 'numeric' }).split(' ')[0].replaceAll(',', '');
        var dateMonth = today.toLocaleTimeString('en-us', { month: 'long' }).split(' ')[0].replaceAll(',', '');
        var dateDay = today.toLocaleTimeString('en-us', { day: 'numeric' }).split(' ')[0].replaceAll(',', '');
        var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false };
        var prnDt = today.toLocaleTimeString('en-us', { weekday: 'long' }).split(' ')[0].replaceAll(',', '');
        
        component.set('v.dateDay', dateDay);
        component.set('v.dateYear', dateYear);
        component.set('v.dateMonth', dateMonth);
        component.set('v.day', prnDt);
        console.log('third execution::==>'+dateToPass);
        helper.getVisitRecs(component, event, helper); 
        helper.loadCompletedTasks(component, event, helper);
        console.log('forth execution::==>'+event);
        helper.reloadPage(component, event, helper);
        console.log('fivth execution::==>'+event);
    },
    
    
    handleAmend: function (component, event, helper) {
        
        var buttonId =event.getSource().get("v.name");
        component.set("v.selectedVisitPlanedId",buttonId);
        component.set("v.ShowAmedVistPop",true);
        var action = component.get('c.getSelectedVisitDetails');
        action.setParams({
            visitId : buttonId
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.visitRec', result);
            } 
        });
        $A.enqueueAction(action);
    },
    handleStartVisit: function (component, event, helper) {
        
        // helper.getVisitData(component, event, helper);
        var record = event.getSource().get('v.value');
        var recordId = record.Account__c;
        component.set('v.visitIDtoStart', record.Id);
        component.set('v.accIdToShow', recordId);
        component.set('v.showTodaysTaskComponent',false);
        component.set('v.showStartVisitComponent',true);
        /*var cmpEvent = component.getEvent("fieldVisitComponentEvent"); 
        cmpEvent.setParams({"visitId" : record.Id}); 
        cmpEvent.fire(); */
    },
    
    getActualVistiDateChange : function (component, event, helper) {
        
        var selVisitDate = component.find('auraidActialVisitdate').get('v.value');
        component.set("v.visitPlanedDate",selVisitDate);
        var visitDescription = component.find('visitDescription').get('v.value');
        component.set("v.visitDescription",visitDescription);
    },
    
    StartVisitDay: function (component, event, helper) {
        debugger;
        var lat;
        var long;
        var userLocation = navigator.geolocation;
        if (userLocation) {
            // component.set("v.disableVisitButtons", false);
            userLocation.getCurrentPosition(function (position) {
                lat = position.coords.latitude;
                long = position.coords.longitude;
                if ((lat != null && lat != undefined && lat != '') && (long != null && long != undefined && long != '')) {
                    var today = new Date();
                    var year = today.getFullYear();
                    var month = String(today.getMonth() + 1).padStart(2, '0');
                    var day = String(today.getDate()).padStart(2, '0');
                    var formattedDate = year + '-' + month + '-' + day;
                    component.set('v.selectedDate', formattedDate);
                    helper.getVisitRecs(component, event, helper);
                    // helper.loadCompletedTasks(component, event, helper);
                    helper.StartVisitDayhelper(component,lat, long);
                    component.set("v.currentLatitude", lat);
                    component.set("v.currentLongitude", long);
                }
                
            });
        } 
    },
    EndVisitDay : function (component, event, helper) {
        
        var lat;
        var long;
        var userLocation = navigator.geolocation;
        if (userLocation) {
            userLocation.getCurrentPosition(function (position) {
                lat = position.coords.latitude;
                long = position.coords.longitude;
                if ((lat != null && lat != undefined && lat != '') && (long != null && long != undefined && long != '')) {
                    helper.EndVisitDayhelper(component,lat, long);
                    component.set("v.currentLatitude", lat);
                    component.set("v.currentLongitude", long);
                    component.set('v.disableVisitButtons', true);
                    component.set('v.ShowEndDay', true);
                }
            });
        }
    },
    closeModelPop : function (component, event, helper) {
        component.set("v.ShowAmedVistPop",false);
    },
    updateVisitHandler: function (component, event, helper) {
        debugger;
        var visitRecord = component.get("v.visitRec");
        var plannedVisitDate = new Date(visitRecord.Planned_visit_date__c);
        var selectedDate = new Date(component.find("auraidActualVisitDate").get("v.value"));
    
        if (selectedDate > plannedVisitDate) {
            // Selected date is valid, proceed with the action.
            var action = component.get("c.updateAmendVisitRecord");
            action.setParams({
                visitRec: visitRecord
            });
    
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var data = response.getReturnValue();
                    if (data != null) {
                        alert("SUCCESS");
                    }
                }
            });
    
            $A.enqueueAction(action);
        } else {
            // Display an error message when the selected date is not greater than the planned visit date.
            alert("New selected date cannot be earlier than the planned visit date.");
        }
    },
    
    
    handleNextClicked : function(component, event, helper){
        
        var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var counter = component.get("v.nextCounter") + 1;
        component.set("v.nextCounter",counter);
        let curr = new Date();
        var date = new Date();
        let week = []
        const dates = [];
        const mql = window.matchMedia('(max-width: 820px)');
        let mobileView = mql.matches;
        if(mobileView){
            date.setDate(date.getDate() + (3 * counter));
            console.log(date);
            curr = date;
            for (let i = 0; i < 3; i++) {
                let first = curr.getDate();
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
                curr.setDate(curr.getDate() + 1);
                
            }
            component.set("v.mobileDates", dates); 
        }else{
            date.setDate(date.getDate() + (7 * counter));
            console.log(date);
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
        }
        
       	component.set('v.selectedDate',week[0]);
        var selectedDate = component.get('v.selectedDate');
        if(selectedDate != null && selectedDate != undefined){
            var dateNew = new Date();
            dateNew.setFullYear(selectedDate.slice(0,4));
            dateNew.setDate(selectedDate.slice(8,10));
            dateNew.setMonth(selectedDate.slice(5,7)-1);
            var today = dateNew;
        }
        var dateYear = today.toLocaleTimeString('en-us', { year: 'numeric' }).split(' ')[0].replaceAll(',', '');
        var dateMonth = today.toLocaleTimeString('en-us', { month: 'long' }).split(' ')[0].replaceAll(',', '');
        var dateDay = today.toLocaleTimeString('en-us', { day: 'numeric' }).split(' ')[0].replaceAll(',', '');
        var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false };
        var prnDt = today.toLocaleTimeString('en-us', { weekday: 'long' }).split(' ')[0].replaceAll(',', '');
        
        component.set('v.dateDay', dateDay);
        component.set('v.dateYear', dateYear);
        component.set('v.dateMonth', dateMonth);
        component.set('v.day', prnDt);
        helper.getVisitRecs(component, event, helper); 
        helper.loadCompletedTasks(component, event, helper);
        helper.reloadPage(component, event, helper);
    },
    
    handlePrevClicked : function(component, event, helper){
        
        var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var counter = component.get("v.nextCounter") - 1;
        component.set("v.nextCounter",counter);
        let curr = new Date();
        var date = new Date();
        let week = []
        const dates = [];
        const mql = window.matchMedia('(max-width: 820px)');
        let mobileView = mql.matches;
        if(mobileView){
            date.setDate(date.getDate() + (3 * counter));
            console.log(date);
            curr = date;
            for (let i = 0; i < 3; i++) {
                let first = curr.getDate();
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
                curr.setDate(curr.getDate() + 1);
                
            }
            component.set("v.mobileDates", dates); 
        }else{
            date.setDate(date.getDate() + (7 * counter));
            console.log(date);
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
        }
        
        component.set('v.selectedDate',week[0]);
        var selectedDate = component.get('v.selectedDate');
        if(selectedDate != null && selectedDate != undefined){
            var dateNew = new Date();
            dateNew.setFullYear(selectedDate.slice(0,4));
            dateNew.setDate(selectedDate.slice(8,10));
            dateNew.setMonth(selectedDate.slice(5,7)-1);
            var today = dateNew;
        }
        var dateYear = today.toLocaleTimeString('en-us', { year: 'numeric' }).split(' ')[0].replaceAll(',', '');
        var dateMonth = today.toLocaleTimeString('en-us', { month: 'long' }).split(' ')[0].replaceAll(',', '');
        var dateDay = today.toLocaleTimeString('en-us', { day: 'numeric' }).split(' ')[0].replaceAll(',', '');
        var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false };
        var prnDt = today.toLocaleTimeString('en-us', { weekday: 'long' }).split(' ')[0].replaceAll(',', '');
        
        component.set('v.dateDay', dateDay);
        component.set('v.dateYear', dateYear);
        component.set('v.dateMonth', dateMonth);
        component.set('v.day', prnDt);
        helper.getVisitRecs(component, event, helper); 
        helper.loadCompletedTasks(component, event, helper);
        helper.reloadPage(component, event, helper);
    },
    
})