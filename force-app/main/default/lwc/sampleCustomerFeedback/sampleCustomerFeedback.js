import { LightningElement,wire,api,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createFeedback from '@salesforce/apex/ProjectHanlder.createFeedback' 
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class SampleCustomerFeedback extends NavigationMixin(LightningElement) {
    
    @api recordId
    @track dateChoosed;
    @track feedback;

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    inputChange(event){
        let name = event.target.name;
        let value = event.target.value;
        
        if(name=='feedback'){
            this.feedback = value;
        }else{
            if(new Date(value) <new Date()){
                this.dateChoosed = null;
                this.showNotification('Invalid Date','Past Date cannot be choose.','error')
            }else{
                this.dateChoosed = value;
            }
        }
    }

    recordPageUrl;
    submitForm(){
        if(this.feedback!=null && this.dateChoosed!=null){
            debugger;
            let obj = {};
            obj.Specific_inputs_by_customer__c = this.feedback;
            obj.Actual_Date_of_Dispatch__c	 = new Date(this.dateChoosed).toISOString();
            createFeedback({id:this.recordId,feedback:obj.Specific_inputs_by_customer__c,cDate:obj.Actual_Date_of_Dispatch__c}).then(result=>{
                console.log("Result",result);
                if(result && result.status) {
                    this.showNotification('Success','Feedback Submitted','success');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.message,
                            objectApiName: 'Project__c', // objectApiName is optional
                            actionName: 'view'
                        }
                    });
                    this.closeAction();
                }else {
                    this.showNotification('Error',result && result.message ? result.message : 'Failed to submit feedback, contact system administrator','error');
                }
            }).catch(err=>{
                console.log("Error---",err);
                this.showNotification('Failed','Failed to submit feedback','error');
            })
        }
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