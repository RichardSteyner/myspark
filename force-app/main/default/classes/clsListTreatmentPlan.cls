public class clsListTreatmentPlan {
      public string code { get; set; } 
      public string message { get; set; } 
      public Data data { get; set; }
    
      public class Data    {
            public List<clsTreatmentPlan.Entry> entry { get; set; } 
            public integer total { get; set; } 
            public string type { get; set; } 
            public string resourceType { get; set; } 
        }

}