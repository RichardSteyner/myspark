public class clsListVitals {
    
		public String message{get;set;}
		public list<vital_entries> vital_entries{get;set;}
		public String code{get;set;}
	
    public class vitals{
		public String vital_name{get;set;}
		public String vital_unit{get;set;}
		public String vital_value{get;set;}
	}
	
    public class vital_entries{
		public String entry_date{get;set;}
		public String encounter_id{get;set;}
		public String vital_entry_id{get;set;}
		public list<vitals> vitals{get;set;}
	}
    
}