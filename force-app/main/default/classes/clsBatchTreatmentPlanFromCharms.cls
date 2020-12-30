public class clsBatchTreatmentPlanFromCharms implements Database.Batchable<account>, Database.Stateful, Database.AllowsCallouts{
   private clsPageContext PageContext;
   private clsConnectionChram cn = new clsConnectionChram();
   Private RecordType recordType;
   private list<string> lstIds;
   private list<string>lstTCase;
    
    public clsBatchTreatmentPlanFromCharms(list<string> Ids){
        lstIds = Ids;
        recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' and Name = 'CarePlan' LIMIT 1];
    }
    
   public List<account> start(Database.BatchableContext BC){
       return [select id, External_ID__c,PersonContactId,Phone,PersonHomePhone from account where External_ID__c in : lstIds];
    }
    
    public void execute(Database.BatchableContext BC, List<account> scope){
    list<case> lstCase = new list<case>();
        
       try{
           for(Account ac : scope){
               String idP = ac.External_ID__c;
               String xparam = '/fhir/patients/'+idP+'/treatmentplan';
               String body = cn.getJSON(xparam,'GET');
               body = body.replaceAll('"system:"', '"xsystem:"');
               
               clsListTreatmentPlan TreatmentPlan = new clsListTreatmentPlan();
               TreatmentPlan = (clsListTreatmentPlan) JSON.deserialize(body,clsListTreatmentPlan.class);  
                         
               list<clsTreatmentPlan.Resource> lstR = new  list<clsTreatmentPlan.Resource>();
               integer i = 1;
               
               system.debug('data : ' + TreatmentPlan.data.Entry);
               for(clsTreatmentPlan.Entry e : TreatmentPlan.data.Entry){
                   lstR.add(e.resource);  
                   //system.debug('e.resource : ' +i + ' --  ' + e.resource);
                   i++;
               }
                   
             // system.debug('Lst Resource : ' + lstR);
              if(!lstR.isEmpty()){
                       clsTreatmentPlan.Resource  rs =  lstR.get(0);  
                       dateTime due = dateTime.valueOf(rs.period.start + ' 00:00:00');
                       long cxid =  due.getTime();
                  
                       case c = new case();
                       c.AccountId = ac.id;
                       //c.ContactId = ac.PersonContactId;
                       c.subject = rs.title;
                       c.description = rs.description;
                       c.Status = 'new';
                       c.Origin='web';
                       c.RecordTypeId = recordType.id;
                       c.HealthCloudGA__DueDate__c = date.valueOf(rs.period.start);
                  	   c.Aux_id__c = ac.External_ID__c+':xdt:'+cxid;
                       lstCase.add(c);
                  	   lstTCase.add(c.Aux_id__c);
               }
           }
           
       }catch(Exception e){
          system.debug('Error : ' + e.getMessage());
       }
        
       system.debug('x_Case : '  + lstCase ); 
       if(!lstCase.isEmpty()){
           upsert lstCase Aux_id__c;
       }
    }
    
    public void finish(Database.BatchableContext BC){ 
       system.database.executeBatch(new clsBatchTeamCareFromCharms(lstTCase) );
    }
}