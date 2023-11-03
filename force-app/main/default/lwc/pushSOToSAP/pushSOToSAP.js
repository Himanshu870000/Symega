import { LightningElement, api, wire, track} from 'lwc';
import {CloseActionScreenEvent} from 'lightning/actions';
import sendSONotification from '@salesforce/apex/OpportunityCreateSaleOrderController.sendSONotification'
import getLineItemDet from '@salesforce/apex/OpportunityCreateSaleOrderController.getLineItemDetails'
import updateOpp from '@salesforce/apex/OpportunityCreateSaleOrderController.updateOpp'
import updateUserRecord from '@salesforce/apex/OpportunityCreateSaleOrderController.updateUser';
import updateAccRecord from '@salesforce/apex/OpportunityCreateSaleOrderController.updateAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class PushSOToSAP extends LightningElement {

    @api recordId;
    initiallySubmitted = false;
    show1stPage = false;
    showSpinner = true;
    accRecId;
    dispRecId;
    missingFieldsList;
    onlyAccMissingFieldList;
    userId;
    bhId;
    isAccount = false;
    pickValList;
    pan;
    gst;
    fssai;

    showUserField = false;
    showBhField = false;
    custAddFieldsMissing = false;
    accFieldsMissing = false;
    showPAN = false;
    showGST = false;
    showFSSAI = false;

    showUserField = false;
    showBhField = false;
    showDlvryPlantField = false;
    showCustTypeField = false;
    showAccSegField = false;
    showTaxType = false;
    showTaxCollect = false;
    showPaymentTerms = false;
    showTransportTerms = false;

    @track dlvryPlantList = [];
    @track custTypeList = [];
    @track accSegList = [];
    @track taxTypeList = [];
    @track taxCollectList = [];
    @track paymentTermsList = [];
    @track transportTermsList = [];

    dlvryPlantVal;
    accSegVal;
    custTypeVal;
    taxTypeVal;
    taxCollectVal;
    paymentTermsVal;
    transportTermsVal;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        debugger;
        getLineItemDet({recId : this.recordId}).then(data => {
            this.showSpinner = false;
            if(data.fertCodesPresentForAll == false){
                this.showToast('Error','FERT Code missing','error');
                this.closePopup();
            }
            else{
                if(data.reqFieldsMissing == false){
                    this.sendSONotification();
                }
                else{
                    this.show1stPage = true;
                    this.initiallySubmitted = data.initiallySubmitted;

                    this.accRecId = data.accRecId;
                    this.dispRecId = data.dispRecId;

                    this.missingFieldsList = data.missingFieldsList;
                    this.onlyAccMissingFieldList = data.onlyAccMissingFieldList;
                    this.isAccount = data.isAccount;

                    if(data.missingFieldsList.length > 0){
                        if(this.isAccount != true){
                            this.custAddFieldsMissing = true;
                        }
                        else{
                            this.accFieldsMissing = true;
                        }
                    }

                    if(data.onlyAccMissingFieldList.length>0){
                        
                        if(data.onlyAccMissingFieldList.includes('Delivery_Plant__c')){
                             this.showDlvryPlantField = true;
                        }
                        if(data.onlyAccMissingFieldList.includes('Customer_Type__c')){
                             this.showCustTypeField = true;
                        }
                        if(data.onlyAccMissingFieldList.includes('Account_Segment__c')){
                             this.showAccSegField = true;
                        }
                        if(data.onlyAccMissingFieldList.includes('Tax_Type__c')){
                            this.showTaxType = true;
                        }
                        if(data.onlyAccMissingFieldList.includes('PAN_Number__c')){
                            this.showPAN = true;
                        }
                        if(data.onlyAccMissingFieldList.includes('GST_number__c')){
                            this.showGST = true;
                        }
                        if(data.onlyAccMissingFieldList.includes('Payment_terms__c')){
                            this.showPaymentTerms = true;
                        }
                        if(data.onlyAccMissingFieldList.includes('Tax_Collected_At_Source__c')){
                            this.showTaxCollect = true;
                        }
                        if(data.onlyAccMissingFieldList.includes('FSSAI__c')){
                            this.showFSSAI = true;
                        }
                        if(data.onlyAccMissingFieldList.includes('Transportation_Terms__c')){
                            this.showTransportTerms = true;
                        }

                   }

                    this.userId = data.userId;
                    this.bhId = data.bhId;
                    if(data.userId != null || data.userId != undefined){
                        this.showUserField = true;
                    }
                    if(data.bhId != null || data.bhId != undefined){
                        this.showBhField = true;
                    }

                    this.pickValList = data.pickValList;

                    if(this.pickValList != undefined){
                        let Arr5  = this.pickValList.Delivery_Plant__c.Delivery_Plant__c;
                        let Arr6 = this.pickValList.Customer_Type__c.Customer_Type__c;
                        let Arr7 = this.pickValList.Account_Segment__c.Account_Segment__c;

                        let Arr1 = this.pickValList.Tax_Type__c.Tax_Type__c;
                        let Arr2 = this.pickValList.Tax_Collected_At_Source__c.Tax_Collected_At_Source__c;
                        let Arr3 = this.pickValList.Payment_terms__c.Payment_terms__c;
                        let Arr4 = this.pickValList.Transportation_Terms__c.Transportation_Terms__c;


                        let option1=[]
                        for(var i=0; i < Arr1.length; i++){
                            option1.push({label:Arr1[i],value:Arr1[i]});
                        }
                        this.taxTypeList=option1;

                        let option2=[]
                        for(var i=0; i < Arr2.length; i++){
                            option2.push({label:Arr2[i],value:Arr2[i]});
                        }
                        this.taxCollectList=option2;

                        let option3=[]
                        for(var i=0; i < Arr3.length; i++){
                            option3.push({label:Arr3[i],value:Arr3[i]});
                        }
                        this.paymentTermsList=option3;

                        let option4=[]
                        for(var i=0; i < Arr4.length; i++){
                            option4.push({label:Arr4[i],value:Arr4[i]});
                        }
                        this.transportTermsList=option4;


                        let option5=[]
                        for(var i=0; i < Arr5.length; i++){
                            option5.push({label:Arr5[i],value:Arr5[i]});
                        }
                        this.dlvryPlantList=option5;

                        let option6=[]
                        for(var i=0; i < Arr6.length; i++){
                            option6.push({label:Arr6[i],value:Arr6[i]});
                        }
                        this.custTypeList=option6;

                        let option7=[]
                        for(var i=0; i < Arr7.length; i++){
                            option7.push({label:Arr7[i],value:Arr7[i]});
                        }
                        this.accSegList=option7;
                    }
                }
            }
        })
    }

    sendSONotification(){
        debugger;
        sendSONotification({id : this.recordId}).then(data=>{
            if(data=='Success'){
                this.showToast('Success','Notification Sent Successfully','success');
            }else{
                this.showToast('Success',data,'success');
            }
            if(this.showSpinner == true){
                this.showSpinner = false;
            }

            this.updateOpp();
        })
    }

    handleChange(event){
        debugger;
        let name = event.target.name;

        if(name == 'UserCode'){
            this.userSapCode = event.target.value
        }
        else if(name == 'BHCode'){
            this.bhSapCode = event.target.value
        }
        else if(name == 'dlvryPlant'){
            this.dlvryPlantVal = event.target.value
        }
        else if(name == 'custType'){
            this.custTypeVal = event.target.value
        }
        else if(name == 'accSeg'){
            this.accSegVal = event.target.value
        }

        else if(name == 'taxType'){
            this.taxTypeVal = event.target.value
        }
        else if(name == 'taxCollect'){
            this.taxCollectVal = event.target.value
        }
        else if(name == 'paymentTerms'){
            this.paymentTermsVal = event.target.value
        }
        else if(name == 'transportTerms'){
            this.transportTermsVal = event.target.value
        }
        else if(name == 'gst'){
            this.gst = event.target.value
        }
        else if(name == 'pan'){
            this.pan = event.target.value
        }
        else if(name == 'fssai'){
            this.fssai = event.target.value
        }
    }

    // @wire(sendSONotification,{id : '$recordId'})
    // wiredResponse(result){
    //     debugger;
    //     if(result.data){
    //         console.log('DATA----',result.data);
            
    //         if(result.data=='Success'){
    //             this.showToast('Success','Notification Sent Successfully','success');
    //         }else{
    //             this.showToast('Success',result.data,'success');
    //         }

    //         this.updateOpp();
    //         console.log(result);
    //     }
    // }

    updateOpp(){
        updateOpp({soId:this.recordId}).then(result =>{
            console.log('Opp Update Result',result);

            if(result!='Success'){
                this.showToast('Failed',result,'error');
                this.dispatchEvent(new CloseActionScreenEvent());        
            }else{
                this.closePopup();
            }
        }).catch(err =>{
            console.log('Errror-----',err);
        })
    }

    closePopup(){
        this.dispatchEvent(new CloseActionScreenEvent());
        setTimeout(()=>window.location.reload(),1500);
    }

    showToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleSuccess(){
        debugger;
        this.showToast('Success', 'Account updated successfully', 'success');
        this.show1stPage = false;

        if(this.showUserField){
            console.log('this.userpsap s ', this.userSapCode);
            updateUserRecord({userSAPcode:this.userSapCode, userId:this.userId, accRec : this.accRec})
        }
        if(this.showBhField){
            console.log('this.bhSapCode ', this.bhSapCode);
            updateUserRecord({userSAPcode:this.bhSapCode, userId:this.bhId, accRec : this.accRec})
        }

        if((this.dlvryPlantVal != undefined && this.dlvryPlantVal != '') || (this.custTypeVal != undefined && this.custTypeVal != '') || (this.accSegVal != undefined && this.accSegVal != '') ||
        (this.taxTypeVal != undefined && this.taxTypeVal != '') || (this.taxCollectVal != undefined && this.taxCollectVal != '') || (this.paymentTermsVal != undefined && this.paymentTermsVal != '') ||
        (this.transportTermsVal != undefined && this.transportTermsVal != '') || (this.pan != undefined && this.pan != '') || (this.gst != undefined && this.gst != '') || (this.fssai != undefined && this.fssai > 0)
        ){
            updateAccRecord({accId:this.accRecId, dlvryPlant:this.dlvryPlantVal, custType : this.custTypeVal, accSeg : this.accSegVal, taxType : this.taxTypeVal, taxCollect : this.taxCollectVal, paymentTerms : this.paymentTermsVal, transportTerms : this.transportTermsVal, Gst : this.gst, Pan : this.pan, fssai : this.fssai})
        }

        this.sendSONotification();
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleError(){
        debugger;
    }
}