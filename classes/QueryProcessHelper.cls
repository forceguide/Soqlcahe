public with sharing class QueryProcessHelper {
	
	/*
	*	Process the query and create a new log for each query
	*/
	public static void processQuery(List<Query__c> queryList, Id queryRunId){

		// Run the query and create a audit log
		if (!queryList.isEmpty() && queryRunId != null){
			for (Query__c query : queryList){
				// Instantiate the log handler
				apexLogHandler.apexLog log = new apexLogHandler.apexLog('queryLogScheduler','execute', query.Name, queryRunId, query.Id); 

				// Run the actual query
				Database.query(query.Soql__c);

				// Save the logs 
				log.saveLogs();  
			}
		}
	}
}