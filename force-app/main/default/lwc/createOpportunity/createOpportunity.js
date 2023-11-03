import { LightningElement,wire,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getProjectRecord from '@salesforce/apex/ProjectHanlder.getProjectRecord'
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class CreateOpportunity extends NavigationMixin(LightningElement) {
      // -- AUTHOR:: Bhasker --
    
    @api recordId;
    projectRecord;
    isAllowedToCreate = false;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getProjectRecord({projectId : this.recordId}).then(data=>{
            if(data){
                this.projectRecord = data[0];
                console.log('RecordId',this.recordId);
                console.log('Data',data);
                this.getRd();
            }
        })
    }

    // @wire(getProjectRecord,{projectId:'$recordId'})
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
        getProjectRecord({projectId:this.projectRecord.Id}).then(res=>{
            console.log("Log2----",res);
            this.projectRecord = res[0];
            this.isAllowedToCreate = true /*this.projectRecord.Status__c == 'Sample Accepted'*/;
            if(this.isAllowedToCreate){
                this.openCreateRecordForm();
            }else{
                const event = new ShowToastEvent({
                    title: 'Failed!',
                    message: 'Can not create opportunity, Since sample is not accepted',
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
            Name: `Project Opportunity`,
            Sample__c: this.projectRecord.Id,
            AccountId:this.projectRecord.Account__c,
            CloseDate:this.projectRecord.Opportunity_Close_Date__c?this.projectRecord.Opportunity_Close_Date__c:null,
            StageName:'New',
            End_Use_Category__c:this.projectRecord.End_Use_category__c,
            End_Use_Application__c:this.projectRecord.End_Use_Applications__c,
            CurrencyIsoCode : this.projectRecord.CurrencyIsoCode
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
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