import { LightningElement, wire, api } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJs'; 
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRevenueTrackFromGoal from '@salesforce/apex/lwcComponentHelper.getRevenueTrackFromGoal'

export default class PieChartToShowExpectedAmt extends LightningElement {

    @api recordId;
    chart;
    chartjsInitialized = false;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    getRecordDetails(){
        getRevenueTrackFromGoal({goalId : this.recordId}).then(data=>{
            if(data)
            {  
                this.updateChart(data)
                this.error=undefined;
            }
            else if(error)
            {
                this.error = error;
                this.getGoalRecord = undefined;
            }
        })
    }

    // @wire (getRevenueTrackFromGoal,{goalId : '$recordId'}) 
    // getGoalRecord({error,data})
    // {
    //     console.log("Dataaaaa=========",data);
    //     if(data)
    //     {  
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
                labels:["Target", "Expected Amount"]
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
        // console.log("ToUpdate-----",data);
        // this.chart.data.labels.push(data);
        // this.chart.data.datasets.forEach((dataset) => {
        //     dataset.data.push(count);
        // });
        // console.log("ChartData-----",this.chart);
        // this.chart.update();

        let dataList  = Object.entries(data).map(([key, value]) => ({key,value}));

        dataList.forEach(item=>{
            if(item.key=='Target__c' || item.key=='Expected_Amount__c'){
                //this.chart.data.labels.push(item.key);
                this.chart.data.datasets[0].data.push(item.value);
            }
        })
        this.chart.update();
    }

}