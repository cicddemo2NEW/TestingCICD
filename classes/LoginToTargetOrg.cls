Global class LoginToTargetOrg{
@AuraEnabled
public static string callwebService(string userNameInfo, string passwordSecurityT, string OrgInfo){
try{
string enpointURL = 'https://test.salesforce.com/services/Soap/u/54.0';
if(OrgInfo=='Production'){
    enpointURL = 'https://login.salesforce.com/services/Soap/u/54.0';
    }

/*Login, Provide Username and Password of the Webservice Provider */
partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
partnerSoapSforceCom.LoginResult lr = sp.login(userNameInfo, passwordSecurityT,enpointURL);
return lr.sessionId;
//account acc = new account(name=lr.sessionId);//unable to print in debug log. so created as account for testing purpose.
//insert acc;
}catch(exception ex){
system.debug(ex.getmessage());
return ex.getmessage();
}





}}