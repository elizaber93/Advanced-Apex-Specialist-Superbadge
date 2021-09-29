public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}
    

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert  = new List<ProductWrapper>();
        addRows();
        
    }

    public void addRows(){
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++){
            productsToInsert .add(new ProductWrapper());
        }
    }

    public List<ChartHelper.ChartData> getInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference save(){

        SavePoint savePoint = Database.setSavePoint();
        Integer insertedRecordCount = 0;
        try {
            List<Product2> productListToInsert = new List<Product2>();
            List<PricebookEntry> entryListToInsert = new List<PricebookEntry>();
            List<ProductWrapper> validWrapperList = new List<ProductWrapper>();
            for (ProductWrapper wrapper : productsToInsert ) {
                if(wrapper.productRecord.Name != null &&
                wrapper.productRecord.Name != '' &&
                wrapper.productRecord.Family != null &&
                wrapper.productRecord.Family != Constants.SELECT_ONE &&
                wrapper.productRecord.isActive &&
                wrapper.productRecord.Initial_Inventory__c != null &&
                wrapper.productRecord.Initial_Inventory__c != 0 &&
                wrapper.pricebookEntryRecord.UnitPrice != null &&
                wrapper.pricebookEntryRecord.UnitPrice != 0) {
                    validWrapperList.add(wrapper);
                    productListToInsert.add(wrapper.productRecord);
                }
            }
            
            Database.SaveResult[] productSaveResults = Database.insert(productListToInsert, false);
            
            for(Integer i = 0; i < productSaveResults.size(); i++) {
                if(productSaveResults[i].isSuccess()) {
                  PriceBookEntry pricebookEntry = validWrapperList[i].pricebookEntryRecord;
                  pricebookEntry.Product2Id = productSaveResults[i].getId();
                  pricebookEntry.IsActive = true;
                  pricebookEntry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                  entryListToInsert.add(pricebookEntry);
                  insertedRecordCount++;
                }
            }
            Database.SaveResult[] pricebookEntrySaveResults = Database.insert(entryListToInsert, false);

            for(Integer i = 0; i < pricebookEntrySaveResults.size(); i++) {
                if(!pricebookEntrySaveResults[i].isSuccess()) {
                    throw new IllegalArgumentException();
                }
            }
            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,insertedRecordCount+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            Database.rollback(savePoint);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
        return null;
    }

    private boolean isValid(ProductWrapper wrapper) {
        boolean result = true;
        result &= wrapper.productRecord.Name != null;
        result &= wrapper.productRecord.Name != '';
        result &= wrapper.productRecord.Family != null;
        result &= wrapper.productRecord.Family != Constants.SELECT_ONE;
        result &= wrapper.productRecord.isActive;
        result &= wrapper.productRecord.Initial_Inventory__c != null;
        result &= wrapper.productRecord.Initial_Inventory__c != 0;
        result &= wrapper.pricebookEntryRecord.UnitPrice != null;
        result &= wrapper.pricebookEntryRecord.UnitPrice != 0;
        return result;
    }

    public static List<SelectOption> getFamilyOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for (Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(entry.getLabel(),entry.getLabel()));
        }
            return options;
    }

    public class ProductWrapper {
        public Product2 productRecord {get;set;} 
        public PricebookEntry pricebookEntryRecord {get;set;}
        public ProductWrapper() {
            this.productRecord = new Product2(Initial_Inventory__c =0, Name='Test Product', isActive=true);
            this.pricebookEntryRecord = new PricebookEntry(Unitprice=0.0);
        }
        public ProductWrapper(Product2 prod, PricebookEntry entry) {
            this.productRecord = prod;
            this.pricebookEntryRecord = entry;
        }
    }

    public List<ChartHelper.ChartData> getChartData() {
        return ChartHelper.getInventory();
    }

}