({
	/*doInit : function(component, event, helper) {
        debugger;
        let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let date=new Date();
        let year=date.getFullYear();
        let month=date.getMonth();
        let MonthName=monthNames[date.getMonth()];
        var action = component.get('c.getAllDateOfTravelDayVisitPlan');
        action.setParams({ 
            month:MonthName,
            year:year
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                var data = response.getReturnValue();
                if(data.dayVisitPlanList !=null && data.dayVisitPlanList.length >0){
                    var resultdata = data.dayVisitPlanList;
                    component.set("v.dataList",resultdata);
                   // alert(JSON.stringify(data.dayVisitPlanList)) 
                }
            }
        });
        $A.enqueueAction(action);
    },*/
    
    travelTableDataEvent : function(component, event, helper){
        debugger;
        /*var MonthName = event.getParam("Month");
        var year = event.getParam("Year"); 
        var action = component.get('c.getMonthlyRecord');
        action.setParams({ 
            month:MonthName,
            year:year
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                var data = response.getReturnValue();
                if(data !=null && data.length >0){
                    var resultdata = data;
                    component.set("v.dataList",resultdata);
                   // alert(JSON.stringify(data.dayVisitPlanList)) 
                }
            }
        });
        $A.enqueueAction(action);*/
        
        var dataList = event.getParam("dataList");
        component.set('v.dataList', dataList);
        
    }
})