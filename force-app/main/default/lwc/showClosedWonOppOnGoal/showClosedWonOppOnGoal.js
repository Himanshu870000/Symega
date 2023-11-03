import { LightningElement, api, wire} from 'lwc';
import getAllClosedWonOpportunitites from '@salesforce/apex/lwcComponentHelper.getAllClosedWonOpportunitites';

export default class ShowClosedWonOppOnGoal extends LightningElement {

    @api recordId ;
    closedwonOpportunity = [];

    connectedCallback() {
        setTimeout(() => {
            this.goalTrackingRecordDetails();
        }, 300);
    }


    goalTrackingRecordDetails() {
        getAllClosedWonOpportunitites({ goalId: this.recordId })
            .then(data => {
                if(data){
                    console.log('Data',data);
                    this.closedwonOpportunity =data;
                    
                }
        })
    }
    
    // @wire(getAllClosedWonOpportunitites,{goalId : '$recordId'})
    // wiredResponse(result){
    //     //debugger;
    //     if(result && result.data){
    //         this.closedwonOpportunity = result.data;
    //     }
    //     console.log("Result-----",result);
    // }

}