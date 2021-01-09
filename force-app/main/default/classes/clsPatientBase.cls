public class clsPatientBase {

   
    public class facility{
		public String facility_id{get;set;}
        
        public facility (String lfacility_id){
            facility_id = lfacility_id;
        }
	}  
    
     public class qualifier{
        public Integer id_qualifier{get;set;}
        public String id_of_patient{get;set;}
        public String file_id{get;set;}        
    }
    
      public class address{
        public String address_line1{get;set;}
        public String address_line2{get;set;}
        public String area{get;set;}
        public String city{get;set;}
        public String state{get;set;}
        public String county_code{get;set;}
        public String country{get;set;}
        public String zip_code{get;set;}
        public String district{get;set;}
        public String post_box {get;set;}   
	}
    
       public class contact{
        public String mobile {get;set;}
        public String home_phone{get;set;}
        public String work_phone{get;set;}
        public String work_phone_extn{get;set;}
        public String email{get;set;}
    }
    
     public class caregiver{
        public String type {get;set;}
        public String first_name{get;set;}
        public String middle_name{get;set;}
        public String last_name{get;set;}
        public String dob{get;set;}
        public String gender{get;set;}
        public String ssn{get;set;}
        public String relationship{get;set;}
        public String same_as_patient_contact{get;set;}
        public clsPatientBase.contact contact {get;set;}
        public clsPatientBase.address address{get;set;}
    }
    
      public class guarantor{
        public String first_name{get;set;}
        public String middle_name{get;set;}
        public String last_name{get;set;}
        public String dob{get;set;}
        public String gender{get;set;}
        public String ssn{get;set;}
        public String relationship{get;set;}
        public String same_as_patient_contact{get;set;}
        public clsPatientBase.contact contact {get;set;}
        public clsPatientBase.address address{get;set;}
    }
    
     public class category{
        public String category_id {get;set;}
                  
        public category (String lcategory_id){
            category_id = lcategory_id;
        }
         
    }
}