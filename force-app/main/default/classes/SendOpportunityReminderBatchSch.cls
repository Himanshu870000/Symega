global class SendOpportunityReminderBatchSch implements schedulable{
    global void execute(SchedulableContext sc){
        Database.Executebatch(new SendOpportunityReminderBatch());
    }
}


//String jobID = System.schedule('My Scheduable', '0 0 22 * * ? *' , new ScheduleOppReminderBatchClass());