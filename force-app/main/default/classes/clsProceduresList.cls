public class clsProceduresList {
    
    public String code { get; set; } 
    public String message { get; set; } 
    public Data data { get; set; } 
    
     public class Data    {
        public List<clsProcedure.Entry> entry { get; set; } 
        public Integer total { get; set; } 
        public String type { get; set; } 
        public String resourceType { get; set; } 
    }
    
}