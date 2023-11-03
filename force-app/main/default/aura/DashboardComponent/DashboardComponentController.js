({
    doinit : function(component, event, helper){
        component.set("v.showtabOne",true);
    },
    ShowFirsttab :function(component, event, helper){
        
        
        component.set("v.showtabOne",true);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabfour",false);
        component.set("v.showtabfive",false);
    },
    ShowSecondtab :function(component, event, helper){
        
        
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",true);
        component.set("v.showtabthree",false);
        component.set("v.showtabfour",false);
        component.set("v.showtabfive",false);
        
    },
    Showthirdtab :function(component, event, helper){
        
        
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",true);
        component.set("v.showtabfour",false);
        component.set("v.showtabfive",false);
        
    },
    Showfourtab :function(component, event, helper){
        
        
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabfour",true);
        component.set("v.showtabfive",false);
        
    },
    Showfivetab :function(component, event, helper){
        
        
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabfour",false);
        component.set("v.showtabfive",true);
        
    },
})