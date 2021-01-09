public class clsProcedure {

    public class Identifier {
        public String use { get; set; } 
        public Long value { get; set; }
    }

    public class Note {
        public String text { get; set; }
    }

    public class Code {
        public String text { get; set; }
    }

    public class Subject {
        public String reference { get; set; } 
        public String display { get; set; } 
    }

    public class Resource {
        public List<Identifier> identifier { get; set; }
        public List<Note> note { get; set; }
        public Code code { get; set; }
        public Subject subject { get; set; }
        public Date performedDateTime { get; set; }
        public String resourceType { get; set; }
        public String status { get; set; }
        public Boolean notDone { get; set; }
    }
    
    public class Entry {
        public Resource resource { get; set; } 
    }
    
}