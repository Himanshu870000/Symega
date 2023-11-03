angular.module('cp_app').controller('customers_ctrl', function ($scope,$rootScope, $log, $timeout) {
    
    $scope.customers=[];
    $rootScope.activeTab = 2;
    $scope.viewOption='Table';
    $scope.showForm=false;
    $scope.directCustomers=[];
    $scope.customerDetailsshow;
    $scope.customerDetails={
        Customer_Account__c:'select'
    }
    
    $scope.account={
        Name:'',
        Email__c:'',
        Phone:'',
        GST_number__c:'',
        PAN_Number__c:'',
        Currency__c:'--None--',
        Payment_terms__c:'--None--',
        Delivery_Plant__c:'--None--',
        Customer_Type__c:'--None--',
        Account_Segment__c:'--None--',
        Tax_Type__c:'--None--',
        Transportation_Terms__c:'--None--',
        Tax_Collected_At_Source__c:'--None--',

        ShippingCountry:'',
        ShippingStreet:'',
        ShippingCity:'',
        ShippingState:'',
        ShippingPostalCode:'',

        BillingCountry:'',
        BillingStreet:'',
        BillingCity:'',
        BillingState:'',
        BillingPostalCode:'',
    }

    $scope.paymentTerms = [];
    $scope.deliveryPlant = [];
    $scope.customerType = [];
    $scope.accSegment = [];
    $scope.taxType = [];
    $scope.transPortTerms = [];
    $scope.taxSource = [];
    $scope.currency = [];

    $scope.getAllCustomer=function(){
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.getMyCustomers(candidateId,function(results,evt){
            debugger;
            if(results.length > 0) {
                let customers = [];
                results.forEach(function(customerWrp) {
                    customerWrp.disAllocation.totalSales = customerWrp.totalSales;
                    customers.push(customerWrp.disAllocation);
                })
                $scope.customers=customers;
    
                console.log(results);
                $rootScope.showSpinner = false;
                
                $scope.$apply();  
                $('#example').DataTable();
            }
        });
        
        $rootScope.showSpinner=true;
        DistributorDashboard_Controller.getDirectCustomers(function(results,evt){
            $scope.directCustomers=results;
            $rootScope.showSpinner=false;
            $scope.$apply();
        })

        let fields = ['Payment_terms__c','Delivery_Plant__c','Customer_Type__c','Account_Segment__c','Tax_Type__c','Transportation_Terms__c','Tax_Collected_At_Source__c','Currency__c'];

        DistributorDashboard_Controller.getPickListValues('Account',fields,function(results,evt){
            if(results){
                $scope.deliveryPlant = results.Delivery_Plant__c;
                $scope.paymentTerms = results.Payment_terms__c;
                $scope.customerType = results.Customer_Type__c;
                $scope.accSegment = results.Account_Segment__c;
                $scope.taxType = results.Tax_Type__c;
                $scope.transPortTerms = results.Transportation_Terms__c;
                $scope.taxSource = results.Tax_Collected_At_Source__c;
                $scope.currency = results.Currency__c;
                $scope.$apply();
            }
        })

    }
    $scope.viewDetails=function(index){
        $scope.customerDetailsshow=$scope.customers[index];
        console.log($scope.customerDetailsshow);
    }
    $scope.view=function(e){
        
        
        $scope.$apply();
        if($scope.viewOption==='Table') $('#example').DataTable();
    }   
    $scope.createCustomerForm=function(){
        $scope.showForm=!$scope.showForm;
       // if($scope.viewOption==='Table') $('#example').DataTable();
    }

   
    
    $scope.duplicacyMsg = '';
    $scope.addCustomer=function(){
        
        $scope.duplicacyMsg = '';

        if(!$scope.account.Name){
            Swal.fire('','Please enter Name','error');
            return;
        }
        if(!$scope.account.Email__c){
            Swal.fire('','Please enter email','error');
            return;
        }
        if(!$scope.account.Phone){
            Swal.fire('','Please enter phone','error');
            return;
        }
        if(!$scope.account.PAN_Number__c){
            Swal.fire('','Please enter PAN','error');
            return;
        }
        if(!$scope.account.Payment_terms__c || $scope.account.Payment_terms__c=='--None--'){
            Swal.fire('','Please select payment terms','error');
            return;
        }
        if(!$scope.account.Account_Segment__c || $scope.account.Account_Segment__c=='--None--'){
            Swal.fire('','Please select account segment','error');
            return;
        }


        if($scope.account.Currency__c=='--None--'){
            $scope.account.Currency__c = '';
        }
        if($scope.account.Delivery_Plant__c=='--None--'){
            $scope.account.Delivery_Plant__c = '';
        }
        if($scope.account.Customer_Type__c=='--None--'){
            $scope.account.Customer_Type__c = '';
        }
        if($scope.account.Tax_Type__c=='--None--'){
            $scope.account.Tax_Type__c = '';
        }
        if($scope.account.Transportation_Terms__c=='--None--'){
            $scope.account.Transportation_Terms__c = '';
        }
        if($scope.account.Tax_Collected_At_Source__c=='--None--'){
            $scope.account.Tax_Collected_At_Source__c = '';
        }


        if($scope.account.Delivery_Plant__c){
            $scope.account.Delivery_Plant__c = $scope.account.Delivery_Plant__c.replace('&amp;','&')
        }

        if($scope.account.Customer_Type__c){
            $scope.account.Customer_Type__c = $scope.account.Customer_Type__c.replace('&amp;','&')
        }

        if($scope.account.Account_Segment__c){
            $scope.account.Account_Segment__c = $scope.account.Account_Segment__c.replace('&amp;','&')
        }

        if($scope.account.Tax_Type__c){
            $scope.account.Tax_Type__c = $scope.account.Tax_Type__c.replace('&amp;','&')
        }

        if($scope.account.Transportation_Terms__c){
            $scope.account.Transportation_Terms__c = $scope.account.Transportation_Terms__c.replace('&amp;','&')
        }

        if($scope.account.Tax_Collected_At_Source__c){
            $scope.account.Tax_Collected_At_Source__c = $scope.account.Tax_Collected_At_Source__c.replace('&amp;','&')
        }

        console.log('Account----',$scope.account);
       
        $rootScope.showSpinner=true;
        DistributorDashboard_Controller.createDirectCustomer($scope.account,candidateId,function(result,evt){
            if(result=='Success'){
                $scope.getAllCustomer();
                Swal.fire('Customer added succesfully', '', 'success');
                $scope.account={
                    Name:'',
                    Email__c:'',
                    Phone:'',
                    GST_number__c:'',
                    PAN_Number__c:'',
                    Currency__c:'--None--',
                    Payment_terms__c:'--None--',
                    Delivery_Plant__c:'--None--',
                    Customer_Type__c:'--None--',
                    Account_Segment__c:'--None--',
                    Tax_Type__c:'--None--',
                    Transportation_Terms__c:'--None--',
                    Tax_Collected_At_Source__c:'--None--',

                    ShippingCountry:'',
                    ShippingStreet:'',
                    ShippingCity:'',
                    ShippingState:'',
                    ShippingPostalCode:'',

                    BillingCountry:'',
                    BillingStreet:'',
                    BillingCity:'',
                    BillingState:'',
                    BillingPostalCode:'',
                }
                $scope.$apply();
            }else if(result=='Failed'){
                Swal.fire('Failed to create custome, please contact to adminstrator','','error');
            }else{
                $scope.duplicacyMsg = result;
                $("#customerDuplicacyPopup").modal('show');
            }
            $scope.showForm=false;
            $rootScope.showSpinner=false;
            $scope.$apply();
        })
    }
    
    $scope.closeDuplicacyPopup = function(){
        $("#customerDuplicacyPopup").modal('hide');
    }

    $scope.createCustomerConfirmed = function(){
        DistributorDashboard_Controller.createDirectCustomerConfirmed($scope.account,candidateId,function(result,evt){
            if(result=='Success'){
                $scope.getAllCustomer();
                Swal.fire('Customer added succesfully', '', 'success');
                $scope.account={
                    Name:'',
                    Email__c:'',
                    Phone:'',
                    GST_number__c:'',
                    PAN_Number__c:'',
                    Currency__c:'--None--',
                    Payment_terms__c:'--None--',
                    Delivery_Plant__c:'--None--',
                    Customer_Type__c:'--None--',
                    Account_Segment__c:'--None--',
                    Tax_Type__c:'--None--',
                    Transportation_Terms__c:'--None--',
                    Tax_Collected_At_Source__c:'--None--',

                    ShippingCountry:'',
                    ShippingStreet:'',
                    ShippingCity:'',
                    ShippingState:'',
                    ShippingPostalCode:'',

                    BillingCountry:'',
                    BillingStreet:'',
                    BillingCity:'',
                    BillingState:'',
                    BillingPostalCode:'',
                }
            }else{
                Swal.fire(result+' ,please contact to adminstrator','','error');
            }

            $("#customerDuplicacyPopup").modal('hide');
            $scope.showForm=false;
            $rootScope.showSpinner=false;
            $scope.$apply();
        })
    }
})