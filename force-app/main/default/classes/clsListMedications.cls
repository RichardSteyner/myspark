public class clsListMedications {
    	public list<medication> medications{get;set;}
		public String message{get;set;}
		public page_context page_context{get;set;}
		public String code{get;set;}
    
	public class page_context{
		public String has_more_page{get;set;}
		public String sort_column{get;set;}
		public String per_page{get;set;}
		public String sort_order{get;set;}
		public String page{get;set;}
	}
    
	public class medication{
		public String strength_description{get;set;}
		public String generic_drug_name{get;set;}
		public String generic_product_name{get;set;}
		public String drug_details_id{get;set;}
		public String trade_name{get;set;}
		public String dispense_unit{get;set;}
		public String doseform_description{get;set;}
		public String refills{get;set;}
		public String encounter_id{get;set;}
		public String dispense{get;set;}
		public String directions{get;set;}
		public String intake_rounte{get;set;}
		public String is_directions_edited{get;set;}
		public String dosage_unit{get;set;}
		public String manufacturing_type{get;set;}
		public String date_of_entry{get;set;}
		public String substitute_generic{get;set;}
		public String patient_id{get;set;}
		public String days_of_supply{get;set;}
		public String patient_medication_id{get;set;}
	}
}