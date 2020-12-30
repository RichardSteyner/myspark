public class clsListProblems {

		public String message{get;set;}
		public data data{get;set;}
		public String code{get;set;}
    
	public class subject{
		public String display{get;set;}
		public String reference{get;set;}
	}
    
	public class resource{
		public String clinicalStatus{get;set;}
		public String onsetDateTime{get;set;}
		public list<category> category{get;set;}
		public String resourceType{get;set;}
		public subject subject{get;set;}
		public list<identifier> identifier{get;set;}
		public code code{get;set;}
	}
    
	public class identifier{
		public Decimal value{get;set;}
		public String use{get;set;}
	}
    
	public class entry{
		public resource resource{get;set;}
	}
    
	public class data{
		public String type{get;set;}
		public Integer total{get;set;}
		public String resourceType{get;set;}
		public list<entry> entry{get;set;}
	}
    
	public class coding{
		public String code{get;set;}
		public String display{get;set;}
		public String xsystem {get;set;}
	}
    
	public class code{
		public String text{get;set;}
		public list<coding> coding{get;set;}
	}
    
	public class category{
		public list<coding> coding{get;set;}
	}
    
}