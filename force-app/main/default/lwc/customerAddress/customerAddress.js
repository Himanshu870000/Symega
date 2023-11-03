import { LightningElement,wire,api,track } from 'lwc';
import getCustomerRecord from '@salesforce/apex/CustomerAddressController.getCustomerRecord' ;
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CustomerAddress extends LightningElement {   

    @api recordId;
    @track showContactNote;

    connectedCallback(){
        setTimeout(() => {
           // this.getRecordDetails();
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails() {
        getCustomerRecord({ dipRecId: this.recordId })
            .then(result => {
               console.log('result--->',result);
               if(result.Contact__c == null){
                   this.showContactNote = true;
               }
                
            })
            .catch(error => {
                console.log(error);
            });
    }

    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }


}