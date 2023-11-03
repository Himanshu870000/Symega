import { LightningElement,wire,api } from 'lwc';
import getAccRecord from '@salesforce/apex/AccountHandler.getRecord'
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class CreateSalesOrderAccount extends NavigationMixin(LightningElement) {
    @api recordId;
    accRecord;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getAccRecord({accId:this.recordId}).then(data=>{
            if(data){
                this.accRecord = data[0];
                console.log('RecordId',this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }

    // @wire(getAccRecord,{accId:'$recordId'})
    // recordDetails({data,error}){
    //     if(data){
    //         this.accRecord = data[0];
    //         console.log('RecordId',this.recordId);
    //         console.log('Data',data);
    //         this.openCreateRecordForm();
    //     }
    //     if(error){
    //         console.log("Error",error);
    //     }
    // }

    openCreateRecordForm(){
        let defaultValues = encodeDefaultFieldValues({
            Account__c: this.accRecord.Id
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