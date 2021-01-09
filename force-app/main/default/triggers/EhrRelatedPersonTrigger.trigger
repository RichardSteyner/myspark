trigger EhrRelatedPersonTrigger on HealthCloudGA__EhrRelatedPerson__c ( after insert,after update) {

  if(ApexUtil.isEhrRelatedPersonTriggerInvoked){
          
    if ( trigger.isInsert || trigger.isUpdate){
          
        RecordType recordTypeRPCaregiver = [SELECT Id,Name FROM RecordType WHERE SobjectType='HealthCloudGA__EhrRelatedPerson__c' and DeveloperName='Caregiver' Limit 1] ;
        
        List<Account> ListAccount = new List<Account>();
        Set<String> SetAccountId = New Set<String>();
        
        for (HealthCloudGA__EhrRelatedPerson__c NewRP  :  Trigger.new) {         
                ListAccount.Add(new Account (Id = NewRP.HealthCloudGA__Account__c , Sync__c=True ));       
            	SetAccountId.add(NewRP.HealthCloudGA__Account__c);
         }
        
        if(trigger.isAfter){                                               
        
            Map<String,List<HealthCloudGA__EhrRelatedPerson__c>> MapAccountRelatedPerson = New Map<String,List<HealthCloudGA__EhrRelatedPerson__c>>();         
            For( HealthCloudGA__EhrRelatedPerson__c RPC : [SELECT Id,HealthCloudGA__Account__c,HealthCloudGA__Account__r.External_ID__c  FROM HealthCloudGA__EhrRelatedPerson__c WHERE RecordTypeId = : recordTypeRPCaregiver.Id and HealthCloudGA__Account__c IN :  SetAccountId  order by HealthCloudGA__Account__c ASC , ID ASC]){
                if(MapAccountRelatedPerson.get(RPC.HealthCloudGA__Account__c) == NULL) MapAccountRelatedPerson.put(RPC.HealthCloudGA__Account__c,new List<HealthCloudGA__EhrRelatedPerson__c>());
                MapAccountRelatedPerson.get(RPC.HealthCloudGA__Account__c).add(RPC);
            }
            
            Integer count;
            List<HealthCloudGA__EhrRelatedPerson__c> ListRelatedPerson = new List<HealthCloudGA__EhrRelatedPerson__c>();
            for(String Str : MapAccountRelatedPerson.keyset()){
				count =0;
                for( HealthCloudGA__EhrRelatedPerson__c RPC: MapAccountRelatedPerson.get(Str)){
                    RPC.Caregiver_Type__c = count;
                    RPC.Caregiver_ExtId_PatIdTypeId__c = RPC.HealthCloudGA__Account__r.External_ID__c+'_'+count;
                    Count += 1;
                    ListRelatedPerson.add(RPC);
                }                
            }
            
            ApexUtil.isEhrRelatedPersonTriggerInvoked=False;
            if(!ListRelatedPerson.isEmpty()) Update ListRelatedPerson;
            ApexUtil.isEhrRelatedPersonTriggerInvoked=True;
            
            
            ApexUtil.isAccountTriggerInvoked = False;
            if(!ListAccount.isEmpty()) Update ListAccount;
            ApexUtil.isAccountTriggerInvoked = True;    
            
        }    
        
       
    }
  
    
  }
    
    
}