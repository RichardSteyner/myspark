Global class clsBatchGetPatientsfromCharm implements Database.Batchable<clsPatient>, Database.Stateful, Database.AllowsCallouts{
   private clsPageContext PageContext;
   private clsConnectionChram cn = new clsConnectionChram();
    
   map<String,clsPatient> mapPatient =  new map<String,clsPatient>();
   map<String,HealthCloudGA__CandidatePatient__c> mapCandidatePatient = new map<String,HealthCloudGA__CandidatePatient__c>(); 
   
    public List<clsPatient> start(Database.BatchableContext BC){        
        Long timestamp = long.valueOf('1601557544691') ; //datetime.now().getTime();
        
        Set<String> IdsFacilities = new Set<String>();
        String IdsF = '';
        for(Facilities__c f : [select facility_id__c from Facilities__c where Activate__c = True]){
            IdsFacilities.add(f.facility_id__c);
            IdsF += f.facility_id__c+',';
        }
        
        IdsF = IdsF.removeEnd(',');
      
        clsListPatients lstPatients = new clsListPatients();
        List<clsPatient> auxPatients = new List<clsPatient>();
        integer page = 1;
        
        do{
            String xparam = '/patients?facility_id='+IdsF+'&modified_time_greater_equals='+timestamp;
            String body = cn.getJSON(xparam,'GET');
            lstPatients = (clsListPatients) JSON.deserialize(body,clsListPatients.class);   
            PageContext = lstPatients.page_context;
            auxPatients.addAll(lstPatients.patients);
            page++;
            
        }while(Boolean.valueOf(PageContext.has_more_page)) ;
        
       return auxPatients;
    }
    
    public void execute(Database.BatchableContext BC, List<clsPatient> scope) {
       RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
       map<String, Account> mapPersonAccount = new map<String,Account>();
        
        for(clsPatient p : scope){
            //Candidate Patient;
            HealthCloudGA__CandidatePatient__c xc = new HealthCloudGA__CandidatePatient__c();
            xc.External_ID__c = p.patient_id;
            xc.HealthCloudGA__GivenName1__c = p.first_name;
            xc.HealthCloudGA__FamilyName1__c = p.last_name;
            xc.HealthCloudGA__Name__c = p.full_name;
            xc.HealthCloudGA__BirthDate__c = String.IsNotBlank(p.dob) ? Date.valueOf(p.dob) : null ;
            xc.DOB_Format__c = p.dob_format;
            //is_auto_calculated_dob
            //record_id
            xc.Language__c = p.language;
            //created_time
            //created_date
            xc.Next_Visit_Date__c = p.next_visit_date;
            //appointment_id
            //active // Default True
            xc.Gender__c = p.gender;
            xc.Gender_Identity__c = p.gender_identity;
            xc.Email__c = p.email;
            xc.Mobile__C = P.mobile;
            xc.Home_Phone__c = p.home_phone;
            xc.Work_Phone__c = p.work_phone;
            xc.Work_Phone_Extn__c = p.work_phone_extn;
            xc.Preferred_Communication__c = p.preferred_communication;
            xc.Primary_Phone__c = p.primary_phone;
            xc.Is_Silhouette__c = Boolean.valueOf(p.is_silhouette);
            //phr_login_id
            xc.Account_Type__c = p.account_type;
            xc.Blood_Group__c = p.blood_group;
            //external_id           
            xc.HealthCloudGA__Address1Line1__c = p.address_line1;
            xc.HealthCloudGA__Address1Line2__c = p.address_line2;
            xc.HealthCloudGA__Address1City__c	 = p.city;
            xc.HealthCloudGA__Address1Country__c  = p.country;
            xc.HealthCloudGA__Address1State__c = p.state;
            xc.HealthCloudGA__Address1PostalCode__c = p.postal_code;
            xc.County__c = p.county;
            xc.District__C = P.district;
          	xc.HealthCloudGA__MaritalStatusLabel__c = p.marital_status;
            xc.Source__c = p.source;
            xc.Category__c = p.category;
            //custom_field_value       
           
            mapCandidatePatient.put(xc.External_ID__c,xc);  
			mapPatient.put(xc.External_ID__c,p);
        }
        upsert mapCandidatePatient.values() External_ID__c;
      
    }
    
    public void finish(Database.BatchableContext BC){ 
        system.Database.executeBatch(new clsBatchConvertPatientfromCharm(mapPatient.values()));
        /// get medical care plan .. case
    }
}