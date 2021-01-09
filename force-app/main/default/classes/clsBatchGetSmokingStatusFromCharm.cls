public class clsBatchGetSmokingStatusFromCharm implements Database.Batchable<Account>, 
                                                        Database.Stateful, 
                                                        Database.AllowsCallouts {
    
    private clsConnectionChram cn = new clsConnectionChram();   
    private Map<String, String> mapPatientIds = new map<String, String>();
    private List<String> patientIds;
    
    public clsBatchGetSmokingStatusFromCharm(List<String> xIds){  
        patientIds= xIds;    
    }
    
    public List<Account> start(Database.BatchableContext BC){
        System.debug('Start - clsBatchGetSmokingStatusFromCharm');
        return [select Id, External_ID__c from Account where External_ID__c in: patientIds];
       
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        
        Map<Id, Account> accountsUpdate = new Map<Id, Account>();

        for(Account acc : scope){
            mapPatientIds.put(acc.External_ID__c, acc.Id);
        }

        for(String eId : mapPatientIds.keySet()){
            try{
                String xparam = '/fhir/patients/' + eId + '/smokingstatus';
                String body = cn.getJSON(xparam,'GET');
                clsSmokingStatus jsonSmoking = (clsSmokingStatus) JSON.deserialize(body, clsSmokingStatus.class);
                
                if(jsonSmoking.data!=null && jsonSmoking.data.valueCodeableConcept!=null) {
                    accountsUpdate.put(mapPatientIds.get(eId), new Account(Id=mapPatientIds.get(eId),
                                                                            Smoking_Status__c=jsonSmoking.data.valueCodeableConcept.text));
                }else{
                    accountsUpdate.put(mapPatientIds.get(eId), new Account(Id=mapPatientIds.get(eId),
                                                                            Smoking_Status__c=null));
                }
                        
            } catch(Exception e){
                System.debug('clsBatchGetSmokingStatusFromCharm - ' + e.getMessage());
            }
        }

        List<Database.SaveResult> saveResults = Database.update(accountsUpdate.values(),  false);
        for(Database.SaveResult saveResult : saveResults) 
            if(!saveResult.isSuccess()) 
                for(Database.Error saveError : saveResult.getErrors()) 
                    System.debug('clsBatchGetSmokingStatusFromCharm - Update Error: ' + saveError.getMessage());
              
    }
     
    public void finish(Database.BatchableContext BC){ 
       
    }
    
}