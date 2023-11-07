import { LightningElement,wire,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getRecordDetails from '@salesforce/apex/ProjectHanlder.getSliRecord';
import getRecordTypeId from '@salesforce/apex/ProjectHanlder.getProjectRecordTypeId';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class RequestTecDocOnSLI extends  NavigationMixin(LightningElement) {

     @api recordId;
     qntRecord;

      connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

     getRecordDetails(){
        getRecordDetails({sampLId : this.recordId}).then(data=>{
            if(data){
                this.qntRecord = data;
                console.log('RecordId', this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }

    openCreateRecordForm(){
        debugger;
        getRecordTypeId({recordTypeName: 'Tech_Doc'}).then(result=>{
            console.log("RecordTypeRECEIVED-----",result);
            let recordTypeId = result;
            let defaultValues = encodeDefaultFieldValues({
                Tech_Doc_Name__c :this.qntRecord.Line_Item_Name__c,
                Product_ID__c:this.qntRecord.Product__r.Name,
                CurrencyIsoCode : this.qntRecord.CurrencyIsoCode,
                Account__c : this.qntRecord.Sample__r.Opportunity__r.Account.Id
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