public with sharing class Constants {
    
    public static final Integer DEFAULT_ROWS = 5;
    public static final String SELECT_ONE = System.Label.Select_One;
    public static final String INVENTORY_LEVEL_LOW = System.Label.Inventory_Level_Low;
    public static final List<Schema.PicklistEntry> PRODUCT_FAMILY = getPoductFamilyEntries();
    public static final String DRAFT_ORDER_STATUS = 'Draft';
    public static final String ACTIVATED_ORDER_STATUS = 'Activated';
    public static final String INVENTORY_ANNOUNCEMENTS = 'Inventory Announcement';
    public static final String ERROR_MESSAGE = 'An error has occurred, please take a screenshot with the URL and send it to IT.';
    public static final Id STANDARD_PRICEBOOK_ID = '01s5g00000O0t1cAAB';

    private static List<Schema.PicklistEntry> getPoductFamilyEntries() {
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
		List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        if (!picklistEntries.isEmpty()) {
            return picklistEntries;
        } else {
            return new List<Schema.PicklistEntry>();
        }

    }
}
