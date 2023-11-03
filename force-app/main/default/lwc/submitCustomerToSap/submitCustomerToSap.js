import { LightningElement,api,track } from 'lwc';
import createCustomer from '@salesforce/apex/SAP_CreateCustomerCallout.createCustomer';	
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class SubmitCustomerToSap extends LightningElement 
{
  @api recordId;
  @api display;
    connectedCallback()
    {
        console.log(this.recordId);
       // setTimeout(()=>console.log(this.recordId),this.sendingId(),3000);
        debugger;
        setTimeout(() => this.sendingId(),2000);
       /* createCustomer({recId:this.recordId})
        .then(result => {
            this.display = result;
            this.showSuccessToast();
        })
        .catch(error => {
            this.error = error;
            this.showErrorToast();
        });  */     
    }
    sendingId()
    {
        createCustomer({recId:this.recordId})
        .then(result => {
            this.display = result;
            this.showSuccessToast();
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            this.error = error;
            this.showErrorToast();
            this.dispatchEvent(new CloseActionScreenEvent());
        }); 
    }


    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: 'Operation successfull',
            variant: 'success',
            mode: 'pester'
        });
        this.dispatchEvent(evt);
    }
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Some unexpected error',
            variant: 'error',
            mode: 'pester'
        });
        this.dispatchEvent(evt);
    }

}