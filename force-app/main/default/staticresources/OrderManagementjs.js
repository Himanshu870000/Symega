var app=angular.module('myapp',[]);
app.controller('myctrl',function($scope){
    
    $scope.productlist=[];
    $scope.searchList = [];
    $scope.recentList = [];
    $scope.alertRole = false;
    $scope.placeOrder = true;
    $scope.cartItemBtn = false;
    $scope.accId = accId;
    $scope.visitId = visitId;
    $scope.searchproduct=function(){
        debugger;
        $scope.productlist=[]; 
        $scope.allProd = true;
        $scope.searchResult = '';
        OrderManagementController.products('01s5g000007udhm',function(result,event){
            if(event.status){
                $scope.productlist=result;
                for(var key=0;key<10;key++){
                    if(key != 'remove'){
                        $scope.recentList.push($scope.productlist[key]); 
                    }
                    
                }
                $scope.$apply();
            }
            else if (event.type==='exception'){
                alert(event.message);
            }else{
                alert(event.message);
            }
        },
                                           {escape:true}
                                          );
    } 
    $scope.searchproduct();//constructor to load data on pageload
    
    $scope.productquantity =0;
    
    //function to create list of items added to cart
    $scope.selecteditemlist=[];
    //  $scope.quants=quant;
    $scope.addtocart=function(param,quant){
        //alert(param);
        debugger;
        console.log('quant::'+quant);
        $scope.productquantity++;
        //alert("Item Added to Cart,press Submit to Proceed");
        var items=$scope.productlist[param];
        
        $scope.selecteditemlist.push(items);
        $scope.placeOrder = true;
        $scope.cartItemBtn = true;
    }
    
    $scope.removeItem = function(param){
        debugger;
        console.log('param'+param);
        $scope.selecteditemlist.splice(param, 1);
        if($scope.selecteditemlist.length == 0){
            $scope.placeOrder = false;
            $scope.cartItemBtn = false;
            $scope.productquantity = 0;
        }
    }
    
    $scope.myProduct= 	true;
    $scope.mycart	= 	false;
    //to hide all products div and display added cart div
    $scope.showproductcart = function(){
        debugger;
        $scope.myProduct= 	false;
        $scope.mycart	= 	true;
        if($scope.selecteditemlist.length == 0){
            $scope.placeOrder = false;
        }
    }
    
    $scope.cancelCartItem = function(){
        $scope.mycart	= 	false;
    }
    $scope.searchProduct = function(param){
        debugger;
        if(param == '')
            $scope.allProd = true;
        else
            $scope.allProd = false;
        $scope.alertRole = false;
        $scope.searchList = [];
        console.log('param::'+param);
        for(var key in $scope.productlist){
            if(key != 'remove'){
                if($scope.productlist[key].Name.toLowerCase().includes(param.toLowerCase())){
                    $scope.searchList.push($scope.productlist[key]);
                }
            }
        }
        if(param != '' && $scope.searchList.length == 0){
            $scope.alertRole = true;
        }
        console.log('$scope.searchList::'+$scope.searchList);
    }
    
    
    $scope.backToDealerPage = function(){
        let mainURL = window.location.origin+'/apex';
        window.location.replace(mainURL + "/StartVisit?id="+$scope.accId+"&vistId="+$scope.visitId);
    }
    $scope.insertOrderItem = [];
    $scope.pricebookEntryid = [];
    
    $scope.insertorderItem=function(){
        debugger;
        for(var i=0;i<$scope.selecteditemlist.length;i++){
            delete $scope.selecteditemlist[i]['$$hashKey'];
            $scope.pricebookEntryid.push($scope.selecteditemlist[i].Product2Id);
            $scope.insertOrderItem.push($scope.selecteditemlist[i]);
        }
        OrderManagementController.pricebookEntry($scope.pricebookEntryid,function(result,event){
            debugger;
            if (result,event){
                if(result != null){
                    for(var key in $scope.insertOrderItem){
                        if(key != 'remove'){
                            for(var rkey in result){
                                if(key != 'remove'){
                                    if(result[rkey].Product2Id == $scope.insertOrderItem[key].Product2Id){
                                        $scope.insertOrderItem[key].id = result[rkey].id;
                                    }
                                }
                            }
                        }
                    }
                    
                    OrderManagementController.insertOrderItemS($scope.insertOrderItem,$scope.accId, function(result,event){
                        debugger;
                        if (result,event){
                            if(result != null){
                                Swal.fire('Your order has been placed. Please note the order number : '+ result);
                                Swal.fire({title:'Order Placed',text:'Your product has been placed. Please refer order number for future : '+ result},
                                          function(isConfirm) {
                                              let mainURL = window.location.origin+'/apex';
                                              window.location.replace(mainURL + "/StartVisit?id="+$scope.accId);
                                              $scope.$apply();
                                          })
                            }
                            //  alert("order item has been Inserted");
                        }else if (event.type==='exception'){
                            alert(event.message);
                        }else{
                            alert(event.message);
                        }
                    },
                                                               {escape:true}
                                                              );
                }
            }
        },
                                                 {escape:true}
                                                );
        console.log('selected item::'+$scope.selecteditemlist);
        
    }	
    
    
});