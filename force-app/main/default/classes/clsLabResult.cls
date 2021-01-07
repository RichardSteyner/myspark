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
        public String text { get; set; }
    }

    public class Code {
        public String text { get; set; } 
    }

    public class Component {
        public ReferenceRange referenceRange { get; set; }
        public Code code { get; set; } 
        public Code interpretation { get; set; } 
        public UnitValue valueQuantity { get; set; } 

        public Decimal getReferenceRangeHigh(){
            try {
                if(referenceRange!=null && referenceRange.high!=null && referenceRange.high.value!=null)
                    return Decimal.valueOf(referenceRange.high.value);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            return null;
        }

        public Decimal getReferenceRangeLow(){
            try {
                if(referenceRange!=null && referenceRange.low!=null && referenceRange.low.value!=null)
                    return Decimal.valueOf(referenceRange.low.value);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            return null;
        }

        public String getReferenceRangeCustom(){
            if(referenceRange!=null)
                    return referenceRange.text;
            return null;
        }

        public String getUnit(){
            try {
                if(valueQuantity!=null && valueQuantity.unit!=null)
                    return valueQuantity.unit;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            return null;
        }
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
        /*----------------------OR----------------------*/
        public ReferenceRange referenceRange { get; set; }
        public Code interpretation { get; set; } 
        public UnitValue valueQuantity { get; set; } 
        
        public Code code { get; set; }  
        public Date effectiveDateTime { get; set; } 
        public Subject subject { get; set; }
        public Category category { get; set; }
        public String resourceType { get; set; } 
        public String status { get; set; } 

        public Decimal getReferenceRangeHigh(){
            try {
                if(referenceRange!=null && referenceRange.high!=null && referenceRange.high.value!=null)
                    return Decimal.valueOf(referenceRange.high.value);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            return null;
        }

        public Decimal getReferenceRangeLow(){
            try {
                if(referenceRange!=null && referenceRange.low!=null && referenceRange.low.value!=null)
                    return Decimal.valueOf(referenceRange.low.value);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            return null;
        }

        public String getReferenceRangeCustom(){
            if(referenceRange!=null)
                    return referenceRange.text;
            return null;
        }

        public String getUnit(){
            try {
                if(valueQuantity!=null && valueQuantity.unit!=null)
                    return valueQuantity.unit;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            return null;
        }
    }
    
    public class Entry {
        public Resource resource { get; set; } 
    }
    
}