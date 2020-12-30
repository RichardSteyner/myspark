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
              Mobile__c,
              Home_Phone__c,
              Work_Phone__c,
              Work_Phone_Extn__c,
              Email__c,
              Emergency_Contact_Name__c,
              Emergency_Contact_Number__c,
              Emergency_Contact_Number_Extn__c,
              Preferred_Communication__c,
              Email_Notifications__c,
              Text_Notifications__c,
              Voice_Notifications__c,
              Payment_Source__c,
              External_ID__c,
              Record_Id__c,
              Facility__c,
              Facility__r.facility_id__c
              from Account where Sync__c = True ];
    }
     public void execute(Database.BatchableContext BC, List<Account> scope) {
         
         ClsPatientPost Patient;
         String body;
         ClsPatientGet PatientResp;
         List<Account> ListAccount = new List<Account>();
         
         for(Account AC : scope ){
             
             body='';
             PatientResp=null;
             Patient = new ClsPatientPost();   
             
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
             
             Patient.address = new clsPatientBase.address();
             Patient.address.address_line1 = AC.BillingStreet;
             Patient.address.address_line2 = AC.Address_Line_2__c;
            // Patient.address.area = '' ;
			 Patient.address.city  = AC.BillingCity;
             Patient.address.state = AC.BillingState;
            // Patient.address.county_code='';
             Patient.address.country= AC.BillingCountry;
             Patient.address.zip_code= AC.BillingPostalCode;
            // Patient.address.district='';
            // Patient.address.post_box='';
           
             
             Patient.mobile = AC.Mobile__c;
             Patient.home_phone = AC.Home_Phone__c;
             Patient.work_phone = AC.Work_Phone__c;
             Patient.work_phone_extn = AC.Work_Phone_Extn__c;
             Patient.email = AC.Email__c;
             
             Patient.emergency_contact_name = AC.Emergency_Contact_Name__c;
             Patient.emergency_contact_number = AC.Emergency_Contact_Number__c;
             Patient.emergency_contact_number_extn = AC.Emergency_Contact_Number_Extn__c;
                  
             //Caregivers
             
             //Guarantor
               
             Patient.preferred_communication = AC.Preferred_Communication__c;
             Patient.email_notification  = AC.Email_Notifications__c == 'Yes' ? 'true': 'false' ;
             Patient.text_notification = AC.Text_Notifications__c == 'Yes' ? 'true' : 'false' ;
             Patient.voice_notification = AC.Voice_Notifications__c == 'Yes' ? 'true' : 'false';
                   
             //Category
             
             Patient.payment_source= AC.Payment_Source__c;
       		 
                          
            if(AC.Facility__c != null){
                 if(String.isNotBlank(AC.Facility__r.facility_id__c)){
                    Patient.facilities = new list<clsPatientBase.facility>();
                    Patient.facilities.add(new clsPatientBase.facility(AC.Facility__r.facility_id__c));  
                 }                   
             }    
             
             Patient.duplicate_check = 'True';
             
             try{        
                if(String.isBlank(AC.External_ID__c)){   
                    //System.debug('req.body:'+JSON.serialize(Patient,True));
                    body = cn.postJSON('/patients','POST',JSON.serialize(Patient,True));                 
                 }else{
                    Patient.Record_Id = AC.Record_Id__c;
                    //System.debug('req.body:'+JSON.serialize(Patient,True));
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