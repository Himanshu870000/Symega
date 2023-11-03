import { LightningElement, wire, api } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJs'; 
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRevenueTrackFromGoal from '@salesforce/apex/lwcComponentHelper.getRevenueTrackFromGoal'

export default class RingChartToShowTarget extends LightningElement {
    @api recordId;
    chart;
    goalRecord;
    
    chartjsInitialized = false;



    connectedCallback() {
        setTimeout(() => {
            this.goalTrackingRecordDetails();
        }, 300);
    }

    goalTrackingRecordDetails() {
        getRevenueTrackFromGoal({ goalId: this.recordId })
            .then(data => {
                if(data){
                    console.log('Data',data);
                    this.updateChart(data)
                    
                }
        })
    }


    // @wire (getRevenueTrackFromGoal,{goalId : '$recordId'}) 
    // getGoalRecord({error,data})
    // {
    //     console.log("Dataaaaa=========",data);
    //     if(data)
    //     {  
    //         //this.goalRecord = data;
    //         this.updateChart(data)
    //         this.error=undefined;
    //     }
    //     else if(error)
    //     {
    //         this.error = error;
    //         this.getGoalRecord = undefined;
    //     }
    // }

      config={
        type : 'doughnut',
            data :
            { 
                datasets :[ 
                    { 
                        data: [],
                        backgroundColor :[
                                        'rgb(235, 86, 52)',
                                        'rgb(52, 235, 100)'
                                        ],
                        label:'Dataset 1'
                    }
                ],
                labels:["Target", "Achieved Target"]
            },
            options: { responsive : true,
                       legend : { position :'right' },
                       animation:{ animateScale: true, animateRotate : true }
                     }
    };
   
  
    renderedCallback(){

        if(this.chartjsInitialized) return;

        this.chartjsInitialized = true;

        Promise.all([
            loadScript(this,chartjs)
        ])
        .then(() =>{
            const ctx = this.template.querySelector('canvas.donut').getContext('2d');
            this.chart = new window.Chart(ctx, this.config);
        })
        .catch(error =>{
                this.dispatchEvent( new ShowToastEvent
                        ({
                            title : 'Error loading ChartJS',
                            message : error.message,
                            variant : 'error',
                        }),
                );
            });
    }

    updateChart(data){
    
        let dataList  = Object.entries(data).map(([key, value]) => ({key,value}));

        dataList.forEach(item=>{
            if(item.key=='Target__c' || item.key=='Achieved_Target__c'){
                //this.chart.data.labels.push(item.key);
                this.chart.data.datasets[0].data.push(item.value);
            }
        })

        this.chart.update();
    }
}