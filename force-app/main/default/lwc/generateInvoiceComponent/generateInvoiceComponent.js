import { LightningElement,wire,api,track} from 'lwc';

import getOppRecord from '@salesforce/apex/ProjectHanlder.getOppRecordLWC'
import saveProformaPDF from '@salesforce/apex/PerformaInvoicePDFController.savePDF'
import emailToClients from '@salesforce/apex/PerformaInvoicePDFController.emailToClient'
import updateINROpp from '@salesforce/apex/PerformaInvoicePDFController.updateINROpp'
import updateUSAOpp from '@salesforce/apex/PerformaInvoicePDFController.updateUSAOpp'
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import indLink from '@salesforce/label/c.Opp_Indian_Link'; 
import USA_Link from '@salesforce/label/c.Opp_USA_Link'; 

export default class GenerateInvoiceComponent extends LightningElement {
    @api recordId;
    @track pdfLink;
    @track wiredResult;
    @track record;
    @track loaded;
    @track isINR = false;
    @track incFreight = false;
    @track hideInputFields = false;
    @track values = {
        propseDate:"",
        carriageBy:"By road",
        dischargePort:"",
        reciept:"",
        portLoading:"Port",
        vessel:"",
        checks:false,
        frCharge:0
    };

    get carriageOption(){
        return [
            {'label': 'By Road', 'value': 'By road'},
            {'label': 'By Rail', 'value': 'By Rail'},
            {'label': 'By Air', 'value': 'By air'},
            {'label': 'By Sea', 'value': 'By sea'},
            ];
    }

    get loadingOptions(){
        return [
            {'label': 'Port', 'value': 'Port'},
            {'label': 'Chennai', 'value': 'Chennai'},
            {'label': 'Kochi', 'value': 'Kochi'},
            {'label': 'Ennore', 'value': 'Ennore'},
            {'label': 'Kolkata', 'value': 'Kolkata'},
            {'label': 'Kandla', 'value': 'Kandla'},
            {'label': 'Mangalore', 'value': 'Mangalore'},
            {'label': 'Mormugao', 'value': 'Mormugao'},
            {'label': 'Mumbai Port Trust', 'value': 'Mumbai Port Trust'},
            {'label': 'Nhava', 'value': 'Nhava'},
            {'label': 'Paradip', 'value': 'Paradip'},
            {'label': 'Tuticorin', 'value': 'Tuticorin'},
            {'label': 'Visakhapatnam', 'value': 'Visakhapatnam'},
            {'label': 'Port Blair', 'value': 'Port Blair'},
        ];
    }


    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getOppRecord({id : this.recordId}).then(data=>{
            if(data){
                this.record = data;

                if(this.record && this.record.CurrencyIsoCode){
                    debugger;
                    this.isINR = this.record.CurrencyIsoCode=='INR';
                    
                    if(this.isINR){
                        this.values.propseDate = this.record.Proposed_Date_of_Dispatch__c;
                        this.values.frCharge =  this.record.Freight_charges__c;
                    }else if(!this.isINR && this.record.Pre_carriage_By__c && this.record.Port_of_Discharge__c && this.record.Place_of_Reciept_by_Pre_Carrier__c && this.record.Port_of_Loading__c && this.record.Vessel_Flight_Name_Voy_No__c){
                        this.values.carriageBy =     this.record.Pre_carriage_By__c;
                        this.values.dischargePort =     this.record.Port_of_Discharge__c;
                        this.values.reciept =     this.record.Place_of_Reciept_by_Pre_Carrier__c;
                        this.values.portLoading =     this.record.Port_of_Loading__c;
                        this.values.vessel =     this.record.Vessel_Flight_Name_Voy_No__c;
                    }
                }
    
                if(this.isINR){
                    this.pdfLink = indLink+this.record.Id;
                }
                else{
                    this.pdfLink = USA_Link+this.record.Id;
                }
    
                console.log('pdfLink----',this.pdfLink);
                console.log('RECORD----',this.record);
                this.loaded = true;
            }
        })
    }

    
    // @wire(getOppRecord,{id:'$recordId'})
    // wiredResponse(result){
    //     debugger;
    //     this.wiredResult = result;
    //     console.log('RECORD----',result);
    //     if(result && result.data){
    //         debugger;
    //         this.record =result.data;

    //         if(this.record && this.record.CurrencyIsoCode){
    //             debugger;
    //             this.isINR = this.record.CurrencyIsoCode=='INR';
                
    //             if(this.isINR){
    //                 this.values.propseDate = this.record.Proposed_Date_of_Dispatch__c;
    //                 this.values.frCharge =  this.record.Freight_charges__c;
    //             }else if(!this.isINR && this.record.Pre_carriage_By__c && this.record.Port_of_Discharge__c && this.record.Place_of_Reciept_by_Pre_Carrier__c && this.record.Port_of_Loading__c && this.record.Vessel_Flight_Name_Voy_No__c){
    //                 this.values.carriageBy =     this.record.Pre_carriage_By__c;
    //                 this.values.dischargePort =     this.record.Port_of_Discharge__c;
    //                 this.values.reciept =     this.record.Place_of_Reciept_by_Pre_Carrier__c;
    //                 this.values.portLoading =     this.record.Port_of_Loading__c;
    //                 this.values.vessel =     this.record.Vessel_Flight_Name_Voy_No__c;
    //             }
    //         }

    //         if(this.isINR){
    //             this.pdfLink = indLink+this.record.Id;
    //         }
    //         else{
    //             this.pdfLink = USA_Link+this.record.Id;
    //         }

    //         console.log('pdfLink----',this.pdfLink);
    //         console.log('RECORD----',this.record);
    //         this.loaded = true;
    //     }
    // }



    inputChangeHandler(event){
        let eventName = event.target.name;
        let value = event.target.value;

        debugger;

        if(eventName=='proposeDate'){
            this.values.propseDate = value;
        }
        if(eventName=='carriage_by'){
            this.values.carriageBy = value;
        }
        if(eventName=='dischargePort'){
            this.values.dischargePort = value;
        }
        if(eventName=='reciept'){
            this.values.reciept = value;
        }
        if(eventName=='portLoading'){
            this.values.portLoading = value;
        }
        if(eventName=='vessel'){
            this.values.vessel = value;
        }
        if(eventName=='check'){
            this.values.checks = event.target.checked;
        }
        if(eventName=='fChrg'){
            this.values.frCharge = value;
        }

        console.log("Values",this.values);
    }

    handleNext(){
        if(this.isINR){
            this.incFreight = this.values.checks;
            updateINROpp({oppId : this.recordId, purposeDate : this.formatDate(new Date(this.values.propseDate)), freightChrg : this.values.frCharge, includeFreight : this.incFreight}).then(result =>{
                debugger;
                console.log("Result",result);
                if(result=='Success'){
                    this.hideInputFields = true;
                }
            }).catch(error =>{
                this.hideInputFields = true;
                console.log("Error",error);
            });
        }else{
            console.log('VALUES',this.values);
            updateUSAOpp({oppId:this.recordId,carriageBy:this.values.carriageBy,dischargePort:this.values.dischargePort,reciept:this.values.reciept,portLoading:this.values.portLoading,vessel:this.values.vessel}).then(result =>{
                debugger;
                console.log("Result",result);
                this.hideInputFields = true;
            }).catch(error =>{
                console.log("Error",error);
                this.hideInputFields = true;
            });
        }
    }
    savePDF(){
        saveProformaPDF({url:this.pdfLink,id:this.record.Id,fileName:this.record.Name+"_FILE"}).then(result => {
            debugger;
            console.log("JADSJKHKDHSD",result);
            this.showNotification('Success','Your performa invoice generated successfully','success');
            this.closeAction();
        }).catch(error=>{
            console.log("Error",error);
        });
    }
    emailToClient(){
        emailToClients({url:this.pdfLink,oppId:this.record.Id}).then(result => {
            debugger;
            this.showNotification('Success','Performa Invoice sent successfully','success');
            this.closeAction();
        }).catch(error=>{
            console.log("Error",error);
        });
    }

    formatDate(date){
        return (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear();
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}