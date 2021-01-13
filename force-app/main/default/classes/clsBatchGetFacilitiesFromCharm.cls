public class clsBatchGetFacilitiesFromCharm implements Database.Batchable<clsFacilities>,Database.Stateful,Database.AllowsCallouts{
   private clsPageContext PageContext;
   private clsConnectionChram cn = new clsConnectionChram();
    
    public List<clsFacilities> start(Database.BatchableContext BC){
        clsListFacilities lstFacility = new clsListFacilities();
        List<clsFacilities> auxFacilities = new List<clsFacilities>();
        integer page = 1;
        
        do{
            String xparam = '/facilities?page=' + page;
            String body = cn.getJSON(xparam,'GET');
            lstFacility = (clsListFacilities) JSON.deserialize(body,clsListFacilities.class);   
            PageContext = lstFacility.page_context;
            auxFacilities.addAll(lstFacility.facilities);
            page++;
        }while(Boolean.valueOf(PageContext.has_more_page)) ;
                           
        return lstFacility.facilities;
    }
    
    public void execute(Database.BatchableContext BC, List<clsFacilities> scope) {
        list<Facilities__c> lstFacilities = new list<Facilities__c>();
        system.debug('rvc sys body :' + scope);
        
        for(clsFacilities fc : scope){
           		Facilities__c objF = new Facilities__c( 
                address_line1__c = fc.address_line1,
                address_line2__c = fc.address_line2,
                city__c = fc.city,
                country__c = fc.country,
                Name = fc.facility_name,
                facility_code__c = fc.facility_code,
                facility_id__c = fc.facility_id,
                facility_status__c = fc.facility_status,
                mobile__c = fc.mobile,
                office_phone__c = fc.office_phone,
                state__c = fc.state,
                Sync_Charm__c = TRUE,
                zip_code__c = fc.zip_code,
                Activate__c = TRUE 
            );
            lstFacilities.add(objF);
        }
        upsert lstFacilities facility_id__c;
    }
    
    public void finish(Database.BatchableContext BC){ 
       // database.executeBatch(new clsBatchGetPatientsfromCharm());
        
       database.executeBatch(new clsBatchPostPatientToCharm(),10);
    }
}