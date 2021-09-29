@isTest
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest
    private static void Product2Extension_UnitTest(){
        PageReference pageRef = page.Product2New;
        List<Product2> prodList = TestDataFactory.constructProducts(Constants.DEFAULT_ROWS);
        List<Product2Extension.ProductWrapper> wrapperList = new List<Product2Extension.ProductWrapper>();
        for(Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
            PricebookEntry entry = new PricebookEntry(UnitPrice = 100);
            wrapperList.add(new Product2Extension.ProductWrapper(prodList.get(i),entry));
        }
        Integer initialRowCount;
        Integer updatedRowCount;
        Test.startTest();
            Product2Extension ext = new Product2Extension(new ApexPages.StandardController(prodList.get(0)));

            initialRowCount = ext.productsToInsert.size();
            System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size(), 'initial row count isn\'t correct');
            ext.addRows();
            System.assertEquals(Constants.DEFAULT_ROWS * 2, ext.productsToInsert.size(), 'updated row count isn\'t correct');
            updatedRowCount = ext.productsToInsert.size();
            for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
                ext.productsToInsert.set(i, wrapperList.get(i)); 
            }
            ext.save();
        Test.stopTest();

        AggregateResult[] agr = [SELECT Count(Id)prodCount FROM Product2];
        Integer insertedProdCount = Integer.valueOf(agr.get(0).get('prodCount'));

        
        
        System.assertEquals(Constants.DEFAULT_ROWS, insertedProdCount, 'products weren\'t updated correctly');
    }

    

    @isTest
    private static void Product2Trigger_UnitTest() {
        TestDataFactory.insertTestData(1);
        List<ChartHelper.chartData> cht = ChartHelper.getInventory();

        List<Order> orders = [  SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                                    (
                                        SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2.Id,
                                             Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                                        FROM OrderItems
                                    )
                                FROM Order
                                WITH SECURITY_ENFORCED];
    
        Test.startTest();
        OrderExtension ext = new OrderExtension(new ApexPages.StandardController(orders.get(0)));
        
        Id product2Id = ext.orderItemList.get(0).product2Id;
        List<Product2> products = [SELECT Id, Quantity_Remaining__c, Quantity_Ordered__c FROM Product2 WHERE Id = :product2Id];
        ext.orderItemList.get(0).Quantity = Constants.DEFAULT_ROWS *2;
        ext.onFieldChange();
        ext.save();
        List<Order> ordersAftedUpdate = [  SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                                            (
                                                SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2.Id,
                                                     Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                                                FROM OrderItems
                                            )
                                            FROM Order
                                            WITH SECURITY_ENFORCED  ];
        
        orders.get(0).Status = Constants.ACTIVATED_ORDER_STATUS;
        update orders;
        List<Product2> productsUpdated = [SELECT Id, Quantity_Remaining__c, Quantity_Ordered__c FROM Product2 WHERE Id = :product2Id];
        System.assertEquals(productsUpdated.get(0).Quantity_Ordered__c, Constants.DEFAULT_ROWS * 2, '');
        System.assertEquals(true, cht.size() > 0,'');
        Test.stopTest();   
}

}