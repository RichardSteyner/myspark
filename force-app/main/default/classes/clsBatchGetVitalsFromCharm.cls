public class clsBatchGetVitalsFromCharm Implements Database.Batchable<String>,Database.Stateful,Database.AllowsCallouts{

 	private List<String> ListPatients;
    private clsConnectionChram cn = new clsConnectionChram();
    
    public clsBatchGetVitalsFromCharm (List<String> ListPat){
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
         clsListVitals ListVitals ;
         List<HealthCloudGA__EhrObservation__c> ListEhrObservation = new List<HealthCloudGA__EhrObservation__c>();
         HealthCloudGA__EhrObservation__c EhrObservation;
         Set<String> SetVitals = new Set<String>(); 
         List<HealthCloudGA__EhrObservation__c> ListEhrObservationDel = new List<HealthCloudGA__EhrObservation__c>();
        
         for (String AEI : scope){
                    
           // try{

            Body = cn.getJSON('/patients/'+AEI+'/vitals','GET');
           
            ListVitals = (clsListVitals) JSON.deserialize(Body,clsListVitals.class);   
    		
            if (ListVitals != null ) {
                
                if (ListVitals.vital_entries != null && !ListVitals.vital_entries.isEmpty() ){   
                    
                    for (clsListVitals.vital_entries  VET :ListVitals.vital_entries ) {
                        
                        SetVitals.add(VET.vital_entry_id);
                    
                        if (VET.vitals != null && !VET.vitals.isEmpty()){
                            Integer Cont = 0;
                            
                            for (clsListVitals.vitals  ET : VET.vitals){
                                if(String.isNotBlank(ET.vital_value)){
                                    Cont++;
                                    EhrObservation = new HealthCloudGA__EhrObservation__c();
                                    EhrObservation.External_Id__c = VET.vital_entry_id;
                                    EhrObservation.HealthCloudGA__Account__c = MapAccountExternalId.get(AEI).Id;
                                    EhrObservation.HealthCloudGA__AppliesDateTime__c = DateTime.valueOf(VET.entry_date);
                                    EhrObservation.HealthCloudGA__NameLabel__c = ET.vital_name;
                                    EhrObservation.HealthCloudGA__ValueQuantity__c = ET.vital_value;
                                    EhrObservation.HealthCloudGA__ValueQuantityUnit__c = ET.vital_unit;    
                                    EhrObservation.External_Id_Line__c = EhrObservation.External_Id__c +'_'+ String.valueOf(Cont);
                                    EhrObservation.Active__c = True ;
                                    ListEhrObservation.add(EhrObservation);
                                }                                             	
                            }                       
                        }
                        
                    }
         
                }
            }
             
                 
                 
            List<HealthCloudGA__EhrObservation__c> getListEhrObservation = new list<HealthCloudGA__EhrObservation__c> ();
            if (!SetVitals.isEmpty()) getListEhrObservation.addall([SELECT Id , External_Id__c ,External_Id_Line__c FROM HealthCloudGA__EhrObservation__c WHERE External_Id__c IN :SetVitals and Active__c=True ]);     
             
            for(HealthCloudGA__EhrObservation__c Ehr1 : getListEhrObservation){
                Boolean IndNotDel = False;
                for(HealthCloudGA__EhrObservation__c Ehr2 : ListEhrObservation){
                    if(Ehr2.External_Id_Line__c == Ehr1.External_Id_Line__c) IndNotDel=True;
                }                
                if (!IndNotDel) ListEhrObservationDel.add(Ehr1);
            }                                           
       
         /* }catch (Exception e){
             system.debug('Error msj  : '+ e.getMessage());
           }               
           */  
         } 
         
          if(!ListEhrObservationDel.isEmpty()) Delete ListEhrObservationDel;
            
          if(!ListEhrObservation.isEmpty()) upsert ListEhrObservation HealthCloudGA__EhrObservation__c.External_Id_Line__c;
         
     }
    
     public void finish(Database.BatchableContext BC){ 
         
     }
}