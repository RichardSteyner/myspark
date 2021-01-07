public class clsAssessmentList {
	 public string code { get; set; } 
     public string message { get; set; } 
     public Data data { get; set; } 


  	public class Data    {
        public List<clsAssessment.Entry> entry { get; set; } 
        public integer total { get; set; } 
        public string type { get; set; } 
        public string resourceType { get; set; } 
    }
}