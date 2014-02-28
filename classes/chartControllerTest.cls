@isTest
private class chartControllerTest {
	
	private static Boolean setupTestData = false;
	private static Id queryRunId1;
	private static Id queryRunId2;
	private static Id queryId1;
	private static Id queryId2;
 	private static Id queryId3;
	
	/*
	*	setup test data
	*/
	private static void setupTestData(){

		// Insert query runs
		queryRunId1 = Database.insert(new Query_Run__c(Name='Test run 1', Run_Time__c=System.now())).getId();
		queryRunId2 = Database.insert(new Query_Run__c(Name='Test run 2', Run_Time__c=System.now().addHours(1))).getId();

		// Insert query records 
		queryId1 = Database.insert(new Query__c(Name='Account',Active__c=true,Soql__c='SELECT Id, Name FROM Account')).getId();
		queryId2 = Database.insert(new Query__c(Name='Contact',Active__c=true,Soql__c='SELECT Id, Name FROM Contact')).getId();
		queryId3 = Database.insert(new Query__c(Name='Opportunity',Active__c=true,Soql__c='SELECT Id, Name FROM Opportunity')).getId();

		// insert query logs
		List<Apex_Log__c> apexLogsList = new List<Apex_Log__c>{ new Apex_Log__c(Query_Run_Time__c=queryRunId1,start_ms__c=System.currentTimeMillis(),stop_ms__c=System.currentTimeMillis()+100,class_name__c='Test Class',method_name__c='Test Method',Query__c=queryId1),
																new Apex_Log__c(Query_Run_Time__c=queryRunId1,start_ms__c=System.currentTimeMillis(),stop_ms__c=System.currentTimeMillis()+200,class_name__c='Test Class',method_name__c='Test Method',Query__c=queryId2),
																new Apex_Log__c(Query_Run_Time__c=queryRunId2,start_ms__c=System.currentTimeMillis(),stop_ms__c=System.currentTimeMillis()+300,class_name__c='Test Class',method_name__c='Test Method',Query__c=queryId3)
															  };		
		insert apexLogsList;					 
		
		setupTestData = true; 
	}

	/*
	*	Test getQueryRuns method
	*/
	static testMethod void test_getQueryRuns() {
		Test.startTest();

		// Create test Data
		if (!setupTestData) setupTestData();

		// Test Query run 1
		System.Test.setCurrentPageReference(new PageReference('/apex/x?'));
		chartController cls = new chartController();

		// Check query runs 
		System.assertEquals(2,cls.getQueryRuns().size());
		System.assertNotEquals(1,cls.getQueryRuns().size());

		Test.stopTest();
	}

	/*
	*	Test getQueryLogs method
	*/
	static testMethod void test_getQueryLogs() {
		Test.startTest();

		// Create test Data
		if (!setupTestData) setupTestData();

		// Get the query runds 
		Query_Run__c queryRun1 = [SELECT Id, Name FROM Query_Run__c WHERE Id=:queryRunId1 LIMIT 1];
		Query_Run__c queryRun2 = [SELECT Id, Name FROM Query_Run__c WHERE Id=:queryRunId2 LIMIT 1];


		// Test Query run 1
		System.Test.setCurrentPageReference(new PageReference('/apex/x?'));
		chartController cls = new chartController(new ApexPages.standardController(queryRun1));

		cls.getQueryLogs();

		// Check asserts
		System.assertEquals(2,cls.apexLogsList.size());
		System.assert(cls.stdController.getId() == queryRun1.Id);


		// Test Query run 2
		System.Test.setCurrentPageReference(new PageReference('/apex/x?'));
		cls = new chartController(new ApexPages.standardController(queryRun2));

		cls.getQueryLogs();

		// Check asserts
		System.assertEquals(1,cls.apexLogsList.size());
		System.assertNotEquals(2,cls.apexLogsList.size());
		System.assert(cls.stdController.getId() == queryRun2.Id);


		// Set queryId = null
		System.Test.setCurrentPageReference(new PageReference('/apex/x?'));
		cls = new chartController(new ApexPages.standardController(queryRun2));

		cls.queryRunId = null;
		cls.getQueryLogs();

		// Check asserts
		System.assertEquals(0,cls.apexLogsList.size());

		Test.stopTest();
	}
	
}