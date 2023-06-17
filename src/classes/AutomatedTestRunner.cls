global class AutomatedTestRunner implements Schedulable {
    
    @TestVisible
    private final AutomatedTestSetup__mdt testSetup = null;
    
    public AutomatedTestRunner(AutomatedTestSetup__mdt testSetup) {
        this.testSetup = testSetup;
    }
    
    public static void setup() {
        
        List<AsyncApexJob> scheduledJobs = [SELECT CronTrigger.CronExpression
                                            FROM AsyncApexJob
                                            WHERE Status = 'Queued'
                                            AND ApexClass.Name = 'AutomatedTestRunner'];
        
        Set<String> alreadyScheduled = new Set<String>();
        for (AsyncApexJob scheduledJob : scheduledJobs) {
            alreadyScheduled.add(scheduledJob.CronTrigger.CronExpression);
        }
        
        List<AutomatedTestSetup__mdt> schedulingSetup = [SELECT Label, Cron__c, TestNamePattern__c, Exclude__c, EmailTo__c 
                                                         FROM AutomatedTestSetup__mdt WHERE Active__c = true];
        try {
            for (AutomatedTestSetup__mdt scheduleSetup : schedulingSetup) {
                if (!alreadyScheduled.contains(scheduleSetup.Cron__c)) {
                    System.schedule('AutomatedTestRunner ' + scheduleSetup.Label, scheduleSetup.Cron__c, new AutomatedTestRunner(scheduleSetup));
                }
            }
        } catch (AsyncException ex) {
            System.debug('There was an error scheduling a job');
        }
    }
    
    global void execute(SchedulableContext sc) {
        
        List<ApexClass> apexTestClasses = getApexTestClasses();
        if (!apexTestClasses.isEmpty()) {
            
            List<ApexTestQueueItem> testQueueItems = createQueueItems(apexTestClasses);
            
            String jobId = null;
            if (!Test.isRunningTest()) {
                insert testQueueItems;
                List<ApexTestQueueItem> queueItemsParentId = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id = :testQueueItems[0].Id];
				jobId = queueItemsParentId[0].ParentJobId;
            }
            
            String nextExecutionCron = getNextExecutionCron();
            System.schedule('AutomatedTestReport ' + jobId, nextExecutionCron, new AutomatedTestReport(this.testSetup, jobId));
        }
    }
    
    private List<ApexClass> getApexTestClasses() {
        
        String queryClasses = 'SELECT Id FROM ApexClass WHERE NameSpacePrefix = null';
        queryClasses += ' AND Name LIKE \'' + this.testSetup.TestNamePattern__c + '\'';
        
        if (this.testSetup.Exclude__c != null) {
            List<String> excludeClasses = this.testSetup.Exclude__c.split(',');
            for (String excludeClass : excludeClasses) {
                queryClasses += ' AND Name != \'' + excludeClass.trim() + '\'';
            }
        }
        
        return Database.query(queryClasses);
    }
    
    private List<ApexTestQueueItem> createQueueItems(List<ApexClass> apexClasses) {
        List<ApexTestQueueItem> testQueueItems = new List<ApexTestQueueItem>();
        for (ApexClass testClass : apexClasses) {
            testQueueItems.add(new ApexTestQueueItem(ApexClassId = testClass.Id));
        }
        return testQueueItems;
    }
    
    private String getNextExecutionCron() {
        
        Datetime currentTime = System.now();
        currentTime = currentTime.addMinutes(30);
        
        String cronExpression = '0 '; // Second
        cronExpression += currentTime.format('m') + ' '; // Minute
        cronExpression += currentTime.format('H') + ' '; // Hour
        cronExpression += currentTime.format('d') + ' '; // Day
        cronExpression += currentTime.format('M') + ' '; // Month
        cronExpression += '? '; // Day of week
        cronExpression += currentTime.format('yyyy') + ' '; // Year
        
        return cronExpression;
    }

}