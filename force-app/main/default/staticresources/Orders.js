angular.module('cp_app').controller('order_ctrl', function ($scope,$rootScope, $log, $timeout) {
    
    $scope.Orders=[];
    $scope.customers=[];
    $rootScope.activeTab=4;
    $scope.customerSelected = 'All'
    $scope.viewOption='Table';
    $scope.orderDetails;

    $scope.order = {
        Name:'',
        Submitted_Date__c:'',
        Expected_Delivery_Date__c:'',
    };

    $scope.orderToUpdate = {};


    $scope.getOrders=function(){
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.getSalesOrders(candidateId,$scope.customerSelected,function(results,evt){
            //$scope.customers=results;
            $scope.Orders=results;
            $rootScope.showSpinner = false;
            $scope.$apply();  

            $('#orderTable').DataTable();

            console.log("Orders-----",$scope.Orders);
        })
    }

   

     $scope.getAllCustomer=function(){
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.getDistributionAllocation(candidateId,function(results,evt){
            if(results!==null){
            	results.forEach(customer=>{
                    if($scope.customers.find(item=>item.Id==customer.Customer_Account__r.Id)==null){
                        $scope.customers.push(customer.Customer_Account__r);
                    }
            	})    
            }
            $rootScope.showSpinner = false;
            $scope.$apply();  
        })
    }
	$scope.getAllCustomer();
    
    $scope.view=function(e){
        if($scope.viewOption==='Table') $('#example').DataTable();
        console.log($scope.viewOption)
        //$scope.apply();
    }

    $scope.showSalesOrderForm = false;

    $scope.visibleSalesOrderForm=function(){
        $scope.showSalesOrderForm=!$scope.showSalesOrderForm;
    }

    $scope.customerChangeHandler = function(e){
        console.log('customerSelected---',$scope.customerSelected);
        $scope.getOrders();
    }

    $scope.details=function(index){
        if(index==='close'){
            $scope.orderDetails=undefined;
            return;
        }
        $scope.orderDetails=$scope.Orders[index];
        console.log($scope.Orders[index])
    }

    $scope.invoiceSelected = function(invoice){
        $scope.orderDetails.invoiceSelected= invoice;
    }


    $scope.closeInvoice = function(){
        delete $scope.orderDetails.invoiceSelected;
        $scope.$apply();
    }

    $scope.editSalesOrder = function(index){
        $scope.orderToUpdate = $scope.Orders[index];
        if($scope.orderToUpdate.Expected_Delivery_Date__c){
            $scope.orderToUpdate.Expected_Delivery_Date__c = new Date($scope.orderToUpdate.Expected_Delivery_Date__c);
        }
        $scope.showSalesOrderForm = true;
        $scope.$apply();
    }

    $scope.updateSalesOrder = function(){
        console.log('SalesOrder Opp-----', $scope.orderToUpdate);

        if(!$scope.orderToUpdate.Name){
            Swal.fire('','Please Enter Sales Order Name','error');
            return;
        }
        if(!$scope.orderToUpdate.Amount__c){
            Swal.fire('','Please Enter Sales Order Amount','error');
            return;
        }
        if(!$scope.orderToUpdate.Order_quantity__c){
            Swal.fire('','Please Enter Order Quantity','error');
            return;
        }

      
        let obj = {
            id:$scope.orderToUpdate.Id,
            accId:$scope.orderToUpdate.Account__c,
            oppId:$scope.orderToUpdate.Opportunity__c,
            name:$scope.orderToUpdate.Name,
            customer:$scope.orderToUpdate.Distributer_Customer__c,
            quantity:$scope.orderToUpdate.Order_quantity__c,
            amount:$scope.orderToUpdate.Amount__c,
            //submittedDate:formatDate(new Date($scope.salesOrderObj.submittedDate)),
            expectedDate: $scope.orderToUpdate.Expected_Delivery_Date__c?formatDate(new Date($scope.orderToUpdate.Expected_Delivery_Date__c)):'',
            customerPoNumber:$scope.orderToUpdate.Customer_PO_Ref_no__c,
            remarks:$scope.orderToUpdate.Remarks__c,
            plant:$scope.orderToUpdate.Plant__c
        }


        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.updateSalesOrder(obj,function(results,evt){
            $rootScope.showSpinner = false;
            console.log('Result----',results);
            console.log('OBJ----',obj);

            if(results){
                $scope.orderToUpdate = {};
                $scope.visibleSalesOrderForm();
                Swal.fire('','Order Updated Successfully','success');
                $scope.getOrders();
            }else{
                Swal.fire('','Something went wrong!','error');
            }

            $scope.$apply();  
        })

    }

     function formatDate(date){
        return (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear();
    }
});