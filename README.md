# SFDC Automated Tests
Automated running and reporting of Salesforce Apex test classes. 

You can configure when to run the tests, who to send the report to, which tests to run and which not to run. 

[View the story on Medium (Inglés)]()

[Ver el artículo en Medium (Español)]()

<a href="https://githubsfdeploy.herokuapp.com?owner=Salesforce Jedi&repo=https://github.com/sfdcjedi/sfdc-automated-tests&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

# Metadata List
- **AutomatedTestSetup__mdt**: Test execution setup
- **AutomatedTestRunner.cls**: Test execution runner based on setup
- **AutomatedTestRunner_Test.cls**: Test class with the unit tests of AutomatedTestRunner
- **AutomatedTestReport.cls**: Send email report
- **AutomatedTestReport_Test.cls**: Test class with the unit tests of AutomatedTestReport

# Example
```java
AutomatedTestRunner.setup();
```
