public class clsBatchGetMedicationsFromCharm Implements Database.Batchable<String>,Database.Stateful,Database.AllowsCallouts{

 private List<String> ListPatients;
    private clsConnectionChram cn = new clsConnectionChram();
    
    public clsBatchGetMedicationsFromCharm (List<String> ListPat){
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
         clsListMedications ListMedications ;
         List<HealthCloudGA__EhrMedicationPrescription__c> ListEhrMedicationPrescription = new List<HealthCloudGA__EhrMedicationPrescription__c>();
         HealthCloudGA__EhrMedicationPrescription__c EhrMedication;
         integer page;
         Boolean has_more_page;
         
         for (String AEI : scope){
            //System.debug('/patients/'+AEI+'/medications');
          if (MapAccountExternalId.get(AEI) != null ){
              
            page = 1;
                        
           do{
               
               try{
                   
            has_more_page=false;    
            Body = cn.getJSON('/patients/'+AEI+'/medications?page=' + page,'GET');
               
            Map<String, Object> m =  (Map<String, Object>)  JSON.deserializeUntyped(Body);            
               
            ListMedications = (clsListMedications) JSON.deserializeStrict(Json.serialize(m),clsListMedications.class);   
    		
            if (ListMedications != null && MapAccountExternalId.get(AEI) != null){
                 
                 if (!ListMedications.medications.isEmpty() ){                     
                     for (clsListMedications.medication md : ListMedications.medications){
                            //System.debug('Alle:'+Alle);
                            EhrMedication = new HealthCloudGA__EhrMedicationPrescription__c();
                 			EhrMedication.HealthCloudGA__Account__c = MapAccountExternalId.get(AEI).Id;
                         	EhrMedication.External_Id__c = md.patient_medication_id;
                         	EhrMedication.From_Date__c = (String.isNotBlank(md.date_of_entry) ? Date.valueOf(md.date_of_entry) : null); //date_of_entry
                         	EhrMedication.Dosage__c = md.dosage_unit; //dosage_unit
                         	EhrMedication.Intake_Type__c = md.intake_rounte; //intake_rounte
                         	EhrMedication.HealthCloudGA__DispenseQuantityValue__c = String.isNotBlank(md.dispense) ? Decimal.valueOf(md.dispense) : 0 ; //dispense
                         	EhrMedication.Refills__c = md.refills; //refills
                         	EhrMedication.HealthCloudGA__DispenseQuantityUnit__c = md.dispense_unit; //dispense_unit
                         	//drug_details_id
                         	EhrMedication.Drug__c =md.generic_drug_name; //generic_drug_name
                         	EhrMedication.Supplement__c = md.generic_product_name; //generic_product_name
                         	EhrMedication.Trade_Name__c = md.trade_name;
                         	EhrMedication.Strength_Description__c = md.strength_description;
                         	EhrMedication.Doseform_Description__c = md.doseform_description;
                         	//encounter_id
                         	EhrMedication.Directions__c = md.directions;
                         	EhrMedication.Comments__c= md.directions;
                         	EhrMedication.Is_Directions_Edited__c = Boolean.valueOf(md.is_directions_edited);
                         	EhrMedication.Manufacturer__c = md.manufacturing_type;
                         	EhrMedication.Substitute_Generic__c = md.substitute_generic;
                         	EhrMedication.Days_Of_Supply__C = md.days_of_supply;
                         	ListEhrMedicationPrescription.add(EhrMedication);
                            
                     }      
                 }
                 
                 has_more_page = Boolean.valueOf(ListMedications.page_context.has_more_page);
             } 
               
                   }catch (Exception e){
             system.debug('Error msj  : '+ e.getMessage());
           }
                   
           }while(has_more_page) ;
          } 
         } 
         
        if(!ListEhrMedicationPrescription.isEmpty()) Upsert ListEhrMedicationPrescription HealthCloudGA__EhrMedicationPrescription__c.External_ID__c ;
         
     }
    
     public void finish(Database.BatchableContext BC){ 
         
     }
}