public class clsBatchGetPatientfromCharm2 Implements Database.Batchable<clsPatient>, Database.Stateful, Database.AllowsCallouts {
 
   private clsPageContext PageContext;
   private clsConnectionChram cn = new clsConnectionChram();
   Map<String,String> MapFacility = new Map<String,String>();
   list<String> lstPatientIdCharm = new list<String>() ;      
              
   public List<clsPatient> start(Database.BatchableContext BC){        
        
        Long timestamp = long.valueOf('1601557544691') ; //datetime.now().getTime();
       
        String IdsF = '';
        for(Facilities__c f : [select facility_id__c from Facilities__c where Activate__c = True]){
           
            MapFacility.put(f.facility_id__c,f.Id);
            IdsF += f.facility_id__c+',';
        }
        
        IdsF = IdsF.removeEnd(',');
      
        clsListPatients lstPatients = new clsListPatients();
        List<clsPatient> auxPatients = new List<clsPatient>();
        integer page = 1;
        
        do{
            String xparam = '/patients?facility_id='+IdsF+'&modified_time_greater_equals='+timestamp+'&page=' + page ;
            String body = cn.getJSON(xparam,'GET');
            lstPatients = (clsListPatients) JSON.deserialize(body,clsListPatients.class);   
            PageContext = lstPatients.page_context;
            auxPatients.addAll(lstPatients.patients);
            page++;
            
        }while(Boolean.valueOf(PageContext.has_more_page)) ;
        
       return auxPatients;
    }
    
   public void execute(Database.BatchableContext BC, List<clsPatient> scope) {

     RecordType recordTypeAccount = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' and DeveloperName = 'Business_Account' LIMIT 1];
     RecordType recordTypeContact = [SELECT Id,Name FROM RecordType WHERE SobjectType='Contact' and DeveloperName='Guarantor' Limit 1] ; 
     RecordType recordTypeContactCaregiver = [SELECT Id,Name FROM RecordType WHERE SobjectType='Contact' and DeveloperName='Caregiver' Limit 1] ;

       
      List<ClsPatientGet> ListPatientGet = new List<ClsPatientGet>();
      String auxbodypatient;
      ClsPatientGet patient;
      ClsPatientGet.patient PatPatient;
      Account Acc;    
          
      List<Account> ListAccount = new List<Account>(); 
             
      Contact ContGuarantor;
      Map<String,Contact> MapContactGuarantor = new Map<String,Contact>();
             
      IdentityDocument PatientID;
      Map<String,List<IdentityDocument>> MapIdentityDocument = new Map<String,List<IdentityDocument>>();
      
      Contact ContCaregiver;
      Map<String,List<Contact>> MapContactCaregivers = new Map<String,List<Contact>>();
            
      for(clsPatient clsp : scope ){
          auxbodypatient = '';
          patient = new ClsPatientGet();
          Acc = new Account();
          ContGuarantor = null;
          PatientID = null;
          ContCaregiver = null ;
          
          try{              
          
          auxbodypatient = cn.getJSON('/patients/'+clsp.patient_id,'GET');
              
          patient = (ClsPatientGet) JSON.deserialize(auxbodypatient,ClsPatientGet.class); 
          
              if(patient.patient != null){
                  PatPatient = patient.patient;
                  lstPatientIdCharm.add(PatPatient.patient_id);
                  Acc.RecordTypeId = recordTypeAccount.Id;
                  Acc.External_ID__c = PatPatient.patient_id;
                  Acc.Record_Id__c = PatPatient.record_id;
                  Acc.Name = PatPatient.first_name + ' ' + PatPatient.middle_name + ' '+ PatPatient.last_name;
                  //Acc.FirstName = PatPatient.first_name; //PersonAccount
                  //Acc.MiddleName = PatPatient.middle_name; //PersonAccount
                  //Acc.LastName = PatPatient.last_name; //PersonAccount                 
                  Acc.DOB__c = String.IsNotBlank(PatPatient.dob) ? Date.valueOf(PatPatient.dob) : null ;
                  //is_auto_calculated_dob
                  Acc.Sex__c = PatPatient.gender;
				  Acc.Gender_Identity__c = PatPatient.gender_identity;                    
			      Acc.Nick_Name__c = PatPatient.nick_name;
                  Acc.Suffix__c = PatPatient.suffix; 
                  Acc.Maiden_Name__c = PatPatient.maiden_name;
                  Acc.Deceased__c = Boolean.valueOf(PatPatient.deceased);
                  Acc.DOD__c = String.IsNotBlank(PatPatient.dod) ? Date.valueOf(PatPatient.dod) : null ;
                  Acc.Cause_Of_Death__c = PatPatient.cause_of_death;
                  
                  if (PatPatient.facilities != null ){
                      for( clsPatientBase.facility fac : PatPatient.facilities) {
                          Acc.Facility__c = MapFacility.get(fac.facility_id);
                          break;
                      }
                  }
                  
                  //id_qualifiers
                  
                  if(PatPatient.id_qualifiers != null){
                      for(clsPatientBase.qualifier Q : PatPatient.id_qualifiers){
                          PatientID = new IdentityDocument();
                          PatientID.IdDocumentType = Q.id_qualifier;
                          PatientID.File_CharmId__c = Q.file_id;
                          PatientID.Name = Q.id_of_patient;                          
                          PatientID.External_PatientIdTypeID__c = PatPatient.patient_id+'_'+Q.id_qualifier;
                          
                          if(MapIdentityDocument.get(PatPatient.patient_id) == null ){
                              MapIdentityDocument.put(PatPatient.patient_id, new List<IdentityDocument>());
                          }                          
                          MapIdentityDocument.get(PatPatient.patient_id).add(PatientID);
                      }
                  }
                  
                  if(PatPatient.primary_contact_details != null){
                      
                        Acc.Address_Line_1__c = PatPatient.primary_contact_details.address_line1;
                        Acc.BillingStreet = PatPatient.primary_contact_details.address_line1;                    
                        Acc.BillingCity = PatPatient.primary_contact_details.city;
                        Acc.BillingCountry = PatPatient.primary_contact_details.country;
                        Acc.BillingState = PatPatient.primary_contact_details.state;
                        Acc.BillingPostalCode = PatPatient.primary_contact_details.zip_code;
                      	
                      	Acc.Address_Line_2__c = PatPatient.primary_contact_details.address_line2;
                      	Acc.ShippingStreet = PatPatient.primary_contact_details.address_line2;
                      	Acc.ShippingCity = PatPatient.primary_contact_details.city;
                        Acc.ShippingCountry = PatPatient.primary_contact_details.country;
                        Acc.ShippingState = PatPatient.primary_contact_details.state;
                        Acc.ShippingPostalCode = PatPatient.primary_contact_details.zip_code;
                      
                      	Acc.County__c = PatPatient.primary_contact_details.county;
                      	Acc.District__c = PatPatient.primary_contact_details.district;
                      	Acc.Area__c =PatPatient.primary_contact_details.area; 
                      	
                      	Acc.Mobile__c = PatPatient.primary_contact_details.mobile;
                      	Acc.Home_Phone__c = PatPatient.primary_contact_details.home_phone;
                      	Acc.Work_Phone__c = PatPatient.primary_contact_details.work_phone;
                      	Acc.Work_Phone_Extn__c = PatPatient.primary_contact_details.work_phone_extn;
                      	Acc.Email__c = PatPatient.primary_contact_details.email;
                      	Acc.Primary_Phone__c = PatPatient.primary_contact_details.primary_phone;
                      	Acc.Preferred_Communication__c = PatPatient.primary_contact_details.preferred_communication;
                        
                      	//cargiver_first_name
                      	//cargiver_last_name
                      	//fax
                      	
                  }
                  
                  Acc.Emergency_Contact_Name__c = PatPatient.emergency_contact_name; //Acc.Contact_Name__pc = PatPatient.emergency_contact_name; //PersonAccount
                  Acc.Emergency_Contact_Number__c = PatPatient.emergency_contact_number; //Acc.Contact_Number__pc = PatPatient.emergency_contact_number; //PersonAccount
                  Acc.Emergency_Contact_Number_Extn__c = PatPatient.emergency_contact_number_extn;
                  
                  //caregivers
                  
                  if( PatPatient.caregivers != null ){
                      if(!PatPatient.caregivers.isEmpty()){
                          for(clsPatientBase.caregiver CG : PatPatient.caregivers){
                              ContCaregiver = new Contact();
                              if(String.isNotBlank(CG.last_name)){
                                  
                                  ContCaregiver.Caregiver_Type__c = Integer.valueOf(CG.type);
                                  ContCaregiver.FirstName = CG.first_name;
                                  ContCaregiver.MiddleName = CG.middle_name;
                                  ContCaregiver.LastName = CG.last_name;
                                  ContCaregiver.Birthdate = String.IsNotBlank(CG.dob) ? Date.valueOf(CG.dob) : null ;
                                  ContCaregiver.HealthCloudGA__Gender__c = String.isNotBlank(CG.gender) ? CG.gender.Capitalize() : '';
                                  ContCaregiver.SSN__c = CG.ssn;
                                  ContCaregiver.Relationship__c=CG.relationship;                                 
                                  ContCaregiver.ExtCaregiver_PatIdTypeId__c = PatPatient.patient_id+'_'+CG.type;
                                  
                                  if(CG.address != null){
                                      ContCaregiver.MailingStreet = CG.address.address_line1;
                                      ContCaregiver.OtherStreet = CG.address.address_line2;
                                      ContCaregiver.MailingCity = ContCaregiver.OtherCity =  CG.address.city;
                                      ContCaregiver.MailingState = ContCaregiver.OtherState = CG.address.state;
                                      ContCaregiver.MailingCountry = ContCaregiver.OtherCountry = CG.address.country;
                                      ContCaregiver.MailingPostalCode = ContCaregiver.OtherPostalCode = CG.address.zip_code;                        
                                  } 
                                  
                                  if(CG.contact != null){
                                      ContCaregiver.MobilePhone = CG.contact.mobile;
                                      ContCaregiver.HomePhone = CG.contact.home_phone;
                                      ContCaregiver.Work_Phone__c = CG.contact.work_phone;
                                      ContCaregiver.Work_Phone_Extn__c = CG.contact.work_phone_extn;
                                      ContCaregiver.Email = CG.contact.email;
                                  }
                                    
                                  ContCaregiver.RecordTypeId = recordTypeContactCaregiver.Id;
                                  
                                  if(MapContactCaregivers.get(PatPatient.patient_id) == null){
                                      MapContactCaregivers.put(PatPatient.patient_id, new List<Contact>());
                                  }
                                  
                                  MapContactCaregivers.get(PatPatient.patient_id).add(ContCaregiver);                                  
                                  
                              }
                          }
                      }
                  }
                  
                  //guarantor
                  if(PatPatient.guarantor != null){
                      ContGuarantor = new Contact();
                      ContGuarantor.FirstName = PatPatient.guarantor.first_name;
                      ContGuarantor.MiddleName = PatPatient.guarantor.middle_name;
                      ContGuarantor.LastName = PatPatient.guarantor.last_name;
                      ContGuarantor.Birthdate = String.IsNotBlank(PatPatient.guarantor.dob) ? Date.valueOf(PatPatient.guarantor.dob) : null ;
                      ContGuarantor.HealthCloudGA__Gender__c = String.isNotBlank(PatPatient.guarantor.gender) ? PatPatient.guarantor.gender.Capitalize() : '';
                      ContGuarantor.SSN__c = PatPatient.guarantor.ssn;
                      ContGuarantor.Relationship__c = PatPatient.guarantor.relationship;
                      
                      if(PatPatient.guarantor.address != null){
                          ContGuarantor.MailingStreet = PatPatient.guarantor.address.address_line1;
                          ContGuarantor.OtherStreet = PatPatient.guarantor.address.address_line2;
                          ContGuarantor.MailingCity = ContGuarantor.OtherCity =  PatPatient.guarantor.address.city;
                          ContGuarantor.MailingState = ContGuarantor.OtherState = PatPatient.guarantor.address.state;
                          ContGuarantor.MailingCountry = ContGuarantor.OtherCountry = PatPatient.guarantor.address.country;
                          ContGuarantor.MailingPostalCode = ContGuarantor.OtherPostalCode = PatPatient.guarantor.address.zip_code;                        
                      } 
                      
                      if(PatPatient.guarantor.contact != null){
                          ContGuarantor.MobilePhone = PatPatient.guarantor.contact.mobile;
                          ContGuarantor.HomePhone = PatPatient.guarantor.contact.home_phone;
                          ContGuarantor.Work_Phone__c = PatPatient.guarantor.contact.work_phone;
                          ContGuarantor.Work_Phone_Extn__c = PatPatient.guarantor.contact.work_phone_extn;
                          ContGuarantor.Email = PatPatient.guarantor.contact.email;
                      }
						
                      ContGuarantor.RecordTypeId = recordTypeContact.Id;
                      if (String.isNotBlank(ContGuarantor.LastName)) MapContactGuarantor.put(PatPatient.patient_id,ContGuarantor); //RESTRIC
                  }                  
                  
                  Acc.Email_Notifications__c = Boolean.valueOf(PatPatient.email_notification) ? 'Yes' : 'No';
                  Acc.Text_Notifications__c = Boolean.valueOf(PatPatient.text_notification) ? 'Yes' : 'No';
                  Acc.Voice_Notifications__c = Boolean.valueOf(PatPatient.voice_notification) ? 'Yes' : 'No';
                  Acc.Blood_Group__c = PatPatient.blood_group;
                  Acc.Primary_Language__c = PatPatient.language;
                  Acc.Race__c = PatPatient.race;
                  Acc.Ethnicity__c=PatPatient.ethnicity;
                  Acc.Smoking_Status__c = PatPatient.smoking_status;
                  Acc.Marital_Status__c = PatPatient.marital_status;
                  Acc.Employment_Status__c = PatPatient.employment_status;
                  Acc.Sexual_Orientation__c = PatPatient.sexual_orientation;
                  Acc.Mother_First_Name__c = PatPatient.mother_first_name;
                  Acc.Mother_Last_Name__c = PatPatient.mother_last_name;
                  Acc.Birth_Order__c = String.IsNotBlank(PatPatient.birth_order) ? Date.valueOf(PatPatient.birth_order) : null ;
                  //categories
                  Acc.Introduction__c = PatPatient.introduction;
                  //source_name
                  //source_value                 
                  Acc.Payment_Source__c = PatPatient.payment_source;
                  Acc.Payment_Start_Date__c = String.IsNotBlank(PatPatient.payment_start_date) ? Date.valueOf(PatPatient.payment_start_date) : null ;
                  Acc.Payment_End_Date__c = String.IsNotBlank(PatPatient.payment_end_date) ? Date.valueOf(PatPatient.payment_end_date) : null ;
                  //external_id
                  //is_active
                  Acc.Is_Silhouette__c = Boolean.valueOf(PatPatient.is_silhouette);
                  //id_qualifier
                  //id_of_patient
                  Acc.Primary_Care_Provider__c = PatPatient.primary_care_provider;
                  Acc.Secondary_Care_Provider__c = PatPatient.secondary_care_provider;
                  Acc.Referred_Source__c = PatPatient.referred_source;
                  Acc.Referred_Specific_Source__c = PatPatient.referred_specific_source;
                  Acc.About_Patient__c = PatPatient.about_patient;
                  Acc.Category__c  = PatPatient.category;
                  
				  Acc.Last_Sync__c = DateTime.now();
                  
                  ListAccount.add(Acc);
              }      
           }
           catch(Exception e){
               system.debug('convertP : ' + e.getMessage()); 
           }
       }
       ApexUtil.isAccountTriggerInvoked = False;
       if(!ListAccount.isEmpty()) Upsert ListAccount Account.External_ID__c;
       ApexUtil.isAccountTriggerInvoked = True;
       
       Map<String,Account> MapIdCharmAccount = new Map<String,Account>();
       
       for(Account A : ListAccount) if( String.isNotBlank(A.Id) ) MapIdCharmAccount.put(A.External_ID__c,A);
       
       List<AccountContactRelation> ListAccContRelation = new List<AccountContactRelation>();
           
       if (!MapIdCharmAccount.isEmpty()) ListAccContRelation.addall([Select Id,AccountId,Account.External_ID__c,ContactId,Contact.RecordTypeId FROM AccountContactRelation WHERE (Contact.RecordTypeId = : recordTypeContact.Id or Contact.RecordTypeId = : recordTypeContactCaregiver.Id ) and Account.External_ID__c in : MapIdCharmAccount.keyset() ]);
             
       Map<String,List<Contact>> MapAccountContactsGuarantors = new Map<String,List<Contact>>();
       
       For (AccountContactRelation ACR:ListAccContRelation) {
           if (ACR.Contact.RecordTypeId == recordTypeContact.Id){ //Guarantors
               if(MapAccountContactsGuarantors.get(ACR.Account.External_ID__c) == null ){
                   MapAccountContactsGuarantors.put(ACR.Account.External_ID__c,new List<Contact>());               
               }
                 MapAccountContactsGuarantors.get(ACR.Account.External_ID__c).add(new Contact (Id = ACR.ContactId ));
           }         
       }
           
       //ContactGuarantor
       
       List<Contact> ListContactGuarantor = new List<Contact>();
              
       for(String AccCharmId : MapContactGuarantor.keyset())
       {
           if(MapIdCharmAccount.get(AccCharmId) != null)
          	 MapContactGuarantor.get(AccCharmId).AccountId = MapIdCharmAccount.get(AccCharmId).Id ;
           
           if(MapAccountContactsGuarantors.get(AccCharmId) != null)
               for (Contact Cont2 : MapAccountContactsGuarantors.get(AccCharmId)){
                   MapContactGuarantor.get(AccCharmId).Id = Cont2.Id;
               }
           
           ListContactGuarantor.add(MapContactGuarantor.get(AccCharmId));
       }        
       
     //  if (!ListContactGuarantor.isEmpty()) Upsert ListContactGuarantor;
       
       List<Account> LisstAccount = new List<Account>();
       
       for(Contact Cont3 : ListContactGuarantor ){
           LisstAccount.add(new Account (Id = Cont3.AccountId,Guarantor__c = Cont3.Id));
       }
		
       ApexUtil.isAccountTriggerInvoked = False;
       if (!LisstAccount.IsEmpty()) Update LisstAccount;
       ApexUtil.isAccountTriggerInvoked = True;
              
       //Caregivers
       List<Contact> ListContactCaregivers = new List<Contact>();
       for(String AccCharmId : MapContactCaregivers.keySet()){
           if(MapIdCharmAccount.get(AccCharmId) != null){
               for(Contact ContCG : MapContactCaregivers.get(AccCharmId)){
                   ContCG.AccountId = MapIdCharmAccount.get(AccCharmId).Id;
                   ListContactCaregivers.add(ContCG);
               }
           }        
       }
              
      // if (!ListContactCaregivers.isEmpty()) Upsert ListContactCaregivers Contact.ExtCaregiver_PatIdTypeId__c ;
       
     // DELETE CONTACT
     
     Set<Contact> SetContact = new Set<Contact>();
     Boolean IndDelete; 
     For (AccountContactRelation ACR:ListAccContRelation) {
         IndDelete = True;
         if (ACR.Contact.RecordTypeId == recordTypeContactCaregiver.Id){ //Caregivers
             for(Contact CG : ListContactCaregivers){
                 if(CG.id == ACR.ContactId){
                     IndDelete=False;
                     Break;
                 }
             } 
         }
       
         //If it was not found before, continue 
         if(ACR.Contact.RecordTypeId == recordTypeContact.Id && IndDelete){ //Guarantors
            for(Contact G : ListContactGuarantor){
                if(G.id == ACR.ContactId){
                    IndDelete=False;
                    Break;
                }
         	}
         }
        
         if(IndDelete) SetContact.add(new Contact(Id=ACR.ContactId));
     }
       
       
  //   if(!SetContact.isEmpty())  Delete (new List<Contact>(SetContact));
       
       
     //Identity Document
       String PatientSFId;
       List<IdentityDocument> ListID = New List<IdentityDocument>();
       
       for (String PatientCharmId : MapIdentityDocument.keyset()){
           PatientSFId='';
           if(MapIdCharmAccount.get(PatientCharmId) != null){
               PatientSFId = MapIdCharmAccount.get(PatientCharmId).Id ;
               for(IdentityDocument ID : MapIdentityDocument.get(PatientCharmId)){
                   ID.RelatedLegalEntityId = PatientSFId;
                   ListID.add(ID);
               }
           }          
       }
       
       if(!ListID.isEmpty()) Upsert ListID IdentityDocument.External_PatientIdTypeID__c ;
              
   }
    
   public void finish(Database.BatchableContext BC){ 
        
         	database.executeBatch(new clsBatchPostPatientToCharm());            	
            database.executeBatch(new clsBatchGetAllergiesfromCharm(lstPatientIdCharm));            
            database.executeBatch(new clsBatchGetMedicationsFromCharm(lstPatientIdCharm));
            database.executeBatch(new clsBatchGetProblemsfromCharm(lstPatientIdCharm));
			database.executeBatch(new clsBatchGetCCDAFromCharm(lstPatientIdCharm));
			database.executeBatch(new clsBatchGetVaccinesFromCharm(lstPatientIdCharm));
            database.executeBatch(new clsBatchTreatmentPlanFromCharms(lstPatientIdCharm));        	
       
   }
    
}