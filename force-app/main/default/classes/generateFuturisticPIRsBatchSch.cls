global class generateFuturisticPIRsBatchSch implements schedulable{
    global void execute(SchedulableContext sc)
    {
        Database.Executebatch(new generateFuturisticPIRsBatch());
    }
}