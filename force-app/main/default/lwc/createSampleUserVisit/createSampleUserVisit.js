import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateSampleUserVisit extends NavigationMixin(LightningElement) {
    
    connectedCallback(){
        debugger;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Project__c',
                actionName: 'new'
            }
        });
    }
}