import { LightningElement,api,wire,track } from 'lwc';
import getProjectRecord from '@salesforce/apex/SampleInvoicePDFController.getProjectRecord';
import savePDF from '@salesforce/apex/SampleInvoicePDFController.savePDF';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import exportSampleURL from '@salesforce/label/c.SampleInvoiceLink'; 
import domesticSampleURL from '@salesforce/label/c.Domestic_Sample_Invoice_URL'; 

export default class SampleDetailsPDF extends LightningElement {

    @api recordId;
    @track urlUsed;
       
    connectedCallback(){
        debugger;
        setTimeout(() => {
            //this.urlUsed = exportSampleURL + this.recordId;
            this.getRecord();
        },300);
    }

    getRecord(){
        debugger;
        getProjectRecord({ smpleId : this.recordId}).then(data=>{
            debugger;
            console.log('Data',data);
            if(data.Shipping_Type__c == 'Export'){
                this.urlUsed = exportSampleURL + this.recordId;
            }
            else if(data.Shipping_Type__c == 'Domestic'){
                this.urlUsed = domesticSampleURL + this.recordId;
            }
        })
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