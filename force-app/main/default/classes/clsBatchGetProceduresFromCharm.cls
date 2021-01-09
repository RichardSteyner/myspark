public class clsBatchGetProceduresFromCharm implements Database.Batchable<Account>, 
                                                        Database.Stateful, 
                                                        Database.AllowsCallouts {
    
    private clsConnectionChram cn = new clsConnectionChram();   
    private Map<String, String> mapPatientIds = new map<String, String>();
    private List<String> patientIds;
    
    public clsBatchGetProceduresFromCharm(List<String> xIds){  
        patientIds= xIds;    
    }
    
    public List<Account> start(Database.BatchableContext BC){
        System.debug('Start - clsBatchGetProceduresFromCharm');
        return [select Id, External_ID__c from Account where External_ID__c in: patientIds];
       
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        
        List<HealthCloudGA__EHRProcedure__c> procedures = new List<HealthCloudGA__EHRProcedure__c>();
        HealthCloudGA__EHRProcedure__c auxProcedure;

        for(Account acc : scope){
            mapPatientIds.put(acc.External_ID__c, acc.Id);
        }

        for(String eId : mapPatientIds.keySet()){
              /*  date dt = mapCase.get(id).Account.Last_Sync__c;
                String xdate =  dt.year()+'-'+dt.month()+'-'+dt.day();
                String subUrl = '?from_date='+xdate*/
            try{
                String xparam = '/fhir/patients/' + eId + '/procedures';
                String body = cn.getJSON(xparam,'GET');
                clsProceduresList jsonProcedures = (clsProceduresList) JSON.deserialize(body, clsProceduresList.class);
                              
                for(clsProcedure.Entry en : jsonProcedures.data.entry){
                    auxProcedure = new HealthCloudGA__EHRProcedure__c();  
                    auxProcedure.HealthCloudGA__Account__c = mapPatientIds.get(eId);
                    auxProcedure.Charm_Id__c = String.valueOf(en.resource.identifier.get(0).value);
                    auxProcedure.HealthCloudGA__Code__c = en.resource.code.text;
                    auxProcedure.HealthCloudGA__Notes__c = en.resource.note!=null && en.resource.note.size()>0 ? en.resource.note[0].text : null;
                    auxProcedure.HealthCloudGA__PerformedDateTime__c = en.resource.performedDateTime;
                    auxProcedure.HealthCloudGA__Status__c = en.resource.status;
                    System.debug(auxProcedure);
                    procedures.add(auxProcedure);     
                        
                }
            } catch(Exception e){
                System.debug('clsBatchGetProceduresFromCharm - ' + e.getMessage());
            }
        }

        List<Database.UpsertResult> upsertResults = Database.upsert(procedures, HealthCloudGA__EHRProcedure__c.Charm_Id__c, false);
        for(Database.UpsertResult upsertResult:upsertResults) 
            if(!upsertResult.isSuccess()) 
                for(Database.Error upsertError : upsertResult.getErrors()) 
                    System.debug('clsBatchGetProceduresFromCharm - Upsert Error: ' + upsertError.getMessage());
              
    }
     
    public void finish(Database.BatchableContext BC){ 
       
    }

}