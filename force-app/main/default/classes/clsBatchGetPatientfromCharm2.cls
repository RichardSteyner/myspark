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
       
      List<ClsPatientGet> ListPatientGet = new List<ClsPatientGet>();
      String auxbodypatient;
      ClsPatientGet patient;
      ClsPatientGet.patient PatPatient;
      Account Acc;
      
      List<Account> ListAccount = new List<Account>();     
       
      RecordType recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' and DeveloperName = 'IndustriesIndividual' LIMIT 1];
       
      for(clsPatient clsp : scope ){
          auxbodypatient = '';
          patient = new ClsPatientGet();
          Acc = new Account();
          
          try{              
          
          auxbodypatient = cn.getJSON('/patients/'+clsp.patient_id,'GET');
              
          patient = (ClsPatientGet) JSON.deserialize(auxbodypatient,ClsPatientGet.class); 
          
              if(patient.patient != null){
                  PatPatient = patient.patient;
                  lstPatientIdCharm.add(PatPatient.patient_id);
                  Acc.RecordTypeId = recordType.Id;
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
                      	Acc.Area__c =PatPatient.primary_contact_details.area; //Area
                      	
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
                  //guarantor
                  
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