global class ScheduleAutoSyncToOptiva implements Schedulable{
    global void execute(SchedulableContext sc) {
        System.abortJob(sc.getTriggerId());
        //Database.executeBatch(new AutoSyncBatchSampleToOptiva(),1);
        //AutoSyncSampleToOptiva.syncSample();
    }
}