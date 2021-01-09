public class clsHealthConcerns {
    
   public class Code    {
        public string text { get; set; } 
    }

    public class Subject    {
        public string reference { get; set; } 
        public string display { get; set; } 
    }

    public class Coding    {
        public string xsystem { get; set; } 
        public string code { get; set; } 
        public string display { get; set; } 
    }

    public class Category    {
        public List<Coding> coding { get; set; } 
        public string text { get; set; } 
    }

    public class Resource    {
        public Code code { get; set; } 
        public Subject subject { get; set; } 
        public string clinicalStatus { get; set; } 
        public List<Category> category { get; set; } 
        public string onsetDateTime { get; set; } 
        public string resourceType { get; set; } 
    }

    public class Entry    {
        public Resource resource { get; set; } 
    }

}