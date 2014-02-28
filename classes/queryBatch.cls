global class queryBatch implements Database.Batchable<sObject> {
	
	String query;
	Id queryRunId;
	
	global queryBatch(String soql, Id queryRunId) {
		this.query = soql;
		this.queryRunId = queryRunId;
	}
	
	// Batch start
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	// Batch execute
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<Query__c> queryList = (List<Query__c>)scope;
		QueryProcessHelper.processQuery(queryList, queryRunId); 
	}
	
	// Batch finish
	global void finish(Database.BatchableContext BC) {} 
	
}