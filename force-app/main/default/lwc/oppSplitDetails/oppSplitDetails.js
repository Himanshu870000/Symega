import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class OppSplitDetails extends LightningElement {
    @api productList;
    @api oppName;
    @track saveDraftValues = [];
    dateChoosed;

    connectedCallback(){
        console.log("JSJJSJSJS",JSON.stringify(this.oppRecord));
    }

    inputChangeHandler(event){
        debugger;
        let id = event.currentTarget.dataset.id;
        let value = parseInt(event.target.value);

        let prodList = [...this.productList];

        let index = prodList.findIndex(prod=>prod.Id==id);
        let obj = {...prodList[index]};
        obj.quantityChoosed = obj.remainingQuantity<value?obj.remainingQuantity:value;
        obj.amountChoosed = parseFloat(((obj.TotalPrice/obj.Quantity)*obj.quantityChoosed).toFixed(1))
        obj.remainingAmount = parseFloat((obj.TotalPrice - obj.amountChoosed).toFixed(1));
        prodList[index] = obj;
        this.productList = prodList;
    }


    @api getProductList(){
        debugger;
        if(!this.dateChoosed){
            const evt = new ShowToastEvent({
                title: 'Choose Date',
                message: 'Please fill expected order date',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            var dateDiv =  this.template.querySelector('[name="'+'date'+'"]');
            dateDiv.setCustomValidity("Please enter expected Order Date!");
            this.dateChoosed = null;
        }else{
            let nextOrderDate = new Date(this.dateChoosed).toISOString();
            let closeDate = new Date();
            closeDate.setDate(closeDate.getDate()+60);
            closeDate = closeDate.toISOString();
            return {oppName:this.oppName,products:this.productList,nextOrderDate:nextOrderDate,closeDate:closeDate}
        }
    }

    oppNameChange(event){
        console.log(this.oppRecord);
        this.oppName = event.target.value;
    }

    nextOrderDateChange(event){
        debugger;
        let dateSelected = new Date(event.target.value);
        if(dateSelected<new Date()){
            this.dateChoosed = null;
            this.showToast('Invalid Date','Past Date cannot be choose.','error')
        }else{
            this.dateChoosed = event.target.value;
        }
    }

    showToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    connectedCallback(){
    }
}