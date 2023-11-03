angular.module('cp_app').controller('sample_ctrl', function ($scope,$rootScope, $log, $timeout) {
    $rootScope.activeTab = 6;
    $scope.samples=[];

    $scope.packagingUnitValues = [];
    $scope.quantityUnitValues = [];
    let samplesCopy;
    $scope.deleteLineItems = [];
    $scope.viewOption='Table';
    $scope.customerSelected = 'All'
    $scope.showSampleForm=false;
    $scope.isEdit = false;
    
    console.log("Profile______+++++",distributorProfile);
   
    $scope.products=[];
    $scope.selectedCustomerContacts;
    $scope.sampleFormData={
        Status__c:'New',
        Account__c:candidateId,
        Distributer_Customer__c:'select',
        Customers_Contact__c:'',
        Sample_Name__c:'',
        City__c:'',
        Country__c:'',
        State__c:'',
        Street__c:'',
        Postal_Code__c:''
    };

    $scope.sampleLineItems=[
        {
            Product__c:'',
            Quantity__c:1,
            Quantity_Unit__c:'--None--',
            Packaging_Quantity__c:1,
            Packaging_Unit__c:'--None--',
            Current_Shelf_life__c:'',
            Additional_Comments__c:'',
            Customer_Instructions__c:'',
            Regulatory_Requirements__c:''
        }
    ]
    $scope.oppDate=new Date();
  
    $scope.sampleDetails;
    $scope.customers=[];

    $scope.getSample=function(){
        $rootScope.showSpinner = true;

        let picklistFields = ['Quantity_Unit__c','Packaging_Unit__c'];

        DistributorDashboard_Controller.getPickListValues('Sample_Line_Item__c',picklistFields,function(results,evt){
            $scope.packagingUnitValues = results.Packaging_Unit__c;
            $scope.quantityUnitValues = results.Quantity_Unit__c;

            $scope.$apply();
            console.log('PicklistValues--------',results);
        })


        DistributorDashboard_Controller.getSamples(candidateId,function(results,evt){
            //$scope.customers=results;
            $scope.samples=results;
            $scope.samples.samples.map(sample=>{
                sample.isExpand=true;
                sample.lineItems=[]
            });
            $scope.samples.samples.forEach(sample=>{
                sample.Opportunity_Close_Date__c = new Date(sample.Opportunity_Close_Date__c);
                $scope.samples.lineItems.forEach(lines=>{
                    if(sample.Id===lines.Sample__c){
                        sample.lineItems.push(lines);
                    }
                })	
            })

            samplesCopy = {...$scope.samples};
            
            console.log('Samples-----',$scope.samples.samples);
            $rootScope.showSpinner = false;   
            $scope.$apply();  
            $('#example').DataTable();
        });
        
        DistributorDashboard_Controller.getChannelSalesProducts(candidateId,function(results,evt){
            console.log('Products---',results);
            $scope.products=results;
            $('#example').DataTable();
        })

        getCustomerContacts(candidateId);
    }

    function getCustomerContacts(customerId){
        debugger;
        DistributorDashboard_Controller.getCustomerContacts(customerId,function(result,evt){
            console.log('Customer Contacts---',result);
            if(result && result.Customer_Contact__r && result.Customer_Contact__r.Id){
                $scope.sampleFormData.Customers_Contact__c = result.Customer_Contact__r.Id;
                $scope.sampleFormData.Customer_Name = result.Customer_Contact__r.Name;
            }else{
                $scope.sampleFormData.Customers_Contact__c = '';
                $scope.sampleFormData.Customer_Name = '';
            }
            $scope.$apply();
        });

    }

    $scope.getCustomer = function(){
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.getDistributionAllocation(candidateId,function(results,evt){
            
            $rootScope.showSpinner = false;
            let cList = [];
            results.forEach(customer=>{
                debugger;
                if(cList.find(item=>item.Id==customer.Customer_Account__r.Id)==null){
                    cList.push(customer.Customer_Account__r);
                }
            })

            $scope.customers = cList;
            $scope.$apply(); 
            console.log('CUSTOMERSSS-----',$scope.customers);
        });
    }

    $scope.getCustomer();

    $scope.visibleSampleForm=function(){
        $scope.showSampleForm=!$scope.showSampleForm;
        $scope.isEdit = false;
        $scope.deleteLineItems = [];

        $scope.sampleLineItems=[
            {
                Product__c:'',
                Quantity__c:1,
                Quantity_Unit__c:'--None--',
                Packaging_Quantity__c:1,
                Packaging_Unit__c:'--None--',
                Current_Shelf_life__c:'',
                Additional_Comments__c:'',
                Customer_Instructions__c:'',
                Regulatory_Requirements__c:''
            }
        ]

    }

    $scope.hideSampleForm = function() {
        $scope.showSampleForm = false;
        $scope.isEdit = false;

        $scope.sampleFormData={
            Status__c:'New',
            Account__c:candidateId,
            Distributer_Customer__c:'select',
            Customers_Contact__c:'',
            Sample_Name__c:'',
            City__c:'',
            Country__c:'',
            State__c:'',
            Street__c:'',
            Postal_Code__c:''
        };

        $scope.sampleLineItems=[
            {
                Product__c:'',
                Quantity__c:1,
                Quantity_Unit__c:'--None--',
                Packaging_Quantity__c:1,
                Packaging_Unit__c:'--None--',
                Current_Shelf_life__c:'',
                Additional_Comments__c:'',
                Customer_Instructions__c:'',
                Regulatory_Requirements__c:''
            }
        ]
    }

    $scope.editOpp=function(index){

        let sampleSelected = $scope.samples.samples[index];
        let lineItems = $scope.samples.samples[index].lineItems;

        console.log('sampleSelected----',sampleSelected);

        debugger;

        if(sampleSelected){
            $scope.sampleFormData = sampleSelected;
        }

        if(lineItems){
            let updatedLineItems = [];
            lineItems.forEach(item=>{
                let obj = {...item};
                let product = $scope.products.find(p=>p.Id==obj.Product__c);

                if(product){
                    obj.UnitPicklist = product.Sampling_Qty_UNIT__c?product.Sampling_Qty_UNIT__c.split(';'):null;
                }
                updatedLineItems.push(obj);
            });
            $scope.sampleLineItems = updatedLineItems;
        }
       
        getCustomerContacts(sampleSelected.Distributer_Customer__c?sampleSelected.Distributer_Customer__c:candidateId);
        debugger;
        console.log('SampleSelected----',$scope.sampleFormData);
        console.log('Lineitems----',$scope.sampleLineItems);

        $scope.isEdit = true;
        $scope.deleteLineItems = [];
        $scope.showSampleForm=!$scope.showSampleForm;
        $scope.$apply();
    }


	$scope.details=function(index){
		$scope.sampleDetails=$scope.samples.samples[index];
		$scope.expandLineItem(index);
		console.log($scope.sampleDetails)
    }

	$scope.addNewSampleLine=function(){
            if($scope.sampleLineItems.length>=6){
                swal("You can add upto 6 line items ");
                return;
            }
            $scope.sampleLineItems.push({
                Product__c:'',
                Quantity__c:1,
                Quantity_Unit__c:'--None--',
                Packaging_Quantity__c:1,
                Packaging_Unit__c:'--None--',
                Current_Shelf_life__c:'',
                Additional_Comments__c:'',
                Customer_Instructions__c:'',
                Regulatory_Requirements__c:''
            });
    }

    $scope.removeSampleLine=function(index){
        if(index!=0){
            if($scope.sampleLineItems[index].Id){
                $scope.deleteLineItems.push($scope.sampleLineItems[index].Id);
            }
            $scope.sampleLineItems.splice(index,1);
        }
    }

    
    $scope.profile;
    DistributorDashboard_Controller.getDistributorDetails(candidateId,function(result,evt){
        debugger;
        console.log('Profile',result);
        $scope.profile = result;
        $scope.$apply();
    })
    
    $scope.submitSample=function(){
     	
        let years;
        let month;
        let date;

        if($scope.isEdit){
            if($scope.sampleFormData.Opportunity_Close_Date__c){
                years=$scope.sampleFormData.Opportunity_Close_Date__c.getFullYear();
                month=$scope.sampleFormData.Opportunity_Close_Date__c.getMonth()+1;
                date=$scope.sampleFormData.Opportunity_Close_Date__c.getDate();
            }else{
                Swal.fire('Empty','Choose Opportunity Close Date','error');
            }
        }else{
            years=$scope.oppDate.getFullYear();
            month=$scope.oppDate.getMonth()+1;
            date=$scope.oppDate.getDate();
        }

        console.log($scope.sampleLineItems);

       if(!$scope.sampleFormData.Sample_Name__c){
            Swal.fire('Empty','Please enter sample name','error');
            return;
       }

        if($scope.sampleFormData.Status__c==null||$scope.sampleFormData.Status__c=='select') {
            Swal.fire('','Choose Sample status','error');
            return;
        }

        if($scope.sampleFormData.Distributer_Customer__c=='select') {
            delete $scope.sampleFormData.Distributer_Customer__c;
        }

        let errorOccured = false;
        let errorReason = '';

        console.log('SampleLineItems------',$scope.sampleLineItems);

        let sampleLineItemsCopy = [];
        $scope.sampleLineItems.forEach(item => {
            let obj = {...item};
            debugger;

            if($scope.isEdit){
                delete obj.Product__r;
                delete obj.CurrencyIsoCode
            }
            
            if(!obj.Quantity_Unit__c||obj.Quantity_Unit__c=='--None--'){
                errorOccured = true;
                errorReason = 'Please choose quantity unit';
                return;
            }
            if(!obj.Packaging_Unit__c||obj.Packaging_Unit__c=='--None--'){
                errorOccured = true;
                errorReason = 'Please choose packaging unit';
                return;
            }
            if(obj.Product__c==''){
                errorOccured = true;
                errorReason = 'Please choose lineitem product';
                return;
            }
            if(obj.Quantity__c==null || obj.Quantity__c<0){
                errorOccured = true;
                errorReason = 'Please choose lineitem Quantity';
                return;
            }
            if(obj.Packaging_Quantity__c==null || obj.Packaging_Quantity__c<0){
                errorOccured = true;
                errorReason = 'Please choose lineitem Packaging quantity';
                return;
            }

            delete obj.UnitPicklist;
            debugger;
            sampleLineItemsCopy.push(obj);
        });

        if(errorOccured){
            Swal.fire('',errorReason,'error');
            return;
        }

        let obj =  {...$scope.sampleFormData};
        delete obj.Customer_Name
        delete obj.Opportunity_Close_Date__c;
        delete obj.isExpand;
        
        if($scope.isEdit){
            delete obj.lineItems
            delete obj.$$hashKey;
            delete obj.Account__r;
            delete obj.RecordType;
            delete obj.CurrencyIsoCode;
            delete obj.RecordTypeId
        }

        obj.CurrencyIsoCode = $scope.profile.CurrencyIsoCode;

        console.log('SampleSelected----',obj);
        console.log('Lineitems----',$scope.sampleLineItems);


        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.createSamples(obj,date,month,years,sampleLineItemsCopy,$scope.deleteLineItems,function(result,evt){
            $rootScope.showSpinner = false;
            console.log('Result---->',result);
            if(result){
                swal(`Sample ${$scope.isEdit?'updated':'created'} successfully`);
                $scope.showSampleForm=!$scope.showSampleForm;
                $scope.isEdit = false;
                $scope.deleteLineItems = [];

                $scope.sampleFormData={
                    Status__c:'New',
                    Account__c:candidateId,
                    Distributer_Customer__c:'select',
                    Customers_Contact__c:'',
                    Customer_Name:'',
                    City__c:'',
                    Country__c:'',
                    State__c:'',
                    Street__c:'',
                    Postal_Code__c:''
                };
                
                $scope.sampleLineItems=[
                    {
                        Product__c:'',
                        Quantity__c:1,
                        Quantity_Unit__c:'--None--',
                        Packaging_Quantity__c:1,
                        Packaging_Unit__c:'--None--',
                        Current_Shelf_life__c:'',
                        Additional_Comments__c:'',
                        Customer_Instructions__c:'',
                        Regulatory_Requirements__c:''
                    }
                ]
                $scope.getSample();
            }
        })
     }            
    
      
    $scope.customerChangeHandler = function(customer){
        debugger;
        console.log('customerSelected---',customer);
        debugger;
        if(customer!=='select'&& customer!='All'){
            $scope.samples.samples= samplesCopy.samples.filter(opp=>{
                console.log('COPP---',opp);
                if(opp.Distributer_Customer__c===customer){
                    return opp;
                }
            }); 
            
            if($scope.samples.samples[0]==null){
                $scope.samples.samples = [];
            }
        }else{
           // $scope.getSample();
            $scope.samples = samplesCopy;
            $scope.$apply();
        }
    }

    $scope.changeProduct=function(prod,index){
    	//console.log(prod);
        debugger;
        console.log('PRODU',$scope.products)

        let pIndex = $scope.products.findIndex(p=>p.Id==prod);
        let obj = {...$scope.products[pIndex]};

        obj.Sampling_Qty_UNIT__c = obj.Sampling_Qty_UNIT__c?obj.Sampling_Qty_UNIT__c.split(';'):null;

        $scope.sampleLineItems[index].UnitPicklist = obj.Sampling_Qty_UNIT__c;

        $scope.$apply();
    }

    $scope.packagingUnitChange = function(valueSelected,index){
        debugger;
        if(valueSelected!=null){
            $scope.sampleLineItems[index].Packaging_Unit__c = valueSelected;
        }else{
            $scope.sampleLineItems[index].Packaging_Unit__c = $scope.sampleLineItems[index].Packaging_Unit__c;
        }
        $scope.$apply();
    }

    $scope.customerChange = function(customerId){
        let csId = customerId=='select'?candidateId:customerId;

        getCustomerContacts(csId);

        let customer = $scope.customers.find(item=>item.Id==customerId);

        $scope.sampleFormData.City__c = customerId=='select'?distributorProfile.ShippingAddress.city:customer.ShippingAddress.city;
        $scope.sampleFormData.Country__c = customerId=='select'?distributorProfile.ShippingAddress.country:customer.ShippingAddress.country;
        $scope.sampleFormData.State__c = customerId=='select'?distributorProfile.ShippingAddress.state:customer.ShippingAddress.state;
        $scope.sampleFormData.Street__c = customerId=='select'?distributorProfile.ShippingAddress.street:customer.ShippingAddress.street;
        $scope.sampleFormData.Postal_Code__c = customerId=='select'?distributorProfile.ShippingAddress.postalCode:customer.ShippingAddress.postalCode;

        $scope.$apply();
        debugger;
    };

    $scope.expandLineItem=function(index){
        console.log(index);
        $scope.samples.samples.map((sample,i)=>{    
            if(index===i){
                return sample.isExpand=!sample.isExpand
            }
        })
    }

    
    $scope.submitSampleToOptiva = function(recId){
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.submitSampleToOptiva(recId,'Sample',function(res,evt){
            console.log('SUBMITSAMPLETOOPTIVA------',res);
            $rootScope.showSpinner = false;
            if(res.code=='200'){
                Swal.fire('Success','Sample submitted succesfully!','success');
                $scope.sampleDetails.Submit_Sample_To_Optiva__c = true;
                $scope.sampleDetails.Submitted_To_SAP_Optiva__c = true;
            }else{
                Swal.fire('Failed',res.message,'error');
            }
            $scope.$apply();
        })
    }
});