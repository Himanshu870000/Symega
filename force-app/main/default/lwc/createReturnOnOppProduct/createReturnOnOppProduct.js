import { LightningElement,api,wire,track} from 'lwc';
import getRecordDetails from '@salesforce/apex/lwcComponentHelper.getOppProductRecord';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';


export default class CreateReturnOnOppProduct extends NavigationMixin(LightningElement) {

    @api recordId;
    @track recordTypeSelected;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getRecordDetails({ lineItemId : this.recordId}).then(data=>{
            if(data){
                this.prodRecord = data;
                console.log('RecordId', this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }   

    // @wire(getRecordDetails,{ lineItemId : '$recordId'})
    // recordDetails({data,error}){
    //     if(data){
    //         this.prodRecord = data;
    //         console.log('RecordId', this.recordId);
    //         console.log('Data',data);
    //         this.openCreateRecordForm();
    //     }
    //     if(error){
    //         console.log("Error",error);
    //     }
    // }

    openCreateRecordForm(){
        let defaultValues = encodeDefaultFieldValues({
            Name: `${this.prodRecord.Name} - Return`,
            Opportunity_Product__c: this.prodRecord.Id,
            Sale_Order__c	: this.prodRecord.Sales_Order__c
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Return__c',
                actionName: 'new'
            },state: {
                defaultFieldValues: defaultValues
            }
        });
    }
    
}