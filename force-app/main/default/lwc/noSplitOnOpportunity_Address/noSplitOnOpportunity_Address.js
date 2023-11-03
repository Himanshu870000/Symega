import { LightningElement,api,track} from 'lwc';
import getAllAddresses from "@salesforce/apex/OppSplitParentController.getAllCustomerAddress";
import createOpp from '@salesforce/apex/NoSplitOpportunityHelper.createOneTimeOppRecLWC';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {CloseActionScreenEvent} from 'lightning/actions';

export default class NoSplitOnOpportunity_Address extends NavigationMixin(LightningElement) {
    @api recordId;
    selectedAddressIndex = -1;
    selectedBilAddressIndex = -1;
    @track ship_addresses = [];
    @track bill_addresses = [];
    error;
    @track checkedShipAdd;
    @track checkedBillAdd
    @track accRecord;
    @track nextBtn = true;
    
    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getAllAddresses({oppId : this.recordId}).then(data => {
            if(data){
                debugger;
                let clonedData = JSON.parse(JSON.stringify(data));
                this.oppRecord = clonedData.Opportunity;
                this.ship_addresses = clonedData.customer_ship_addresses;
                this.bill_addresses = clonedData.customer_bill_addresses;
                this.selectedAddressIndex = clonedData.ship_selected_index != undefined ? clonedData.ship_selected_index : -1;
                this.selectedBilAddressIndex = clonedData.bill_selected_index != undefined ? clonedData.bill_selected_index : -1;
                console.log('RecordId', this.recordId);
                console.log('Data',clonedData);
                if(this.ship_addresses && this.bill_addresses ){
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
        }
         if(this.checkedShipAdd &&  this.checkedBillAdd ){
                this.nextBtn = false;
        }else{
              this.nextBtn = true;
        }
        
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
        }
         if(this.checkedShipAdd &&  this.checkedBillAdd ){
                this.nextBtn = false;
        }else{
              this.nextBtn = true;
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
        if(index === -1 || billingIndex === -1) {
            const evt = new ShowToastEvent({
                title: "No Selection",
                message: "Please select Shipping and Billing address in-order to proceed.",
                variant: "Warning",
            });
            this.dispatchEvent(evt);
            return;
        }

        let selectedAddress = this.ship_addresses[index];
        let addressId = selectedAddress.id;
        let accShipAddress = false;

        let selectedBillingAddress = this.bill_addresses[billingIndex];
        let billAddressId = selectedBillingAddress.id;
        let accountBillAddress = false;
        
        if(selectedAddress.id === 'Shipping') {
            addressId = undefined;
            accShipAddress = true;
        }
        
        if(selectedBillingAddress.id === 'Billing') {
            billAddressId = undefined;
            accountBillAddress = true;
        }

        let billingAddress = this.bill_addresses.find(item=>item.checked);
        let shippingAddress = this.ship_addresses.find(item=>item.checked);

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

            customShippingAddress: addressId,
            accountShipAddress: accShipAddress,
            customBillingAddress: billAddressId,
            accountBillAddress: accountBillAddress
        };

        console.log('addressWrapper -- ' + addressWrapper);

        createOpp({oppId:this.recordId, opWrapper:addressWrapper}).then(result=>{
            console.log('Result----',result);
            if(result === 'SUCCESS'){
                this.isLoaded = true;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.showToast('Success','No-Split Created Successfully','success')
                this.refreshPage();
            }else{
                this.isLoaded = true;
                this.showToast('No-Split Creation Failure',result,'error');
                this.closeAction();
            }
        }).catch(err=>{
            this.isLoaded = true;
            console.log(err);
            //this.showToast('No-Split Creation Failures',err,'error');
            console.log("Error",err);
            this.closeAction();
        })
    }    

    showToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}