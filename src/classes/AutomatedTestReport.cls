global class AutomatedTestReport implements Schedulable {
    
    @TestVisible
    private final String jobId = null;
    @TestVisible
    private final AutomatedTestSetup__mdt testSetup = null;
    @TestVisible
    private Boolean isAllMethodsPassed = false;
    
    public AutomatedTestReport(AutomatedTestSetup__mdt testSetup, String jobId) {
        this.jobId = jobId;
        this.testSetup = testSetup;
    }
    
    global void execute(SchedulableContext sc) {
        
        List<ApexTestResult> testResults = getTestResults();
        
        String htmlTable = generateReportTable(testResults);
        
        sendEmailReport(htmlTable);
	}
    
    private List<ApexTestResult> getTestResults() {
        List<ApexTestResult> testResults = [SELECT ApexClass.Name, MethodName, Outcome, Message
                                            FROM ApexTestResult
                                            WHERE AsyncApexJobId = :this.jobId];
        return testResults;
    }
    
    private String generateReportTable(List<ApexTestResult> testResults) {
        
        Integer methodsPassed = 0;
        Integer totalMethods = 0;
        String currentClass = '';
        
        String failTable = '<table border="1" cellpadding="5px">';
        for (ApexTestResult result : testResults) {
            if (result.Outcome == 'Pass') {
                methodsPassed++;
            } else {
                if (result.ApexClass.Name != currentClass) {
                    currentClass = result.ApexClass.Name;
                    failTable += '<tr style="background: #ddd; font-weight: bold;"><td colspan="2">' + currentClass + '</td></tr>\n';
                }
                failTable += '<tr><td>' + result.MethodName + '</td><td> ' + result.Message + '</td></tr>\n';
            }
            totalMethods++;
        }
        failTable += '</table>';
        
        String fullBody = '<p>Test methods passed (' + methodsPassed + '/' + totalMethods + ')</p>\n';
        
        if (totalMethods != methodsPassed) {
            fullBody += '<p>Failures Summary:</p>\n' + failTable;
        } else {
            fullBody += '<p>All tests passed. Great Job!</p>\n';
            this.isAllMethodsPassed = true;
        }
        
        return fullBody;
    }
    
    private List<Messaging.SendEmailResult> sendEmailReport(String htmlBody) {
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(this.testSetup.EmailTo__c.split('[,\\s]+'));
        mail.setSubject('Automated Test Results: ' + (this.isAllMethodsPassed ? 'Pass' : 'Fail'));
        mail.setHtmlBody(htmlBody);
        emailList.add(mail);
        
        return Messaging.sendEmail(emailList);
    }

}