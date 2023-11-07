$(document).ready(function () {
    
    let repVisits = [];
    let eventss=[]
    let selectedEventKPIS = [];
    let selectedEvent;
    let selectedObject;
    let selecteLocation;
    let selectedUser;
    let currentAccount;
    let SelectedRecord;
    let selectedUserId;
    let visiteDateToApex;
    let Leadgeolatitude;
    let Leadgeolongitude;
    let AccountLatitude;
    let AccountLongitude;
    let AccountId;
    let dateTime;
    let addlat;
    let addlong;
    let startTime;
    let endTime;
    let accMap = new Map();
    let configureCalendar = function () {
        debugger;
        
        $("#calendar").fullCalendar('removeEvents');
        $("#calendar").fullCalendar('addEventSource', repVisits);
	
    }
   
   

    
    
    debugger;
    const queryString = window.location.search;
    let jobAppId = queryString.split("id=").pop();
    
    MonthlyVisitViewerController.getcurrentUserRoutes(function (result, event) {
        debugger;
        console.log('--- result Object :' + result);
        $(result).each(function (i, e) {
            debugger;
            $("#pick-two").after('<option value="' + result[i] + '">' + result[i] + '</option>');
        });
        
    }, { escape: false });
    
    MonthlyVisitViewerController.fetchPageData(jobAppId,function (result, event) {
        debugger;
        let monthName=jobAppId;
        console.log('--- result' + result);
        eventss=[...result];

        if(result!=null){
            result.forEach(item=>{
                repVisits.push({ id: item.Id, start: item.Actual_visit_date__c,title:item.Account__r.Name, kpiId:item.KPI_Target__c});
            })
            //repVisits = [...result];
        }
        
        
        if (event.status) {
            $('#calendar').fullCalendar({
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay'
                },
                themeSystem: "standard",
                cache: true,
                defaultDate: monthName,
                navLinks: true,
                editable: true,
                eventLimit: true,
                events: repVisits,
                dragScroll: true,
                droppable: true,
                weekNumbers: true,
                displayEventTime: false,
                
                eventDrop: function (event, delta, revertFunc) {
                    debugger;
                    // toastr.success("Button has been enabled successfully!", "Success", {
                    //     closeButton: true,
                    //     progressBar: true,
                    //     positionClass: "toast-top-right"
                    // });
                    // alert(event.title + " was dropped on " + event.start.format());
                    if (!confirm("Are you sure about this change? ")) {
                        revertFunc();
                    } else {

                        $.each(repVisits, function (i, visit) {
                            if (visit.id === event.id) {
                                repVisits[i].start = event.start._d.getTime();
                                updateSingleVisitDate(repVisits[i]);
                            }
                            console.log(repVisits[i]);
                        });

                        // $.each(eventss, function (i, visit) {
                        //     if (visit.id === event.id) {
                        //         eventss[i].start = event.start._d.getTime();
                        //     }
                        //     console.log(eventss[i]);
                        // });
                    }
                },
                eventClick: function (event, jsEvent, view) {
                    // toastr.success("Button has been enabled successfully!", "Success", {
                    //     closeButton: true,
                    //     progressBar: true,
                    //     positionClass: "toast-top-right"
                    // });
                    // // alert('abc');
                    debugger;
                    selectedEvent = event;

                    getVisitKpis(selectedEvent)
                    
                },
                dayClick: function (date, jsEvent, view) {
                    jsEvent.preventDefault();
                },
                drop: function (date ,jsEvent) {
                    visiteDateToApex = date;
                   
                    console.log('repVisits.length::'+repVisits.length);
                    debugger;
                    //repVisits.push({ id: $(this).attr("data-accid"), start: date._i });
                                      
                    
                    for (var i = 0; i < repVisits.length; i++){
                        if(repVisits[i].start !=null){
                            if(repVisits[i].start ==visiteDateToApex && repVisits[i].id==AccountId){
                                
                            }
                            else{

                            }
                            
                        }
                        else{
                            handleAddressSelection(date, this);
                        }
                    }

                    // for (var i = 0; i < repVisits.length; i++) {
                       
                    //     if(repVisits[i].id==currentAccount && repVisits[i].start==apexDate){
                    //         alert('there is already visit for this account');
                    //         return;
                    //        // handleAddressSelection(date, this);
                    //     }else{
                    //         currentAccount = repVisits[i].id;
                    //         return;
                    //        // handleAddressSelection(date, this);
                    //     }
                    // }
                    
                    //callGeolocationMethod();
                    if ($('#drop-remove').is(':checked')) {
                        $(this).remove();
                    }
                },
                eventConstraint: {
                    start: moment().format('YYYY-MM-DD'),
                    end: '2100-01-01' // hard coded goodness unfortunately
                }
            });
            $('#calendar').fullCalendar('gotoDate', monthName);
        }
        $("#spinner").hide();
    }, { escape: false });
    

    function updateSingleVisitDate(visit){
        let visits = [];

        let v = {Id:visit.Id,Planned_visit_date__c:visit.start};
        
        visits.push(v);
           
        MonthlyVisitViewerController.createVisits(visits, function (result, event) {
            console.log('--- result' + result);
            debugger;
            if (event.status) {
                console.log('event created successfully');
            }
            $("#spinner").hide();
        }, { escape: false });
    }
    
    function callGeolocationMethod() {
        debugger;
        MonthlyVisitViewerController.getCurrentRecordGeoLocation(currentAccount, function (result, event) {
            debugger;
            console.log('--- result Object :' + result);
            if (result) {
                AccountLatitude = result.Geo_Location__Latitude__s;
                AccountLongitude = result.Geo_Location__Longitude__s;
                // for (var key in result) {
                // if (key == "Geolocation__Longitude__s") {
                Leadgeolatitude = result.Geo_Location__Latitude__s;
                Leadgeolongitude = result.Geolocation__Longitude__s;
                //callVisitAccountCreateRecordMethod();
                // console.log("Lead Found Lead Method Called")
                console.log("Account Found Account Method Called")
                // break;
                //  }
                //  else if (key == "Geo_Location__Latitude__s") {
                // AccountLatitude = result.Geo_Location__Latitude__s;
                //   AccountLongitude = result.Geo_Location__Longitude__s;
                
                //  console.log("Account Found Account Method Called")
                //   break;
                //  }
                // }
            }
        }, { escape: false }); 
        //   callVisitAccountCreateRecordMethod();
    }
    
    
    /*
    function callVisitLeadCreateRecordMethod() {
        debugger;
        let apexDate = visiteDateToApex.toISOString();
        MonthlyVisitViewerController.createVisitObjectType(currentAccount, apexDate, Leadgeolatitude, Leadgeolongitude, function (result, event) {
            debugger;
            console.log('--- result Object :' + result);
            if (result.length != null) {
                alert("VISIT for Lead Created Successfully !")
            }
        }, { escape: false });
    }
    */
    function callVisitAccountCreateRecordMethod() {
        debugger;
        let apexDate = visiteDateToApex.toISOString();
        MonthlyVisitViewerController.createVisitObjectTypev1(AccountId, apexDate, addlat, addlong, startTime,endTime,function (result, event) {
            console.log('--- result Object :' + result);

            if(result!=null){
                let index = repVisits.findIndex(item=>item.id==currentAccount);
                //repVisits[index].id = result;
                
                // toastr.success("VISIT CreatedS Successfully!", "Success", {
                //     closeButton: true,
                //     progressBar: true,
                //     positionClass: "toast-top-right"
                // });
                // alert("VISIT Created Successfully !")
                swal({
                    title: "Good job!",
                    text: 'Visit Created Successfully!',
                    icon: 'success',
                    buttons: false,
                    timer: 1000,
                });
                //window.location.reload();
            }else{
                //alert('Error to create visit');
                swal ({
                    title:"Oops" ,  
                    text:"Something went wrong!" ,  
                    icon:"error",
                    buttons: false,
                    timer: 1000,
                   // showCancelButton: true
                })
            }
        }, { escape: false });
    }
    
    
    
    $("#upsert-visit").click(function () {
        $("#spinner").show();
        debugger;
        var salesRep = $('#user-select').find(":selected").val();
        if (salesRep && repVisits && repVisits.length > 0) {
            let visits = [], visit;
            for (let i = 0; i < repVisits.length; i++) {
                visit = {};
                visit.id = repVisits[i].id;
                visit.Account__c = repVisits[i].accountId;
                visit.Planned_visit_date__c = repVisits[i].start;
                visit.Assigned_User__c = salesRep;
                visits.push(visit);
            }
            MonthlyVisitViewerController.createVisits(visits, function (result, event) {
                console.log('--- result' + result);
                debugger;
                if (event.status) {
                    console.log('event created successfully');
                }
                $("#spinner").hide();
            }, { escape: false });
        }
        else {
            $("#spinner").hide();
            alert('Please select visit inorder to create.');
        }
    });
    
    $("#search-account").click(function () {
        debugger;
        $("#search-pannel").toggle();
    });
    
    $("#search-dealer").click(function () {
        debugger;
        let userId = $("#user-select option:selected").val();
        if (userId == undefined || userId === "") {
            alert('Please select sales rep in-order to search');
            return;
        }
        var searchString = $('#search-box').val();
        if (searchString == undefined || searchString.length < 3) {
            alert('You need to provide at least 3 characters to search.');
            return;
        }
        $("#spinner").show();
        debugger;
        selecteLocation = $('#user-selectlocation :selected').text();
        MonthlyVisitViewerController.getRepAccounts(selectedUser, selecteLocation, function (accountList, event) {
            debugger;
            if (event.status) {
                if (accountList && accountList.length == 0) {
                    alert('No Records found.');
                } else {
                    $("#event-container").empty();
                    $(accountList).each(function (i, e) {
                        $("#event-container").append(
                            '<div class="fc-event" data-accid="' + accountList[i].Id + '">' + accountList[i].Name + '</div>'
                        );
                    });
                    setEventDraggable();
                }
                
            } else {
                console.log(result);
                alert('Something went wrong');
            }
            $("#spinner").hide();
        });
    });
    
    $("#clear-dealer").click(function () {
        $('#search-box').val("");
        $("#event-container").empty();
        updateDefaultRepAccounts($("#user-select option:selected").val());
    });
    
    $("#delete-event").click(function () {
        debugger;
        if (selectedEvent) {
            if (selectedEvent.id) {
                $("#spinner").show();
                MonthlyVisitViewerController.deleteEvent(selectedEvent.id, function (result, event) {
                    if (event.status) {
                        $("#calendar").fullCalendar('removeEvents', selectedEvent._id);
                    } else {
                        alert('Something went wrong, please contact system admin.');
                    }
                    $('#event-modal').hide();
                    $("#spinner").hide();
                });
            } else {
                $("#calendar").fullCalendar('removeEvents', selectedEvent._id);
                $('#event-modal').hide();
            }
        }
    });
    
    $(".close-modal").click(function () {
        debugger;
        console.log(selectedEvent);
        $('#event-modal').hide();
    });
    
    $("#user-select").change(function () {
        debugger;
        let userId = $(this).children("option:selected").val();
        if (userId == undefined || userId === "" || userId === "Select...")
            $("#upsert-visit").prop('disabled', true);
        $("#event-container").empty();
        updateDefaultRepAccounts(userId);
        //  getLocationOnObjectType();
    });
    
    $("#user-selectRecords").change(function () {
        debugger;
        $("#search-pannel").toggle();
        SelectedRecord = $('#user-selectRecords :selected').text();
    });
    
    $("#user-selectUser").change(function () {
        debugger;
        getUser();
    });
    
    function getLocationOnObjectType() {
        MonthlyVisitViewerController.getAllLocationRecords(function (result, event) {
            debugger;
            console.log('--- result Object :' + result);
            
            $(result).each(function (i, e) {
                debugger;
                $("#pick-four").after('<option value="' + result[i] + '">' + result[i].Name + '</option>');
            });
            
        }, { escape: false });
    }
    
    function getUser() {
        debugger;
        selectedUser = $('#user-selectUser :selected').text();
        if (selectedUser != null && selecteLocation != null && selectedObject == 'Account') {
            MonthlyVisitViewerController.getRepAccounts(selectedUser, selecteLocation, function (accountList, event) {
                debugger;
                if (event.status) {
                    if (accountList.length == 0) {
                        $("#event-container").empty();
                        alert('No Account Records found.');
                    } else {
                        $("#event-container").empty();
                        $(accountList).each(function (i, e) {
                            $("#event-container").append(
                                '<div class="fc-event" data-accid="' + accountList[i].Id + '">' + accountList[i].Name + '</div>'
                            );
                        });
                        setEventDraggable();
                    }
                    
                } else {
                    console.log(result);
                    alert('Something went wrong');
                }
                $("#spinner").hide();
            });
        } else if (selectedUser != null && selecteLocation != null && selectedObject == 'Lead') {
            debugger;
            MonthlyVisitViewerController.getRepLeads(selectedUser, selecteLocation, function (accountList, event) {
                debugger;
                if (event.status) {
                    if (accountList.length == 0 && selectedUser != 'Select...') {
                        $("#event-container").empty();
                        alert('No Records found !');
                    } else {
                        $("#event-container").empty();
                        $(accountList).each(function (i, e) {
                            $("#event-container").append(
                                '<div class="fc-event" data-accid="' + accountList[i].Id + '">' + accountList[i].Name + '</div>'
                            );
                        });
                        setEventDraggable();
                    }
                    
                } else {
                    console.log(result);
                    alert('Something went wrong');
                }
                $("#spinner").hide();
            });
        }
    }
    
    $("#user-selectlocation").change(function () {
        debugger;
        selecteLocation = $('#user-selectlocation :selected').text();
        callGetUserData();
    });
    
    function callGetUserData() {
        debugger;
        MonthlyVisitViewerController.fetchGroupmemeber(selecteLocation, function (result, event) {
            debugger;
            if (event.status) {
                if (result.length > 0) {
                    for (var i = 0; i < result.length; i++) {
                        selectedUserId = result[i].Id;
                    }
                    $("#user-selectUser").empty();
                    var mySelect = $('#user-selectUser');
                    $(result).each(function (i, e) {
                        mySelect.append(
                            '<option value="' + result[i].Id + '">' + result[i].LastName + '</option>' + '<br>'
                        );
                    });
                    
                }
                console.log("User Record ::" + result);
                getUser();
            }
            else {
                alert("Something went wrong !")
            }
            
        }, { escape: false });
    }
    
    function updateDefaultRepAccounts(userId) {
        $("#event-container").hide();
        $("#search-pannel").hide();
        $("#search-account").hide();
        $("#upsert-visit").prop('disabled', true);
        $("#spinner").show();
        if (userId && userId !== "") {
            $("#event-container").show();
            $("#upsert-visit").prop('disabled', false);
            $("#search-account").show();
            MonthlyVisitViewerController.getUserVisits(userId, function (result, event) {
                selectedObject = $('#user-select :selected').text();
                // callLeadRecordMethod();
                debugger;
                if (event.status) {
                    //repVisits = [];
                    for (let i = 0; i < result.accountList.length; i++) {
                        let calVisit = {};
                        calVisit.id = result.accountList[i].Id;
                        calVisit.title = result.accountList[i].Name;
                        accMap.set(result.accountList[i].Id, result.accountList[i]);
                        //  calVisit.start = result.accountList[i].Planned_visit_date__c;
                        //  calVisit.end = result.accountList[i].Planned_visit_date__c;
                        repVisits.push(calVisit);
                    }
                    console.log(repVisits);
                    
                    $(result.accountList).each(function (i, e) {
                       
                        $("#event-container").append(
                            '<div class="fc-event" data-accid="' + result.accountList[i].Id + '">' + result.accountList[i].Name + '</div>'
                        );
                    });
                    setEventDraggable();
                    configureCalendar();
                } else {
                    alert('Something went wrong!');
                }
                $("#spinner").hide();
            });
        }
    }
    
    function setEventDraggable() {
        /* initialize the external events
        -----------------------------------------------------------------*/
        $('#external-events .fc-event').each(function () {
            // store data so the calendar knows to render an event upon drop
            $(this).data('event', {
                title: $.trim($(this).text()), // use the element's text as the event title
                stick: true // maintain when user navigates (see docs on the renderEvent method)
            });
            // make the event draggable using jQuery UI
            $(this).draggable({
                zIndex: 999,
                revert: true,      // will cause the event to go back to its
                revertDuration: 0  //  original position after the drag
            });
        });
        /* initialize the calendar
        -----------------------------------------------------------------*/
    }

    function getVisitKpis(selectedEvent) {
        console.log('SelectedEvent',selectedEvent)
        MonthlyVisitViewerController.showKpi(selectedEvent.id, function (result, event) {
            console.log('resultkpi',result)
            if (result || result.length>0){
                    
                    $("#kpi-radio").empty();
                    selectedEventKPIS = [];

                    result.forEach(res=>{
                        res.checked = selectedEvent.kpiId==res.Id;

                        var radioElement = $('<input>')
                        .attr({
                            type: 'radio',
                            id: res.Id,
                            value: res.Id,
                            checked: res.checked
                        })
                        .on('change', onKPIChange)
                        .appendTo('#kpi-radio');
    
                        $('<label>')
                            .attr('for', res.Id)
                            .text(res.KPI_Target_Name__c)
                            .appendTo('#kpi-radio');

                            $('</br>').appendTo('#kpi-radio');

                        selectedEventKPIS.push(res);
                       
                    });



                    $("#modal-heading-01").text(selectedEvent.title);
                    $("#myModal").show();
                 }
        });
    }


    let selectedKPIId = '';
    function onKPIChange(event){
        debugger;

        selectedKPIId = '';

        let checkedIndex = selectedEventKPIS.findIndex(item=>item.checked==true);
        let newSelectedKPIIndex = selectedEventKPIS.findIndex(item=>item.Id==event.target.id);

        if(checkedIndex!=-1){
            selectedEventKPIS[checkedIndex].checked = false;
        }

        selectedEventKPIS[newSelectedKPIIndex].checked = true;


        if(checkedIndex!=newSelectedKPIIndex){
            $("#save-kpi-btn").prop("disabled", false);
            selectedKPIId = selectedEventKPIS[newSelectedKPIIndex].Id;
        }


        $('#kpi-radio').empty();
        selectedEventKPIS.forEach(res=>{
            var radioElement = $('<input>')
            .attr({
                type: 'radio',
                id: res.Id,
                value: res.Id,
                checked: res.checked
            })
            .on('change', onKPIChange)
            .appendTo('#kpi-radio');

            $('<label>')
                .attr('for', res.Id)
                .text(res.KPI_Target_Name__c)
                .appendTo('#kpi-radio');

                $('</br>').appendTo('#kpi-radio');
                       
        });
        console.log('KPICHANGED---',event.target.id);
    }

     
    $("#save-kpi-btn").click(function () {
        debugger;
        tagKPIToVisit();
    });

    $(".close-modal").click(function() {
        $("#address-modal").hide();
    });

let selectedDate, selectedInstance;
let addressMap;
function handleAddressSelection(date, instance) {
    debugger;
    addressMap = new Map();
    selectedDate = date;
    selectedInstance = instance;
    $("#address-parent").empty();
    if(accMap.has($(instance).attr("data-accid"))) {
        let account = accMap.get($(instance).attr("data-accid"));
        console.log("Account selected-----",account);
        if(account && account.ShippingCity && account.ShippingCountry && account.ShippingState) {
            addressMap.set('999', {city: account.ShippingCity, country: account.ShippingCountry, lat: account.Geo_Location__Latitude__s, long: account.Geo_Location__Longitude__s, pCode: account.ShippingPostalCode, state: account.ShippingState, street: account.ShippingStreet});
            $("#address-parent").append('<span class="slds-radio"><input type="radio" id="999" value="999" name="address-radio" checked="" /><label class="slds-radio__label" for="999"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.ShippingCity+', <b>Country:</b> '+account.ShippingCountry+', <b>Pin-Code: </b>'+ account.ShippingPostalCode+', <b>State:</b> '+account.ShippingState+', <b>Street: </b> '+account.ShippingStreet+'</span></label></span>');
        }


        if(account && account.BillingCity && account.BillingCountry && account.BillingState) {
            addressMap.set('777', {city: account.BillingCity, country: account.BillingCountry, lat: account.Geo_Location__Latitude__s, long: account.Geo_Location__Longitude__s, pCode: account.BillingPostalCode, state: account.BillingState, street: account.BillingStreet});
            $("#address-parent").append('<span class="slds-radio"><input type="radio" id="777" value="777" name="address-radio" checked="" /><label class="slds-radio__label" for="777"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.BillingCity+', <b>Country:</b> '+account.BillingCountry+', <b>Pin-Code: </b>'+ account.BillingPostalCode+', <b>State:</b> '+account.BillingState+', <b>Street: </b> '+account.BillingStreet+'</span></label></span>');
        }
        if(account && account.Dispatch_Address__r) {
            for(let i = 0; i < account.Dispatch_Address__r.length; i++) {
                addressMap.set(i+"", {city: account.Dispatch_Address__r[i].Address__City__s, country: account.Dispatch_Address__r[i].Address__CountryCode__s, lat: account.Dispatch_Address__r[i].Geo_Location__latitude__s, long: account.Dispatch_Address__r[i].Geo_Location__c, pCode: account.Dispatch_Address__r[i].Address__PostalCode__s, state: account.Dispatch_Address__r[i].Address__StateCode__s, street: account.Dispatch_Address__r[i].Address__Street__s});
                $("#address-parent").append('<span class="slds-radio"><input type="radio" id="'+i+'" value="'+i+'" name="address-radio" checked="" /><label class="slds-radio__label" for="'+i+'"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.Dispatch_Address__r[i].Address__City__s+', <b>Country:</b> '+account.Dispatch_Address__r[i].Address__CountryCode__s+', <b>Pin-Code: </b>'+ account.Dispatch_Address__r[i].Address__PostalCode__s+', <b>State:</b> '+account.Dispatch_Address__r[i].State__c+', <b>Street: </b> '+account.Dispatch_Address__r[i].Street__c+'</span></label></span>');
            }
        }
    }
   
    $("#address-modal").show();
}


    function tagKPIToVisit(){
        MonthlyVisitViewerController.tagKIPToVisit(selectedEvent.id,selectedKPIId, function (result, event) {
            debugger;
            // toastr.success("Button has been enabled successfully!", "Success", {
            //     closeButton: true,
            //     progressBar: true,
            //     positionClass: "toast-top-right"
            // });
            $("#myModal").hide();
        });
    }


    // result.forEach(item=>{
    //     repVisits.push({ id: item.Id, start: item.Actual_visit_date__c,title:item.Account__r.Name});
    // })

    $("#save-event").click(function() {
        debugger;
        let radioId = $('input[name="address-radio"]:checked').val();
        if(radioId && addressMap && addressMap.has(radioId)) {
            //city: "Bengaluru", country: "India",lat: undefined,long: undefined,pCode: "560076",state: "Karnataka",street: "#SD3, Taj Regency, 7th Main, 12th cross"
            let addressObj = addressMap.get(radioId);
            let obj = { start : selectedDate._i, City__c: addressObj.city, Country__c: addressObj.country, Geo_Location__latitude__s: addressObj.lat, Geo_Location__longitude__s: addressObj.long, Postal_Code__c: addressObj.pCode, State__c: addressObj.state, Street__c: addressObj.street};
            AccountId = $(selectedInstance).attr("data-accid");
            let dateTime = visiteDateToApex.toISOString();
            addlat=addressObj.lat;
            addlong=addressObj.long;
            let apexDate = visiteDateToApex.toISOString();
            var startTimeValue = document.getElementById('time-input-id-47').value;
            var endTimeValue = document.getElementById('time-input-id-48').value;
            startTime=startTimeValue;
            endTime=endTimeValue;
            callVisitAccountCreateRecordMethod(AccountId,apexDate,addlat,addlong,startTime,endTime);
            console.log('LATLANG',obj);
            // if(selectedTab=='first'){
            //     obj.accountId = $(selectedInstance).attr("data-accid");
            // }else{
            //     debugger;
            //     obj.leadId = $(selectedInstance).attr("data-accid");
            // }

            // repVisits.push(obj);

            // console.log("Visit After saved----",repVisits);

            // // is the "remove after drop" checkbox checked?
            // if($('#drop-remove').is(':checked')) {
            //     // if so, remove the element from the "Draggable Events" list
            //     $(selectedInstance).remove();
            // }
            $("#address-modal").hide();
        }else {
            alert('something went wrong, please try again later');
        }
    });
});




