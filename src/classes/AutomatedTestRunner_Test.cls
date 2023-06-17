@isTest
public class AutomatedTestRunner_Test {

    @isTest
    public static void testConstructor() {
        
        List<AutomatedTestSetup__mdt> schedulingSetup = [SELECT Cron__c, TestNamePattern__c, Exclude__c, EmailTo__c 
                                                         FROM AutomatedTestSetup__mdt WHERE Active__c = true];
        
        Test.startTest();
        AutomatedTestRunner testRunner = null;
        if (!schedulingSetup.isEmpty()) {
            testRunner = new AutomatedTestRunner(schedulingSetup[0]);
        }
        Test.stopTest();
        
        if (!schedulingSetup.isEmpty()) {
        	System.assertEquals(schedulingSetup[0], testRunner.testSetup);
        }
    }
    
    @isTest
    public static void testSetup() {
        
        List<AutomatedTestSetup__mdt> schedulingSetup = [SELECT Cron__c, TestNamePattern__c, Exclude__c, EmailTo__c 
                                                         FROM AutomatedTestSetup__mdt WHERE Active__c = true];
        
        Test.startTest();
        AutomatedTestRunner.setup();
        Test.stopTest();
        
        if (!schedulingSetup.isEmpty()) {
            List<AsyncApexJob> scheduledJobs = [SELECT CronTrigger.CronExpression
                                                FROM AsyncApexJob
                                                WHERE Status = 'Queued'
                                                AND ApexClass.Name = 'AutomatedTestRunner'];
            
            System.assertNotEquals(0, scheduledJobs.size());
        }
        
    }
    
    @isTest
    public static void testAlreadyScheduled() {
        
        List<AutomatedTestSetup__mdt> schedulingSetup = [SELECT Cron__c, TestNamePattern__c, Exclude__c, EmailTo__c 
                                                         FROM AutomatedTestSetup__mdt WHERE Active__c = true];
        
        AutomatedTestRunner.setup();
        
        Test.startTest();
        AutomatedTestRunner.setup();
        Test.stopTest();
        
        if (!schedulingSetup.isEmpty()) {
            List<AsyncApexJob> scheduledJobs = [SELECT CronTrigger.CronExpression
                                                FROM AsyncApexJob
                                                WHERE Status = 'Queued'
                                                AND ApexClass.Name = 'AutomatedTestRunner'];
            
            System.assertNotEquals(0, scheduledJobs.size());
        }
        
    }
    
}