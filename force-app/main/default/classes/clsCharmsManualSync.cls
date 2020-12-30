public class clsCharmsManualSync {    
    Private Boolean IndSync = True;
    
    public Boolean Running{
    get {
      return IndSync;
    	}
 	 }
    
	public PageReference doSync() {
        IndSync=False;
        if (!Test.isRunningTest()) database.executeBatch(new clsBatchGetFacilitiesFromCharm());
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Manual synchronization is in progress.'));
        return null;
    }
}