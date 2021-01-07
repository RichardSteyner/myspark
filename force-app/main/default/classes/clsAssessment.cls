public class clsAssessment {

    public class Period    {
        public string start { get; set; } 
    }

    public class Subject    {
        public string reference { get; set; } 
        public string display { get; set; } 
    }

    public class Resource    {
        public Period period { get; set; } 
        public Subject subject { get; set; } 
        public string description { get; set; } 
        public string title { get; set; } 
        public string resourceType { get; set; } 
    }

    public class Entry    {
        public Resource resource { get; set; } 
    }

  
}