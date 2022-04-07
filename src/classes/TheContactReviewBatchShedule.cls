public class TheContactReviewBatchShedule implements Schedulable {

    public void execute(SchedulableContext sc) {
        ForOwnersToReviewContactBatch batchforRemind = new ForOwnersToReviewContactBatch();
        Database.executebatch(batchforRemind);
    }
}