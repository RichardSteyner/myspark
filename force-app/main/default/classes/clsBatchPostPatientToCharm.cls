Global class clsBatchPostPatientToCharm  implements Database.Batchable<Account>, Database.Stateful, Database.AllowsCallouts{
   private clsPageContext PageContext;
   private clsConnectionChram cn = new clsConnectionChram();
   
    
   public List<Account> start(Database.BatchableContext BC){
          
      return [Select Name,
              FirstName,
              MiddleName,
              LastName,
              DOB__c,
              Sex__c,
              Gender_Identity__c,
              Nick_Name__c,
              Suffix__c,
              Maiden_Name__c,
              Deceased__c,
              DOD__c,
              Cause_Of_Death__c,
              BillingStreet,
              BillingCity,
              BillingCountry,
              BillingState,
              BillingPostalCode,
              Address_Line_2__c,
              ShippingStreet,
              Area__c,
              County__c,
              District__c,
              Mobile__c,
              Home_Phone__c,
              Work_Phone__c,
              Work_Phone_Extn__c,
              Email__c,
              Emergency_Contact_Name__c,
              Emergency_Contact_Number__c,
              Emergency_Contact_Number_Extn__c,
              Guarantor__c,
              Preferred_Communication__c,
              Email_Notifications__c,
              Text_Notifications__c,
              Voice_Notifications__c,
              Payment_Source__c,
              External_ID__c,
              Record_Id__c,
              Facility__c,
              Facility__r.facility_id__c,
              Blood_Group__c,
				Primary_Language__c,
                Race__c,
                Ethnicity__c,
                Smoking_Status__c,
                Marital_Status__c,
                Employment_Status__c,
                Sexual_Orientation__c,
                Mother_First_Name__c,
                Mother_Last_Name__c,
                Birth_Order__c,
                Introduction__c,
                Payment_Start_Date__c,
                Payment_End_Date__c,
                Referred_Source__c,
                Referred_Specific_Source__c
              from Account where Sync__c = True ];
    }
     public void execute(Database.BatchableContext BC, List<Account> scope) {
         
         RecordType recordTypeContactCaregiver = [SELECT Id,Name FROM RecordType WHERE SobjectType='Contact' and DeveloperName='Caregiver' Limit 1] ;
         
         ClsPatientPost Patient;
         String body;
         ClsPatientGet PatientResp;
         List<Account> ListAccount = new List<Account>();
         
         Map<Id,Contact> MapGuarantor = new Map<Id,Contact>();
         Contact ContGuarantor;
         
         for(Account AC : scope ) if(String.isNotBlank(AC.Guarantor__c)) MapGuarantor.put(AC.Guarantor__c,null);         
         MapGuarantor = New Map<Id,Contact>([SELECT FirstName,MiddleName,LastName,Birthdate,HealthCloudGA__Gender__c,SSN__c,Relationship__c,OtherStreet,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,MobilePhone,HomePhone,Work_Phone__c,Work_Phone_Extn__c,Email FROM CONTACT WHERE ID in : MapGuarantor.keyset()]);
         
         Map<Id,Account> MapAccount = new Map<Id,Account>(scope);
         
         //Caregivers
         List<AccountContactRelation> ListAccountContactRelationCaregivers = [SELECT Id , AccountId, Account.External_Id__c, ContactId, Contact.id, Contact.FirstName, Contact.LastName, Contact.MiddleName ,Contact.Caregiver_Type__c, Contact.Birthdate, Contact.HealthCloudGA__Gender__c, Contact.SSN__c, Contact.Relationship__c, Contact.ExtCaregiver_PatIdTypeId__c, Contact.MailingStreet, Contact.OtherStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MobilePhone, Contact.HomePhone, Contact.Work_Phone__c, Contact.Work_Phone_Extn__c, Contact.Email  FROM AccountContactRelation WHERE AccountId in : MapAccount.keyset() and Contact.RecordTypeId =: recordTypeContactCaregiver.id Order by AccountId asc , Contact.Caregiver_Type__c asc];     
		 Map<String,List<Contact>> MapAccountIdContactCaregivers= new Map<String,List<Contact>>();
		 clsPatientBase.caregiver Caregiver;
         
         for( AccountContactRelation ACR : ListAccountContactRelationCaregivers){
             
             if(MapAccountIdContactCaregivers.get(ACR.AccountId) == null) 
                 	MapAccountIdContactCaregivers.put(ACR.AccountId,new List<Contact>());
             
             if(String.isNotBlank(ACR.ContactId)) MapAccountIdContactCaregivers.get(ACR.AccountId).add(ACR.Contact);
         }
         
         
         for(Account AC : scope ){
             
             body='';
             PatientResp=null;
             Patient = new ClsPatientPost();   
             ContGuarantor = new Contact();
                 
             Patient.first_name = AC.Name.Split(' ')[0];
             //Patient.middle_name = AC.MiddleName;
             Patient.last_name = AC.Name.Split(' ')[1];          
             
             Patient.dob = String.valueOf(AC.DOB__c);
             Patient.gender = AC.Sex__c.ToLowerCase(); 
             Patient.gender_identity= AC.Gender_Identity__c;
             Patient.nick_name= AC.Nick_Name__c;
             Patient.suffix = AC.Suffix__c ;
             Patient.maiden_name = AC.Maiden_Name__c;
             Patient.deceased = String.ValueOf(AC.Deceased__c);  
             Patient.dod = String.valueOf(AC.DOD__c);
             Patient.cause_of_death = AC.Cause_Of_Death__c;             
             
            if(AC.Facility__c != null){
                 if(String.isNotBlank(AC.Facility__r.facility_id__c)){
                    Patient.facilities = new list<clsPatientBase.facility>();
                    Patient.facilities.add(new clsPatientBase.facility(AC.Facility__r.facility_id__c));  
                 }                   
             }                 
             
             Patient.address = new clsPatientBase.address();
             
             if(String.isNotBlank(AC.BillingState)){
                 Patient.address.address_line1 = AC.BillingStreet;
                 Patient.address.address_line2 = AC.ShippingStreet;
                 Patient.address.area = AC.Area__c ;
                 Patient.address.city  = AC.BillingCity;
                 Patient.address.state = AC.BillingState;
                 Patient.address.county_code= AC.County__c;
                 Patient.address.country= AC.BillingCountry;
                 Patient.address.zip_code= AC.BillingPostalCode;
                 Patient.address.district=AC.District__c;
                 //Patient.address.post_box='';
           
             }                       
             
             Patient.mobile = AC.Mobile__c;
             Patient.home_phone = AC.Home_Phone__c;
             Patient.work_phone = AC.Work_Phone__c;
             Patient.work_phone_extn = AC.Work_Phone_Extn__c;
             Patient.email = AC.Email__c;
             
             Patient.emergency_contact_name = AC.Emergency_Contact_Name__c;
             Patient.emergency_contact_number = AC.Emergency_Contact_Number__c;
             Patient.emergency_contact_number_extn = AC.Emergency_Contact_Number_Extn__c;
                  
             //Caregivers
             
             if(MapAccountIdContactCaregivers.get(AC.Id) != null){
                 Patient.caregivers = new list<clsPatientBase.caregiver>();
                 for (Contact ContCaregiver : MapAccountIdContactCaregivers.get(AC.Id)) {
                     Caregiver = new clsPatientBase.caregiver ();
                     Caregiver.first_name = ContCaregiver.FirstName;
                     Caregiver.middle_name = ContCaregiver.MiddleName;
                     Caregiver.last_name = ContCaregiver.LastName;
                     Caregiver.dob = String.valueOf(ContCaregiver.Birthdate);
                     Caregiver.ssn = ContCaregiver.SSN__c;
                     Caregiver.relationship = ContCaregiver.Relationship__c; 
                     
                     Caregiver.address = new clsPatientBase.address();
                     Caregiver.address.address_line1 = ContCaregiver.MailingStreet;
                     Caregiver.address.address_line2 = ContCaregiver.OtherStreet;
                     Caregiver.address.city = ContCaregiver.MailingCity;
                     Caregiver.address.state = ContCaregiver.MailingState;
                     Caregiver.address.country = ContCaregiver.MailingCountry;
                     Caregiver.address.zip_code = ContCaregiver.MailingPostalCode;
                     
                     Caregiver.contact = new clsPatientBase.contact();
                     Caregiver.contact.mobile = ContCaregiver.MobilePhone;
                     Caregiver.contact.home_phone = ContCaregiver.HomePhone;
                     Caregiver.contact.work_phone = ContCaregiver.Work_Phone__c;
                     Caregiver.contact.work_phone_extn = ContCaregiver.Work_Phone_Extn__c;
                     Caregiver.contact.email = ContCaregiver.Email;
                     
                     Patient.caregivers.add(Caregiver);
                 }  
             }
                                      
             //Guarantor
                    
             if(String.isNotBlank(AC.Guarantor__c) && MapGuarantor.get(AC.Guarantor__c) != null ){
                 
                ContGuarantor =  MapGuarantor.get(AC.Guarantor__c);
                Patient.guarantor = new clsPatientBase.guarantor();
                Patient.guarantor.first_name = ContGuarantor.FirstName;
                Patient.guarantor.middle_name = ContGuarantor.MiddleName;
                Patient.guarantor.last_name = ContGuarantor.LastName;
				Patient.guarantor.dob = String.valueOf(ContGuarantor.Birthdate);
                Patient.guarantor.gender = ContGuarantor.HealthCloudGA__Gender__c.toLowerCase();
                Patient.guarantor.ssn = ContGuarantor.SSN__c;
                Patient.guarantor.relationship = ContGuarantor.Relationship__c;
                
                if(String.isNotBlank(ContGuarantor.MailingState)){
                    Patient.guarantor.address = new clsPatientBase.address();
                    Patient.guarantor.address.address_line1 = ContGuarantor.MailingStreet;
                    Patient.guarantor.address.address_line2 = ContGuarantor.OtherStreet;
                    Patient.guarantor.address.city = ContGuarantor.MailingCity;
                    Patient.guarantor.address.state = ContGuarantor.MailingState;
                    Patient.guarantor.address.country = ContGuarantor.MailingCountry;
                    Patient.guarantor.address.zip_code = ContGuarantor.MailingPostalCode;
                 }
                
                Patient.guarantor.contact = new clsPatientBase.contact();
                Patient.guarantor.contact.mobile = ContGuarantor.MobilePhone;
                Patient.guarantor.contact.home_phone = ContGuarantor.HomePhone;
                Patient.guarantor.contact.work_phone = ContGuarantor.Work_Phone__c;
                Patient.guarantor.contact.work_phone_extn = ContGuarantor.Work_Phone_Extn__c;
                Patient.guarantor.contact.email = ContGuarantor.email;            
                 
             }
               
             Patient.preferred_communication = AC.Preferred_Communication__c;
             
             Patient.email_notification  = AC.Email_Notifications__c == 'Yes' ? 'true': 'false' ;
             Patient.text_notification = AC.Text_Notifications__c == 'Yes' ? 'true' : 'false' ;
             Patient.voice_notification = AC.Voice_Notifications__c == 'Yes' ? 'true' : 'false';
             Patient.blood_group = AC.Blood_Group__c;
             Patient.language = AC.Primary_Language__c;
             Patient.race = AC.Race__c;
             Patient.ethnicity= AC.Ethnicity__c;
             Patient.smoking_status= AC.Smoking_Status__c;
             Patient.marital_status = AC.Marital_Status__c;
             Patient.employment_status=AC.Employment_Status__c;
             Patient.sexual_orientation = AC.Sexual_Orientation__c;
             Patient.mother_first_name = AC.Mother_First_Name__c;
             Patient.mother_last_name = AC.Mother_Last_Name__c;
             Patient.birth_order = String.valueOf(AC.Birth_Order__c);
             //CATEGORIES
             Patient.introduction = AC.Introduction__c;
             //source_name
             //source_value
             Patient.payment_source = AC.Payment_Source__c;
             Patient.payment_start_date = String.valueOf(AC.Payment_Start_Date__c);
             Patient.payment_end_date = String.valueOf(AC.Payment_End_Date__c);
             //external_id
             //is_active
             Patient.source_name = AC.Referred_Source__c ;
             Patient.source_value = AC.Referred_Specific_Source__c;
            
             //Categories
             
             Patient.duplicate_check = 'True';
             
             try{        
                if(String.isBlank(AC.External_ID__c)){   
                    //System.debug('req.body:'+JSON.serialize(Patient,True));
                    body = cn.postJSON('/patients','POST',JSON.serialize(Patient,True));                 
                 }else{
                    Patient.Record_Id = AC.Record_Id__c;
                    System.debug('req.body:'+JSON.serialize(Patient,True));
                    body = cn.postJSON('/patients/'+AC.External_ID__c,'PUT',JSON.serialize(Patient,True));
                 }
                 
                // System.debug('body:'+body);
                 if(String.isNotBlank(body)){                     
                     PatientResp = (ClsPatientGet) JSON.deserialize(body,ClsPatientGet.class);
                     if(PatientResp != null){
                         if(PatientResp.patient != null){
                             AC.External_ID__c=PatientResp.patient.patient_id;
                             AC.Record_Id__c = PatientResp.patient.record_id;
                             AC.Sync__c=False;
                             AC.Last_Sync__c = DateTime.now(); 
                         }
                     }
                 }
                 
           }Catch(Exception e){ system.debug('patient_Error :' + e.getMessage()); }    
            
             ListAccount.add(AC);
         }
         
        ApexUtil.isAccountTriggerInvoked = False;
        if(!ListAccount.isEmpty()) Update ListAccount ;
        ApexUtil.isAccountTriggerInvoked = True;
     }
     public void finish(Database.BatchableContext BC){ 
         
     }
}