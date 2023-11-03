import { LightningElement,api,track,wire } from 'lwc';
import getOpportunityprods from '@salesforce/apex/SubmitForFertCodeController.getOpportunityprods'; 
import GetPicklistValues_Object from '@salesforce/apex/SubmitForFertCodeController.GetPicklistValues_Object';  
import updateOppProdList from '@salesforce/apex/SubmitForFertCodeController.updateOppProdList'; 
import updateUserRecord from '@salesforce/apex/SubmitForFertCodeController.updateUser';
import updateAccRecord from '@salesforce/apex/SubmitForFertCodeController.updateAccount';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SubmitForFertCode extends LightningElement {

 @api recordId;
 @track oppProdList = [];

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

   wrapperObject = {
     prodId: '',
     bool: false 
   }
  wrapperArray = [];
  missingFieldsList;
  missingFieldsListForUser;
  missingFieldsListForBH;
  dlvryPlantVal;
  accSegVal;
  custTypeVal;

     connectedCallback(){
          debugger;
          console.log('recordId ===> '+this.recordId);
          setTimeout(() => {
               this.getRecordDetails();
               this.GetPicklistValues_Object();
          }, 300);
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

     getRecordDetails(){
          debugger;
          getOpportunityprods({OppId:this.recordId}).then(data=>{
               if(data){
                    console.log('Data',data);
                    this.oppProdList = data.oliList;
                    debugger;
                    console.log('recordId ===> '+this.recordId);
                    if(this.oppProdList.length!=0){
                    
                         for(let i=0;i<this.oppProdList.length;i++){
                              let ProdRecord=  {Id:null,Plant__c:null,Control_Code_HSN_Code__c:null,Shelf_Life__c:null,Allergen_Status_Required__c:null,Veg_Nonveg_Logo_In_Label__c:null}
                              if(this.oppProdList[i].Product2Id){

                                   ProdRecord.Id=this.oppProdList[i].Product2Id;
                                   ProdRecord.Plant__c = this.oppProdList[i].Product2.Plant__c;
                                   ProdRecord.Control_Code_HSN_Code__c = this.oppProdList[i].Product2.Control_Code_HSN_Code__c;
                                   ProdRecord.Shelf_Life__c = this.oppProdList[i].Product2.Shelf_Life__c;
                                   ProdRecord.Allergen_Status_Required__c =  this.oppProdList[i].Product2.Allergen_Status_Required__c;
                                   ProdRecord.Veg_Nonveg_Logo_In_Label__c = this.oppProdList[i].Product2.Veg_Nonveg_Logo_In_Label__c;
                              }
                              this.prod2List.push(ProdRecord);
                         }
                         console.log('  this.prod2List---->',  JSON.stringify(this.prod2List));
                    }


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

    changeHandler(event){
        debugger;
         let sectionName=event.currentTarget.dataset.name; // ApiName
         let id=event.currentTarget.dataset.id;  // RecordId
 
         if(sectionName=='Address'){
              if(event.target.city){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_City__c=event.target.city;
                         }
                    })
              } 

              if(event.target.street){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_Street__c=event.target.street;
                         }
                    })
              } 

              if(event.target.country){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_Country__c=event.target.country;
                         }
                    })
              } 

              if(event.target.province){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_State__c=event.target.province;
                         }
                    })
              } 

              if(event.target.postalCode){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_Postal_Code__c=event.target.postalCode;
                         }
                    })
              } 

         }else{

              this.oppProdList.forEach((element) => {
                    if(element.Id==id){
                       element[sectionName]=event.target.value;
                    }
                    else{
                         this.prod2List.forEach((item)=>{

                              if(item.Id == id){
                                   if(sectionName == 'Allergen_Status_Required__c'){
                                         item[sectionName]=event.target.checked;

                                   }else{
                                        item[sectionName]=event.target.value;
                                   }
                                  
                              }

                         })

                    }
                    console.log('prod2List---->',this.prod2List);
                    console.log('prod2List--->',JSON.stringify(this.prod2List));
               })

          } 
       console.log('this.oppProdList--'+JSON.stringify(this.oppProdList));
       
    }
    
    updateOppProdList(){
          debugger;
          updateOppProdList({oppLineList:this.oppProdList,prod2List:this.prod2List}).then(data=>{
               if(data == 'SUCCESS'){
                    console.log('Data',data);
                    this.showToast('Success', 'Notification to Sales Ops sent successfully!', 'success');
                    this.closeModal();
               }
               else if(data == 'create'){
                    console.log('Data',data);
                    this.showToast('Success', 'Customer Creation in Progress!', 'success');
                    this.closeModal();
               }
               else{
                    this.showToast('Error', data, 'error');
               }
          })
    }

     showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
     }

     closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
     }
    
     handleSave(){
         debugger;
         this.updateOppProdList();
     }

     handleError(){
          debugger;
     }

     handleSuccess(){
          debugger;
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

}