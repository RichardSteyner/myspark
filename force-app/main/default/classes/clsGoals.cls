public class clsGoals {
  public class Subject    {
        public string reference { get; set; } 
        public string display { get; set; } 
    }

    public class Description    {
        public string text { get; set; } 
    }

    public class Resource    {
        public Subject subject { get; set; } 
        public Description description { get; set; } 
        public string startDate { get; set; } 
        public string resourceType { get; set; } 
        public string status { get; set; } 
    }

    public class Entry    {
        public Resource resource { get; set; } 
    }
}