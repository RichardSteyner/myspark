public class clsProblems {
 	public string code { get; set; } 
    public string message { get; set; } 
    public clsProblems.Data data { get; set; } 

 public class Identifier{
        public string use { get; set; } 
        public string value { get; set; } 
    }

    public class Coding    {
        public string xsystem { get; set; } 
        public string code { get; set; } 
        public string display { get; set; } 
    }

    public class Code    {
        public List<Coding> coding { get; set; } 
        public string text { get; set; } 
    }

    public class Subject    {
        public string reference { get; set; } 
        public string display { get; set; } 
    }

    public class Coding2    {
        public string xsystem { get; set; } 
        public string code { get; set; } 
        public string display { get; set; } 
    }

    public class Category    {
        public List<Coding2> coding { get; set; } 
    }

    public class Resource    {
        public List<Identifier> identifier { get; set; } 
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

    public class Data    {
        public List<Entry> entry { get; set; } 
        public integer total { get; set; } 
        public string type { get; set; } 
        public string resourceType { get; set; } 
    }

 }