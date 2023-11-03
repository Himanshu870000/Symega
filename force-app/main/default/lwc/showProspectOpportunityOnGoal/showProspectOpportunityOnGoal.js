import { LightningElement, api, wire} from 'lwc';
import goalTrackingRecord from '@salesforce/apex/lwcComponentHelper.getAllProspectOpportunitites';

export default class ShowProspectOpportunityOnGoal extends LightningElement {
    @api recordId;
    prospectOpp = [];

    connectedCallback() {
        setTimeout(() => {
            this.goalTrackingRecordDetails();
        }, 300);
    }

    goalTrackingRecordDetails() {
        goalTrackingRecord({ goalId: this.recordId })
            .then(data => {
                if(data){
                    console.log('Data',data);
                    this.prospectOpp =data;
                    
                }
        })
    }


    // @wire(goalTrackingRecord,{goalId : '$recordId'})
    // wiredResponse(result){
    //     //debugger;
    //     if(result && result.data){
    //         this.prospectOpp = result.data;
    //     }
    //     console.log("Result-----",result);
    // }
}