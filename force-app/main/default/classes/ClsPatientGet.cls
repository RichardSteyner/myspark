public class ClsPatientGet {

		public String message{get;set;}
		public patient patient{get;set;}
		public String code{get;set;}
    
	public class primary_contact_details{
		public String mobile{get;set;}
		public String home_phone{get;set;}
		public String district{get;set;}
		public String work_phone{get;set;}
		public String zip_code{get;set;}
		public String work_phone_extn{get;set;}
		public String country{get;set;}
		public String email{get;set;}
		public String county{get;set;}
		public String primary_phone{get;set;}
		public String state{get;set;}
		public String preferred_communication{get;set;}
		public String city{get;set;}
		public String cargiver_first_name{get;set;}
		public String area{get;set;}
		public String cargiver_last_name{get;set;}
		public String address_line2{get;set;}
		public String fax{get;set;}
		public String address_line1{get;set;}
	}
    
	public class patient{
		public String emergency_contact_number{get;set;}
		public String ethnicity{get;set;}
		public String smoking_status{get;set;}
		public String race{get;set;}
		public String marital_status{get;set;}
		public String language{get;set;}
		public String employment_status{get;set;}
		public String blood_group{get;set;}
		public String sexual_orientation{get;set;}
		public String voice_notification{get;set;}
		public String mother_first_name{get;set;}
		public String text_notification{get;set;}
		public String mother_last_name{get;set;}
		public String email_notification{get;set;}
		public String birth_order{get;set;}
		public clsPatientBase.guarantor guarantor{get;set;}
		public list<clsPatientBase.category> categories{get;set;}	
		public list<clsPatientBase.caregiver> caregivers{get;set;}
		public String introduction{get;set;}
		public String emergency_contact_number_extn{get;set;}
		public String custom_field_1{get;set;}
		public String emergency_contact_name{get;set;}
		public String custom_field_2{get;set;}
		public primary_contact_details primary_contact_details{get;set;}
		public String custom_field_3{get;set;}
		public List<clsPatientBase.qualifier> id_qualifiers{get;set;}
		public String custom_field_4{get;set;}
		public list<clsPatientBase.facility> facilities{get;set;}
		public String custom_field_5{get;set;}
		public String cause_of_death{get;set;}
		public String source_name{get;set;}
		public String dod{get;set;}
		public String source_value{get;set;}
		public String deceased{get;set;}
		public String payment_source{get;set;}
		public String maiden_name{get;set;}
		public String payment_start_date{get;set;}
		public String suffix{get;set;}
		public String payment_end_date{get;set;}
		public String nick_name{get;set;}
		public String external_id{get;set;}
		public String gender_identity{get;set;}
		public String is_active{get;set;}
		public String gender{get;set;}
		public String is_silhouette{get;set;}
		public String is_auto_calculated_dob{get;set;}
		public String id_qualifier{get;set;}
		public String dob{get;set;}
		public String id_of_patient{get;set;}
		public String full_name{get;set;}
		public String primary_care_provider{get;set;}
		public String last_name{get;set;}
		public String secondary_care_provider{get;set;}
		public String middle_name{get;set;}
		public String referred_source{get;set;}
		public String first_name{get;set;}
		public String referred_specific_source{get;set;}
		public String record_id{get;set;}
		public String about_patient{get;set;}
		public String patient_id{get;set;}
		public String category{get;set;}
	}

	
}