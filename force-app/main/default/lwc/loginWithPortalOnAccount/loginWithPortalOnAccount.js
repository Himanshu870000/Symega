import { LightningElement,api,wire} from 'lwc';
import distributerBaseUrl from '@salesforce/label/c.SymegaSiteURL'
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateHashCode from '@salesforce/apex/LoginWithPortalOnAccountController.hashcodeCreationUpdation'
import pendingDocuments from '@salesforce/apex/LoginWithPortalOnAccountController.pendingDocuments'

const FIELDS = [
    'Account.Login_Hash_Code__c',
    'Account.Status__c'
];

export default class LoginWithPortalOnAccount extends LightningElement {
    @api recordId;

    // connectedCallback(){
    //     setTimeout(() => {
    //         this.getRecordDetails();
    //     }, 300);
    // }

    // getRecordDetails(){
    //     getRecord({ recordId: this.recordId, fields: FIELDS }).then(data=>{
    //         if(data){
    //             if(data.fields.Status__c.value=='Document Submission' && data.fields.Login_Hash_Code__c.value){
    //                 let loginUrl = `${distributerBaseUrl}documentUpload?hc=${data.fields.Login_Hash_Code__c.value}`;
    //                 window.open(loginUrl, '_blank');
    //                 this.closeAction();
    //             }else if(data.fields.Login_Hash_Code__c.value){
    //                 this.checkDocumentStatus(data.fields.Login_Hash_Code__c.value);
    //             }else{
    //                 this.generateHashCode();
    //             }
    //         }
    //     })
    // }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredResponse(result){
        debugger;
        console.log('Result-----',result);
        if(result && result.data){
            if(result.data.fields.Status__c.value=='Document Submission' && result.data.fields.Login_Hash_Code__c.value){
                let loginUrl = `${distributerBaseUrl}documentUpload?hc=${result.data.fields.Login_Hash_Code__c.value}`;
                window.open(loginUrl, '_blank');
                this.closeAction();
            }else if(result.data.fields.Login_Hash_Code__c.value){
                this.checkDocumentStatus(result.data.fields.Login_Hash_Code__c.value);
            }else{
                this.generateHashCode();
            }
        }
    }

    checkDocumentStatus(hashCode){
        let loginUrl;
        debugger;
        pendingDocuments({accId:this.recordId}).then(result=>{
            if(result){
                loginUrl = `${distributerBaseUrl}documentUpload?hc=${hashCode}`;
            }else{
                loginUrl = `${distributerBaseUrl}DistributorDashboard?hc=${hashCode}#/Home`;
            }
            window.open(loginUrl, '_blank');
            this.closeAction();
        }).catch(error=> this.showNotification('Error',error,'error'));
    }

    generateHashCode(){
        generateHashCode({accId:this.recordId}).then(result=>{
            this.checkDocumentStatus(result);
        }).catch(error=>{
            console.log('Error',error);
            this.showNotification('Failed',error,'error');
            this.closeAction();
        })
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