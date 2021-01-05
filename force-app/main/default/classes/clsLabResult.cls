public class clsLabResult {

    public class Identifier {
        public String use { get; set; } 
        public Long value { get; set; }
    }

    public class UnitValue {
        public String unit { get; set; }
        public String value { get; set; }
    }

    public class ReferenceRange {
        public UnitValue high { get; set; }
        public UnitValue low { get; set; }
    }

    public class Code {
        public String text { get; set; } 
    }

    public class Component {
        public ReferenceRange referenceRange { get; set; }
        public Code code { get; set; } 
        public Code interpretation { get; set; } 
        public UnitValue valueQuantity { get; set; } 
    }

    public class Subject    {
        public String reference { get; set; } 
        public String display { get; set; } 
    }

    public class Category {
        public String text { get; set; }
    }

    public class Resource {
        public List<Identifier> identifier { get; set; }
        public List<Component> component { get; set; }
        public Code code { get; set; }  
        public Date effectiveDateTime { get; set; } 
        public Subject subject { get; set; }
        public Category category { get; set; }
        public String resourceType { get; set; } 
        public String status { get; set; } 
    }
    
    public class Entry {
        public Resource resource { get; set; } 
    }
    
}