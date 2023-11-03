import { LightningElement,api,wire,track} from 'lwc';
import getAllAddresses from "@salesforce/apex/ProjectHanlder.getAllCustomerAddress";
import getAccountDetails from '@salesforce/apex/ProjectHanlder.getAccRecord';
import getRecordTypeId from '@salesforce/apex/ProjectHanlder.getOppRecordTypeId';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateOpportunityOnAccount extends NavigationMixin(LightningElement) {
    @api recordId;
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
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getAllAddresses({custId : this.recordId}).then(data => {
            if(data){
                debugger;
                let clonedData = JSON.parse(JSON.stringify(data));
                this.accRecord = clonedData.account;
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
            // if(error){
            //     this.error = error;
            //     console.log("Errorsss",error);
            // }
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
        
    
        this.openCreateRecordForm(addressId, accShipAddress, billAddressId, accountBillAddress);
    }    

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
   
    openCreateRecordForm(addressId, accShipAddress, billAddressId, accountBillAddress){
        debugger;
        getRecordTypeId({recordTypeName: 'Parent'}).then(result=>{
            console.log("RecordTypeRECEIVED-----",result);
            console.log("accShipAddress-----",accShipAddress);
            console.log("accountBillAddress-----",accountBillAddress);

            let billingAddress = this.bill_addresses.find(item=>item.checked);
            let shippingAddress = this.ship_addresses.find(item=>item.checked);


            let recordTypeId = result;
            let defaultValues = encodeDefaultFieldValues({
                AccountId:this.accRecord.Id,
                Name:`${this.accRecord.Name}-Opportunity`,
                StageName:'New',
                CurrencyIsoCode : this.accRecord.CurrencyIsoCode,
                LeadSource : this.accRecord.AccountSource,

                Billing_City__c : billingAddress.city,
                Billing_State__c : billingAddress.state,
                Billing_Street__c : billingAddress.street,
                Billing_Postal_Code__c : billingAddress.postalCode,
                Billing_Country__c : billingAddress.country,

                Shipping_City__c : shippingAddress.city,
                Shipping_State__c : shippingAddress.state,
                Shipping_Street__c : shippingAddress.street,
                Shipping_Postal_Code__c : shippingAddress.postalCode,
                Shipping_Country__c : shippingAddress.country,

                Customer_Shipping_Address__c: addressId,
                Account_Shipping_Address__c: accShipAddress,
                Customer_Billing_Address__c: billAddressId,
                Account_Billing_Address__c: accountBillAddress
            });

            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Opportunity',
                    actionName: 'new'
                },state: {
                defaultFieldValues: defaultValues,
                recordTypeId: recordTypeId
                }
            });
        }).catch(error=>{
            console.log("Error-----",error);
        })
    }
}