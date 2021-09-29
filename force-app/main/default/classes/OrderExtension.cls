/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get; set;}
    public List<OrderItem> orderItemList {get; set;}
    public String selectedFamily {get; set;}
    public List<chartHelper.chartData> pieData {get; set;}
    public Map<Id,ChartHelper.ChartData> pieDataMap{get;set;}
    public Decimal total {get; set;}
    public Map<Id,OrderItem> orderItemMap{get; set;}
    public ApexPages.StandardSetController standardSetController {get; set;}
    
    public OrderExtension(ApexPages.StandardController standardController){
        this.getControllerData();
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        for (OrderItem item : orderRecord.OrderItems) {
            System.debug(item.product2.Id + ' ' + item);
            orderItemMap.put(item.product2.Id, item);
        }
        System.debug(orderItemMap);
        this.getOrderItemList();
    }

    public void getControllerData() {
        String query = 'SELECT  Id, Product2.Id, Product2.Name, Product2.Family, Product2.Quantity_Remaining__c, UnitPrice FROM PriceBookEntry';
        if (this.selectedFamily != null && this.selectedFamily != Constants.SELECT_ONE) {
            query += ' WHERE Product2.Family = :selectedFamily';
        }
        query += ' WITH SECURITY_ENFORCED';
        this.standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        this.standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }


    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    public void getOrderItemList() {
        orderItemList = new List<OrderItem>();
        for (PriceBookEntry pbe : (List<PricebookEntry>)standardSetController.getRecords()) {
            if (orderItemMap.containsKey(pbe.product2Id)) {
                orderItemList.add(orderItemMap.get(pbe.product2Id));
            } else {
                OrderItem item = new OrderItem();
                item.product2 = pbe.Product2;
                item.product2.Id = pbe.Product2.Id;
                item.PricebookEntryId = pbe.Id;
                item.Quantity = 0;
                item.UnitPrice = pbe.UnitPrice;
                this.orderItemList.add(item);
                System.debug(item.product2.Id + ' ' + item);
                this.orderItemMap.put(item.Product2.Id,item);
            }
        }
        System.debug(orderItemMap);
    }
   

    /**
     * @name OnFieldChange
     * @description
    **/
    public void onFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        
            pieData = new List<ChartHelper.ChartData>();
            total = 0;
        
        if (pieDataMap == null) {
            pieDataMap = new Map<Id,ChartHelper.ChartData>();
        }
        
        
        for (OrderItem item : orderItemList) {
            if (item.quantity > 0) {
                System.debug(item.product2.Id + ' ' + item);
                orderItemMap.put(item.product2.Id, item);
                System.debug(orderItemMap);
            }
        }
        for (OrderItem item : orderItemMap.Values()) {
            if (item.quantity > 0) {
                pieDataMap.put(item.Product2.Id, new ChartHelper.ChartData(item.Product2.Name, item.Quantity*item.UnitPrice));
                //pieData.add(new ChartHelper.ChartData(item.Product2.Name, item.Quantity*item.UnitPrice));
                //total += item.UnitPrice * item.Quantity;
            }
        }
        for (ChartHelper.ChartData data : pieDataMap.values()) {
            pieData.add(data);
            total += data.val;
        }
        

    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void selectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
    
        this.getControllerData();
        this.getOrderItemList();
        
    }

    /**
     * @name Save
     * @description
    **/
    public void save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        System.debug('im here');
        System.Savepoint sp = Database.setSavepoint();

        try {
          if(orderRecord.Pricebook2Id == null) {
            orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
          }
          upsert orderRecord;
    
          List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
          List<OrderItem> orderItemsToDelete = new List<OrderItem>();
    
          for (OrderItem oi : orderItemMap.values()) {
            if(oi.Quantity > 0) {
              if(oi.OrderId == null) {
                oi.OrderId = orderRecord.Id;
              }
              orderItemsToUpsert.add(oi);
            } else if(oi.Id != null) {
              orderItemsToDelete.add(new OrderItem(id=oi.Id));
              oi.Id = null;
            }
          }
    
          upsert orderItemsToUpsert;
          delete orderItemsToDelete;
    
        } catch (Exception e){
          Database.rollback(sp);
          apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,Constants.ERROR_MESSAGE));
        }
        

    }


    /**
     * @name First
     * @description
    **/
    public void first(){
        standardSetController.first();
        this.getOrderItemList();
    }


    /**
     * @name Next
     * @description
    **/
    public void next(){
        standardSetController.next();
        this.getOrderItemList();
    }


    /**
     * @name Previous
     * @description
    **/
    public void previous(){
        standardSetController.previous();
        this.getOrderItemList();
    }

    /**
     * @name Last
     * @description
    **/
    public void last(){
        standardSetController.last();
        this.getOrderItemList();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean getHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean getHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer getTotalPages(){
        return (Integer)Math.ceil(standardSetController.getResultSize()/(Decimal)Constants.DEFAULT_ROWS);
        
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer getPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> getFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for (Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(entry.getLabel(),entry.getLabel()));
        }
            return options;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order queryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2.Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
            WITH SECURITY_ENFORCED
        ];
    }

}