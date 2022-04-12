public class DeploymentController {
	
    @AuraEnabled(cacheable=true) 
    public static List<DeploymentObject> getReleaseDeploymentDetails(String ReleaseId){
        
        List<DeploymentObject> deploymentObjectList = new List<DeploymentObject>();
        List<Data_Migration_Details__c> dataMigrationMetadataList = [select id,Name,Object_API_Name__c from Data_Migration_Details__c order by 	Sequence__c ASC NULLS LAST];
		
        Map<String,CPQ_Release_Item__c> releaseItemMap = new Map<String,CPQ_Release_Item__c>();
        List<CPQ_Release_Item__c> releaseItems = [select Id,Object_Api_Name__c,Ids__c,Deployment_Status__c from CPQ_Release_Item__c where CPQ_Release__c =: ReleaseId ];
        for(CPQ_Release_Item__c releaseItem: releaseItems){
            releaseItemMap.put(releaseItem.Object_Api_Name__c, releaseItem);
        }
        
        for(Data_Migration_Details__c dmd: dataMigrationMetadataList){
            if(releaseItemMap.get(dmd.Object_API_Name__c) != null){           	
               DeploymentObject dobj = new DeploymentObject();
               dobj.ObjectAPIName = dmd.Object_API_Name__c; 
               dobj.ObjectLabel = dmd.Name;
               dobj.Ids = releaseItemMap.get(dmd.Object_API_Name__c).Ids__c;
               dobj.DeploymentStatus = releaseItemMap.get(dmd.Object_API_Name__c).Deployment_Status__c;
               deploymentObjectList.add(dobj); 
            } 
           
        }
        
        return deploymentObjectList;        
    }
    public class DeploymentObject{
        @AuraEnabled public String ObjectAPIName;
        @AuraEnabled public String ObjectLabel;
        @AuraEnabled public String Ids;
        @AuraEnabled public Boolean DeploymentStatus;
        
    }
}