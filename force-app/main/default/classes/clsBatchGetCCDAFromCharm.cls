public class clsBatchGetCCDAFromCharm Implements Database.Batchable<String>,Database.Stateful,Database.AllowsCallouts{

 	private List<String> ListPatients;
    private clsConnectionChram cn = new clsConnectionChram();
    
    public clsBatchGetCCDAFromCharm (List<String> ListPat){
        ListPatients = New List<String> ();
        ListPatients.addAll(ListPat) ;        
    }
    
    public List<String> start(Database.BatchableContext BC){
        return ListPatients;
    }
    
    public void execute(Database.BatchableContext BC, List<String> scope) {
         
         Set<String> SetAccount = new Set<String>();
         SetAccount.addAll(scope);
		         
         Map<String, String> MapAccountIdExternalId = new Map<String, String>();       
         Map<String,String> MapNameCCDAContenDocument = new Map<String,String>();         
        
         for(Account A : [SELECT Id,External_ID__c FROM Account WHERE External_ID__c in : SetAccount ] ) 
         {
             MapAccountIdExternalId.put(A.External_ID__c,A.Id);
             MapNameCCDAContenDocument.put(A.External_ID__c+'_CCDA',null);
         }
                     
        for(ContentDocument CD : [Select Id,Title from ContentDocument where Title in : MapNameCCDAContenDocument.keySet() ]) MapNameCCDAContenDocument.put(CD.Title,CD.Id);
           
         String CCDA = '' ;
   		 ContentVersion CV;
         Map<String,ContentVersion> MapContentVersion = new Map<String,ContentVersion>();
        
         for (String AEI : scope){
            if (MapAccountIdExternalId.get(AEI) != null ){
                   
              try{
    
                CCDA = cn.getJSON('/fhir/patients/'+AEI+'/ccda','GET');
                    
                    if(String.isNotBlank(CCDA)){
                        
                        CV = new ContentVersion();  
                        if(MapNameCCDAContenDocument.get(AEI+'_CCDA') != null ) CV.ContentDocumentId = MapNameCCDAContenDocument.get(AEI+'_CCDA');
                        CV.Title = AEI+'_CCDA' ;                    
                        CV.PathOnClient = AEI+'_CCDA' + '.xml';
                        CV.VersionData = Blob.valueOf(CCDA); 
                        MapContentVersion.put(AEI+'_CCDA',CV);                                                  
                        
                    }                
            
              }catch (Exception e){
                 system.debug('Error msj  : '+ e.getMessage());
               }           
            }
         } 
        
        if(!MapContentVersion.isEmpty())
        {   
            Insert MapContentVersion.values();
        
        Set<String> SetIdContentVersion = new Set<String>();
        
        For(ContentVersion CV0: MapContentVersion.values()) SetIdContentVersion.add(CV0.Id);
        
        for(ContentVersion CV1 : [Select Id,ContentDocumentId,Title from ContentVersion where Id in: SetIdContentVersion ]) MapContentVersion.put(CV1.Title,CV1);
        
        ContentDocumentLink CDL ;
        List<ContentDocumentLink> ListContentDocument = new List<ContentDocumentLink>();
        
        for (String AEI : scope){
          if (MapAccountIdExternalId.get(AEI) != null ){
            if(MapNameCCDAContenDocument.get(AEI+'_CCDA') == null ){
                        CDL = new ContentDocumentLink();
                    	CDL.ContentDocumentId =MapContentVersion.get(AEI+'_CCDA').ContentDocumentId;
                    	CDL.LinkedEntityId = MapAccountIdExternalId.get(AEI) ;
                    	ListContentDocument.add(CDL);
          }     
          }
        }
        
        if(!ListContentDocument.isEmpty()) insert ListContentDocument;        
         
    	}
     }
    
     public void finish(Database.BatchableContext BC){ 
         
     }
}