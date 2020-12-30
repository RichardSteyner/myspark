public class clsListAllergies {
		public list<allergies> allergies{get;set;}
		public String message{get;set;}
		public page_context page_context{get;set;}
		public String code{get;set;}
	
	public class page_context{
		public String has_more_page{get;set;}
		public String per_page{get;set;}
		public String applied_filter{get;set;}
		public String page{get;set;}
		public String sort_column{get;set;}
		public String sort_order{get;set;}
	}
	
	public class allergies{
		public String reactions{get;set;}
		public String severity{get;set;}
		public String type{get;set;}
		public String observed_on{get;set;}
		public String allergen{get;set;}
		public String status{get;set;}
		public String patient_id{get;set;}
		public String date_of_entry{get;set;}
		public String patient_allergy_id{get;set;}
	}
}