public class clsSmokingStatus {
    
    public String code { get; set; } 
    public String message { get; set; } 
    public Data data { get; set; } 

    public class Coding {
        public String xsystem { get; set; }
        public String code { get; set; }
        public String display { get; set; }
    }

    public class ValueCodeableConcept {
        public List<Coding> coding { get; set; }
        public String text;
    }

    public class Subject {
        public String reference { get; set; } 
        public String display { get; set; } 
    }

    public class Category {
        public String text { get; set; }
    }
    
     public class Data    {
        public ValueCodeableConcept valueCodeableConcept { get; set; }
        public Subject subject { get; set; }
        public List<Category> category { get; set; }
        public String resourceType { get; set; } 
    }
    
}