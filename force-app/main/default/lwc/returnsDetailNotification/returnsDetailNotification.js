import { LightningElement, api, wire } from 'lwc';
import notificationDetails from '@salesforce/apex/Utility.sendReturnDetailsNotificaiton';
import updateSaleOrder from '@salesforce/apex/ProjectHanlder.updateSaleOrder';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class ReturnsDetailNotification extends LightningElement {
    @api recordId;


    connectedCallback() {
        setTimeout(() => {
            this.goalTrackingRecordDetails();
        }, 300);
    }

    goalTrackingRecordDetails() {
        notificationDetails({ saleOrderId: this.recordId })
            .then(data => {
                if(data){
                    this.updateSO_Record();
                    console.log(data);
                    
                }
        })
    }


    // @wire(notificationDetails,{ saleOrderId : '$recordId'})
    // recordDetails(result){
    //     debugger;
    //     if(result.data){
    //         this.updateSO_Record();
    //         console.log(result);
    //     }
    // }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    updateSO_Record(){
        updateSaleOrder({soId : this.recordId}).then(res=>{
            debugger;
            console.log('Sale Order Update Result',res);
            this.showNotification('Success','Return details have been sent successfully','success');
            this.closeAction();
        }).catch(error=>{
            console.log("Error",error);
        })
    }
    showNotification(title,message,variant){
        debugger;
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    connectedCallback() {
        debugger;
        setTimeout(()=>this.closeAction(),2000);
    }
}