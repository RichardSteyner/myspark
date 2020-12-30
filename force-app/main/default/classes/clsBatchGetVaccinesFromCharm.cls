public class clsBatchGetVaccinesFromCharm Implements Database.Batchable<String>,Database.Stateful,Database.AllowsCallouts{

 	private List<String> ListPatients;
    private clsConnectionChram cn = new clsConnectionChram();
    
    public clsBatchGetVaccinesFromCharm (List<String> ListPat){
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
         clsListVaccines ListVaccines ;
         List<HealthCloudGA__EhrImmunization__c> ListEhrImmunization = new List<HealthCloudGA__EhrImmunization__c>();
         HealthCloudGA__EhrImmunization__c EhrImmunization;
         integer page;    
         Boolean has_more_page;
        
         for (String AEI : scope){
             
           if (MapAccountExternalId.get(AEI) != null ){ 
               
           page = 1;                            
             
              	do{
                  
                   try{
                        
                    has_more_page=false;    
                                        
                    Body = cn.getJSON('/patients/'+AEI+'/vaccines?page=' + page,'GET');
                   
                    ListVaccines = (clsListVaccines) JSON.deserialize(Body,clsListVaccines.class);   
                    
                    if (ListVaccines != null ) {
                        
                        if (ListVaccines.vaccines != null && !ListVaccines.vaccines.isEmpty() ){   
                            Date date_of_expiry ; 
                            
                            for(clsListVaccines.vaccines VAC : ListVaccines.vaccines){
                                
                                EhrImmunization = new HealthCloudGA__EhrImmunization__c();
                                EhrImmunization.External_Id__c = VAC.patient_vaccine_map_id;
                                EhrImmunization.HealthCloudGA__Account__c = MapAccountExternalId.get(AEI).Id;
                                EhrImmunization.Name__c = VAC.vaccine_name;                            
                                EhrImmunization.HealthCloudGA__DoseQuantity__c =  VAC.dosage;
                                EhrImmunization.HealthCloudGA__DoseQuantityUnits__c = VAC.dosage_unit;
                                EhrImmunization.HealthCloudGA__RouteCode__c = VAC.intake_route;
                                EhrImmunization.HealthCloudGA__SiteCode__c = VAC.site;
                                EhrImmunization.HealthCloudGA__LotNumber__c = VAC.vaccine_lot_number;
                                EhrImmunization.Note_to_Nurse__c = VAC.note_to_nurse;       
                                
                                if(String.isNotBlank(VAC.date_of_expiry)){
                                   date_of_expiry = Date.valueOf(VAC.date_of_expiry);
                                   EhrImmunization.HealthCloudGA__ExpirationDate__c = Datetime.newInstance(date_of_expiry.year(), date_of_expiry.month(), date_of_expiry.day());                                 
                                }
                                
                                //ordering_provider_id
                                //ordering_provider_name
                                EhrImmunization.Is_Administered__c = Boolean.valueOf(VAC.is_administered);
                                EhrImmunization.HealthCloudGA__DateAdministered__c = DateTime.valueOf(VAC.date_of_vaccination);
                                //encounter_id
                                EhrImmunization.Vis_Shared__c = VAC.vis_shared;
                                EhrImmunization.Vis_Given_Date__c = (String.isNotBlank(VAC.vis_given_date) ? Date.valueOf(VAC.vis_given_date) : null);
                                //date_time_of_vaccination
                                EhrImmunization.NDC_code__c = VAC.ndc_code;
                                EhrImmunization.Funding_Source__c = VAC.funding_source;
                                EhrImmunization.VFC_Eligibility__c = VAC.vfc_eligibility;
                                ListEhrImmunization.add(EhrImmunization);
                                }
                            }
                       
                        }                
                                            
                        has_more_page = Boolean.valueOf(ListVaccines.page_context.has_more_page);
                     
                        
                    }catch (Exception e){
                     system.debug('Error msj  : '+ e.getMessage());
                   }
         
               }while(has_more_page);     
                 
        		}
            }                                  
            
         if(!ListEhrImmunization.isEmpty()) upsert ListEhrImmunization HealthCloudGA__EhrImmunization__c.External_Id__c;
         
     }
    
     public void finish(Database.BatchableContext BC){ 
         
     }
}