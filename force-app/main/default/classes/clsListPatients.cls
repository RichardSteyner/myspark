public class clsListPatients {
	public string code { get; set; } 
    public string message { get; set; } 
    public List<clsPatient> patients { get; set; } 
    public clsPageContext page_context { get; set; } 
}