global class queryLogScheduler implements Schedulable {

	@TestVisible private static QueryLogger__c 		queryLogger {get {
														if (queryLogger == null) return QueryLogger__c.getOrgDefaults();
														return queryLogger;
											  		 } set;}
	// interface method
	global void execute(SchedulableContext sc) {
		Boolean runQuery = false;
		
		// Check decay parameter
		if (queryLogger != null && queryLogger.Hourly_Decay__c != null){
			// Checks current hour with the reverse decay parameter
			if (queryLogger.Hourly_Decay__c > 0){
				if (Math.mod(system.now().hour(), Integer.valueOf(queryLogger.Hourly_Decay__c)) == 0) runQuery = true;
			}
		}else if (queryLogger != null && queryLogger.Hourly_Decay__c == null){ 
			runQuery = true;
		} 

		// Schedule the next job
		System.schedule('QueryLogger','0 0 0-23 ? * *',new queryLogScheduler());


		if (runQuery || Test.isRunningTest()){
			// Create a new query run time records 
			Id queryRunId = Database.insert(new Query_Run__c(Name=String.valueOf(System.now()),Run_Time__c=System.now())).getId(); 


			// Set MAX_QUERY_SIZE value from the queryLogger record
			Integer MAX_QUERY_SIZE = (queryLogger != null && queryLogger.Query_Size__c != null) ? Integer.valueOf(queryLogger.Query_Size__c) : 10;

			// String query 
			String query = 'SELECT Id, Name, Soql__c FROM Query__c WHERE Active__c = true ORDER BY Name LIMIT '+MAX_QUERY_SIZE;
			
			// Get the queries
			List<Query__c> rsQuery = Database.query(query);

			// If the maxmimum query size less than or equal 100 
			if (rsQuery.size() <= 100){
				QueryProcessHelper.processQuery(rsQuery, queryRunId); 
			// If the maxmimum query size greater than 100 
			// Calls batch apex
			}else{ 
				queryBatch batch = new queryBatch(query, queryRunId);
				if (!Test.isRunningTest()) Database.executebatch(batch,100);
			}
		}
	}
}