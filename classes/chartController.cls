public with sharing class chartController {
	
	public ApexPages.standardController stdController 		{get; set;}
	public String 						queryrunId 			{get; set {
																			if (value != null) queryRun = [SELECT Id, Name, Run_Time__c FROM Query_Run__c WHERE Id=: value LIMIT 1];
																			queryrunId = value;
																	  }
															}
	public List<Apex_Log__c>			apexLogsList		{get; set;}
	public Query_Run__c                 queryRun 			{get; set;}
	

	/*
	*	Constructor 
	*/
	public chartController() {
		apexLogsList = new List<Apex_Log__c>(); 
		queryRun = new Query_Run__c();
	}

	/*
	*	Constructor taking standard controller as a parameter
	*/
	public chartController(ApexPages.standardController controller) {
		stdController = controller;
		queryrunId = String.valueOf(stdController.getId());
		getQueryLogs();
	}


	/*
	*	Description : Get all the query runs
	*	return : select list - query runs
	*/
	public List<SelectOption> getQueryRuns(){
		List<SelectOption> options = new List<SelectOption>();
		for (Query_Run__c qRun : [SELECT Id, Name FROM Query_Run__c ORDER BY Run_Time__c]){
			options.add(new SelectOption(String.valueOf(qRun.Id), qRun.Name));
		}
		return options;
	}

	/*
	*	Description : Get all the apex logs for the query run
	*	return : :List of all the apex logs for given run time.
	*/
	public void getQueryLogs(){ 
		apexLogsList = new List<Apex_Log__c>(); 
		// Get the logs
		if (!String.isBlank(queryrunId)){
			apexLogsList = [SELECT Id, Name, Query__r.Name, Response_Time__c FROM Apex_Log__c WHERE Query_Run_Time__c =: queryrunId ORDER BY Query__r.Name];
		}
	}
}