public class clsImplant {

    public class Identifier {
        public String use { get; set; } 
        public Long value { get; set; }
    }

    public class Patient {
        public String reference { get; set; } 
        public String display { get; set; } 
    }

    public class Udi {
        public String deviceIdentifier { get; set; }
        public String name { get; set; }
    }

    public class Resource {
        public List<Identifier> identifier { get; set; }
        public Patient patient { get; set; }
        public Udi udi { get; set; }
        public String version { get; set; }
        public String resourceType { get; set; }
        public String status { get; set; }
        public String manufacturer { get; set; }
        public Date expirationDate { get; set; }
    }
    
    public class Entry {
        public Resource resource { get; set; } 
    }
    
}
