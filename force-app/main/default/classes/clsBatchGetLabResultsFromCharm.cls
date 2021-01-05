public class clsBatchGetLabResultsFromCharm implements Database.Batchable<Account>, 
                                                        Database.Stateful, 
                                                        Database.AllowsCallouts {
    
    private clsConnectionChram cn = new clsConnectionChram();   
    private Map<String, String> mapPatientIds = new map<String, String>();
    private List<String> patientIds;
    
    public clsBatchGetLabResultsFromCharm(List<String> xIds){  
        patientIds= xIds;    
    }
    
    public List<Account> start(Database.BatchableContext BC){        
        
        Long timestamp = long.valueOf('1601557544691') ; //datetime.now().getTime();
        
        /*d*/
        
       return [select Id, External_ID__c from Account where External_ID__c in: patientIds];
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        
        List<HealthCloudGA__EhrMedicationStatement__c> labResults = new List<HealthCloudGA__EhrMedicationStatement__c>();
        HealthCloudGA__EhrMedicationStatement__c auxLabResult;

        for(Account acc : scope){
            mapPatientIds.put(acc.External_ID__c, acc.Id);
        }

        for(String eId : mapPatientIds.keySet()){
              /*  date dt = mapCase.get(id).Account.Last_Sync__c;
                String xdate =  dt.year()+'-'+dt.month()+'-'+dt.day();
                String subUrl = '?from_date='+xdate*/
                
            String xparam = '/fhir/patients/' + eId + '/labresults';
            String body = cn.getJSON(xparam,'GET');
            clsLabResultsList jsonLabResults = (clsLabResultsList) JSON.deserialize(body, clsLabResultsList.class);
                              
            for(clsLabResult.Entry en : jsonLabResults.data.entry){
                //hacer un for para los components    
                auxLabResult = new HealthCloudGA__EhrMedicationStatement__c();  
                auxLabResult.HealthCloudGA__Account__c = mapPatientIds.get(eId);
                auxLabResult.HealthCloudGA__MedicationCode__c = en.resource.code.text;
                auxLabResult.Charm_Id__c = en.resource.identifier.get(0).value + '-' + en.resource.code.text.toUpperCase();
                System.debug(auxLabResult);
                labResults.add(auxLabResult);          
                    
            }
        }

        //insert labResults;
              
     }
     
    public void finish(Database.BatchableContext BC){ 
       
    }

}
