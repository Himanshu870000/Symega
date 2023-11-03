import { LightningElement, api, wire } from 'lwc';
import emailToFinanceTeam from '@salesforce/apex/Utility.sendPLPriceReqEmailNotificaiton'
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RequestPvtLabelPrice extends LightningElement {

    @api recordId;


    connectedCallback() {
        setTimeout(() => {
            this.goalTrackingRecordDetails();
        }, 300);
    }

    goalTrackingRecordDetails() {
        emailToFinanceTeam({ oppId: this.recordId })
            .then(data => {
                if(data){
                    console.log('Data',data);
                    this.showNotification('Success','Request for Pvt Label Price sent successfully','success');
                    this.closeAction();
                }
        })
    }


    // @wire(emailToFinanceTeam,{ oppId : '$recordId'})
    // recordDetails(result){
    //     debugger;
    //     if(result){
    //         this.showNotification('Success','Request for Pvt Label Price sent successfully','success');
    //         this.closeAction();
    //     }
    //     // if(error){
    //     //     console.log("Error in sending the Email",error);
    //     // }
    // }

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

    connectedCallback() {
        // alert("Called");
        setTimeout(()=>this.closeAction(),2000);
    }
}