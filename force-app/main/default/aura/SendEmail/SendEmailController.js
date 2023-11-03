({
    doInit: function(component, event, helper) {
        var action = component.get("c.fetchOpportunityDetails");
        action.setParams({
            OppId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                var departmentListName= [];
                var serverResponse = response.getReturnValue();
                component.set("v.emailId",serverResponse.Email);
                component.set("v.TemplateName",serverResponse.emailTemplateName);
                component.set("v.emailTemps",serverResponse.emailTemplateList);
                component.set("v.DepartmentList",serverResponse.DepartDetails);
                component.set("v.DepartmentMemberList",serverResponse.DepartMemberdetails);
                for(var i=0; i<serverResponse.DepartDetails.length; i++){
                    departmentListName.push(serverResponse.DepartDetails[i])
                }
                
                /*for(var i=0; i<serverResponse.emailTemplateName.length; i++){
                    component.set("v.selectedValue",serverResponse.emailTemplateName[0]);
                }
                
                for(var i=0; emailTemplateList.length; i++){
                    if(emailTemplateList[i].Name == selectedValue){
                        component.set("v.myMessage",serverResponse.emailTemplateList[i].body);
                    }
                }*/
                component.set("v.DepartmentName",departmentListName);
                
              
                for(var i=0;i<serverResponse.emailTemplateList.length;i++){
                    if(serverResponse.emailTemplateList[i].Name == component.get("v.selectedValue")){
                        component.set("v.subject", serverResponse.emailTemplateList[i].Subject);
                        component.set("v.myMessage", serverResponse.emailTemplateList[i].Body);
                        component.set("v.OppRecord", serverResponse.OppRec);
                        
                    }   
                }
            } else{
                debugger;
            }
        });
        $A.enqueueAction(action);
    },
    Send : function(component, event, helper) {
        debugger;
        var email = component.find("inpsummary").get("v.value");
        //var email=helper._e('txtEmail').value;
        var Subject=helper._e('txtSubject').value;
        var Message=component.get("v.myMessage");
        
        if(email==''){
            alert('Email-Id is required');
        }
        else if(Subject==''){
            alert('Subject is required');
        }
            else if(Message==''){
                alert('Message is required');
            }
                else{
                    /*if(!email.match(regExpEmailformat)){
                        alert("Invalid Email Id");
                    }
                    else{
                      */ helper.SendEmail(component);
                }
    },
    
    showSpinner: function(component, event, helper) {        
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){        
        component.set("v.Spinner", false);
    },
    onChange: function (component,event,helper) {
        debugger;
        var emailTemplateSelected = component.find('select').get('v.value');
        var emailTemplateList = component.get("v.emailTemps");
        for(var i=0;i<emailTemplateList.length;i++){
            if(emailTemplateList[i].Name == emailTemplateSelected){
                component.set("v.subject", emailTemplateList[i].Subject);
                component.set("v.myMessage", emailTemplateList[i].Body);
            }   
        }
    },
    
    onChangeDepart: function (component,event,helper) {
        debugger;
        var DepartmentSelected = component.find('selectDepart').get('v.value');
        var DepartmentWholeList = component.get("v.DepartmentList");
        var DepartmentSelectedId;
        for(var i=0; i<DepartmentWholeList.length; i++){
            if(DepartmentWholeList[i].Name == DepartmentSelected){
                DepartmentSelectedId = DepartmentWholeList[i].Id;
            }
        }
        var Departmembers = component.get("v.DepartmentMemberList");
        var SelectedDepartmentMembers = [];
        for(var i=0;i<Departmembers.length;i++){
            if(Departmembers[i].Department__c == DepartmentSelectedId){
                //SelectedDepartmentMembers.push(Departmembers[i].Contact_First_Name__c + ' ' + Departmembers[i].Contact_Last_Name__c)
                SelectedDepartmentMembers.push({'label': Departmembers[i].Contact_First_Name__c + ' ' + Departmembers[i].Contact_Last_Name__c,'value':Departmembers[i].Contact_Email__c });
            }   
        }
        component.set("v.options", SelectedDepartmentMembers);
    },
    
    handleSelectedMember : function (component,event,helper){
        debugger;
        //Get the Selected values 
        var selectedValues = event.getParam("value");
        //Update the Selected Values  
        component.set("v.selectedMemberList", selectedValues);
    }
})