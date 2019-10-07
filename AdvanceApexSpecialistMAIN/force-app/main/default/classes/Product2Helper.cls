public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name =: Constants.INVENTORY_ANNOUNCEMENTS OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS) LIMIT 1 ];
    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> oldList, List<Product2> newList){
        //ToDo: Declare a List of Product2 records named needsAnnouncement

        //ToDo: Declare a Map of Strings to Inventory_Setting__mdt records

        //ToDo: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key

        //ToDo: Loop through the Products in newList
        // Use the corresponding Inventory Setting record to determine the correct Low Quantity Alert
        // If the Product's Quantity Remaining has been changed to less than the Low Quantity Alert
        //      add it to the needsAnnouncement list

        //ToDo: Pass records to the postAlerts method
        
		List<Product2> needsAnnouncement = new List<Product2>();
        
        Map<String,Inventory_Setting__mdt> mapInvSettings = new Map<String,Inventory_Setting__mdt>();

        for( Inventory_Setting__mdt inv : [SELECT Id,DeveloperName,Low_Quantity_Alert__c FROM Inventory_Setting__mdt] ){
            mapInvSettings.put(inv.DeveloperName, inv);
        }

        for( Integer i=0; i<newList.size(); i++ ){
            
            if( oldList[i].Quantity_Remaining__c != newList[i].Quantity_Remaining__c 
               	&& mapInvSettings.containsKey(newList[i].Family) 
               	&& newList[i].Quantity_Remaining__c < mapInvSettings.get(newList[i].Family).Low_Quantity_Alert__c){
            	
                   needsAnnouncement.add(newList[i]); 
            }
            
        }
        
        PostAlerts(needsAnnouncement);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            // ToDo: Construct a new AnnouncementInput for the Chatter Group so that it:
            // expires in a day
            // does not notify users via email.
            // and has a text body that includes the name of the product followed by the INVENTORY_LEVEL_LOW constant
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
      		ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            ConnectApi.AnnouncementInput singlePost = new ConnectApi.AnnouncementInput();
            singlePost.expirationDate = Date.today().addDays(1);
            singlePost.sendEmails = false;
            singlePost.parentId = COLLABORATION_GROUP[0].Id;
            
            textSegmentInput.text = p.Name+' '+String.valueOf(Constants.INVENTORY_LEVEL_LOW);

            messageBodyInput.messageSegments.add(textSegmentInput);
            
            singlePost.body = messageBodyInput;
            
            toPost.add(singlePost);
        }
        // ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
        AnnouncementQueueable queueable = new AnnouncementQueueable();
        queueable.toPost = toPost;
        System.enqueueJob(queueable);
    }
}