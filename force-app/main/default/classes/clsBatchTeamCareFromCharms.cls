public class clsBatchTeamCareFromCharms implements Database.Batchable<Case>, Database.Stateful, Database.AllowsCallouts{
   Private clsConnectionChram cn = new clsConnectionChram();   
   Private map<string, string> mapPatient = new map<string, string>();
   Private map<string,list<case>> mapCase = new map<string,list<case>>();
    
   Private list<String>Ids;
    
  
   public clsBatchTeamCareFromCharms(list<String> xIds){  Ids= xIds;    }     
    
   public List<Case> start(Database.BatchableContext BC){
       return [select id, Aux_id__c,Team_Care_From_Charm__c from case where Aux_id__c in :	Ids];
   }
    
   public void execute(Database.BatchableContext BC, List<Case> scope){
     
       for(Case  c : Scope){
          string s = c.Aux_id__c;
          string[] x =  s.split(':xdt:');
          mapPatient.put(s, x[0]); 
           
          if(!mapCase.containsKey(x[0])){
             mapCase.put(x[0],new list<case>());
          }
          mapCase.get(x[0]).add(c);
       }
       
       list<case>lstCase = new list<case>();
       for(string id : mapPatient.values()){
           String xparam = '/fhir/patients/'+id+'/careteam';
           String body = cn.getJSON(xparam,'GET');
           body = body.replaceAll('"system:"', '"xsystem:"');
                   
           clsListCareTeam CareTeam = new clsListCareTeam(); 
           CareTeam = (clsListCareTeam) JSON.deserialize(body,clsListCareTeam.class);
           
           String Team='';
           for(clsTeamCare.Participant pt : CareTeam.data.Participant){
               String xrole = pt.role.text;    
               Team +=  pt.member.display+'('+xrole+'); ';
           }
           
           if(mapCase.containsKey(id)){
                for(Case cs : mapCase.get(id)){
                   cs.Team_Care_From_Charm__c = Team;
                   lstCase.add(cs);
                }
           }
       }
       
       update lstCase;
   }
    
    public void finish(Database.BatchableContext BC){ 
      
    }
}