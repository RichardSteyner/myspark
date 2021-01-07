public class clsBatchGetImplantsFromCharm implements Database.Batchable<Account>, 
                                                        Database.Stateful, 
                                                        Database.AllowsCallouts {
    
    private clsConnectionChram cn = new clsConnectionChram();   
    private Map<String, String> mapPatientIds = new map<String, String>();
    private List<String> patientIds;
    
    public clsBatchGetImplantsFromCharm(List<String> xIds){  
        patientIds= xIds;    
    }
    
    public List<Account> start(Database.BatchableContext BC){
        System.debug('Start - clsBatchGetImplantsFromCharm');
        return [select Id, External_ID__c from Account where External_ID__c in: patientIds];
       
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        
        List<HealthCloudGA__EhrDevice__c> implants = new List<HealthCloudGA__EhrDevice__c>();
        HealthCloudGA__EhrDevice__c auxImplant;

        for(Account acc : scope){
            mapPatientIds.put(acc.External_ID__c, acc.Id);
        }

        for(String eId : mapPatientIds.keySet()){
              /*  date dt = mapCase.get(id).Account.Last_Sync__c;
                String xdate =  dt.year()+'-'+dt.month()+'-'+dt.day();
                String subUrl = '?from_date='+xdate*/
            try{
                String xparam = '/fhir/patients/' + eId + '/implants';
                String body = cn.getJSON(xparam,'GET');
                clsImplantsList jsonImplants = (clsImplantsList) JSON.deserialize(body, clsImplantsList.class);
                                
                for(clsImplant.Entry en : jsonImplants.data.entry){
                    auxImplant = new HealthCloudGA__EhrDevice__c();  
                    auxImplant.Account__c = mapPatientIds.get(eId);
                    auxImplant.Charm_Id__c = String.valueOf(en.resource.identifier.get(0).value);
                    auxImplant.HealthCloudGA__Expiry__c = en.resource.expirationDate;
                    auxImplant.HealthCloudGA__Version__c = en.resource.version;
                    auxImplant.HealthCloudGA__Type__c = en.resource.resourceType;
                    auxImplant.HealthCloudGA__Manufacturer__c = en.resource.manufacturer;
                    auxImplant.Status__c = en.resource.status;
                    auxImplant.HealthCloudGA__Udi__c = en.resource.udi!=null ? en.resource.udi.name : null;
                    System.debug(auxImplant);
                    implants.add(auxImplant);     
                        
                }
            } catch(Exception e){
                System.debug('clsBatchGetImplantsFromCharm - ' + e.getMessage());
            }
        }

        List<Database.UpsertResult> upsertResults = Database.upsert(implants, HealthCloudGA__EhrDevice__c.Charm_Id__c, false);
        for(Database.UpsertResult upsertResult:upsertResults) 
            if(!upsertResult.isSuccess()) 
                for(Database.Error upsertError : upsertResult.getErrors()) 
                    System.debug('clsBatchGetImplantsFromCharm - Upsert Error: ' + upsertError.getMessage());
              
    }
     
    public void finish(Database.BatchableContext BC){ 
       
    }
                                                            
}
