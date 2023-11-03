//https://www.youtube.com/watch?v=jMjp_59Tq8E
$(document).ready(function() {

    let repVisits = [];
    let selectedEvent; 
    let selectedTab = 'first';

    let accMap = new Map();
    let configureCalendar = function() {
        
            //repVisits = result.eventList;
            $("#calendar").fullCalendar('removeEvents'); 
            $("#calendar").fullCalendar('addEventSource', repVisits);
            //$('#calendar-card').show();
    }

    VisitSchedulerController.fetchPageData(function(result, event){
            console.log('--- result',result);
            debugger;
            //$('#calendar-card').hide();
            if(event.status) {
                $('#calendar').fullCalendar({
                    header: {
                        left: 'prev,next today',
                        center: 'title',
                        right: 'month,agendaWeek,agendaDay'
                    },
                    themeSystem: "standard",
                    defaultDate: new Date(),
                    navLinks: true,
                    editable: false,
                    eventLimit: true,
                    events: repVisits,
                    dragScroll: true,
                    droppable: true,
                    weekNumbers: true,
                    eventDrop: function (event, delta, revertFunc) {
                        debugger;
                        alert(event.title + " was dropped on " + event.start.format());
                        if (!confirm("Are you sure about this change? ")) {
                            revertFunc();
                        }else {
                            $.each(repVisits, function(i,visit) {
                                if (visit.id === event.id) {
                                    repVisits[i].start = event.start._d.getTime(); 
                                }   
                                console.log(repVisits[i]); 
                            });
                        }
                    },
                    eventClick: function (event, jsEvent, view) {
                        debugger;
                        if(event.status === 'PENDING' && event.start._d > new Date()) {
                            selectedEvent = event;
                            $("#modal-heading-01").text(event.title);
                            $("#event-modal").show();
                        }
                    },
                    dayClick: function (date, jsEvent, view) {
                        jsEvent.preventDefault();
                    },
                    drop: function(date, jsEvent) {
                        debugger;
                        if(selectedTab=='first'){
                            handleAddressSelection(date, this);
                        }else{
                            handleLeadAddressSelection(date, this);
                        }
                        
                    },
                    eventRender: function(event, element) {         
                        if(event.status === 'PENDING') {
                            element.find(".fc-content").css('background-color', '#15c05c');
                            element.find(".fc-day-grid-event").css('border-color','#15c05c !important');
                            element.find(".fc-bg").css('border','1px solid #15c05c');
                            element.find(".fc-day-grid-event").css('background-color','#15c05c !important');
                            element.css('border', '#15c05c');
                        }else if(event.status === 'INPROGRESS') {
                            element.find(".fc-content").css('background-color', 'orange');
                            element.find(".fc-day-grid-event").css('border-color','orange !important');
                            element.find(".fc-bg").css('border','1px solid orange');
                            element.find(".fc-day-grid-event").css('background-color','orange !important');
                            element.css('border', 'orange');
                        }else if(event.status === 'COMPLETED') {
                            element.find(".fc-content").css('background-color', '#4a4a4a');
                            element.find(".fc-bg").css('border','1px solid #4a4a4a');
                            element.find(".fc-day-grid-event").css('border-color','#4a4a4a !important');
                            element.find(".fc-day-grid-event").css('background-color','#4a4a4a !important');
                            element.css('border', '#4a4a4a');
                        } else if(event.status === 'LAPSE') {
                            element.find(".fc-content").css('background-color', 'red');
                            element.find(".fc-bg").css('border','1px solid #4a4a4a');
                            element.find(".fc-day-grid-event").css('border-color','red !important');
                            element.find(".fc-day-grid-event").css('background-color','red !important');
                            element.css('border', 'red');
                        }       
                    },
                    eventConstraint: {
                        start: moment().format('YYYY-MM-DD'),
                        end: '2100-01-01' // hard coded goodness unfortunately
                    },
                    validRange: function(nowDate) {
                        return {
                            start: nowDate,
                            end: nowDate.clone().add(6, 'months')
                        };
                    },
                });
               

                $(result.salesRepList).each(function(i, e) {
                    $("#pick-none").after('<option value="'+result.salesRepList[i].Id+'">'+result.salesRepList[i].FirstName+' '+result.salesRepList[i].LastName+'</option>');
                });

                if(!result.allowedProfiles){
                    $('#user-select option[value="'+result.currentUserId+'"]').attr("selected", "selected");
                   $('#user-select').prop('disabled', !result.allowedProfiles);

                    if(result.currentUserId == undefined || result.currentUserId === "" || result.currentUserId === "Select...")
                        $("#upsert-visit").prop('disabled', true);
                    $("#event-container").empty();
                    updateDefaultRepAccounts(result.currentUserId);
                }
                
                console.log("OOOOPPPPPP======",result.allowedProfiles);
            }
            $("#spinner").hide();
    },{escape:false});

    $("#upsert-visit").click(function() {
        debugger;
        $("#spinner").show();
        var salesRep = $('#user-select').find(":selected").val();
        if(salesRep && repVisits && repVisits.length > 0) {
            let visits = [],visit;
            for(let i=0; i< repVisits.length; i++) {
                console.log('Visit----',repVisits[i]);
                visit = {};
                visit.id = repVisits[i].id;
                //visit.Name = repVisits[i].title;
                if(repVisits[i].accountId){
                    visit.Account__c = repVisits[i].accountId;
                }else if(!repVisits[i].id && repVisits[i].leadId){
                    debugger;
                    visit.Lead__c = repVisits[i].leadId;
                }
                visit.Planned_visit_date__c = repVisits[i].start;
                visit.Assigned_User__c = salesRep;
                visit.City__c = repVisits[i].City__c;
                visit.Country__c = repVisits[i].Country__c;
                visit.Geo_Location__latitude__s = repVisits[i].Geo_Location__latitude__s;
                visit.Geo_Location__longitude__s = repVisits[i].Geo_Location__longitude__s;
                visit.Postal_Code__c = repVisits[i].Postal_Code__c;
                visit.State__c = repVisits[i].State__c;
                visit.Street__c = repVisits[i].Street__c;
                visits.push(visit);
            }

            console.log("visits----",visits);
            VisitSchedulerController.createVisits(visits, function(result, event){
                console.log('--- result'+result);
                debugger;
                if(event.status) {
                    console.log('event created successfully');
                }
                $("#spinner").hide();
            },{escape:false});
        }
        else {
            $("#spinner").hide();
            alert('Please select visit inorder to create.');
        }
        
    });

    $("#search-account").click(function() {
        $("#search-pannel").toggle();
    });

    $("#search-dealer").click(function() {
        debugger;
        let userId = $( "#user-select option:selected" ).val();
        if(userId == undefined || userId === "") {
            alert('Please select sales rep in-order to search');
            return;
        }
        var searchString = $('#search-box').val();
        if(searchString == undefined || searchString.length < 3) {
            alert('You need to provide at least 3 characters to search.');
            return;
        }
        $("#spinner").show();
        getDealersOrLeads(userId,searchString);
    });

    function getDealersOrLeads(userId,searchString){
        debugger;
        if(selectedTab=='first'){
            VisitSchedulerController.getRepAccounts(userId,searchString,selectedTab, function(accountList, event) {
                if(event.status) {
                    debugger;
                    if(accountList && accountList.length == 0) {
                        alert('No accounts found.');
                    }else {
                        $("#event-container").empty();
                        $(accountList).each(function(i, e) {
                            accMap.set(accountList[i].Id, accountList[i]);
                            $("#event-container").append(
                                '<div class="fc-event" data-accid="'+accountList[i].Id+'">'+accountList[i].Name+'</div>'
                            );
                        });
                        setEventDraggable();
                    }
    
                }else {
                    console.log(result);
                    alert('Something went wrong');
                }
                $("#spinner").hide();
            });
        }else{
            VisitSchedulerController.getRepLeads(userId,searchString, function(accountList, event) {
                if(event.status) {
                    console.log('AccList------',accountList);
                    debugger;
                    if(accountList && accountList.length == 0) {
                        alert('No accounts found.');
                    }else {
                        $("#event-container").empty();
                        $(accountList).each(function(i, e) {
                            accMap.set(accountList[i].Id, accountList[i]);
                            $("#event-container").append(
                                '<div class="fc-event" data-accid="'+accountList[i].Id+'">'+accountList[i].Name+'</div>'
                            );
                        });
                        setEventDraggable();
                    }
    
                }else {
                    console.log(result);
                    alert('Something went wrong');
                }
                $("#spinner").hide();
            });
        }
    }

    $("#clear-dealer").click(function() {
        $('#search-box').val("");
        $("#event-container").empty();
        updateDefaultRepAccounts($("#user-select option:selected").val());
    });

    $("#dealersTab").click(function(){        
        debugger;
        selectedTab = 'first';
        console.log('USERSELECTED----',$("#user-select option:selected").val());
        $('#search-account').show();
        $('#dealersTab').addClass('slds-button slds-button_brand');
        $('#leadTab').removeClass('slds-button slds-button_brand');
        $('#leadTab').addClass('slds-button slds-button_neutral');
        getDealersOrLeads($("#user-select option:selected").val(),'');
    })

    $("#leadTab").click(function(){
        debugger;
        console.log('USERSELECTED----',$("#user-select option:selected").val());
        selectedTab = 'second';
        $('#search-account').show();
        $('#leadTab').removeClass('slds-button slds-button_neutral');
        $('#leadTab').addClass('slds-button slds-button_brand');
        $('#dealersTab').removeClass('slds-button slds-button_brand');
        $('#dealersTab').addClass('slds-button slds-button_neutral');
        getDealersOrLeads($("#user-select option:selected").val(),'');
    })

    $("#delete-event").click(function() {
        debugger;
        if(selectedEvent) {
            if(selectedEvent.id) {
                $("#spinner").show();
                VisitSchedulerController.deleteEvent(selectedEvent.id, function(result, event) {
                    if(event.status) {
                        $("#calendar").fullCalendar('removeEvents',selectedEvent._id);
                    }else {
                        alert('Something went wrong, please contact system admin.');
                    }
                    $('#event-modal').hide();
                    $("#spinner").hide();
                });
            }else {
                $("#calendar").fullCalendar('removeEvents',selectedEvent._id);
                $('#event-modal').hide();
            }
        }
    });

    $(".close-modal").click(function(){
        console.log(selectedEvent);
        $('#event-modal').hide();
    });

    $("#user-select").change(function(){
        let userId = $(this).children("option:selected").val();
        if(userId == undefined || userId === "" || userId === "Select...")
            $("#upsert-visit").prop('disabled', true);
        $("#event-container").empty();
        updateDefaultRepAccounts(userId);
    });

    $(".close-modal").click(function() {
        $("#address-modal").hide();
    });

    function updateDefaultRepAccounts(userId) {

        $("#event-container").hide();
        $("#search-pannel").hide();
        $("#search-account").hide();
        $("#upsert-visit").prop('disabled', true);
        $("#spinner").show();
        if(userId && userId !== "") {
            $("#event-container").show();
            $("#upsert-visit").prop('disabled', false);
            $("#search-account").show();
            VisitSchedulerController.getUserVisits(userId, function(result, event) {
                debugger;
                if(event.status) {
                    
                    repVisits = [];
                    for(let i=0; i < result.visitList.length; i++) {
                        let calVisit = {};
                        calVisit.id = result.visitList[i].Id;
                        calVisit.title = result.visitList[i].Account__r?result.visitList[i].Account__r.Name:result.visitList[i].Lead__r.Name;
                        calVisit.start = result.visitList[i].Planned_visit_date__c;
                        calVisit.end = result.visitList[i].Planned_visit_date__c;
                        calVisit.status = result.visitList[i].Status__c;
                        repVisits.push(calVisit);
                    }
                    console.log(repVisits);

                    $(result.accountList).each(function(i, e) {
                        accMap.set(result.accountList[i].Id, result.accountList[i]);
                        $("#event-container").append(
                            '<div class="fc-event" data-accid="'+result.accountList[i].Id+'">'+result.accountList[i].Name+'</div>'
                        );
                    });
                    setEventDraggable();
                    configureCalendar();
                }else {
                    alert('Something went wrong!');
                }
                $("#spinner").hide();
            });
        }
    }

    function setEventDraggable() {
        /* initialize the external events
        -----------------------------------------------------------------*/
        $('#external-events .fc-event').each(function() {
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
                addressMap.set('999', {city: account.ShippingCity, country: account.ShippingCountry, lat: account.ShippingLatitude, long: account.ShippingLongitude, pCode: account.ShippingPostalCode, state: account.ShippingState, street: account.ShippingStreet});
                $("#address-parent").append('<span class="slds-radio"><input type="radio" id="999" value="999" name="address-radio" checked="" /><label class="slds-radio__label" for="999"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.ShippingCity+', <b>Country:</b> '+account.ShippingCountry+', <b>Pin-Code: </b>'+ account.ShippingPostalCode+', <b>State:</b> '+account.ShippingState+', <b>Street: </b> '+account.ShippingStreet+'</span></label></span>');
            }


            if(account && account.BillingCity && account.BillingCountry && account.BillingState) {
                addressMap.set('777', {city: account.BillingCity, country: account.BillingCountry, lat: account.BillingLatitude, long: account.BillingLongitude, pCode: account.BillingPostalCode, state: account.BillingState, street: account.BillingStreet});
                $("#address-parent").append('<span class="slds-radio"><input type="radio" id="777" value="777" name="address-radio" checked="" /><label class="slds-radio__label" for="777"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.BillingCity+', <b>Country:</b> '+account.BillingCountry+', <b>Pin-Code: </b>'+ account.BillingPostalCode+', <b>State:</b> '+account.BillingState+', <b>Street: </b> '+account.BillingStreet+'</span></label></span>');
            }
            if(account && account.Dispatch_Address__r) {
                for(let i = 0; i < account.Dispatch_Address__r.length; i++) {
                    addressMap.set(i+"", {city: account.Dispatch_Address__r[i].City__c, country: account.Dispatch_Address__r[i].Country__c, lat: account.Dispatch_Address__r[i].Geo_Location__latitude__s, long: account.Dispatch_Address__r[i].Geo_Location__longitude__s, pCode: account.Dispatch_Address__r[i].Postal_Code__c, state: account.Dispatch_Address__r[i].State__c, street: account.Dispatch_Address__r[i].Street__c});
                    $("#address-parent").append('<span class="slds-radio"><input type="radio" id="'+i+'" value="'+i+'" name="address-radio" checked="" /><label class="slds-radio__label" for="'+i+'"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.Dispatch_Address__r[i].City__c+', <b>Country:</b> '+account.Dispatch_Address__r[i].Country__c+', <b>Pin-Code: </b>'+ account.Dispatch_Address__r[i].Postal_Code__c+', <b>State:</b> '+account.Dispatch_Address__r[i].State__c+', <b>Street: </b> '+account.Dispatch_Address__r[i].Street__c+'</span></label></span>');
                }
            }
        }
        $("#address-modal").show();
    }

    
    function handleLeadAddressSelection(date, instance) {
        debugger;
        addressMap = new Map();
        selectedDate = date;
        selectedInstance = instance;
        $("#address-parent").empty();
        if(accMap.has($(instance).attr("data-accid"))) {
            let account = accMap.get($(instance).attr("data-accid"));
            console.log("Account selected-----",account);
            if(account && account.City && account.Country && account.State) {
                addressMap.set('999', {city: account.City, country: account.Country, lat: account.Latitude, long: account.Longitude, pCode: account.PostalCode, state: account.State, street: account.Street});
                $("#address-parent").append('<span class="slds-radio"><input type="radio" id="999" value="999" name="address-radio" checked="" /><label class="slds-radio__label" for="999"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.City+', <b>Country:</b> '+account.Country+', <b>Pin-Code: </b>'+ account.PostalCode+', <b>State:</b> '+account.State+', <b>Street: </b> '+account.Street+'</span></label></span>');
            }
        }
        $("#address-modal").show();
    }

    $("#save-event").click(function() {
        let radioId = $('input[name="address-radio"]:checked').val();
        if(radioId && addressMap && addressMap.has(radioId)) {
            //city: "Bengaluru", country: "India",lat: undefined,long: undefined,pCode: "560076",state: "Karnataka",street: "#SD3, Taj Regency, 7th Main, 12th cross"
            let addressObj = addressMap.get(radioId);
            let obj = { start : selectedDate._i, City__c: addressObj.city, Country__c: addressObj.country, Geo_Location__latitude__s: addressObj.lat, Geo_Location__longitude__s: addressObj.long, Postal_Code__c: addressObj.pCode, State__c: addressObj.state, Street__c: addressObj.street};


            console.log('LATLANG',obj);
            if(selectedTab=='first'){
                obj.accountId = $(selectedInstance).attr("data-accid");
            }else{
                debugger;
                obj.leadId = $(selectedInstance).attr("data-accid");
            }

            repVisits.push(obj);

            console.log("Visit After saved----",repVisits);

            // is the "remove after drop" checkbox checked?
            if($('#drop-remove').is(':checked')) {
                // if so, remove the element from the "Draggable Events" list
                $(selectedInstance).remove();
            }
            $("#address-modal").hide();
        }else {
            alert('something went wrong, please try again later');
        }
    });
});