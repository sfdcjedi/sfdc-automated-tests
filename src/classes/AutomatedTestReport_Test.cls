@isTest
public class AutomatedTestReport_Test {
    
    @isTest
    public static void testConstructor() {
        
        List<AutomatedTestSetup__mdt> schedulingSetup = [SELECT Cron__c, TestNamePattern__c, Exclude__c, EmailTo__c 
                                                         FROM AutomatedTestSetup__mdt WHERE Active__c = true];
        
        Test.startTest();
        AutomatedTestReport testReport = null;
        if (!schedulingSetup.isEmpty()) {
            testReport = new AutomatedTestReport(schedulingSetup[0], null);
        }
        Test.stopTest();
        
        if (!schedulingSetup.isEmpty()) {
        	System.assertEquals(schedulingSetup[0], testReport.testSetup);
        }
    }
    
    @isTest
    public static void testExecute() {
        
        List<AutomatedTestSetup__mdt> schedulingSetup = [SELECT Cron__c, TestNamePattern__c, Exclude__c, EmailTo__c 
                                                         FROM AutomatedTestSetup__mdt WHERE Active__c = true];
        
        AutomatedTestReport testReport = new AutomatedTestReport(schedulingSetup[0], null);
        
        Test.startTest();
        if (!schedulingSetup.isEmpty()) {
            System.schedule('AutomatedTestReport', '0 0 0 * * ?', new AutomatedTestReport(schedulingSetup[0], null));
        }
        Test.stopTest();
        
        if (!schedulingSetup.isEmpty()) {
            List<AsyncApexJob> scheduledJobs = [SELECT CronTrigger.CronExpression
                                                FROM AsyncApexJob
                                                WHERE Status = 'Queued'
                                                AND ApexClass.Name = 'AutomatedTestReport'];
            
            System.assertNotEquals(0, scheduledJobs.size());
        }
    }

}