angular.module('cp_app').controller('case_ctrl', function ($scope,$rootScope, $log, $timeout) {
    
    let casesCopy = [];
    $scope.cases=[];
    $rootScope.activeTab = 5;
    $scope.showCaseForm;
    $scope.customers=[];
    $scope.customerSelected = 'All'
    $scope.viewOption='Table';
    $scope.detailCase;
    $scope.isEdit = false;

    $scope.createCase={
        Origin:'Distributor Portal',
        Status:'New',
        Type:'select',
        Priority:'select',
        Subject:'',
        Description:'',
        AccountId:'',
        Reason:'select',
        Distributer_Customer__c:'select'
    }
    
    $scope.getAllCustomer=function(){
        $rootScope.showSpinner = true;
        debugger;
        DistributorDashboard_Controller.getDistributionAllocation(candidateId,function(results,evt){
            //$scope.customers=results;
            results.forEach(customer=>{
                if($scope.customers.find(item=>item.Id==customer.Customer_Account__r.Id)==null){
                    $scope.customers.push(customer.Customer_Account__r);
                }
            })
           
            $rootScope.showSpinner = false;
            $('#example').DataTable();
            $scope.$apply();  
        })
    }

  
    $scope.getCases=function(){
        $rootScope.showSpinner = true;
        debugger;
        DistributorDashboard_Controller.getCases(candidateId,$scope.customerSelected,function(results,evt){
            $scope.cases=results;
            casesCopy = results;

            console.log('CASES----',casesCopy);
            $rootScope.showSpinner = false;
            $scope.$apply();
        })
    }

	$scope.details=function(index){
	    $scope.detailCase=$scope.cases[index];
    }

    $scope.createCaseForm=function(){
        $scope.showCaseForm=!$scope.showCaseForm;
    }
    
    $scope.customerChangeHandler = function(customer){
        console.log('customerSelected---',customer);
        debugger;

         if(customer!=='All'){
            $scope.cases= casesCopy.filter(opp=>{
                console.log('COPP---',opp);
                if(opp.Distributer_Customer__c===customer){
                    return opp;
                }
            }); 
            
            if($scope.cases[0]==null){
                $scope.cases = [];
            }
        }else{
            $scope.cases = casesCopy;
        }
    }

    let selectedCases
    $scope.editClicked = function(index){
        $scope.isEdit = true;
        let obj = $scope.cases[index];
        selectedCases = $scope.cases[index];

        //delete obj.Account;
        delete obj.CurrencyIsoCode;
       
        debugger;

        if(obj.Reason){
            obj.Reason = obj.Reason.replace('&#39;',"'")
        }
        $scope.createCase = obj;

        console.log('CreateCases----',$scope.createCase);
        $scope.showCaseForm=!$scope.showCaseForm;
        $scope.$apply();
    }

	$scope.submitCase=function(){
       
        $scope.createCase.AccountId = candidateId;
         
        console.log('createCase',$scope.createCase);

        if($scope.createCase.Origin=='select'){
            Swal.fire('Please select Origin', '', 'error');
            return;
        }
        if($scope.createCase.Type=='select'){
            Swal.fire('Please select Type', '', 'error');
            return;
        }
        if($scope.createCase.Priority=='select'){
            Swal.fire('Please select Priority', '', 'error');
            return;
        }
        if($scope.createCase.Reason=='select'){
            Swal.fire('Please select Reason', '', 'error');
            return;
        }

        if($scope.createCase.Distributer_Customer__c=='select'){
            delete $scope.createCase.Distributer_Customer__c;
        }

        $rootScope.showSpinner = true;  
        DistributorDashboard_Controller.createCase($scope.createCase,function(result,evt){
            if(result===true){
                $scope.showCaseForm=!$scope.showCaseForm;
                swal(`${$scope.isEdit?'Case updated successfully.':'Case created successfully.'}`);

                if($scope.isEdit){
                    $scope.isEdit=false;
                }
                
                $rootScope.showSpinner = false;
                $scope.createCase={
                    Origin:'select',
                    Status:'New',
                    Type:'select',
                    Priority:'select',
                    Subject:'',
                    Description:'',
                    AccountId:'',
                    Reason:'select',
                    Distributer_Customer__c:'select'
                }
                $scope.getCases();
            }
        })
    }
})