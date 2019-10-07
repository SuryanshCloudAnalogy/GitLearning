public class OrderHelper {
    
    /**
* @name AfterUpdate
* @description 
* @param List<Order> newList
* @param List<Order> oldList
* @return void
**/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS  && oldList[i].Status == Constants.DRAFT_ORDER_STATUS){
                orderIds.add(newList[i].Id);
            }
        }
        if(orderIds.size()>0)
            RollUpOrderItems(orderIds);
    }
    
    /**
* @name RollUpOrderItems
* @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
* @param Set<Id> activatedOrderIds
* @return void
**/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        Set<Id> product2Ids = new Set<Id>();
        List<OrderItem> orderItems = new   List<OrderItem>();
        if(activatedOrderIds.size()>0){
            orderItems = [SELECT Id, Quantity,OrderId ,Product2Id FROM OrderItem WHERE OrderId IN:activatedOrderIds];
            for(OrderItem item :orderItems){
                product2Ids.add(item.Product2Id);
            }
            Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id IN :product2Ids]);
            List<AggregateResult>aggregatedResults  = [SELECT Product2Id, SUM(Quantity)totalQuantity  FROM OrderItem WHERE Product2Id In :productMap.keySet() GROUP BY Product2Id];
            
            for (AggregateResult ar : aggregatedResults)  {
                system.debug('ar :: '+ar);
               productMap.get((String)ar.get('Product2Id')).Quantity_Ordered__c = Integer.valueOf(ar.get('totalQuantity'));
            }
            
            //ToDo: Perform an update on the records in the productMap
            if(productMap != null && productMap.size() > 0) {
                update productMap.values();
            }
        }
        //ToDo: Declare a Map named "productMap" of Ids to Product2 records
        
        //ToDo: Loop through a query of OrderItems related to the activatedOrderIds
        
        //ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value
        
        //ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
        
        //ToDo: Perform an update on the records in the productMap
    }
    
}