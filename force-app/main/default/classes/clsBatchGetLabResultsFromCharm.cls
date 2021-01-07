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
            try{
                String xparam = '/fhir/patients/' + eId + '/labresults';
                String body = cn.getJSON(xparam,'GET');
                clsLabResultsList jsonLabResults = (clsLabResultsList) JSON.deserialize(body, clsLabResultsList.class);
                                
                for(clsLabResult.Entry en : jsonLabResults.data.entry){
                    //hacer un for para los components
                    if(en.resource.component!=null){
                        for (clsLabResult.Component comp : en.resource.component) {
                            auxLabResult = new HealthCloudGA__EhrMedicationStatement__c();  
                            auxLabResult.HealthCloudGA__Account__c = mapPatientIds.get(eId);
                            auxLabResult.HealthCloudGA__MedicationCode__c = en.resource.code.text;
                            auxLabResult.Charm_Id__c = en.resource.identifier.get(0).value + '-' + comp.code.text.toUpperCase();
                            auxLabResult.Name__c = comp.code.text;
                            auxLabResult.Effective_Date__c = en.resource.effectiveDateTime;
                            auxLabResult.Interpretation__c = comp.interpretation!=null ? comp.interpretation.text : null;
                            auxLabResult.Reference_Range_High__c = comp.getReferenceRangeHigh();
                            auxLabResult.Reference_Range_Low__c = comp.getReferenceRangeLow();
                            auxLabResult.Reference_Range_Custom__c = comp.getReferenceRangeCustom();
                            auxLabResult.Result__c = comp.valueQuantity!=null ? comp.valueQuantity.value : null;
                            auxLabResult.Unit__c = comp.getUnit();
                            System.debug(auxLabResult);
                            labResults.add(auxLabResult);     
                        }
                    } else if(en.resource.referenceRange!=null || en.resource.interpretation!=null || en.resource.valueQuantity!=null) {
                        auxLabResult = new HealthCloudGA__EhrMedicationStatement__c();  
                        auxLabResult.HealthCloudGA__Account__c = mapPatientIds.get(eId);
                        auxLabResult.HealthCloudGA__MedicationCode__c = en.resource.code.text;
                        auxLabResult.Charm_Id__c = en.resource.identifier.get(0).value + '-' + en.resource.code.text.toUpperCase();
                        auxLabResult.Name__c = en.resource.code.text;
                        auxLabResult.Effective_Date__c = en.resource.effectiveDateTime;
                        auxLabResult.Interpretation__c = en.resource.interpretation!=null ? en.resource.interpretation.text : null;
                        auxLabResult.Reference_Range_High__c = en.resource.getReferenceRangeHigh();
                        auxLabResult.Reference_Range_Low__c = en.resource.getReferenceRangeLow();
                        auxLabResult.Reference_Range_Custom__c = en.resource.getReferenceRangeCustom();
                        auxLabResult.Result__c = en.resource.valueQuantity!=null ? en.resource.valueQuantity.value : null;
                        auxLabResult.Unit__c = en.resource.getUnit();
                        System.debug(auxLabResult);
                        labResults.add(auxLabResult);     
                    }            
                        
                }
            } catch(Exception e){
                System.debug(e.getMessage());
            }
        }

        List<Database.UpsertResult> upsertResults = Database.upsert(labResults, HealthCloudGA__EhrMedicationStatement__c.Charm_Id__c, false);
        for(Database.UpsertResult upsertResult:upsertResults) 
            if(!upsertResult.isSuccess()) 
                for(Database.Error upsertError : upsertResult.getErrors()) 
                    System.debug('clsBatchGetLabResultsFromCharm - Upsert Error: ' + upsertError.getMessage());
              
    }
     
    public void finish(Database.BatchableContext BC){ 
       
    }

}