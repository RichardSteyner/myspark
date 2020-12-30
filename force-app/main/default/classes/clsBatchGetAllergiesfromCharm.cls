public class clsBatchGetAllergiesfromCharm Implements Database.Batchable<String>,Database.Stateful,Database.AllowsCallouts{	

    private List<String> ListPatients;
    private clsConnectionChram cn = new clsConnectionChram();
    
    public clsBatchGetAllergiesfromCharm (List<String> ListPat){
        ListPatients = New List<String> ();
        ListPatients.addAll(ListPat) ;        
    }
    
    public List<String> start(Database.BatchableContext BC){
        return ListPatients;
    }
    
     public void execute(Database.BatchableContext BC, List<String> scope) {
         
         Set<String> SetAccount = new Set<String>();
         SetAccount.addAll(scope);
		         
         Map<String, Account> MapAccountExternalId = new Map<String, Account>();
         
         for(Account A : [SELECT Id,External_ID__c FROM Account WHERE External_ID__c in : SetAccount ] ) MapAccountExternalId.put(A.External_ID__c,A);
             
         String Body = '' ;
         clsListAllergies ListAllergies ;
         List<HealthCloudGA__EhrAllergyIntolerance__c> ListEhrAllergies = new List<HealthCloudGA__EhrAllergyIntolerance__c>();
         HealthCloudGA__EhrAllergyIntolerance__c EhrAllergy;
         integer page;
         Boolean has_more_page;
         for (String AEI : scope){
           // System.debug('/patients/'+AEI+'/allergies');
          if (MapAccountExternalId.get(AEI) != null ){  
               page = 1; 
               do{
    
                    try{
                                               
                has_more_page=false;  
                Body = cn.getJSON('/patients/'+AEI+'/allergies?page=' + page,'GET');
                ListAllergies = (clsListAllergies) JSON.deserialize(Body,clsListAllergies.class);   
                 
                //System.debug('Body:'+Body);             
                //System.debug('ListAllergies:'+ListAllergies);
                 
                 if (ListAllergies != null && MapAccountExternalId.get(AEI) != null ){
                     if (!ListAllergies.allergies.isEmpty() ){                     
                         for (clsListAllergies.allergies Alle : ListAllergies.allergies){
                                //System.debug('Alle:'+Alle);
                                EhrAllergy = new HealthCloudGA__EhrAllergyIntolerance__c();
                                EhrAllergy.HealthCloudGA__Account__c = MapAccountExternalId.get(AEI).Id;
                                EhrAllergy.Allergen__c = Alle.allergen;
                                EhrAllergy.Status__c = (Alle.status=='1' ? 'Active':'Inactive');
                                EhrAllergy.Type__c = Alle.type;
                                EhrAllergy.Severity__c = Alle.severity;
                                EhrAllergy.HealthCloudGA__Reaction__c = Alle.reactions;
                                EhrAllergy.Observed_on__c = (String.isNotBlank(Alle.observed_on) ? Date.valueOf(Alle.observed_on) : null); // Alle.observed_on;                       
                                EhrAllergy.Date_Of_Entry__c = (String.isNotBlank(Alle.date_of_entry) ? Date.valueOf(Alle.date_of_entry) : null);
                             	EhrAllergy.External_ID__c= Alle.patient_allergy_id;
                                ListEhrAllergies.add(EhrAllergy);
                                //System.debug('EhrAllergy:'+EhrAllergy);
                         }      
                     }
                 }   
                 
                 has_more_page = Boolean.valueOf(ListAllergies.page_context.has_more_page);
                 
                   }catch (Exception e){
                 system.debug('Error msj  : '+ e.getMessage());
               }
                        
			}
              while(has_more_page) ;
          }
         } 
         
        if(!ListEhrAllergies.IsEmpty()) Upsert ListEhrAllergies HealthCloudGA__EhrAllergyIntolerance__c.External_ID__c ;
         
         System.debug(ListEhrAllergies);
                  
     }
    
     public void finish(Database.BatchableContext BC){ 
         
     }
    
}