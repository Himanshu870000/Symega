import { LightningElement,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getRecordDetails from '@salesforce/apex/ProjectHanlder.getPrjQntRecord';
import getRecordTypeId from '@salesforce/apex/ProjectHanlder.getProjectRecordTypeId';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreateTechDocOnPrjQnt extends NavigationMixin(LightningElement) {
    @api recordId;
    qntRecord;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getRecordDetails({id : this.recordId}).then(data=>{
            if(data){
                this.qntRecord = data;
                console.log('RecordId', this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }

    // @wire(getRecordDetails,{ id : '$recordId'})
    // recordDetails({data,error}){
    //     debugger;
    //     if(data){
    //         this.qntRecord = data;
    //         console.log('RecordId', this.recordId);
    //         console.log('Data',data);
    //         this.openCreateRecordForm();
    //     }
    //     if(error){
    //         console.log("Errorsss",error);
    //     }
    // }

    openCreateRecordForm(){
        debugger;
        getRecordTypeId({recordTypeName: 'Tech_Doc'}).then(result=>{
            console.log("RecordTypeRECEIVED-----",result);
            let recordTypeId = result;
            let defaultValues = encodeDefaultFieldValues({
                Tech_Doc_Name__c :this.qntRecord.Name,
                Product_ID__c:this.qntRecord.SSC_Code__c,
                CurrencyIsoCode : this.qntRecord.CurrencyIsoCode,
                Account__c : this.qntRecord.Sample_Project_Application__r.Account__c
            });

            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Project__c',
                    actionName: 'new'
                },state: {
                    defaultFieldValues: defaultValues,
                    recordTypeId: recordTypeId
                }
            });
        }).catch(error=>{
            console.log("Error-----",error);
        })
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}