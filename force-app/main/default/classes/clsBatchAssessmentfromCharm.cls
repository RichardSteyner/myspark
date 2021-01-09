public class clsBatchAssessmentfromCharm implements Database.Batchable<account>, Database.Stateful, Database.AllowsCallouts {
	Private clsConnectionChram cn = new clsConnectionChram();   
    Private list<String>Ids;
    
    public clsBatchAssessmentfromCharm(list<String> xIds){  Ids= xIds;    }     
    RecordType RdType =  [SELECT Id FROM RecordType WHERE Name = 'assessment' and SObjectType = 'Appoinment__c'];
 
   public List<account> start(Database.BatchableContext BC){
   		return [select id, External_ID__c,Last_Sync__c, name from account where External_ID__c in : Ids];
   }
    
    public void execute(Database.BatchableContext BC, List<account> scope){
       list<Appoinment__c> ListApp = new list<Appoinment__c>(); 
       
        for(Account ac : Scope){
          
          string patientId = ac.External_ID__c;
            
          String xparam = '/fhir/patients/'+patientId+'/assessments';
          String body = cn.getJSON(xparam,'GET');
          body = body.replaceAll('"system:"', '"xsystem:"');
            
          clsAssessmentList AssessmentList = new clsAssessmentList(); 
          AssessmentList = (clsAssessmentList) JSON.deserialize(body,clsAssessmentList.class);
            
          integer i=1;              
          for(clsAssessment.Entry en : AssessmentList.Data.entry){
             dateTime due = dateTime.valueOf(en.resource.period.start + ' 00:00:00');
             long cxid =  due.getTime(); 
              
              
             Appoinment__c appc = new Appoinment__c();
             
             appc.Start_Date__c=  date.valueof(en.resource.period.start);
             appc.Patient__c = ac.id;
             appc.Name=ac.name+' : '+ en.resource.period.start;
             appc.Assessment__c=en.resource.description;
             appc.External_id__c = patientId+':xdt:'+cxid;
             appc.title__c = en.resource.title;
             appc.resourceType__c=en.resource.resourceType;
             appc.RecordTypeId=RdType.id;
             
             ListApp.add(appc);
             i=i+1;
          }
        }
        upsert ListApp External_id__c;
    }
    
    public void finish(Database.BatchableContext BC){ 
      
    }
}