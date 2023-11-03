import { LightningElement, api,track,wire} from 'lwc';
import {CloseActionScreenEvent} from 'lightning/actions';
import { createRecord } from 'lightning/uiRecordApi';
import createOpp from '@salesforce/apex/OpportunityHanlder.createOpp'
import getOppRecord from '@salesforce/apex/OpportunityHanlder.getRecord'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';

export default class OpportunityCreateSaleOrder extends LightningElement {

    @api recordId;

    oppRecord;
    totalPercentage = 0;
    disableAddRow = false;
    @track errorMsg='';
    @track opportunityList = [{index:1, displayOrderDate:false,disable:false, opp:{ percent:0, nextOrderDate:""}}];

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getOppRecord({oppId : this.recordId}).then(data=>{
            if(data){
                this.oppRecord = data[0];
                if(this.oppRecord.Amount==null || this.oppRecord.TotalOpportunityQuantity==null){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Field not found',
                            message: 'Amount and quantity not found',
                            variant: 'error',
                        }),
                    );
                    this.closePopup();
                }
                console.log('RecordId',this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }

    // @wire(getOppRecord,{oppId:'$recordId'})
    // recordDetails({data,error}){
    //     if(data){
    //         this.oppRecord = data[0];
    //         if(this.oppRecord.Amount==null || this.oppRecord.TotalOpportunityQuantity==null){
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Field not found',
    //                     message: 'Amount and quantity not found',
    //                     variant: 'error',
    //                 }),
    //             );
    //             this.closePopup();
    //         }
    //         console.log('RecordId',this.recordId);
    //         console.log('Data',data);
    //         this.openCreateRecordForm();
    //     }
    //     if(error){
    //         console.log("Error",error);
    //     }
    // }
    percentChange(event) {
        debugger;
        let index = event.currentTarget.dataset.id;
        let percentage = event.target.value;
        
        let objSelected = this.opportunityList[index-1];
        let perOccupied = this.calculateTotalPer();

        if(index==1 && percentage!=100){
            objSelected.displayOrderDate = true;
        }else if(index!=1){
            objSelected.displayOrderDate = true;
        }else{
            objSelected.displayOrderDate = true;
        }

        objSelected.opp.percent = parseInt(percentage)>100?100:percentage;
        this.opportunityList[index-1] = objSelected;
        
        this.totalPercentage = this.calculateTotalPer();

        if(this.totalPercentage>100){
            objSelected.opp.percent = 100-perOccupied;
            this.totalPercentage = 100;
        }

        this.disableAddRow = this.totalPercentage>=100;
        //objSelected.displayOrderDate = !this.disableAddRow

        this.opportunityList[index-1] = objSelected;

        console.log("Index----"+index);
        console.log("Percentage----"+percentage);
        return false;
    }

    calculateTotalPer(){
        debugger;
        let total = 0;
        this.opportunityList.forEach(opp=>{
            total+=parseInt(opp.opp.percent);
        })
        return total;
    }

    nextOrderDateChange(event) {
        let index = event.currentTarget.dataset.id;
        let value = event.target.value;

        let objSelected = this.opportunityList[index-1];
        objSelected.opp.nextOrderDate = value;
        this.opportunityList[index-1] = objSelected;
        debugger;
    }

    addRow(){
        debugger;

        let currentObj = this.opportunityList[this.opportunityList.length-1];
        if(currentObj.opp.nextOrderDate.length==0){
            var dateDiv =  this.template.querySelector('[data-id="'+currentObj.index+'"]');
            dateDiv.setCustomValidity("Choose date first!");
            return ;
        }

        this.addItemToList();
    }

    closePopup(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    addItemToList(){
        debugger;

        var dOppList = [];

        this.opportunityList.forEach((opp,index)=>{
            opp.disable = true;
            dOppList.push(opp);
        })

        var obj = {index:this.opportunityList.length+1, displayOrderDate:true,disable:false, opp:{ percent:0, nextOrderDate:""}};
        dOppList.push(obj);
        this.opportunityList = dOppList;
    }

    createOpp(){
        let hasError = false;

        debugger;
        if(this.totalPercentage!=100){
            this.errorMsg = 'Opportunity split should be in total of 100 %'
            return;
        }

        this.opportunityList.forEach(opp=>{
            debugger;
            if(!opp.opp.nextOrderDate || opp.opp.nextOrderDate.length==0){
                var dateDiv =  this.template.querySelector('[data-id="'+opp.index+'"]');
                dateDiv.setCustomValidity("Choose date first!");
                hasError = true;
            }
        });
        
        if(hasError){
            return;
        }

        
        let opList = [];
        this.opportunityList.forEach((opp,index)=>{
            let amount = (this.oppRecord.Amount*parseInt(opp.opp.percent))/100;
            let quantity = (this.oppRecord.TotalOpportunityQuantity*parseInt(opp.opp.percent))/100;

            let nextOrderDate = opp.opp.nextOrderDate && opp.opp.nextOrderDate.length>0?new Date(opp.opp.nextOrderDate).toISOString():null;
            let closeDate;

            if(nextOrderDate){
                // closeDate = new Date(opp.opp.nextOrderDate);
                closeDate = new Date();
                closeDate.setDate(closeDate.getDate()+60);
                closeDate = closeDate.toISOString();
            }else{
                closeDate = new Date();
                //closeDate.setDate(closeDate.getDate()+15);
                closeDate = closeDate.toISOString();
            }
            
            var fields = {'Name' : this.oppRecord.Name+'_'+(opp.opp.percent)+"%", RecordTypeId:'0129D000001KRO3QAO','Amount':amount,'AccountId' : this.oppRecord.AccountId ,'ParenOpp':this.oppRecord.Id, 'StageName' : 'New','CloseDate':closeDate,'Next_Order_Date__c':nextOrderDate,'TotalOpportunityQuantity':quantity,'percent':opp.opp.percent};

            
            opList.push(fields);
        })

        let obj = {record:this.oppRecord,oppList:opList};


        createOpp({'wrapper':obj}).then(result=>{
            debugger;
            console.log("RESULT",JSON.parse(result));
        }).catch(error=>{
            console.log("Error",error);
        })

        // Promise.all(
        // this.opportunityList.map((opp,index) => {
        //     let amount = (this.oppRecord.Amount*parseInt(opp.opp.percent))/100;
        //     let quantity = (this.oppRecord.TotalOpportunityQuantity*parseInt(opp.opp.percent))/100;

        //     let nextOrderDate = opp.opp.nextOrderDate.length>0?new Date(opp.opp.nextOrderDate).toISOString():null;
        //     let closeDate;

        //     if(nextOrderDate){
        //         closeDate = new Date(opp.opp.nextOrderDate);
        //         //closeDate.setDate(closeDate.getDate()+15);
        //         closeDate = closeDate.toISOString();
        //     }else{
        //         closeDate = new Date();
        //         //closeDate.setDate(closeDate.getDate()+15);
        //         closeDate = closeDate.toISOString();
        //     }
            
            
        //     var fields = {'Name' : this.oppRecord.Name+'_'+(opp.opp.percent)+"%", RecordTypeId:'0129D000001KRO3QAO','Amount':amount,'AccountId' : this.oppRecord.AccountId ,'Parent_Opportunity__c':this.oppRecord.Id, 'StageName' : 'New','CloseDate':closeDate,'Next_Order_Date__c':nextOrderDate,'TotalOpportunityQuantity':quantity};

        //     oppList.push(fields);

        //     console.log('OOOPPPFINALLL',fields);
        //     const recordInput = { apiName: 'Opportunity', fields };
        //     return createRecord(recordInput);
        // })).then(results => {
        //     this.createSalesRecord(results);
        // }).catch(error => {
        //     console.log("Error----",error);
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Error creating record',
        //             message: error.body.message,
        //             variant: 'error',
        //         }),
        //     );
        // });
    }

    createSalesRecord(oppList){
        debugger;
        Promise.all(
        oppList.map((opp,index)=>{
            var fields = {'Name' : "Sales_"+this.oppRecord.Name+'_'+(index+1),'Opportunity__c':opp.id,'Amount__c':opp.fields.Amount.value,'Initiated_By__c':userId,'Account__c':this.oppRecord.AccountId};
            const recordInput = { apiName: 'Sales_Order__c', fields };
            return createRecord(recordInput);
        })).then(result => {
            console.log("Sales----",result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Opportunity created',
                    variant: 'success',
                }),
            );
            this.closePopup();
        }).catch(error => {
            console.log("Error----",error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

}