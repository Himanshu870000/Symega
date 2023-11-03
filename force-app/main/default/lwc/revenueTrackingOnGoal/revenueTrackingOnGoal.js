import { LightningElement, api, track } from 'lwc';
import getRevenueTrackData from '@salesforce/apex/lwcComponentHelper.getRevenueTrackFromGoal';

export default class RevenueTrackingOnGoal extends LightningElement {

    @api recordId;
    @api goalTrackData= [];
    @track achived_percentage;
    constructor(){
        super();
        //console.log('recordid::'+this.recordId);
       // console.log('objectname:'+this.objectApiName);
    }
    connectedCallback(){
        debugger;
        getRevenueTrackData({goalId:this.recordId}).then(result=>{
            debugger;
            console.log('result::'+result);
            this.goalTrackData = result;
            console.log('this.goalTrackData::'+this.goalTrackData);
            
            this.achived_percentage = (this.goalTrackData.Achieved_Target__c * 100) / this.goalTrackData.Target__c;
        }).catch(error=>{
            console.log('error::'+error);
        })
    }

}