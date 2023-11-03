import { LightningElement,api,wire} from 'lwc';
import distributerBaseUrl from '@salesforce/label/c.SymegaSiteURL'
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = [
    'Contact.Login_Hash_Code__c'
];

export default class LoginWithPortalOnContact extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredResponse(result){
        debugger;
        if(result && result.data){
            if(result.data.fields.Login_Hash_Code__c.value){
                let loginUrl = `${distributerBaseUrl}DistributorDashboard?hc=${result.data.fields.Login_Hash_Code__c.value}#/Home`
                console.log("LoginURL------",loginUrl);
                window.open(loginUrl, '_blank');
                this.closeAction();
            }else{
                this.showNotification('Failed','HashCode is not available','error');
                this.closeAction();
            }
        }
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


    // connectedCallback(){
    //     let loginUrl = `${distributerBaseUrl}apex/DistributorDashboard?hc=${this.hashCode}#/Home`
    //     console.log("LoginURL------",loginUrl);
    //     window.open(loginUrl, '_blank');
    // }
}