public class clsBatchGetGoalsFromCharm implements Database.Batchable<Case>, Database.Stateful, Database.AllowsCallouts{ 

  Private clsConnectionChram cn = new clsConnectionChram();   
  Private map<string, string> mapPatient = new map<string, string>();
  Private map<string,list<case>> mapCase = new map<string,list<case>>();
   
  Private list<String>Ids;
  
    
  public clsBatchGetGoalsFromCharm(list<String> xIds){  Ids= xIds;    }     
    
 
   public List<Case> start(Database.BatchableContext BC){
   		return [select id, Aux_id__c,Team_Care_From_Charm__c,HealthCloudGA__DueDate__c from case where Aux_id__c in :Ids];
   }
    
    public void execute(Database.BatchableContext BC, List<Case> scope){
       list<HealthCloudGA__CarePlanGoal__c> ListGoals = new list<HealthCloudGA__CarePlanGoal__c>(); 
       
        for(Case c : Scope){
          string s = c.Aux_id__c;
          string[] x =  s.split(':xdt:');
          string patientId = x[0];
            
          dateTime dt = dateTime.valueOf(c.HealthCloudGA__DueDate__c +' 00:00:00') ;
          String subUrl = '?to_date='+dt.format('yyyy-MM-dd');
          String xparam = '/fhir/patients/'+patientId+'/goals'+subUrl;
          System.debug('xparam : '+ xparam);
            
          String body = cn.getJSON(xparam,'GET');
          body = body.replaceAll('"system:"', '"xsystem:"');
            
          clsGoalsList GoalsList = new clsGoalsList(); 
          GoalsList = (clsGoalsList) JSON.deserialize(body,clsGoalsList.class);
            
          integer i=1;              
          for(clsGoals.Entry en : GoalsList.Data.entry){
             dateTime due = dateTime.valueOf(en.resource.startDate + ' 00:00:00');
             long cxid =  due.getTime();
              
             HealthCloudGA__CarePlanGoal__c hg = new HealthCloudGA__CarePlanGoal__c();  
             hg.HealthCloudGA__CarePlan__c = c.id;
             hg.name= patientId+'_'+i;
             hg.HealthCloudGA__Description__c = en.resource.description.text;
             hg.HealthCloudGA__ActivityDate__c = date.valueof(en.resource.startDate);
           	 hg.External_Id__c = c.id +':xdt:'+ cxid;
             ListGoals.add(hg);
             i=i+1;
          }
        }
        upsert ListGoals External_Id__c;
    }
    
    public void finish(Database.BatchableContext BC){ 
      
    }
}