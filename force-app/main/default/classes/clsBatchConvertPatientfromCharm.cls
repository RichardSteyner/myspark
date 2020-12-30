public class clsBatchConvertPatientfromCharm Implements Database.Batchable<HealthCloudGA__CandidatePatient__c>, Database.Stateful, Database.AllowsCallouts {
    
    private map<String, clsPatient> mapPatients = new map<String, clsPatient>();
    Private RecordType recordType;
        
    public clsBatchConvertPatientfromCharm(list<clsPatient> xlstPatients){
         recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' and Name = 'Person Account' LIMIT 1];
         for( clsPatient cl :xlstPatients ){
             mapPatients.put(cl.patient_id , cl);
         }
	}  
        
 	public List<HealthCloudGA__CandidatePatient__c> start(Database.BatchableContext BC){
        return [select id, External_ID__c from HealthCloudGA__CandidatePatient__c where External_ID__c in :mapPatients.keySet()];
    }
    
    public void execute(Database.BatchableContext BC, List<HealthCloudGA__CandidatePatient__c> scope) {
        map <id, HealthCloudGA__CandidatePatient__c> mpCandidateP = new map <id, HealthCloudGA__CandidatePatient__c>(scope);
        map<string, string> mapExtIds = new map<string, string>();
        
        list<HealthCloudGA.Patient> auxlstP = new list<HealthCloudGA.Patient>();
        for(HealthCloudGA__CandidatePatient__c cp : scope){
            clsConnectionChram xcn = new clsConnectionChram();
           
              try{
                   String auxparam = '/fhir/patients/'+cp.External_ID__c+'/careteam';
                   String auxbody = xcn.getJSON(auxparam,'GET');                    
                  
                   String auxpatient = '/patients/'+cp.External_ID__c;
                   String auxbodypatient = xcn.getJSON(auxpatient,'GET');
                  
                   ClsPatientGet patient = (ClsPatientGet) JSON.deserialize(auxbodypatient,ClsPatientGet.class);   
                  
                   //clsPatient patient = mapPatients.get(cp.External_ID__c);
                                                           
                    HealthCloudGA.Patient xp = new HealthCloudGA.Patient();
                    xp.PatientClass = 'Individual' ; //'PersonAccount'; 
                    xp.FirstName = patient.patient.first_name;
                    xp.LastName = patient.patient.last_name;
					xp.customFields.put('DOB__c',patient.patient.dob);
                    //xp.customFields.put('DOB_Format__c',patient.patient.dob_format);   //dob_format              
                    //is_auto_calculated_dob
                    xp.customFields.put('Record_Id__c',patient.patient.record_id);    //record_id
                    xp.customFields.put('Primary_Language__c',patient.patient.language);
                    //created_time
                    //created_date
                    //xp.customFields.put('Next_Visit_Date__c', (String.isNotBlank(patient.patient.next_visit_date) ? Date.valueOf(patient.patient.next_visit_date) : null) ); //next_visit_date
                    //appointment_id
                    //active //Default True                   
                    xp.customFields.put('Sex__c',patient.patient.gender);
					xp.customFields.put('Gender_Identity__c',patient.patient.gender_identity);                    
					
                  	xp.customFields.put('Email__c',patient.patient.primary_contact_details.email);
                  	xp.customFields.put('Mobile__c',patient.patient.primary_contact_details.mobile);
                    xp.customFields.put('Home_Phone__c',patient.patient.primary_contact_details.home_phone);
                    xp.customFields.put('Work_Phone__c',patient.patient.primary_contact_details.work_phone); //work_phone
                    xp.customFields.put('Work_Phone_Extn__c',patient.patient.primary_contact_details.work_phone); //work_phone_extn                 
                    xp.customFields.put('Preferred_Communication__c',patient.patient.primary_contact_details.preferred_communication); //preferred_communication                   
                    xp.customFields.put('Primary_Phone__c',patient.patient.primary_contact_details.primary_phone);//primary_phone
                  	
                  
                   	xp.customFields.put('Is_Silhouette__c',Boolean.valueOf(patient.patient.is_silhouette));//is_silhouette
                    //xp.customFields.put('Primary_Contact__c',patient.patient.emergency_contact_name);//primary_phone
                    //phr_login_id
                    //xp.Type = patient.account_type;//account_type
                    xp.customFields.put('Blood_Group__c',patient.patient.blood_group); //blood_group
                    //external_id
                    //last_modified_time
                    xp.customFields.put('Address_Line_1__c',patient.patient.primary_contact_details.address_line1);
 					xp.BillingStreet = patient.patient.primary_contact_details.address_line1;                    
					xp.BillingCity = patient.patient.primary_contact_details.city;
                    xp.BillingCountry = patient.patient.primary_contact_details.country;
                    xp.BillingState = patient.patient.primary_contact_details.state;
                    xp.BillingPostalCode = patient.patient.primary_contact_details.zip_code;
                  
                  	xp.customFields.put('Address_Line_2__c',patient.patient.primary_contact_details.address_line2);
                  	xp.ShippingCity = patient.patient.primary_contact_details.city;
                    xp.ShippingCountry = patient.patient.primary_contact_details.country;
                    xp.ShippingState = patient.patient.primary_contact_details.state;
                    xp.ShippingPostalCode = patient.patient.primary_contact_details.zip_code;
                  
					xp.customFields.put('County__c',patient.patient.primary_contact_details.county);//county
					xp.customFields.put('District__c',patient.patient.primary_contact_details.district);//district
					xp.customFields.put('Marital_Status__c',patient.patient.marital_status);//marital_status
					xp.AccountSource = patient.patient.source_value;//source
					xp.customFields.put('Category__c',patient.patient.category); //category
					//custom_field_value                  
                    xp.customFields.put('External_ID__c',patient.patient.patient_id);
                    xp.customFields.put('Last_Sync__c',DateTime.now());
                 
                    auxlstP.add(xp);
					mapExtIds.put(patient.patient.patient_id,patient.patient.patient_id);
                }catch(Exception e){ system.debug('convertP : ' + e.getMessage()); 
                }
         }
        
       // system.debug('list_Patient: '+auxlstP.size() );
        for(HealthCloudGA.Patient xp : auxlstP){
            //system.debug('detail_patient : ' + xp);
            try{
                HealthCloudGA.Result res = HealthCloudGA.PatientService.createPatient(xp); 
            }Catch(Exception e){ system.debug('patient_Error :' + e.getMessage()); }
            
            // System.debug('rvc_patients +' + res);
        }
        
   
        map<String,account> mapAccount = new map<String,account>();
        for (account c: [select id,External_ID__c from account where External_ID__c in :mapExtIds.keyset()]){
            mapAccount.put(c.External_ID__c,c);
            
        }
        
                
        list<HealthCloudGA__CandidatePatient__c> lstCandidateUpdate = new list<HealthCloudGA__CandidatePatient__c>();
        
        for(HealthCloudGA__CandidatePatient__c cp: mpCandidateP.values()){
            if(mapAccount.containsKey(cp.External_ID__c)){
                cp.HealthCloudGA__AccountId__c = mapAccount.get(cp.External_ID__c).id;
            	lstCandidateUpdate.add(cp);
            }
            
        }
        /*        
        system.debug('mpAccount patient : ' +mapAccount );
        system.debug('mpCandidateP Patient : ' +mpCandidateP );
        system.debug('candidate Patient : ' +lstCandidateUpdate );*/
       
        update lstCandidateUpdate;
        
        
    }
    
     public void finish(Database.BatchableContext BC){ 
         //database.executeBatch(new clsBatchTreatmentPlanFromCharms());
         
      
            list<String> lstIds = new list<String>() ;
         	lstIds.addAll(mapPatients.keySet());
         
          	database.executeBatch(new clsBatchPostPatientToCharm());            	
            database.executeBatch(new clsBatchGetAllergiesfromCharm(lstIds));            
            database.executeBatch(new clsBatchGetMedicationsFromCharm(lstIds));
            database.executeBatch(new clsBatchGetProblemsfromCharm(lstIds));
			database.executeBatch(new clsBatchGetCCDAFromCharm(lstIds));
			database.executeBatch(new clsBatchGetVaccinesFromCharm(lstIds));
            database.executeBatch(new clsBatchTreatmentPlanFromCharms(lstIds));
        	database.executeBatch(new clsBatchPostPatientToCharm());
        
         
     }
}