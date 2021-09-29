@isTest
private class OrderTests {

    @isTest
    private static void OrderUpdate_UnitTest() {
        Map<Id,Product2> originalProductMap = new Map<Id,Product2>([SELECT Id, Quantity_Ordered__c FROM Product2]);
        List<Order> orders = [SELECT Id, Status FROM Order];

        Test.startTest();
        for (Order ord : orders) {
            ord.Status = Constants.ACTIVATED_ORDER_STATUS;
        }
        update orders;
        Test.stopTest();

        Map<Id,Product2> updatedProductMap = new Map<Id,Product2>([SELECT Id, Quantity_Ordered__c FROM Product2]);
        Map<Id,Integer> prodIdToOIQuantity = new Map<Id,Integer>();

        AggregateResult[] groupRes = [SELECT Product2Id, Sum(Quantity)qnt FROM OrderItem GROUP BY Product2Id];

        for (AggregateResult res : groupRes) {
            prodIdToOIQuantity.put((Id)res.get('Product2Id'),Integer.valueOf(res.get('qnt')));
        }

        for (Id idKey : updatedProductMap.keySet()) {
            TestDataFactory.verifyQuantityOrdered(originalProductMap.get(idKey), updatedProductMap.get(idKey), prodIdToOIQuantity.get(idKey));
        }

    } 

    @testSetup 
    private static void setupTestData () {
        TestDataFactory.insertTestData(Constants.DEFAULT_ROWS); 
    }

    @isTest
    private static void orderExtension_UnitTest() {
        PageReference pageRef = page.OrderEdit;
        List<Order> orders = [SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
        (
            SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2.Id,
                 Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
            FROM OrderItems
        )
    FROM Order
    WITH SECURITY_ENFORCED];

        Test.startTest();

        OrderExtension ext = new OrderExtension(new ApexPages.StandardController(orders.get(0)));
        
        List<SelectOption> options = ext.getFamilyOptions();
        System.assertEquals(1+Constants.PRODUCT_FAMILY.size(), options.size(),'');
        System.assertEquals(Constants.DEFAULT_ROWS, ext.standardSetController.getPageSize(), '');
        System.assertEquals(Constants.DEFAULT_ROWS, ext.orderItemMap.size(), '');
        System.assertEquals(1, ext.getTotalPages(), '');
        ext.selectedFamily = 'Entree';
        ext.selectFamily();
        System.assertEquals(Constants.DEFAULT_ROWS > ext.orderItemList.size(), true, '');
        ext.orderItemList.get(0).Quantity = 2;
        ext.onFieldChange();
        System.assertEquals(false, ext.getHasNext(),'');
        System.assertEquals(false,ext.getHasPrevious(),'');
        System.assertEquals(1, ext.getPageNumber(),'');
        ext.save();

        List<Order> updatedOrders = [SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
        (
            SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2.Id,
                 Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
            FROM OrderItems
        )
    FROM Order
    WITH SECURITY_ENFORCED];

    System.assertEquals(orders.size(), updatedOrders.size(),'');
    
        

        Test.stopTest();
    }


}