public class clsBatchGetProblemsfromCharm Implements Database.Batchable<String>,Database.Stateful,Database.AllowsCallouts{

 	private List<String> ListPatients;
    private clsConnectionChram cn = new clsConnectionChram();
    
    public clsBatchGetProblemsfromCharm (List<String> ListPat){
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
         clsListProblems ListProblems ;
         List<HealthCloudGA__EhrCondition__c> ListEhrConditions = new List<HealthCloudGA__EhrCondition__c>();
         HealthCloudGA__EhrCondition__c EhrCondition;
         
         for (String AEI : scope){
            //System.debug('/patients/'+AEI+'/medications');
         	//integer page = 1;
         	//Boolean has_more_page;
           if (MapAccountExternalId.get(AEI) != null ){ 
             
          /* do{               
            has_more_page=false;    */ 
             
            try{
                
            Body = cn.getJSON('/fhir/patients/'+AEI+'/problems','GET');
            Body.replaceAll('"system":', '"xsystem":');
            
            ListProblems = (clsListProblems) JSON.deserialize(Body,clsListProblems.class);   
    		
            if (ListProblems != null ){
                
                if (ListProblems.data != null ){
                
                 if ((Decimal) ListProblems.data.total > 0)
                     
                 	if (!ListProblems.data.entry.isEmpty() ){                     
                     
                        for (clsListProblems.Entry  ET : ListProblems.data.entry){
                            //System.debug('Alle:'+Alle);
                            
                            if (ET.resource != null ){
                                EhrCondition = new HealthCloudGA__EhrCondition__c();
                                EhrCondition.HealthCloudGA__Account__c = MapAccountExternalId.get(AEI).Id;
                                
                                if(ET.resource.identifier != null && !ET.resource.identifier.isEmpty()){
                                    EhrCondition.External_Id__c =String.valueOf(ET.resource.identifier[0].value) ;
                                }
                                
                                if(ET.resource.code != null){
                                    if(ET.resource.code.coding != null && !ET.resource.code.coding.isEmpty()){
                                        EhrCondition.HealthCloudGA__Code__c= ET.resource.code.coding[0].Code;
                                        EhrCondition.HealthCloudGA__CodeLabel__c = ET.resource.code.coding[0].display;
                                    }
                                }
                                
                                EhrCondition.HealthCloudGA__StatusLabel__c =  ET.resource.clinicalStatus;
                                
                                 if(ET.resource.category != null && !ET.resource.category.isEmpty() ){
                                    if(ET.resource.category[0].coding != null && !ET.resource.category[0].coding.isEmpty()){
                                        EhrCondition.HealthCloudGA__CategoryCode__c= ET.resource.category[0].coding[0].Code;
                                        EhrCondition.HealthCloudGA__CatergoryLabel__c = ET.resource.category[0].coding[0].display;
                                    }
                                }
                                Date DateTemp = Date.valueOf(ET.resource.onsetDateTime);
                                EhrCondition.onsetDateTime__c = DateTime.newInstance(DateTemp.year(), DateTemp.month(), DateTemp.day());
                                EhrCondition.Type__c = ET.resource.resourceType;
                                ListEhrConditions.add(EhrCondition);
                            }
                     }      
                 }
                    
                }
            }
            /*     has_more_page = Boolean.valueOf(ListMedications.page_context.has_more_page);
             } 
               
           }while(has_more_page) ;*/
           }catch (Exception e){
             system.debug('Error msj  : '+ e.getMessage());
           }
                
                }
         } 
         
        if(!ListEhrConditions.IsEmpty()) Upsert ListEhrConditions HealthCloudGA__EhrCondition__c.External_ID__c ;
         
     }
    
     public void finish(Database.BatchableContext BC){ 
         
     }
}