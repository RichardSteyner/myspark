public class clsBatchGetGoalsFromCharm implements Database.Batchable<Case>, Database.Stateful, Database.AllowsCallouts{ 

  Private clsConnectionChram cn = new clsConnectionChram();   
  Private map<string, string> mapPatient = new map<string, string>();
  Private map<string,list<case>> mapCase = new map<string,list<case>>();
   
  Private list<String>Ids;
  
    
  public clsBatchGetGoalsFromCharm(list<String> xIds){  Ids= xIds;    }     
    
 
   public List<Case> start(Database.BatchableContext BC){
   		return [select id, Aux_id__c,Team_Care_From_Charm__c,Account.Last_Sync__c from case where Aux_id__c in :Ids];
   }
    
    public void execute(Database.BatchableContext BC, List<Case> scope){
        
       list<HealthCloudGA__CarePlanGoal__c> ListGoals = new list<HealthCloudGA__CarePlanGoal__c>() ;
       for(Case  c : Scope){
          string s = c.Aux_id__c;
          string[] x =  s.split(':xdt:');
          mapPatient.put(s, x[0]); 
           
          if(!mapCase.containsKey(x[0])){
              mapCase.put(x[0],new list<case>());
          }
          mapCase.get(x[0]).add(c);
       }
          for(string id : mapPatient.values()){
             /*  date dt = mapCase.get(id).Account.Last_Sync__c;
               String xdate =  dt.year()+'-'+dt.month()+'-'+dt.day();
               String subUrl = '?from_date='+xdate*/
               
               String xparam = '/fhir/patients/'+id+'/goals';
               String body = cn.getJSON(xparam,'GET');
               body = body.replaceAll('"system:"', '"xsystem:"');
               clsGoalsList GoalsList = new clsGoalsList(); 
           	   GoalsList = (clsGoalsList) JSON.deserialize(body,clsGoalsList.class);
                             
               for(clsGoals.Entry en : GoalsList.Data.entry){
                   
                   if(mapCase.containsKey(id)){
                      for(Case cs : mapCase.get(id)){
                           HealthCloudGA__CarePlanGoal__c hg = new HealthCloudGA__CarePlanGoal__c();  
                           hg.HealthCloudGA__CarePlan__c = cs.id;
                           hg.HealthCloudGA__Description__c = en.resource.description.text;
                           hg.HealthCloudGA__ActivityDate__c = date.valueof(en.resource.startDate);
                           ListGoals.add(hg);
                   	  } 
                   }
                   
               }
           }
        insert ListGoals;
             
    }
    
    public void finish(Database.BatchableContext BC){ 
      
    }
}