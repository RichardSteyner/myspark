trigger IdentityDocumentTrigger on IdentityDocument (after insert,after update) {
	if(ApexUtil.isIdentityDocumentTriggerInvoked){
         if ( trigger.isInsert || trigger.isUpdate){
       
        Map<String, Account> ListAccount = new Map<String, Account>();
      
        for (IdentityDocument ID  :  Trigger.new) {         
                ListAccount.put(ID.RelatedLegalEntityId, new Account (Id = ID.RelatedLegalEntityId , Sync__c=True ));  
         }
            ApexUtil.isAccountTriggerInvoked = False;
            if(!ListAccount.IsEmpty()) Update ListAccount.values();
            ApexUtil.isAccountTriggerInvoked = True;
       }
        
    }
}