import { LightningElement,wire,api,track } from 'lwc';
import getOppRecord from '@salesforce/apex/OpportunityHanlder.getRecord'
import getAllAddresses from "@salesforce/apex/OpportunityHanlder.getAllCustomerAddress";
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class CreateSalesOrder extends NavigationMixin(LightningElement){
    
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
          //  this.nextBtn = false; // added
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
          //   this.nextBtn = false; 
        }
         if(this.checkedShipAdd &&  this.checkedBillAdd ){
                this.nextBtn = false;
        }else{
              this.nextBtn = true;
        }
    }


    // @wire(getOppRecord,{oppId:'$recordId'})
    // recordDetails({data,error}){
    //     if(data){
    //         this.oppRecord = data[0];
    //         console.log('RecordId',this.recordId);
    //         console.log('Data',data);
    //         this.openCreateRecordForm();
    //     }
    //     if(error){
    //         console.log("Error",error);
    //     }
    // }
    
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
        
    
      //  this.openCreateRecordForm(addressId, accShipAddress, billAddressId, accountBillAddress);
       //   this.openCreateRecordForm();
        this.getRecordDetails();
    }    
    
     closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }



    openCreateRecordForm(){
        let defaultValues = encodeDefaultFieldValues({
            Name: `${this.oppRecord.Name} - SO`,
            Account__c:this.oppRecord.AccountId,
            Opportunity__c: this.oppRecord.Id,
            Amount__c: this.oppRecord.Amount,
            Order_quantity__c:this.oppRecord.TotalOpportunityQuantity,
            Distributer_Customer__c:this.oppRecord.AccountId,
            CurrencyIsoCode: this.oppRecord.CurrencyIsoCode
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Sales_Order__c',
                actionName: 'new'
            },state: {
                defaultFieldValues: defaultValues
            }
        });
    }


}