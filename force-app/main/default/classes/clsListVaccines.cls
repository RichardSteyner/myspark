public class clsListVaccines {

		public list<vaccines> vaccines{get;set;}
		public String message{get;set;}
		public page_context page_context{get;set;}
		public String code{get;set;}
    
	public class vaccines{
		public String date_of_vaccination{get;set;}
		public String is_administered{get;set;}
		public String encounter_id{get;set;}
		public String ordering_provider_name{get;set;}
		public String vis_shared{get;set;}
		public String ordering_provider_id{get;set;}
		public String vis_given_date{get;set;}
		public String date_of_expiry{get;set;}
		public String date_time_of_vaccination{get;set;}
		public String note_to_nurse{get;set;}
		public String ndc_code{get;set;}
		public String vaccine_lot_number{get;set;}
		public String funding_source{get;set;}
		public String site{get;set;}
		public String vfc_eligibility{get;set;}
		public String intake_route{get;set;}
		public String patient_id{get;set;}
		public String dosage{get;set;}
		public String patient_vaccine_map_id{get;set;}
		public String dosage_unit{get;set;}
		public String vaccine_name{get;set;}
	}
    
	public class page_context{
		public String page{get;set;}
		public String sort_column{get;set;}
		public String has_more_page{get;set;}
		public String sort_order{get;set;}
		public String per_page{get;set;}
	}
    
}