import { LightningElement,api,wire,track } from 'lwc';
import savePDF from '@salesforce/apex/SampleInvoicePDFController.savePDF'
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import challanLink from '@salesforce/label/c.NonHazordous'; 
export default class NonHardousPdf extends LightningElement {

     @api recordId;
    @track urlUsed;
       
     connectedCallback(){
         debugger;
        setTimeout(() => {
             this.urlUsed = challanLink + this.recordId;
         },300);
     }

    savePDF(){
        debugger;
        savePDF({url:this.urlUsed,id:this.recordId,fileName:"Sample Invoice"}).then(result => {
            console.log("JADSJKHKDHSD",result);
            this.showNotification('Success','Your Delivery Challan generated successfully','success');
            this.closeAction();
        }).catch(error=>{
            console.log("Error",error);
        });
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }



}