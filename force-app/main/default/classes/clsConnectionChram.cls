public class clsConnectionChram {
    SettingCharm__c Charm = SettingCharm__c.getOrgDefaults();
    Private String url ='';
    
    private String Token;
    private static HttpResponse response = null;
    
    public clsConnectionChram(){
        Token = Charm.Token__c;
    }
   
    Public String getResponse(String url, String parameters, String xbody,Boolean needToken,String Method){
        String xurl = url+parameters;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(xurl);
        request.setMethod(Method);
        request.setHeader('Content-Type','application/json;charset=UTF-8');
        
        if(needToken){
            String xautorization = 'Bearer '+Token;
            
        	request.setHeader('Authorization',xautorization);
            request.setHeader('api_key',charm.apiKey__c);
            
            system.debug('xurl : '+ xurl); 
            system.debug('Method : '+ Method);
            system.debug('Authorization : '+ xautorization);
            system.debug('api_key : '+ charm.apiKey__c);
        }
        If(Method != 'GET' ){
           request.setBody(xbody);
        }
        
        response = http.send(request); 
        system.debug('response aux = '+ response.getStatusCode());
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
        	return response.getBody();
        }else{
            String error = 'Status: '+response.getStatus() +', Code: '+response.getStatusCode()+', Message :'+response.getBody();
            throw new customException(error);
        }
    }
           
    Public String getJSON(String params,String Method){
        String Json = '';
        try{
            Json =  getResponse(Charm.Url_Conection__c,params,'',True,Method);
        }catch(Exception e){
            String errMessage = e.getMessage();
            system.debug('Error msj  : '+ errMessage);
            if(errMessage.indexOf('401') > -1 ){
               Token = updateToken();
               Json =  getResponse(Charm.Url_Conection__c,params,'',True,Method);
               update Charm;
            }else{
               throw e;  
            }
        }
        return Json;
    }
    
    Public String postJSON(String params,String Method, String Body){
        String Json = '';
        try{
            Json =  getResponse(Charm.Url_Conection__c,params,Body,True,Method);
        }catch(Exception e){
            String errMessage = e.getMessage();
            system.debug('Error msj  : '+ errMessage);
            if(errMessage.indexOf('401') > -1 ){
               Token = updateToken();
               Json =  getResponse(Charm.Url_Conection__c,params,'',True,Method);
               update Charm;
            }else{
               throw e;  
            }
        }
        return Json;
    }
    
    public string updateToken(){
        system.debug('solicitud token');
           String xparam = '/token?refresh_token='+Charm.main_Token__c +
           '&client_id='+Charm.Client_id__c+
           '&client_secret='+Charm.Client_secret__c+
           '&redirect_uri='+Charm.redirect_uri__c + 
           '&grant_type='+Charm.grant_type__c;
               
           String auxJson = getResponse(Charm.url_Token__c ,xparam,'',False,'POST');
           clsToken clsTk = (clsToken)JSON.deserialize(auxJson, clsToken.class);
           Charm.Token__c = clsTk.access_token;
           return clsTk.access_token;
             
    } 
    
	public class customException extends Exception{}
}