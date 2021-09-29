public class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param Map<Id,Order> oldMap
     * @return void
    **/
    public static void afterUpdate(List<Order> newList,  Map<Id,Order> oldMap){
        Set<Id> orderIds = new Set<Id>();

        for(Order order : newList) {
            if(oldMap.containsKey(order.Id)) {
                if(order.Status == Constants.ACTIVATED_ORDER_STATUS && oldMap.get(order.Id).Status == Constants.DRAFT_ORDER_STATUS) {
                    orderIds.add(order.Id);
                }
            }
        }
        rollUpOrderItems(orderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void rollUpOrderItems(Set<Id> activatedOrderIds){
        //ToDo: Declare a Map named "productMap" of Ids to Product2 records
        Map<Id, Product2> productMap = new Map<Id, Product2>(); 
        for(OrderItem orderElement : [  SELECT  Id, 
                                                Product2Id, 
                                                Product2.Quantity_Ordered__c, 
                                                Quantity
                                        FROM OrderItem 
                                        WHERE OrderId IN : activatedOrderIds
                                        WITH SECURITY_ENFORCED]){ 
            if(!productMap.containsKey(orderElement.Product2Id)) {
                productMap.put(orderElement.Product2Id, new Product2(Id = orderElement.Product2Id, Quantity_Ordered__c = 0));
            } 
        }
        
        for(AggregateResult res : [ SELECT  Sum(Quantity)activatedQuantity, 
                                            Product2Id 
                                    FROM OrderItem 
                                    WHERE Product2Id IN : productMap.keySet() 
                                    WITH SECURITY_ENFORCED
                                    GROUP BY Product2Id]){
            Id product2Id = (Id)res.get('Product2Id');
            Product2 prod = productMap.get(product2Id);
            prod.Quantity_Ordered__c = (Decimal)res.get('activatedQuantity');
            productMap.put(product2Id , prod);
        }
        try { 
            if(productMap.values() != null && productMap.values().size() > 0){ 
                update productMap.values(); 
            } 
        }catch ( Exception e ){ 
            System.debug('#### Exception Executed : '+e.getStackTraceString()); 
        } 





        /*

        //ToDo: Declare a Map named "productMap" of Ids to Product2 records
        
        Set<Id> orderedProductIds = new Set<Id>();
        //ToDo: Loop through a query of OrderItems related to the activatedOrderIds
        List<OrderItem> itemList = [SELECT  Id, 
                                            Product2Id,
                                            Product2.Quantity_Ordered__c 
                                    FROM OrderItem 
                                    WHERE OrderId IN :activatedOrderIds 
                                    WITH SECURITY_ENFORCED];
        for (OrderItem orderItem : itemList) {
            //ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value
            orderedProductIds.add(orderItem.Product2Id);
        }
        Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT  Id, 
                                                                    Quantity_Ordered__c 
                                                            FROM Product2 
                                                            WHERE Id IN :orderedProductIds
                                                            WITH SECURITY_ENFORCED]);

        AggregateResult[] groupedResults = [SELECT  Product2Id, 
                                                    SUM(Quantity)activatedQuantity 
                                            FROM OrderItem 
                                            WHERE Product2Id In :productMap.keySet() 
                                            WITH SECURITY_ENFORCED
                                            GROUP BY Product2Id];
        for (AggregateResult res : groupedResults) {
            Id product2Id = (Id)res.get('Product2Id');
            Product2 prod = productMap.get(product2Id);
            prod.Quantity_Ordered__c = (Decimal)res.get('activatedQuantity');
            productMap.put(product2Id , prod);
            //productMap.get(String.valueOf(res.get('Product2Id'))).Quantity_Ordered__c = Decimal.valueOf(String.valueOf(res.get('activatedQuantity')));
        }

        //ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
       
        //ToDo: Perform an update on the records in the productMap
            
        if(productMap!=null && productMap.size()>0){
            update productMap.values();
        }*/
    }

}