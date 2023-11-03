global class SubmittedSampleForLast2DaysBatchSch implements schedulable{
    global void execute(SchedulableContext sc)
    {
        Database.Executebatch(new SubmittedSampleForLast2DaysBatch());
    }
}