global class AccReevaluateBusinessPotentialBatchSch implements schedulable{
    global void execute(SchedulableContext sc)
    {
        Database.Executebatch(new AccountReevaluateBusinessPotentialBatch());
    }
}