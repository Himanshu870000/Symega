import { LightningElement,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getRecordDetails from '@salesforce/apex/ProjectHanlder.getLeadRecord'
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class LeadSampleCreation extends LightningElement(LightningElement) {
    @api recordId;
    projectRecord;
    isAllowedToCreate = false;


    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getRecordDetails({leadId : this.recordId}).then(data=>{
            if(data){
                this.projectRecord = data[0];
                console.log('RecordId',this.recordId);
                console.log('Data',data);
                this.getRd();
            }
        })
    }

    // @wire(getRecordDetails,{ leadId : '$recordId'})
    // recordDetails({data,error}){
    //     if(data){
    //         this.projectRecord = data[0];
    //         console.log('RecordId',this.recordId);
    //         console.log('Data',data);
    //         this.getRd();
    //     }
    //     if(error){
    //         console.log("Error",error);
    //     }
    // }


    getRd(){
        getRecordDetails({ leadId : this.projectRecord.Id}).then(res=>{
            console.log("Log2----",res);
            this.projectRecord = res[0];
            this.isAllowedToCreate = this.projectRecord.Company != NULL;
            if(this.isAllowedToCreate){
                this.openCreateRecordForm();
            }else{
                const event = new ShowToastEvent({
                    title: 'Failed!',
                    message: 'Can not create Sample, Since Company is NULL',
                });
                this.dispatchEvent(event);
                this.closeAction();
            }
        }).catch(error=>{
            console.log("Error",error);
        })
    }

    openCreateRecordForm(){

        let defaultValues = encodeDefaultFieldValues({
            RecordTypeId: 'Sample',
            Customer_Contact__c : this.projectRecord.Company,
            Lead__c : this.projectRecord.Id
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Project__c',
                actionName: 'new'
            },state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}