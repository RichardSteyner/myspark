trigger TriggerAccount on Account (before insert,before update) {

     if(ApexUtil.isAccountTriggerInvoked){
         if (trigger.isInsert) {     
             for (Account NewACC  :  Trigger.new) {
                 NewACC.Sync__c = True;
             }
         }
    	 if (trigger.isUpdate){
                         
             Map<String, Schema.SObjectField> MapFields = Schema.SObjectType.Account.fields.getMap(); 
             List<String> Sync = new List<String>{'sync__c'}; 
             Account OldAccount;
             
             for (Account NewACC  :  Trigger.new) {
                 
                  OldAccount = trigger.oldMap.get(NewACC.Id);
                 
                   for (String str : MapFields.keyset()) { 
                     
                    try {                       
                        if(OldAccount != null && NewACC.get(str) != OldAccount.get(str) && !Sync.contains(str)){                            
                            NewACC.Sync__c=true;
                        } 
                    } 
                    catch (Exception e) {
                        System.debug('Error: ' + e);
                    }
                } 
             }
         }
         
     }
    
}