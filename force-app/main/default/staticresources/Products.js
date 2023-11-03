angular.module('cp_app').controller('products_ctrl', function ($scope,$rootScope, $log, $timeout) {
    
    $scope.products=[];
    $rootScope.activeTab = 1;
    $scope.viewOption='Table';
    $scope.productDetails;

    let prodList = [];

    
    $scope.getAllProducts=function(){
        $rootScope.showSpinner = true;
        
        DistributorDashboard_Controller.getSalesProducts(candidateId,function(results,evt){
            console.log(results.length)
            $scope.products=results;
            $rootScope.showSpinner = false;
            $scope.$apply();
            $('#example').DataTable();
            
        })
        
    }
    $scope.view=function(e){
        if($scope.viewOption==='Table') $('#example').DataTable();
        
        $scope.$apply();
    }
    
    $scope.closeProdDetail = function(){
        $('#example').DataTable();
        $scope.productDetails = null;

        //    $scope.$apply();
    }

    
    $scope.details=function(index){
        $scope.productDetails =$scope.products[index];
        console.log($scope.productDetails);
    }
    
})