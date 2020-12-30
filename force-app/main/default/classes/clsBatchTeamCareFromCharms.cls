public class clsBatchTeamCareFromCharms implements Database.Batchable<account>, Database.Stateful, Database.AllowsCallouts{
  
   private clsConnectionChram cn = new clsConnectionChram();
   private list<String> lstIds  = new list<String>();
   private map<String,String>mapPatient = new map<String, String>();
    
    
   public clsBatchTeamCareFromCharms(list<String> Ids){
        lstIds = Ids;
       for(string s : Ids){
           string[] x =  s.split(':xdt:');
          mapPatient.put(s, x[0]); 
       }
   } 
    
    
   public List<account> start(Database.BatchableContext BC){
       return [select id, External_ID__c,PersonContactId,Phone,PersonHomePhone from account where External_ID__c in : mapPatient.values()];
    }
    
    public void execute(Database.BatchableContext BC, List<account> scope){
        CaseTeamRole role = [select Id from CaseTeamRole where Name = 'Care Coordinator' limit 1];
        try{
            for(Account ac : scope){
               String idP = ac.External_ID__c;
               String xparam = '/fhir/patients/'+idP+'/careteam';
               String body = cn.getJSON(xparam,'GET');
               body = body.replaceAll('"system:"', '"xsystem:"');
                
               clsListCareTeam CareTeam = new clsListCareTeam(); 
               CareTeam = (clsListCareTeam) JSON.deserialize(body,clsListCareTeam.class);   
                               
               //system.debug('Care Team : ' + CareTeam.data );   
               //list<contact> lstContact = new list<contact>();  
               for(clsTeamCare.Participant pt : CareTeam.data.Participant){
                 
				                   
                /*  CaseTeamMember ct = new CaseTeamMember();
                  ct.ParentId = theCase.Id;
                  ct.MemberId = 'Cloud Creattion';
                  ct.TeamRoleId = role.Id;*/
                   
                /*    contact  cnt = new Contact();
                    cnt.LastName = pt.member.display;
                    cnt.Especiality__c= pt.role.text;
                    //cnt.External_id__c = pt.
                    lstContact.add(cnt);*/
               }
               
            }
            
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
        
        /*
      Long timestamp = datetime.now().getTime();
         
      clsListCareTeam CareTeam = new clsListCareTeam();
      List<clsTeamCare> auxPatients = new List<clsTeamCare>();
  	  String idP = '100016000000000189';
 	  String xparam = '/fhir/patients/'+idP+'/careteam';
      String body = cn.getJSON(xparam,'GET');
      body = body.replaceAll('"system:"', '"xsystem:"'); 
       
      CareTeam = (clsListCareTeam) JSON.deserialize(body,clsListCareTeam.class);   
       
      system.debug('xbody : ' + CareTeam.data);
         */ 
    }
    
    public void finish(Database.BatchableContext BC){ 
      
    }
}