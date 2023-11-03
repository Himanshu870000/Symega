import { LightningElement, api, wire, track } from 'lwc';
import getProductFields from '@salesforce/apex/CreateProductHandler.getProductFields';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateProduct extends NavigationMixin(LightningElement) {
    @api recordId;
    @track recordTypeSelected;
    @track productFields; 

    connectedCallback(){
        setTimeout(() => {
                this.openCreateRecordForm();
        
        }, 300);
    }

    //@wire(getRecordDetails,{ accId : '$recordId'})

    getRecordDetails(){
        getRecordDetails({accId : this.recordId}).then(data=>{
            if(data){
                this.accRecord = data;
                console.log('RecordId', this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }

    openCreateRecordForm(){
        debugger;
        
            //console.log("RecordTypeRECEIVED-----",result);
            // let recordTypeId = result;
            // let defaultValues = encodeDefaultFieldValues({
            //     Account__c:this.recordId,
            //     Customer_Name__c :this.accRecord.Name,
            //     Application_Name__c	:`${this.accRecord.Name}-Application`,
            //     Customers_Contact__c:this.accRecord.Customer_Contact__c,
            //     City__c:this.accRecord.ShippingCity?this.accRecord.ShippingCity:"",
            //     Country__c:this.accRecord.ShippingCountry?this.accRecord.ShippingCountry:"",
            //     Postal_Code__c	:this.accRecord.ShippingPostalCode?this.accRecord.ShippingPostalCode:"",
            //     State__c:this.accRecord.ShippingState?this.accRecord.ShippingState:"",
            //     Street__c:this.accRecord.ShippingStreet?this.accRecord.ShippingStreet:"",
            //     CurrencyIsoCode : this.accRecord.CurrencyIsoCode
            // });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Product2',
                actionName: 'new'
            },state: {
               
            }
        });
    }
}