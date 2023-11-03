angular.module('cp_app').controller('opportunity_ctrl', function ($scope,$rootScope, $log, $timeout) {
    $scope.globalSearch='';
    console.log("Profile______+++++",distributorProfile);
    $scope.opportunities=[];
    $scope.customerOpps=[];
    $scope.Lines=[];
    $scope.linedetail=[];
    $rootScope.activeTab = 3;
    $scope.showForm=true;
    $scope.customers=[];
    $scope.products=[];
    $scope.viewOption='Table';
    $scope.PriceBooks=[];
    $scope.details;
    $scope.showSalesOrder=false;
    $scope.addLineItem=false;
    $scope.selectCustomer='--select--';
    $scope.allCustomers=[];
    $scope.childOpps=[];
    $scope.filteredOpps=[];
    $scope.salesOrderDetails;
    $scope.oppRecord;
    $scope.productList = [];
    let prodListResp = [];
    let prodList = [];
    $scope.childSplits = [];
    $scope.deleteLineItems = [];
    $scope.isEdit = false;
    $scope.showPerformaInvoice = false;
    $scope.showCreateQuoteForm = false;
    $scope.hasChildSplits = false;
    $scope.showDetails = false;
    $scope.showOppDetails = false;
    $scope.isSplitLeft = true;
    $scope.currentOppName = "";
    $scope.oppName;
    $scope.dateChoosed;
    $scope.plant = [];
    $scope.carriageOption = [
            {'label': 'By Road', 'value': 'By road'},
            {'label': 'By Rail', 'value': 'By Rail'},
            {'label': 'By Air', 'value': 'By air'},
            {'label': 'By Sea', 'value': 'By sea'},
            ];
    $scope.loadingOptions = [
            {'label': 'Port', 'value': 'Port'},
            {'label': 'Chennai', 'value': 'Chennai'},
            {'label': 'Kochi', 'value': 'Kochi'},
            {'label': 'Ennore', 'value': 'Ennore'},
            {'label': 'Kolkata', 'value': 'Kolkata'},
            {'label': 'Kandla', 'value': 'Kandla'},
            {'label': 'Mangalore', 'value': 'Mangalore'},
            {'label': 'Mormugao', 'value': 'Mormugao'},
            {'label': 'Mumbai Port Trust', 'value': 'Mumbai Port Trust'},
            {'label': 'Nhava', 'value': 'Nhava'},
            {'label': 'Paradip', 'value': 'Paradip'},
            {'label': 'Tuticorin', 'value': 'Tuticorin'},
            {'label': 'Visakhapatnam', 'value': 'Visakhapatnam'},
            {'label': 'Port Blair', 'value': 'Port Blair'},
        ];            

    $scope.quoteExpirationDate='';

    $scope.quote = {
        AccountId:'',
        ContactId:'',
        Distributer_Customer__c:'',
        Email:'',
        OpportunityId:'',
        CurrencyIsoCode:'',
        Name:'',

        BillingCity:'',
        BillingCountry:'',
        BillingState:'',
        BillingPostalCode:'',
        BillingStreet:'',

        ShippingCity:'',
        ShippingCountry:'',
        ShippingState:'',
        ShippingPostalCode:'',
        ShippingStreet:'',
    }

    $scope.selectedChildOpp;
    
    $scope.opp={
        Name:'',
        StageName:'New',
        AccountId:candidateId,
        Distributer_Customer__c:'--select--'
        //Pricebook2Id:''
    }

    $scope.performaOpp={};

    $scope.OppProduct=[
        {
            Product2Id:'--select--',
            Quantity:'',
            UnitPrice:'',
            ProductCode:'',
            Packaging_Quantity__c:1,
            Packaging_Unit__c:'select',
            Quantity_Unit__c:'select',
            Markup_Amount__c:'',
            Packaging_Type__c:'Bulk',
            MarkDown_Amount__c:'',
            markupDisabled:false,
            markDownDisabled:false,
        }
    ]
    
    $scope.markupHandler = function(index,event) {

        let obj = $scope.OppProduct[index];
        
        debugger;
        if(event=='markup' && obj.Markup_Amount__c>0){
            obj.markDownDisabled = true;
        }else if(event=='markdown' && obj.MarkDown_Amount__c>0){
            obj.markupDisabled = true;
        }else{
            obj.markupDisabled = false;
            obj.markDownDisabled = false;
        }
        $scope.OppProduct[index] = obj;
    }

    $scope.existOppProduct=[
        {
            Product2Id:'--select--',
            Quantity:'',
            TotalPrice:0,
            ListPrice:0,
            ProductCode:'',
            Subtotal:0,
            Quantity_Unit__c:''
            
        }
    ]
    $scope.showLineItem=function(){
        $scope.addLineItem=!$scope.addLineItem;
    }
    $scope.showDetails=false;
    
    $(document).keydown(function (event) {
    });
    $scope.closeDate=new Date();
    $scope.salesOrders=[];
    $scope.salesOrderDetails=[];

    $scope.getOpportunities=function(){
        $rootScope.showSpinner = true;
        
        DistributorDashboard_Controller.getOpportunities(candidateId,function(results,evt){
            console.log(results);
            $scope.opportunities=results.opps;
            $scope.customerOpps = results.opps;
            $scope.Lines=results.lineItems;
            $scope.salesOrders=results.salesOrders;
            $scope.childOpps=results.childOpps;
            $rootScope.showSpinner = false;
            $scope.$apply();  

            console.log('OPPPSSSS======',$scope.opportunities);
            console.log('ChildOPPPSSSS======',$scope.childOpps);
            console.log('Lines----',$scope.Lines);
        })
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.getChannelSalesProducts(candidateId,function(results,evt){
            $rootScope.showSpinner = false;
            console.log('Products---',results)
            let pList = results.filter(item=>item.PricebookEntries);
           
            $scope.products=pList;

            console.log('Products-----',pList);
        });
        $rootScope.showSpinner=true;
        DistributorDashboard_Controller.getPriceBooks(function(results,evt){
            $rootScope.showSpinner=false;
            $scope.PriceBooks=results;
            //console.log($scope.PriceBooks)
            $scope.$apply();
            $('#example').DataTable();
        })

        let fieldValues = ['Plant__c'];
        $scope.plant = [];
        DistributorDashboard_Controller.getPickListValues('Sales_Order__c',fieldValues,function(results,evt){
            $scope.plant = results.Plant__c;
            console.log('results----',results);
        })
    }


    $scope.profile;
    DistributorDashboard_Controller.getDistributorDetails(candidateId,function(result,evt){
        debugger;
        console.log('Profile',result);
        $scope.profile = result;
        $scope.$apply();
    })
    
    $scope.myFunct = function(keyEvent) {
        //console.log(keyEvent);
        /*if (keyEvent.which === 13)
            alert('I am an alert');*/
    }

    $scope.OpenPerformaInvoice = function() {
        $("#showPerformaInvoice").modal('show');
        $scope.performaOpp.Id = $scope.details.Id;
        debugger;
        
        if($scope.details.CurrencyIsoCode=='INR'){
            $scope.performaOpp.Proposed_Date_of_Dispatch__c = new Date($scope.details.Proposed_Date_of_Dispatch__c);
        }else{
            $scope.performaOpp.Pre_carriage_By__c = $scope.details.Pre_carriage_By__c;
            $scope.performaOpp.Port_of_Discharge__c = $scope.details.Port_of_Discharge__c;
            $scope.performaOpp.Place_of_Reciept_by_Pre_Carrier__c = $scope.details.Place_of_Reciept_by_Pre_Carrier__c;
            $scope.performaOpp.Port_of_Loading__c = $scope.details.Port_of_Loading__c;
            $scope.performaOpp.Vessel_Flight_Name_Voy_No__c = $scope.details.Vessel_Flight_Name_Voy_No__c;
        }
        $scope.$apply();
    }


    $scope.quoteUrl = '';

    $scope.OpenQuoteInvoice = function() {
        $rootScope.showSpinner=true;
        DistributorDashboard_Controller.syncQuote($scope.details.selectedQuote.Id,function(results,evt){
            $("#showQuoteInvoice").modal('show');

            let baseUrl = window.location.origin;
            $scope.quoteUrl = baseUrl+'/QuotePDF?id='+$scope.details.selectedQuote.Id;
            $rootScope.showSpinner=false;
            $scope.$apply();
        });
    }

    $scope.closeQuoteInvoice = function() {
        $("#showQuoteInvoice").modal('hide');
        $scope.quoteUrl = '';
        $scope.$apply();
    }



    $scope.performarURL = '';

    $scope.closePerformaInvoice = function() {
        $("#showPerformaInvoice").modal('hide');
        $scope.performaOpp={};
        $scope.showPerformaInvoice = false;
        $scope.performarURL = '';
        $scope.$apply();
    }

    $scope.performaInvoiceUpdateDetails = function() {
        if($scope.details && $scope.details.CurrencyIsoCode=='INR'){
            debugger;
            $rootScope.showSpinner=true;
            DistributorDashboard_Controller.updateINROpp($scope.performaOpp.Id,formatDate(new Date($scope.performaOpp.Proposed_Date_of_Dispatch__c)),function(results,evt){
                console.log('Products---',results)
                $rootScope.showSpinner=false;
                $scope.performaURL = 'https://symegafood--symegadev--c.visualforce.com/apex/PerformaInvoiceIndia?id='+$scope.performaOpp.Id;
                $scope.showPerformaInvoice = true;
                $scope.$apply();
            });
        }else{
            $rootScope.showSpinner=true;
            DistributorDashboard_Controller.updateUSAOpp($scope.performaOpp.Id,$scope.performaOpp.Pre_carriage_By__c,$scope.performaOpp.Port_of_Discharge__c,
                $scope.performaOpp.Place_of_Reciept_by_Pre_Carrier__c,$scope.performaOpp.Port_of_Loading__c,$scope.performaOpp.Vessel_Flight_Name_Voy_No__c,function(results,evt){
                $rootScope.showSpinner=false;
                $scope.performaURL = 'https://symegafood--symegadev--c.visualforce.com/apex/PerformaInvoicePDF?id='+$scope.performaOpp.Id;
                $scope.showPerformaInvoice = true;
                $scope.$apply();
            })
        }
    }

    function formatDate(date){
        return (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear();
    }

    $scope.downloadInvoice = function(){
        const link = document.createElement("a");
        link.href = $scope.performaURL;
        link.download = 'Proforma Invoice.pdf';
        link.click();
    }

    $scope.downloadQuoteInvoice = function(){
        const link = document.createElement("a");
        link.href = $scope.quoteUrl;
        link.download = 'Quote Invoice.pdf';
        link.click();
    }

    $scope.sendEmailInvoice = function(){
        DistributorDashboard_Controller.sendInvoiceToClient($scope.performaURL,$scope.details.Id,function(results,evt){
            console.log('RESULT----',results);
            if(results=='Success'){
                Swal.fire('Invoice sent successfully', '', 'success');
            }else{
                Swal.fire(results, '', 'error');
            }
        })
    }

    $scope.sendQuoteByEmail = function(){
        console.log('$scope.quoteUrl----',$scope.quoteUrl);
        console.log('Quote Email-----',$scope.details.selectedQuote.Email);
        
        DistributorDashboard_Controller.sendQuoteInvoiceToClient($scope.quoteUrl,$scope.details.selectedQuote.Email,function(results,evt){
            console.log('RESULT----',results);
            if(results=='Success'){
                Swal.fire('Invoice sent successfully', '', 'success');
            }else{
                Swal.fire(results, '', 'error');
            }
        })
    }
    
    $scope.onChangeCustomer=function(customer){
        console.log('customer',customer);
        $scope.customerOpps=[];
        if(customer!=='--select--'){
            $scope.customerOpps= $scope.opportunities.map(opp=>{
                console.log('COPP---',opp);
                if(opp.Distributer_Customer__c===customer){
                    return opp;
                }
            }); 
            
            if($scope.customerOpps[0]==null){
                $scope.customerOpps = [];
            }
        }else{
            $scope.customerOpps= $scope.opportunities
        }
        
        console.log($scope.customerOpps)
    }

    $scope.getAccounts=function(){
        console.log("AccountId-----",candidateId);
        $scope.allCustomers = [];
        DistributorDashboard_Controller.getDistributionAllocation(candidateId,function(res,evt){
            if(res!=null){
                res.forEach(customer=>{
                    if($scope.allCustomers.find(item=>item.Id==customer.Customer_Account__r.Id)==null){
                        $scope.allCustomers.push(customer.Customer_Account__r);
                    }
            	})   
            }
        })
    }
    
    $scope.tab='lineItem'
    $scope.getAccounts();

    $scope.tabs=function(val){
        $scope.tab=val;
    }

    $scope.getAllCustomer=function(){
        $rootScope.showSpinner = true;
        $scope.customers = [];
        DistributorDashboard_Controller.getDistributionAllocation(candidateId,function(results,evt){
            //$scope.customers=results;
          //console.log(results);
            if(results!==null){
            	results.forEach(customer=>{
                	$scope.customers.push(customer.Customer_Account__r);
            	})    
            }
            
          //console.log($scope.customers)
            $rootScope.showSpinner = false;
            $scope.$apply();  
        })
    }
	$scope.getAllCustomer();
    $scope.showOppForm=function(){
        $scope.isEdit = false;
        $scope.deleteLineItems = [];
        $scope.showForm=!$scope.showForm;
    }

    $scope.editOpp=function(index){

        let sOpp = $scope.opportunities[index];
        let lineItems = $scope.opportunities[index].OpportunityLineItems;

        if(sOpp){
            // delete sOpp.OpportunityLineItems
            // delete sOpp.$$hashKey;
            // delete sOpp.Account;
            // delete sOpp.RecordType;
            $scope.opp = sOpp;
        }

        if(lineItems){
            let updatedLineItems = [];

            lineItems.forEach(item=>{
                let obj = {...item};
                // delete obj.Opportunity;
                // delete obj.Product2;

                obj.markupDisabled = obj.MarkDown_Amount__c;
                obj.markDownDisabled = obj.Markup_Amount__c
                updatedLineItems.push(obj);
            });

            $scope.OppProduct = updatedLineItems;
        }
       

        console.log('OppSelected----',$scope.opp);
        console.log('OppProd----',$scope.OppProduct);
        $scope.isEdit = true;
        $scope.showForm=!$scope.showForm;
        $scope.$apply();
    }

	$scope.changeProduct=function(prod,index){
    	//console.log(prod);
        debugger
        console.log('PRODU',$scope.products)
        $scope.products.map(product=>{
            if(product.Id===prod /*&& $scope.OppProduct[index].ProductCode!==undefined*/){
                $scope.OppProduct[index].ProductCode=product.ProductCode;   
                $scope.OppProduct[index].UnitPrice=product.PricebookEntries[0].UnitPrice;  
                return; 
            }
        })
        //console.log($scope.products.find(prod=>{return prod.Id===prod}))
    }
    
    $scope.changeProductLine=function(prod,index){
        //console.log(prod);
        //console.log($scope.products)
        debugger;
        $scope.products.map(product=>{    
            if(product.Id===prod && $scope.existOppProduct[index].ProductCode!==undefined){
                $scope.existOppProduct[index].ProductCode=product.ProductCode;    
            }
        })
        //console.log($scope.products.find(prod=>{return prod.Id===prod}))
    }
                    
    $scope.viewSalesOrder=function(index){
        if(index==='close'){
            $scope.showSalesOrder=false;
            $scope.salesOrderDetails=$scope.salesOrders;
            console.log($scope.showSalesOrder);
            return;
        }
        $scope.showSalesOrder=!$scope.showSalesOrder;
        $scope.salesOrderDetails=$scope.salesOrders[index];
        console.log($scope.salesOrderDetails);
    }
                    

    $scope.oppQuoteSelectedHandler = function(oppQuote){
        $scope.details.selectedQuote = oppQuote;
        $scope.$apply();
    }

	$scope.viewDetails=function(index){
        if(!$scope.showDetails){
            $scope.details=$scope.opportunities[index];

            console.log('Details----',$scope.details);
            
            $scope.lineDetail=[];
            $scope.Lines.map(line=>{
                if(line.OpportunityId===$scope.details.Id){
                    $scope.lineDetail.push(line);
                }   
            });

            $scope.filteredOpps=[];
            $scope.childOpps.map(lines=>{
                if(lines.Parent_Opportunity__c===$scope.details.Id){
                    $scope.filteredOpps.push(lines);    
                } 
            });

            $scope.salesOrderDetails=[];
            $scope.salesOrders.map(sales=>{
                if(sales.Opportunity__c===$scope.details.Id){
                    $scope.salesOrderDetails.push(sales);
                }
            })
        }
        $scope.showDetails=!$scope.showDetails;
        $('#example').DataTable();
    }

    //  $scope.quote = {
    //     AccountId:'',
    //     ContactId:'',
    //     Distributer_Customer__c:'',
    //     Email:'',
    //     OpportunityId:'',
    //     CurrencyIsoCode:'',
    //     Name:'',

    //     BillingCity:'',
    //     BillingCountry:'',
    //     BillingState:'',
    //     BillingPostalCode:'',
    //     BillingStreet:'',

    //     ShippingCity:'',
    //     ShippingCountry:'',
    //     ShippingState:'',
    //     ShippingPostalCode:'',
    //     ShippingStreet:'',
    // }
    $scope.editQuote = function(selectedQuote){

        console.log('selectedQuote---',selectedQuote);
        console.log('Details----',$scope.details);
        $scope.quote = {...selectedQuote};

        // $scope.quote.Id = selectedQuote.Id;
        // $scope.quote.Email = selectedQuote.Email;
        // $scope.quote.Name = selectedQuote.Name;

        $scope.quote.BillingCity = selectedQuote.BillingAddress.city;
        $scope.quote.BillingCountry = selectedQuote.BillingAddress.country;
        $scope.quote.BillingState = selectedQuote.BillingAddress.state;
        $scope.quote.BillingPostalCode = selectedQuote.BillingAddress.postalCode;
        $scope.quote.BillingStreet = selectedQuote.BillingAddress.street;
        $scope.quote.Email = selectedQuote.Email;

        $scope.quote.ShippingCity = selectedQuote.ShippingAddress.city;
        $scope.quote.ShippingCountry = selectedQuote.ShippingAddress.country;
        $scope.quote.ShippingState = selectedQuote.ShippingAddress.state;
        $scope.quote.ShippingPostalCode = selectedQuote.ShippingAddress.postalCode;
        $scope.quote.ShippingStreet = selectedQuote.ShippingAddress.street;
        $scope.quote.CurrencyIsoCode = selectedQuote.CurrencyIsoCode;

        $scope.quoteExpirationDate = new Date(selectedQuote.ExpirationDate);

        $scope.showCreateQuoteForm = true;
    };



    $scope.childOppSelected;
    $scope.childOppClickedHandler = function(childOpp){
        $scope.childOppSelected = childOpp;
        $scope.showDetails = false;
        $rootScope.showSpinner = false;

        DistributorDashboard_Controller.getChildOppSales($scope.childOppSelected.Id,function(results,evt){
            console.log("SalesOrder========: ",results);
            if(results && results.length > 0){
                $scope.childOppSelected.salesOrders = results;
            }

            console.log("ChildOppSelected-----",$scope.childOppSelected);
            $rootScope.showSpinner = false;
            $scope.$apply();  
        })
    }

    $scope.createQuote = function(){
        console.log("Quote",$scope.quote);
        if(!$scope.quote.Name){
            Swal.fire('Please enter quote name', '', 'error')
            return;
        }

        if(!$scope.quoteExpirationDate){
            Swal.fire('Please enter expiration date', '', 'error')
            return;
        }
        if(!$scope.quote.Email){
            Swal.fire('Please enter email', '', 'error')
            return;
        }

        delete $scope.quote.$$hashKey;
        delete $scope.quote.AdditionalAddress;
        delete $scope.quote.BillingAddress;
        delete $scope.quote.QuoteToAddress;
        delete $scope.quote.ShippingAddress;
        delete $scope.quote.ExpirationDate;
        delete $scope.quote.Discount;
        delete $scope.quote.GrandTotal;
        delete $scope.quote.Month__c;
        delete $scope.quote.QuoteNumber;
        delete $scope.quote.Subtotal;
        delete $scope.quote.TotalPrice;
        delete $scope.quote.Total_Quantity_In_Kg__c;


        $rootScope.showSpinner=true;
        DistributorDashboard_Controller.createQuote($scope.quote,formatDate(new Date($scope.quoteExpirationDate)),function(result,event){
            if(result=='Success'){

                Swal.fire(`Quote ${$scope.quote.Id?'Updated':'Created'} Successfully`, '', 'success')
                $scope.closeCreateQuoteForm();
                $scope.showDetails = false;
                $scope.getOpportunities();
            }else{
                Swal.fire(event.result, '', 'error')
            }

            $rootScope.showSpinner=false;
            $scope.$apply();
            console.log('Result----',result);
            console.log('Event',event);
        });
    }


    $scope.childSalesOrderClickedHanlder = function(selectedSalesOrder) {
        $scope.childOppSelected.selectedSalesOrder = selectedSalesOrder;
        $scope.$apply();  
    }

    $scope.invoiceSelectedHandler = function(invoiceSelected) {
        $scope.childOppSelected.selectedSalesOrder.invoiceSelected = invoiceSelected;
        $scope.$apply();  
    }

    $scope.backArrowHandler = function(screenName) {
        debugger;
        if(screenName=='childOppDetails'){
            $scope.showDetails = true;
            $scope.childOppSelected = null;
        }else if(screenName=='childOppSOrders'){
            delete $scope.childOppSelected.selectedSalesOrder
            $scope.$apply();
        }else if(screenName=='invoiceSelected'){
            delete $scope.childOppSelected.selectedSalesOrder.invoiceSelected
            $scope.$apply();
        }else if(screenName=='hideSalesOrderCreation'){
            $scope.showSalesOrderCreation = false;
            $scope.$apply();
        }else if(screenName=='hideQuoteCreation'){
            $scope.closeCreateQuoteForm();
        }else if(screenName=='quoteSelected'){
            delete $scope.details.selectedQuote;
            $scope.$apply();
        }
    }

    $scope.closeSplit = function() {
        $("#closeModel").click();
        clearSplitCache();
    }

    $scope.sendSONotification = function() {
        $rootScope.showSpinner=true;
        console.log('SelectedSalesOrder-----',$scope.childOppSelected.selectedSalesOrder);

        DistributorDashboard_Controller.SendSONotification($scope.childOppSelected.selectedSalesOrder.Id,function(results,evt){
            console.log("Result----",results);
            $rootScope.showSpinner=false;
            $scope.childOppSelected.selectedSalesOrder.Submission_Date__c = new Date();
            Swal.fire('Notification Sent Successfully', '', 'success')
            $scope.$apply();
        })
    }


    $scope.salesOrderObj = {
        accName:'',
        oppName:'',
        accId:'',
        oppId:'',
        name:'',
        quantity : '',
        customer:'',
        amount : '',
        expectedDate:'',
        plant:'--None--',
        customerPoNumber:'',
        remarks:''
    };

    $scope.showSalesOrderCreation = false;
    $scope.showCreateSalesOrder = function() {
        console.log('Result----',$scope.childOppSelected);
        $scope.salesOrderObj.accId = $scope.childOppSelected.AccountId;
        $scope.salesOrderObj.oppId = $scope.childOppSelected.Id;
        $scope.salesOrderObj.quantity = $scope.childOppSelected.TotalOpportunityQuantity;
        $scope.salesOrderObj.amount = $scope.childOppSelected.Amount;
        $scope.salesOrderObj.accName = $scope.childOppSelected.Account.Name;
        $scope.salesOrderObj.oppName = $scope.childOppSelected.Name;
        $scope.salesOrderObj.customer = $scope.childOppSelected.Parent_Opportunity__r.Distributer_Customer__c;

        $scope.showSalesOrderCreation = true;
        $scope.$apply();
    }

    $scope.createSalesOrder = function(){
        if($scope.salesOrderObj.name == ''){
            Swal.fire('','Please Enter Sales Order Name','error');
            return;
        }
        if($scope.salesOrderObj.submittedDate == ''){
            Swal.fire('','Please Enter Submitted Date','error');
            return;
        }
        if($scope.salesOrderObj.expectedDate == ''){
            Swal.fire('','Please Enter Expected Order Date','error');
            return;
        }

        let obj = {
            accId:$scope.salesOrderObj.accId,
            oppId:$scope.salesOrderObj.oppId,
            name:$scope.salesOrderObj.name,
            customer:$scope.salesOrderObj.customer,
            quantity:$scope.salesOrderObj.quantity,
            amount:$scope.salesOrderObj.amount,
            //submittedDate:formatDate(new Date($scope.salesOrderObj.submittedDate)),
            
            expectedDate:formatDate(new Date($scope.salesOrderObj.expectedDate)),
            customerPoNumber:$scope.salesOrderObj.customerPoNumber,
            remarks:$scope.salesOrderObj.remarks
        }

        if($scope.salesOrderObj.plant!='--None--'){
            obj.plant = $scope.salesOrderObj.plant;
        }else{
            obj.plant = '';
        }
        
        console.log('Object----',obj);
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.createSalesOrder(obj,function(result,evt){
            $rootScope.showSpinner = false;
            debugger;
            if(result){
                console.log("SOLIST----",$scope.childOppSelected.salesOrders);
                let soList = [];
                soList.push(result);
                $scope.childOppSelected.salesOrders = soList;
                Swal.fire('Sales Order Created Successfully', '', 'success');
                $scope.showSalesOrderCreation = false;
            }else{
                Swal.fire('','Something went wrong!','error');
            }
        
            $scope.$apply();
            console.log("ObjectCreated----",obj);
            console.log('RESULT',result);
        })
    }

    function formatDate(date){
        return (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear();
    }

    $scope.openSplit = function() {
        debugger;
        //clearSplitCache();
        let pList = [];
        DistributorDashboard_Controller.getRecord($scope.details.Id,function(results,evt){
            if(results && results.length > 0){
                debugger;
                $scope.oppRecord = results[0];

                $scope.oppRecord.OpportunityLineItems && $scope.oppRecord.OpportunityLineItems.forEach(prod=>{
                    let obj = {...prod};    
                    obj.quantityChoosed = obj.Quantity;
                    obj.amountChoosed = obj.TotalPrice;
                    obj.remainingQuantity = obj.Quantity;
                    obj.remainingAmount = obj.TotalPrice;
                    obj.quantityUnit = obj.Quantity_Unit__c;

                    obj.PackagingType = obj.Packaging_Type__c;

                    delete obj.Packaging_Type__c;

                    pList.push(obj);
            })
            prodList = [...pList];
            prodListResp = [...pList];
            $scope.productList = [...pList];
        
            $scope.$apply();  

            console.log("PLIED",pList);
            console.log("Productssss-----",prodListResp.length);
            console.log("ProductListResp12-------",prodListResp);
            console.log("Productssss2-----",prodListResp.length);
            console.log("ProdList----",prodList);
            $("#showSplitModal2").modal('show');

            }
        })
    }

    $scope.addNewSplit = function() {

        console.log("AddNewProdListLength----",$scope.productList.length);
        debugger;
        if($scope.showOppDetails){
            let list = getProductList();

            console.log('OOOOIIIII',list);
            if(list.products && list.products.length == 1 && list.products[0].quantityChoosed==0){
                //$scope.showToast('Error','Choose quantity more than 0','error')
                alert('Choose quantity more than 0');
                return;
            }
            if(list){
                addSplits(list);
                $scope.showOppDetails = false;
            }
        }else{
            $scope.oppName = $scope.oppRecord.Name+'-'+($scope.childSplits.length+1);
            $scope.showOppDetails = $scope.isSplitLeft;
        }
    }

    function addSplits(xsplits){
        let splits = {...xsplits}
        let totalQuantity = 0;
        let totalAmount = 0;

        console.log("Length---",splits.products.length);
        console.log("Splits------",splits);

        let pList = [...prodList];

        splits.products.forEach(sProd=>{
            console.log("SProd----",sProd);
            delete sProd.Quantity_Unit__c;
            delete sProd.$$hashKey;
            delete sProd.CurrencyIsoCode;

            debugger;
            totalQuantity+=parseInt(sProd.quantityChoosed);
            totalAmount+=sProd.amountChoosed;

            if(pList.findIndex(prod=>prod.Id==sProd.Id)>=0 && sProd.quantityChoosed!=0){
                let index = pList.findIndex(prod=>prod.Id==sProd.Id);
                let obj = {...sProd};

                debugger;

                delete obj.Quantity_Unit__c;
                delete obj.$$hashKey;
                delete obj.CurrencyIsoCode;

                obj.quantityChoosed = parseInt(obj.quantityChoosed);

                if(obj.quantityChoosed==obj.remainingQuantity){
                    pList.splice(index,1);
                }else{
                    obj.remainingQuantity = obj.remainingQuantity - obj.quantityChoosed;
                    obj.quantityChoosed = obj.remainingQuantity;
                    obj.amountChoosed = obj.remainingAmount;
                    pList[index] = obj;
                }
            }
        })

        prodList = pList;

        splits.totalQuantity = totalQuantity;
        splits.totalAmount = parseFloat(totalAmount.toFixed(2));

        console.log('TOTALAMOUNT---:::::::::::',splits)

        if(splits.totalQuantity==0){
            alert('Error, Choose quantity more than 0');
            return;
        }

        debugger;
        $scope.childSplits.push(splits);
        $scope.hasChildSplits = $scope.childSplits.length>0;
        $scope.isSplitLeft = prodList.length>0;
        $scope.productList = prodList;
    }


    function getProductList(){
        debugger;
        if(!$scope.dateChoosed){
            alert('Please enter expected Order Date!');
            $scope.dateChoosed = null;
        }else{
            let nextOrderDate = new Date($scope.dateChoosed).toISOString();
            let closeDate = new Date();
            closeDate.setDate(closeDate.getDate()+60);
            closeDate = closeDate.toISOString();
            return {oppName:$scope.oppName,products:prodList,nextOrderDate:nextOrderDate,closeDate:closeDate}
        }
    }

    

    $scope.createOpp = function(){
        let cSplits = [];

        $scope.childSplits.forEach(split=>{
            let closeDate = new Date(split.closeDate);
            let nextOrderDate = new Date(split.nextOrderDate);

            split.closeDate = formatDate(closeDate);
            split.nextOrderDate = formatDate(nextOrderDate);

            delete split.TotalPrice;
            delete split.$$hashKey;
            cSplits.push(split);
        })

        console.log('OppDetails---',$scope.details.Id);
        console.log('CSplits----',cSplits);
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.createOpp($scope.details.Id,cSplits,function(results,evt){
            console.log('Results---',results);
            $rootScope.showSpinner = false;

            if(results && results.length>0){
                $scope.filteredOpps = results;
                clearSplitCache();
                Swal.fire('Splits created successfully', '', 'success')
                $("#showSplitModal2").modal('hide');
                $scope.getOpportunities();
            }else{
                 Swal('Something went wrong!');
            }
        })
    }

    function clearSplitCache(){
        $scope.oppRecord = null;
        $scope.productList = [];
        prodListResp = [];
        prodList = [];
        $scope.childSplits = [];
        $scope.hasChildSplits = false;
        $scope.showOppDetails = false;
        $scope.isSplitLeft = true;
        $scope.currentOppName = "";
        $scope.oppName = null;
        $scope.dateChoosed = null;

        $scope.$apply();
    }


    function formatDate(date){
        return (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear();
    }


    $scope.nextOrderDateChange = function(event){
        debugger;
        console.log("Event---",event);
        let dateSelected = event.dateChoosed;
        if(dateSelected<new Date()){
            $scope.dateChoosed = '';
            event.dateChoosed = '';
            alert('Invalid Date, Past Date cannot be choose.');
            console.log("Current Date-----",$scope.dateChoosed);
        }else{
            $scope.dateChoosed = dateSelected;
        }
    }

    $scope.openCreateQuoteForm = function() {
        console.log("Opp Details ---- ",$scope.details);

        $scope.quote.OpportunityId = $scope.details.Id;
        $scope.quote.AccountId = candidateId;
        $scope.quote.CurrencyIsoCode = $scope.details.CurrencyIsoCode;

        if($scope.details.Distributer_Customer__c){
            let customer = $scope.customers.find(item=>item.Id==$scope.details.Distributer_Customer__c);

            console.log('CustomerDetails------',customer);
            console.log('MyCustomer------',distributorProfile);

            $scope.quote.BillingCity = customer.BillingCity;
            $scope.quote.BillingState = customer.BillingState;
            $scope.quote.BillingStreet = customer.BillingStreet;
            $scope.quote.BillingCountry = customer.BillingCountry;
            $scope.quote.BillingPostalCode = customer.BillingPostalCode;

            $scope.quote.ShippingCity = customer.ShippingCity;
            $scope.quote.ShippingState = customer.ShippingState;
            $scope.quote.ShippingStreet = customer.ShippingStreet;
            $scope.quote.ShippingCountry = customer.ShippingCountry;
            $scope.quote.ShippingPostalCode = customer.ShippingPostalCode;

            $scope.quote.Distributer_Customer__c = $scope.details.Distributer_Customer__c;
            $scope.quote.Email = $scope.details.Distributer_Customer__r.Email__c;
        }else{
            $scope.quote.BillingCity = distributorProfile.BillingCity;
            $scope.quote.BillingState = distributorProfile.BillingState;
            $scope.quote.BillingStreet = distributorProfile.BillingStreet;
            $scope.quote.BillingCountry = distributorProfile.BillingCountry;
            $scope.quote.BillingPostalCode = distributorProfile.BillingPostalCode;

            $scope.quote.ShippingCity = distributorProfile.ShippingCity;
            $scope.quote.ShippingState = distributorProfile.ShippingState;
            $scope.quote.ShippingStreet = distributorProfile.ShippingStreet;
            $scope.quote.ShippingCountry = distributorProfile.ShippingCountry;
            $scope.quote.ShippingPostalCode = distributorProfile.ShippingPostalCode;
            $scope.quote.Email = $scope.details.Account.Email__c;
        }

        let customerId = $scope.details.Distributer_Customer__c?$scope.details.Distributer_Customer__c:candidateId;

        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.getCustomerContacts(customerId,function(result,evt){
            console.log('Customer Contacts---',result);
            if(result && result.Customer_Contact__r && result.Customer_Contact__r.Id){
                $scope.quote.ContactId = result.Customer_Contact__r.Id;
            }else{
                $scope.quote.ContactId = '';
            }

            console.log('Quote',$scope.quote)
            $rootScope.showSpinner = false;
            $scope.showCreateQuoteForm = true;
            $scope.$apply();
        });
    }

    $scope.closeCreateQuoteForm = function() {
        $scope.showCreateQuoteForm = false;
        $scope.quote = {
            AccountId:'',
            ContactId:'',
            Email:'',
            OpportunityId:'',
            CurrencyIsoCode:'',
            Name:'',

            BillingCity:'',
            BillingCountry:'',
            BillingState:'',
            BillingPostalCode:'',
            BillingStreet:'',

            ShippingCity:'',
            ShippingCountry:'',
            ShippingState:'',
            ShippingPostalCode:'',
            ShippingStreet:'',
        }

        $scope.quoteExpirationDate = '';
        $scope.$apply();
    }


    $scope.inputChangeHandler = function(event){
        debugger;
        console.log("Event----",event);

        let id = event.record.Id;
        let value = parseInt(event.record.quantityChoosed);

        let pList = [...$scope.productList];

        let index = pList.findIndex(prod=>prod.Id==id);
        let obj = {...pList[index]};
        obj.quantityChoosed = parseInt(obj.remainingQuantity<value?obj.remainingQuantity:value);
        obj.amountChoosed = parseFloat(((obj.TotalPrice/obj.Quantity)*obj.quantityChoosed).toFixed(1))
        obj.remainingAmount = parseFloat((obj.TotalPrice - obj.amountChoosed).toFixed(1));
        pList[index] = obj;
        prodList = pList;
        $scope.productList = pList;
        $scope.$apply();
    }

    $scope.openNoSplit = function() {
        debugger;

        $("#showNoSplitModal").modal('show');
      
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.noSplit($scope.details.Id,function(results,evt){
            console.log('Results---',results);
            $rootScope.showSpinner = false;

            if(results=='SUCCESS'){
                $("#showNoSplitModal").modal('hide');
                Swal.fire('Splits created successfully', '', 'success');
                $scope.getAllCustomer();
                $scope.showDetails=!$scope.showDetails;
                $scope.getOpportunities();
            }else{
                Swal.fire('Failed to create splits', 'Contact to Symega Admin', 'error')
            }

            $scope.$apply();
        })
    }
                
	$scope.submitOpp=function(){

		if($scope.opp.Name==='' || $scope.opp.AccountId==='' || $scope.opp.AccountId==='--select--' || $scope.opp.StageName==='' || $scope.opp.StageName==='--select--' || $scope.closeDate==='' ){
            swal("Please fill required details")
            return;
        }
        
        let projectTypeSelected = '';

  
        console.log($scope.OppProduct);

        let lineItemList = [];
        let errorOccured = false;
        let errorReason;
        $scope.OppProduct.map((product,index)=>{
            debugger;

            let obj = {...product};

            console.log('Product----',product);

            if(index==0){
                projectTypeSelected = product.Packaging_Type__c;
            }
        
            if(product.ProductCode==='' || product.ProductCode===undefined){
                errorOccured = true;
                errorReason = 'Please choose product';
                return;
            }

            if(product.Packaging_Quantity__c===0 ||  product.Packaging_Quantity__c<0){
                errorOccured = true;
                errorReason = 'Please choose Packaging Quantity';
                return;
            }

            if(product.Quantity===0){
                errorOccured = true;
                errorReason = 'Please choose Quantity in KG ';
                return;
            }

            if(product.Packaging_Unit__c==='select'){
                errorOccured = true;
                errorReason = 'Please choose packaging unit';
                return;
            }
            
            if(product.Quantity_Unit__c==='select'){
                errorOccured = true;
                errorReason = 'Please choose Quantity unit';
                return;
            }

            if(product.Packaging_Type__c!=projectTypeSelected){
                errorOccured = true;
                errorReason = 'Packaging type should be same';
                return;
            }

            delete obj.markupDisabled;
            delete obj.markDownDisabled;
            delete obj.Opportunity;
            delete obj.Product2;

            lineItemList.push(obj);
        })


        if(errorOccured){
            Swal.fire(`${errorReason}`, '', 'error')
            return;
        }


        delete $scope.opp.OpportunityLineItems
        delete $scope.opp.$$hashKey;
        delete $scope.opp.Account;
        delete $scope.opp.RecordType;
        delete $scope.opp.Quotes;

        $scope.opp.CurrencyIsoCode = $scope.profile.CurrencyIsoCode;
      
		const years=$scope.closeDate.getFullYear();
        const month=$scope.closeDate.getMonth()+1;
        const date=$scope.closeDate.getDate();
       
        console.log('$scope.Opp',$scope.opp);
        console.log('$scope.OppProduct',lineItemList);

        if($scope.opp.Distributer_Customer__c=='--select--'){
            console.log('HEHEHEHEHHEHE');
            $scope.opp.Distributer_Customer__c = null;
        }
        $rootScope.showSpinner = true;
        DistributorDashboard_Controller.createOpportunity($scope.opp,date,month,years,lineItemList,$scope.deleteLineItems,function(result,evt){
            console.log('Result----',result);
            if(result===true){
                Swal.fire(`Opportunity  ${$scope.isEdit?'updated':'created'} succesfully.`, '', 'success')
                $rootScope.showSpinner = false;
                $scope.isEdit = false;
                $scope.showOppForm();
                $scope.getAllCustomer();
                $scope.getOpportunities();
            }
            else{
                $rootScope.showSpinner = false;
                swal("Some thing went wrong");
            }
        })
    }
    
    $scope.submitOppLine=function(){
        $scope.existOppProduct.map(product=>{
            if(product.Product2Id==='' || product.Product2Id===undefined || product.Quantity===0 || product.Quantity_Unit__c==='' ||
                product.ListPrice===0 || product.ListPrice<0 ||
                product.Quantity_Unit__c===undefined || product.Subtotal===0 || product.Subtotal<0 || product.TotalPrice<0 || product.TotalPrice===0){
                swal("Please enter valid details ");
                return;
            }
        })
        console.log($scope.existOppProduct,$scope.details.Id)
        $rootScope.showSpinner = !$rootScope.showSpinner;
        DistributorDashboard_Controller.createLineItems($scope.existOppProduct,$scope.details.Id,function(result,evt){
            console.log(result);
            if(result===true){
                $scope.getOpportunities();
                $rootScope.showSpinner =!$rootScope.showSpinner;
                $scope.showDetails=!$scope.showDetails;
                $scope.addLineItem=!$scope.addLineItem;
            }
            else{
                $rootScope.showSpinner = !$rootScope.showSpinner;
                swal("Something went wrong");
            }
        })
    }      

	$scope.addOppProduct=function(){
        $scope.OppProduct.push({
            Product2Id:'--select--',
            ProductCode:'',
            Quantity:'',
            UnitPrice:'',
            Markup_Amount__c:'',
            MarkDown_Amount__c:'',
            Packaging_Type__c:'Bulk',
            Packaging_Quantity__c:1,
            Packaging_Unit__c:'select',
            Quantity_Unit__c:'select',
            markupDisabled:false,
            markDownDisabled:false,
        })    
	}
    
    $scope.addOppProductExist=function(){
        $scope.existOppProduct.push({
            Product2Id:'--select--',
            Quantity:'',
            TotalPrice:0,
            ListPrice:0,
            ProductCode:'',
            Subtotal:0,
            Quantity_Unit__c:''
        })    
	}
    $scope.removeProduct=function(index){
        if(index!=0){
            if($scope.OppProduct[index].Id){
                $scope.deleteLineItems.push($scope.OppProduct[index].Id);
            }
            $scope.OppProduct.splice(index,1);
        }
    }
      $scope.removeProductExist=function(index){
          $scope.existOppProduct.splice(index,1);
      }
        $scope.view=function(e){
            $scope.viewOption=$scope.viewOption==='Table'?'Cards':'Table';
            if($scope.viewOption==='Table') $('#example').DataTable();
            //$scope.$apply();
        }
        
});