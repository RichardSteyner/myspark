public class clsListCareTeam {
 	public string code { get; set; } 
    public string message { get; set; } 
    public Data data { get; set; }
    
    public class Data    {
        public List<clsTeamCare.Identifier> identifier { get; set; } 
        public clsTeamCare.ManagingOrganization managingOrganization { get; set; } 
        public clsTeamCare.Subject subject { get; set; } 
        public string name { get; set; } 
        public clsTeamCare.Category category { get; set; } 
        public List<clsTeamCare.Participant> participant { get; set; } 
        public string resourceType { get; set; } 
        public string status { get; set; } 
    }   
}