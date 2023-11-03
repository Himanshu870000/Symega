({
    doInit: function(component, event, helper) {
        var action = component.get("c.fetchAccountDetails");
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");
        //Console.log(currentUser);
        component.set("v.CurrentUserId",currentUser);
        
        action.setParams({
            AccId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                var departmentListName= [];
                var serverResponse = response.getReturnValue();
                component.set("v.emailId",serverResponse.Email);
                //component.set("v.TemplateName",serverResponse.emailTemplateList.Name);
                component.set("v.emailTemps",serverResponse.emailTemplateList);
                component.set("v.DepartmentList",serverResponse.DepartDetails);
                component.set("v.DepartmentMemberList",serverResponse.DepartMemberdetails);
                for(var i=0; i<serverResponse.DepartDetails.length; i++){
                    departmentListName.push(serverResponse.DepartDetails[i])
                }
                
                /*for(var i=0; i<serverResponse.emailTemplateName.length; i++){
                    component.set("v.selectedValue",serverResponse.emailTemplateName[0]);
                }*/
                var tempNamelist = [];
                for(var i=0; i<serverResponse.emailTemplateList.length; i++) {
                    tempNamelist.push(serverResponse.emailTemplateList[i].Name);
                    
                }
                
                component.set("v.TemplateName",tempNamelist);
                component.set("v.DepartmentName",departmentListName);
                
                
                for(var i=0;i<serverResponse.emailTemplateList.length;i++){
                    if(serverResponse.emailTemplateList[i].Name == component.get("v.selectedValue")){
                        component.set("v.subject", serverResponse.emailTemplateList[i].Subject);
                        component.set("v.myMessage", serverResponse.emailTemplateList[i].Body);
                        component.set("v.AccRecord", serverResponse.accRec);
                        
                    }   
                }
                let inputText = component.find("inpsummary").get("v.value");
                if(inputText != null){
                    component.set('v.isButtonActive',false);
                }
                else{
                    component.set('v.isButtonActive',true);
                }
            } else{
                debugger;
            }
        });
        $A.enqueueAction(action);
    },
    Send : function(component, event, helper) {
        debugger;
        //var email = helper._e('txtEmail').value;
        var emailChecked =  component.get('v.checkEmail');
       var email = component.get("v.emailId"); 
        var Subject = helper._e('txtSubject').value;
        var Message = component.get("v.myMessage");
        
      //  if(email==''){
      //      alert('Email-Id is required');
      //  }
     if(email =='')
     {
       alert('Email Should be Required');
      }
         if(Subject==''){
            alert('Subject is required');
        }
            else if(Message==''){
                alert('Message is required');
            }
                else{
                    helper.SendEmail(component);
                }
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
        if(emailTemplateSelected != null & emailTemplateSelected != "None" )
        {
            component.set('v.disablebutton',false);
        }
        else{
            component.set('v.disablebutton',true);
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
    },
    
    activeButton : function (component,event,helper){
        debugger;
        let inputText = component.find("inpsummary").get("v.checked");

        //var inputtextchecked = event.getSource().get('v.checked');
      //  if(inputText != null){
      //      component.set('v.isButtonActive',false);
      //  }    
      

       if(inputText == true)
       {
        component.set('v.checkEmail',true)
       }
       else{
        component.set('v.checkEmail',false)
       }   
    }
})