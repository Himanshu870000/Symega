import { LightningElement,api,track,wire } from 'lwc';
import getOppRecord from '@salesforce/apex/OpportunityHanlder.getRecord'
import getAllAddresses from "@salesforce/apex/OpportunityHanlder.getAllCustomerAddress";
import updateAddress from "@salesforce/apex/OpportunityHanlder.updateAddress";
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
export default class ChangeAddress extends  NavigationMixin(LightningElement) {

     @api recordId;
    oppRecord;
    selectedAddressIndex = -1;
    selectedBilAddressIndex = -1;
    @track ship_addresses = [];
    @track bill_addresses = [];
    error;
    @track checkedShipAdd;
    @track checkedBillAdd
    @track accRecord;
    //@track oppRecord;
    @track nextBtn = true;
    llcUser = false;
    @track selectedBillingAdd;
    @track selectedShippingAdd;

    connectedCallback(){
        setTimeout(() => {
           // this.getRecordDetails();
            this.getRecordDetails1();
        }, 300);
    }

    getRecordDetails(){
        getOppRecord({oppId:this.recordId}).then(data=>{
            if(data){
                this.oppRecord = data[0];
                console.log('RecordId',this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }

    getRecordDetails1(){
         debugger;
        getAllAddresses({custId : this.recordId}).then(data => {
            if(data){
                debugger;
                let clonedData = JSON.parse(JSON.stringify(data));
               // this.accRecord = clonedData.account;
                //this.oppRecord = clonedData.opp;
                this.ship_addresses = clonedData.customer_ship_addresses;
                this.bill_addresses = clonedData.customer_bill_addresses;
                console.log('this.ship_addresses---->',JSON.stringify(this.ship_addresses));
                console.log('  this.bill_addresses--->',JSON.stringify(this.bill_addresses));
                this.selectedAddressIndex = clonedData.ship_selected_index != undefined ? clonedData.ship_selected_index : -1;
                this.selectedBilAddressIndex = clonedData.bill_selected_index != undefined ? clonedData.bill_selected_index : -1;
                console.log('RecordId', this.recordId);
                console.log('Data',clonedData);
                if(this.ship_addresses){
                    this.nextBtn = false;
                }else{
                    this.nextBtn = true;
                }
            }
            
       })
    }
    
      onAddressSelect(event) {
        debugger;
        let addressId = event.currentTarget.dataset.id;
        let selectedIndex = event.currentTarget.dataset.index;
         this.checkedShipAdd = event.target.checked;
         if(this.checkedBillAdd==undefined){
              this.checkedBillAdd=true;
          }   
        if(addressId && selectedIndex ) {
            if(this.selectedAddressIndex !== -1)
                this.ship_addresses[this.selectedAddressIndex].checked = false;
            this.ship_addresses[selectedIndex].checked = true;
            this.selectedAddressIndex = selectedIndex;
          //  this.nextBtn = false; // added
        }
         if(this.checkedShipAdd){
                this.nextBtn = false;
        }else{
              this.nextBtn = true;
        }
        
        if(this.checkedShipAdd){
            this.selectedShippingAdd =   this.ship_addresses[parseInt(this.selectedAddressIndex)];
            console.log(JSON.stringify(this.selectedShippingAdd));
 
        }
        //else if(this.checkedBillAdd){
        //       this.selectedBillingAdd =   this.bill_addresses[parseInt(this.selectedAddressIndex)];
        //       console.log(JSON.stringify(this.selectedBillingAdd ));

        // }
    }

     onBillAddressSelect(event) {
        debugger;
        let addressId = event.currentTarget.dataset.id;
        let selectedIndex = event.currentTarget.dataset.index;
         this.checkedBillAdd = event.target.checked;   
          if(this.checkedShipAdd==undefined){
              this.checkedShipAdd=true;
          }
        if(addressId && selectedIndex ) {
            if(this.selectedBilAddressIndex !== -1)
                this.bill_addresses[this.selectedBilAddressIndex].checked = false;
            this.bill_addresses[selectedIndex].checked = true;
            this.selectedBilAddressIndex = selectedIndex;
          //   this.nextBtn = false; 
        }
         if(this.checkedShipAdd){
                this.nextBtn = false;
        }else{
              this.nextBtn = true;
        }

        // if(this.checkedShipAdd){
        //     this.selectedShippingAdd =   this.ship_addresses[parseInt(this.selectedAddressIndex)];
        //     console.log(JSON.stringify(this.selectedShippingAdd));
 
        // }else 
        if(this.checkedBillAdd){
              this.selectedBillingAdd =   this.bill_addresses[parseInt(this.selectedBilAddressIndex)];
              console.log(JSON.stringify(this.selectedBillingAdd ));

        }
    }

    
    handleNavigate() {
        debugger;
        let index = this.ship_addresses.findIndex((item) => {
            return item.checked === true;
        });

        let billingIndex = this.bill_addresses.findIndex((item) => {
            return item.checked === true;
        });
        if(index === -1) {
            const evt = new ShowToastEvent({
                title: "No Selection",
                message: "Please select Shipping address in-order to proceed.",
                variant: "Warning",
            });
            this.dispatchEvent(evt);
            return;
        }

        if(index === 0) {
            const evt = new ShowToastEvent({
                title: "No Selection",
                message: "Existing Shipping Address should not be selected.",
                variant: "Warning",
            });
            this.dispatchEvent(evt);
            return;
        }



        
        // let selectedAddress = this.ship_addresses[index];
        // let addressId = selectedAddress.id;
        // let accShipAddress = false;

        // let selectedBillingAddress = this.bill_addresses[billingIndex];
        // let billAddressId = selectedBillingAddress.id;
        // let accountBillAddress = false;
        
        // if(selectedAddress.id === 'Shipping') {
        //     addressId = undefined;
        //     accShipAddress = true;
        // }
        
        // if(selectedBillingAddress.id === 'Billing') {
        //     billAddressId = undefined;
        //     accountBillAddress = true;
        // }
        
    
      //  this.openCreateRecordForm(addressId, accShipAddress, billAddressId, accountBillAddress);
       //   this.openCreateRecordForm();
       //  this.getRecordDetails();
       // here we have to save the Record
       this.updateRecordDetails();
    }    


     updateRecordDetails() {
         debugger;

         if( this.selectedBillingAdd == undefined){
            this.selectedBillingAdd =  this.ship_addresses[0] ;
         } else if(this.selectedShippingAdd == undefined){
             this.selectedShippingAdd =   this.bill_addresses[0] ;

         }
        let billingAddress= this.selectedBillingAdd;
        let shippingAddress= this.selectedShippingAdd;
           const addressWrapper = {
            shipCity: shippingAddress.city,
            shipCountry: shippingAddress.country,
            shipState : shippingAddress.state,
            shipStreet : shippingAddress.street,
            shipCode : shippingAddress.postalCode,

            billCity : billingAddress.city,
            billState : billingAddress.state,
            billStreet : billingAddress.street,
            billCode : billingAddress.postalCode,
            billCountry : billingAddress.country,
           }

           updateAddress({ oppId: this.recordId,recordAddress: addressWrapper })
            .then(result => {
                console.log('result---->'+result);
                if(result == 'SUCCESS'){
                    this.showToast();
                    this.closeAction();
                }              
            })
            .catch(error => {
                console.log(error);
               
            });
 
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Record Updated',
            message: 'Address Updated SuccessFully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    
     closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }



    // openCreateRecordForm(){
    //     let defaultValues = encodeDefaultFieldValues({
    //         Name: `${this.oppRecord.Name} - SO`,
    //         Account__c:this.oppRecord.AccountId,
    //         Opportunity__c: this.oppRecord.Id,
    //         Amount__c: this.oppRecord.Amount,
    //         Order_quantity__c:this.oppRecord.TotalOpportunityQuantity,
    //         Distributer_Customer__c:this.oppRecord.AccountId,
    //         CurrencyIsoCode: this.oppRecord.CurrencyIsoCode
    //     });
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__objectPage',
    //         attributes: {
    //             objectApiName: 'Sales_Order__c',
    //             actionName: 'new'
    //         },state: {
    //             defaultFieldValues: defaultValues
    //         }
    //     });
    // }

}