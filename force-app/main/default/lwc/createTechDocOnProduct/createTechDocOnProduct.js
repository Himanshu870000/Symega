import { LightningElement,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getRecordDetails from '@salesforce/apex/ProjectHanlder.getProdRecord';
import getRecordTypeId from '@salesforce/apex/ProjectHanlder.getProjectRecordTypeId';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreateTechDocOnProduct extends NavigationMixin(LightningElement) {
    
    @api recordId;
    prodRecord;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getRecordDetails({id : this.recordId}).then(data=>{
            if(data){
                this.prodRecord = data;
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
    //         this.prodRecord = data;
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
                Tech_Doc_Name__c :this.prodRecord.Name,
                Product_ID__c:this.prodRecord.Id,
                CurrencyIsoCode : this.prodRecord.CurrencyIsoCode
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