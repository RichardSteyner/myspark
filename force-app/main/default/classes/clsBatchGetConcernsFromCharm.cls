public class clsBatchGetConcernsFromCharm implements Database.Batchable<account>, Database.Stateful, Database.AllowsCallouts {
  Private clsConnectionChram cn = new clsConnectionChram();  
   
  Private list<String>Ids;
  public clsBatchGetConcernsFromCharm(list<String> xIds){  Ids= xIds;    }     
    
	public List<account> start(Database.BatchableContext BC){
   		return [select id, External_ID__c,Last_Sync__c from account where External_ID__c in : Ids];
   }
    
    public void execute(Database.BatchableContext BC, List<account> scope){
        
    }
    
    public void finish(Database.BatchableContext BC){ 
      
    }
}