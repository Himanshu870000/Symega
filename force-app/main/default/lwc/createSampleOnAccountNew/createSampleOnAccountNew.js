import { LightningElement,api,wire,track} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROJECT_OBJECT from '@salesforce/schema/Project__c';
import getRecordDetails from '@salesforce/apex/ProjectHanlder.getAccRecord';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateSampleOnAccountNew extends NavigationMixin(LightningElement) {
    
    accRecord;

    @api recordId;
    @track recordTypeSelected;
    @track options = [];
    @track showModal = true;
    @track showCreateNewRecordForm = false;
    
    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getRecordDetails({accId : this.recordId}).then(data=>{
            if(data){
                this.accRecord = data;
                console.log('RecordId', this.recordId);
                console.log('Data',data);
            }
        })
    }


    // @wire(getRecordDetails,{ accId : '$recordId'})
    // recordDetails({data,error}){
    //     if(data){
    //         this.accRecord = data;
    //         console.log('RecordId', this.recordId);
    //         console.log('Data',data);
    //     }
    //     if(error){
    //         console.log("Errorsss",error);
    //     }
    // }


    @wire(getObjectInfo, { objectApiName: PROJECT_OBJECT })
    accObjectInfo({data, error}) {
        if(data) {
            let optionsValues = [];
            const rtInfos = data.recordTypeInfos;

            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master') {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }

            this.recordTypeSelected = optionsValues[0].value;
            this.options = optionsValues;
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    }

    closeModal(){
        this.showModal = false;
    }

    handleChange(event) {
        debugger;
        this.recordTypeSelected = event.detail.value;
        console.log("RecordTyId",this.recordTypeSelected);
    }

    handleSuccess(){
        if(!this.recordTypeSelected){
            this.showNotification('Empty!',"Choose record Type","error");
            return;
        }
        this.closeModal();
        this.openCreateRecordForm();
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


    openCreateRecordForm(){
        debugger;
        console.log('rec',this.recordTypeSelected);
        
        let defaultValues = encodeDefaultFieldValues({
            Account__c:this.recordId,
            Customer_Name__c :this.accRecord.Name,
            // Lead__c : this.leadRecord.Id,
            Name:`${this.accRecord.Name}-sample`,
            // City__c:this.leadRecord.Address?this.leadRecord.Address.city:"",
            // Country__c:this.leadRecord.Address?this.leadRecord.Address.country:"",
            // Postal_Code__c	:this.leadRecord.Address?this.leadRecord.Address.postalCode:"",
            // State__c:this.leadRecord.Address?this.leadRecord.Address.state:"",
            // Street__c:this.leadRecord.Address?this.leadRecord.Address.street:"",
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Project__c',
                actionName: 'new'
            },state: {
               defaultFieldValues: defaultValues,
               recordTypeId: this.recordTypeSelected
            }
        });
    }

}