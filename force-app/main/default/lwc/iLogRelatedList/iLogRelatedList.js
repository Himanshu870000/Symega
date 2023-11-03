import { LightningElement,api,wire,track } from 'lwc';
//import { NavigationMixin } from 'lightning/navigation';
import passRecordId from '@salesforce/apex/ILogRelatedListLwcController.passRecordId';
export default class ILogRelatedList extends LightningElement 
{
     columns = [
      //  {
      //  type: 'action',
      //  typeAttributes: {rowActions: actions,}
      //  },
        { label: 'Name', fieldName: 'nameUrl', type: 'url',
        typeAttributes: {label: { fieldName: 'name' }, 
        target: '_blank'} },
        { label: 'EndPoint', fieldName: 'endPoint' },
        { label: 'HTTP_Method', fieldName: 'methodType' },
        { label: 'Integration_Type', fieldName: 'integrationType' },
        { label: 'Processing_Time_in_MilliSeconds', fieldName: 'processingTimeInMilliseconds'},
        { label: 'Reference_Id', fieldName: 'referenceId'},
        { label: 'Request_Body', fieldName: 'requestBody'},
        { label: 'Response_Body', fieldName: 'responseBody'},
        { label: 'Response_Status_Code', fieldName: 'responseStatusCode'},
        { label: 'CreatedDate', fieldName: 'createdDate'},

    ];
    
    @api recordId;
         data = [];
        //columns = columns;
       //  connectedCallback() {}
       // Navigate to View Account Page
   /* navigateToViewAccountPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }*/
            
       @wire(passRecordId, {recId: '$recordId'}) 
    WiredRecords({error, data}){
        if(data){
            this.data = data;
            console.log('RecordId---->',this.recordId);
            console.log('dataaa--->',this.data);
            this.error = undefined;
        }else{
            this.error = error;
            
        }
    }
}