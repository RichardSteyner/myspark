public class clsTreatmentPlan {
    
 	public class Period    {
        public string start { get; set; } 
    }

    public class Subject    {
        public string reference { get; set; } 
        public string display { get; set; } 
    }

    public class Code    {
        public string text { get; set; } 
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

    public class Detail    {
        public string scheduledString { get; set; } 
        public Code code { get; set; } 
        public Category category { get; set; } 
    }

    public class Activity    {
        public Detail detail { get; set; } 
    }

    public class Resource{
        public Period period { get; set; } 
        public Subject subject { get; set; } 
        public string description { get; set; } 
        public string title { get; set; } 
        public string resourceType { get; set; } 
        public List<Activity> activity { get; set; } 
    }

    public class Entry    {
        public Resource resource { get; set; } 
    }
    
}