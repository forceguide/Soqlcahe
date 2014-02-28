@isTest
private class queryLogSchedulerTest {
	
	private static Id queryId1;
	private static Id queryId2;
 	private static Id queryId3;
 	private static Boolean setupTestData = false;


	/*
	*	setup test data
	*/
	private static void setupTestData(){ 
		// Insert custom settings 
		Database.insert(new ApexLogSettings__c(name='GlobalActivation',active__c = true, MaxDays__c=0,MaxRecords__c=0));
		Database.insert(new ApexLogSettings__c(name='queryLogger:testmethod',active__c = true, MaxDays__c=0,MaxRecords__c=0));

		Database.insert(new QueryLogger__c(Chart_Colour__c='green',Hourly_Decay__c=2,Query_Size__c=200));

		// Insert query records 
		queryId1 = Database.insert(new Query__c(Name='Account',Active__c=true,Soql__c='SELECT Id, Name FROM Account')).getId();
		queryId2 = Database.insert(new Query__c(Name='Contact',Active__c=true,Soql__c='SELECT Id, Name FROM Contact')).getId();
		queryId3 = Database.insert(new Query__c(Name='Opportunity',Active__c=true,Soql__c='SELECT Id, Name FROM Opportunity')).getId();

		setupTestData = true; 
	}

	// Test query Log Scheduler class without batch
	static testMethod void test_SchedulerWithoutBatch() {
		Test.startTest();
		
		// Create test Data
		if (!setupTestData) setupTestData();

		// Schedule the test job
        String strSchedule = '0 0 0 3 9 ? 2014';
        
		String jobId = System.schedule('queryLogger'+system.now(), strSchedule, new queryLogScheduler());

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		 // Verify the expressions are the same
      	System.assertEquals(strSchedule, ct.CronExpression);
      	
      	// Verify the job has not run
     	System.assertEquals(0, ct.TimesTriggered);
     	System.assert(ct.TimesTriggered != 1);

		Test.stopTest();
	}


	// Test query Log Scheduler class without batch
	static testMethod void test_SchedulerWithBatch() {
		Test.startTest();
		
		// Create test Data
		if (!setupTestData) setupTestData();

		// Insert query records 
		List<Query__c> queryList = new List<Query__c>();
		for (Integer i=0;i<150;i++){
			queryList.add(new Query__c(Name='Test query '+i,Active__c=true,Soql__c='SELECT Id, Name FROM Account'));
		}
		insert queryList;

		// Schedule the test job
		String strSchedule = '0 0 0 3 9 ? 2014';
        
		String jobId = System.schedule('queryLogger'+system.now(), strSchedule, new queryLogScheduler());

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		 // Verify the expressions are the same
      	System.assertEquals(strSchedule, ct.CronExpression);
      	
      	// Verify the job has not run
     	System.assertEquals(0, ct.TimesTriggered);
     	System.assert(ct.TimesTriggered != 1);

     	AsyncApexJob apexJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob];

     	// Verify the expressions are the same
     	System.assert(apexJob.Id != null);
     	System.assertNotEquals(200,apexJob.TotalJobItems);
     	System.assertEquals(0,apexJob.TotalJobItems);

		Test.stopTest();
	}

	// Test batch apex
	static testMethod void test_batchApex() {
		Test.startTest();
		
		// Create test Data
		if (!setupTestData) setupTestData();

		// Insert query records 
		List<Query__c> queryList = new List<Query__c>();
		for (Integer i=0;i<150;i++){
			queryList.add(new Query__c(Name='Test query '+i,Active__c=true,Soql__c='SELECT Id, Name FROM Account'));
		}
		insert queryList;

		// Test batch
		Id queryRunId = Database.insert(new Query_Run__c(Name='Test run 1', Run_Time__c=System.now())).getId();
		queryBatch batchJob = new queryBatch('SELECT Id, Name, Soql__c FROM Query__c WHERE Active__c = true',queryRunId);
		Database.executeBatch(batchJob);
		Test.stopTest();
	}

	// Test QueryHelper
	static testMethod void test_queryProcessing() {
		Test.startTest();
		
		// Create test Data
		if (!setupTestData) setupTestData();

		// Insert query records
		// Test batch
		Id queryRunId = Database.insert(new Query_Run__c(Name='Test run 1', Run_Time__c=System.now())).getId();
		List<Query__c> queryList = [SELECT Id, Name, Soql__c FROM Query__c WHERE Active__c = true ORDER BY Name LIMIT 10];
		QueryProcessHelper.processQuery(queryList, queryRunId);

		// Check apex logs
		List<Apex_Log__c> apexLogList = [SELECT Id, Name, Response_Time__c, Query__c, Query__r.Name FROM  Apex_Log__c WHERE Query__c != null];

		// Check apex Logs
		System.assertNotEquals(6,apexLogList.size());
		System.assert(queryLogScheduler.queryLogger != null);

		for (Apex_Log__c log : apexLogList){
			if (log.Query__c == queryId1) System.assertEquals('Account',log.Query__r.Name);
			if (log.Query__c == queryId2) System.assertEquals('Contact',log.Query__r.Name);
			if (log.Query__c == queryId3) System.assertEquals('Opportunity',log.Query__r.Name);
		}
		Test.stopTest();
	}
}