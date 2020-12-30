public class clsTeamCare {
   public class Identifier    {
        public string use { get; set; } 
        public long value { get; set; } 
    }

    public class ManagingOrganization    {
        public string display { get; set; } 
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

    public class Role    {
        public string text { get; set; } 
    }

    public class Member    {
        public string display { get; set; } 
    }

    public class Participant    {
        public Role role { get; set; } 
        public Member member { get; set; } 
    }
}