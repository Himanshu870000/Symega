import { LightningElement,wire,track,api} from 'lwc';
import getRecord from '@salesforce/apex/Optiva_LWC_NPD_Controller.getRecordTypeName'
import syncSample from '@salesforce/apex/Optiva_LWC_NPD_Controller.syncSample'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {CloseActionScreenEvent} from 'lightning/actions';
import getProjRecList from '@salesforce/apex/Optiva_LWC_NPD_Controller.getProjectAndOppDet'; 
import updateUserRecord from '@salesforce/apex/Optiva_LWC_NPD_Controller.updateUser';
import updateAccRecord from '@salesforce/apex/Optiva_LWC_NPD_Controller.updateAccount';

export default class SampleCreationSyncingOptiva extends LightningElement {
    @api recordId;
    @track showSpinner = true;
    @track responseMsg='';
    @track response;
    @track msgStyle = 'color:green;'
    @track prod2List = [];

 @track options =[];
 @track options1 =[];
 @track options2 =[];
 @track options3 = [];
 @track options4 = [];
 @track dlvryPlantList = [];
 @track custTypeList = [];
 @track accSegList = [];


  idValueMap = new Map();
  @track prodList =[];
  @track jsonVar =[];
  userSapCode;
  bhSapCode;
  userId;
  bhId;
  accId;
  dispId;
  showAccountPage = false;
  showSpinner = true;
  isAccount = false;
  showUserField = false;
  showBhField = false;
  showDlvryPlantField = false;
  showCustTypeField = false;
  showAccSegField = false;
  custAddFieldsMissing = false;
  accFieldsMissing = false;
    

    connectedCallback() {
        setTimeout(() => {
            this.getProjDetails();
            this.GetPicklistValues_Object();
        }, 300);
    }

    getProjDetails(){
        debugger;
        getProjRecList({projId:this.recordId}).then(data=>{
            if(data){
                console.log('Data',data);
                console.log('recordId ===> '+this.recordId);
                                    if(data.missingFieldsList.length > 0) {
                         if(this.showAccountPage != true){
                             this.showAccountPage = true;
                         }
                         this.accId = data.accId;
                         this.dispId = data.dispId;
                         this.missingFieldsList = data.missingFieldsList;
                         this.isAccount = data.isAccount;
                         if(this.isAccount != true){
                              this.custAddFieldsMissing = true;
                         }
                         else{
                              this.accFieldsMissing = true;
                         }
                    }
                    if(data.missingFieldsListForUser.length > 0) {
                         if(this.showAccountPage != true){
                             this.showAccountPage = true;
                         }
                         this.missingFieldsListForUser = data.missingFieldsListForUser;
                         this.userId = data.userIdList[0];
                         this.showUserField = true;
                    }
                    if(data.missingFieldsListForBH.length > 0) {
                         if(this.showAccountPage != true){
                             this.showAccountPage = true;
                         }
                         this.missingFieldsListForBH = data.missingFieldsListForBH;
                         this.bhId = data.bhIdList[0];
                         this.showBhField = true;
                    }
                    if(data.onlyAccMissingFieldList.length>0){
                         if(this.showAccountPage != true){
                             this.showAccountPage = true;
                         }
                         if(data.onlyAccMissingFieldList.includes('Delivery_Plant__c')){
                              this.showDlvryPlantField = true;
                         }
                         if(data.onlyAccMissingFieldList.includes('Customer_Type__c')){
                              this.showCustTypeField = true;
                         }
                         if(data.onlyAccMissingFieldList.includes('Account_Segment__c')){
                              this.showAccSegField = true;
                         }
                    }
                    if(!(data.onlyAccMissingFieldList.length>0 || data.missingFieldsListForBH.length > 0 || data.missingFieldsListForUser.length > 0 || data.missingFieldsList.length > 0)){
                         this.goalTrackingRecordDetails();
                    }

                    this.showSpinner = false;
                    console.log('  this.oppProdList---->',  this.oppProdList);
                    console.log('  this.missingFieldsList --->',  this.missingFieldsList);
            }
        })
    }

    GetPicklistValues_Object(){
        debugger;
        GetPicklistValues_Object().then(data=>{
             debugger;
            if(data){
                console.log('Data',data);
                let Arr=data.Label.Label__c;
                let Arr1 = data.Ingredients_List_Declared_With_Customer.Ingredients_List_Declared_With_Customer__c;
                let Arr2 = data.Packaging_Type.Packaging_Type__c;
                let Arr3 = data.Plant.Plant__c;
                let Arr4 = data.veglogo.Veg_Nonveg_Logo_In_Label__c;

               let Arr5 = data.Delivery_Plant__c.Delivery_Plant__c;
               let Arr6 = data.Customer_Type__c.Customer_Type__c;
               let Arr7 = data.Account_Segment__c.Account_Segment__c;

                let option=[]
                for(var i=0; i < Arr.length; i++){
                  option.push({label:Arr[i],value:Arr[i]});
                }
                this.options=option;

                 let option1=[]
                for(var i=0; i < Arr1.length; i++){
                  option1.push({label:Arr1[i],value:Arr1[i]});
                }
                 this.options1=option1;

                  let option2=[]
                for(var i=0; i < Arr2.length; i++){
                  option2.push({label:Arr2[i],value:Arr2[i]});
                }
                 this.options2=option2;

                  let option3=[]
                for(var i=0; i < Arr3.length; i++){
                  option3.push({label:Arr3[i],value:Arr3[i]});
                }
                 this.options3=option3;

               let option4=[]
               for(var i=0; i < Arr4.length; i++){
                    option4.push({label:Arr4[i],value:Arr4[i]});
               }
               this.options4=option4;

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

                console.log('  this.options---->',JSON.stringify(this.options));
                console.log('  this.options1---->',JSON.stringify(this.options1));
            }
        })
     }

      handleSuccess(){
          debugger;
          this.goalTrackingRecordDetails();
          this.showToast('Success', 'Account updated successfully', 'success');
          this.showAccountPage = false;
          if(this.showUserField){
               console.log('this.userpsap s ', this.userSapCode);
               updateUserRecord({userSAPcode:this.userSapCode, userId:this.userId, accRec : this.accRec})
          }
          if(this.showBhField){
               console.log('this.bhSapCode ', this.bhSapCode);
               updateUserRecord({userSAPcode:this.bhSapCode, userId:this.bhId, accRec : this.accRec})
          }

          if((this.dlvryPlantVal != undefined && this.dlvryPlantVal != '') || (this.custTypeVal != undefined && this.custTypeVal != '') || (this.accSegVal != undefined && this.accSegVal != '')){
               updateAccRecord({accId:this.accId, dlvryPlant:this.dlvryPlantVal, custType : this.custTypeVal, accSeg : this.accSegVal})
          }
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
     }

    handleSave(){
         debugger;
         //this.updateOppProdList();
     }

    goalTrackingRecordDetails() {
        getRecord({ recId: this.recordId })
            .then(data => {
                if(data){
                    console.log('Data',data);
                    if(!data.Submitted_To_SAP_Optiva__c){
                        if(data.RecordType && data.RecordType.Name){
                            this.submitProject(data.RecordType.Name);
                        }
                    }else{
                        this.showToast('Failed','Already synced to optiva');
                        this.closePopup();
                    }
                    
                } else {
                    console.log('error',error);
                    this.closePopup();
                }
        })
    }

    submitProject(recTypeName){
        this.isLoading = true;
        syncSample({recId:this.recordId,recType:recTypeName}).then(result=>{
            console.log('Result---->',result);
            if(result){
                this.response = result;
                this.responseMsg = result.message;
                if(result.status=='Success'){
                    this.showToast('Success',`${recTypeName} Synced Successfully!`,'success');
                    //setTimeout(() => window.location.reload(), 2000);
                }else{
                    this.msgStyle = 'color:red;';
                    this.showToast('Failed','','warning');
                }
                this.isLoading = false;
            }
            //this.closePopup();
        }).catch(error=>{
            this.responseMsg = error;
            this.msgStyle = 'color:red;';
            this.showToast('error',error,'error');
            this.isLoading = false;
            //this.closePopup();
        })
    }

    closePopup(){
        if(this.response && this.response.status=='Success'){
            setTimeout(() => window.location.reload(), 2000);
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}