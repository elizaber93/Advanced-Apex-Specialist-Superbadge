/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup constructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup grp= new CollaborationGroup(   Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS,
                                                            CollaborationType='Public');
        return grp;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> constructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Product2> productList = new List<Product2>();
        
        for (Integer i = 0; i < cnt; i++) {
           
            productList.add(new Product2(   Name = 'TestProduct'+i,
                                            isActive = true,
                                            Initial_Inventory__c = 10,
                                            Family = Constants.PRODUCT_FAMILY.get(math.mod(i,4)).getValue()
                                            ));
        }
        return productList;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> constructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PricebookEntry> entryList = new List<PricebookEntry>();
        for (Product2 prod : prods) {
            entryList.add(new PricebookEntry(   Product2Id = prod.Id,
                                                isActive = true,
                                                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                                                UnitPrice = 250));
        }
        return entryList;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> constructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accountList = new List<Account>();
        for (Integer i = 0; i < cnt; i++) {
            accountList.add(new Account(Name = 'TestAccount' + i));
        }
        return accountList;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> constructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < cnt; i++) {
            Contact contact = new Contact(LastName = 'ContactTest' + i,
                                            AccountId = accts.get(i).Id);
            contactList.add(contact);
        }
        return contactList;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> constructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> orderList = new List<Order>();
        Integer j = 0;
        for (Integer i = 0; i < cnt; i++) {
            Order order = new Order(EffectiveDate = Date.today(),
                                    Status = Constants.DRAFT_ORDER_STATUS,
                                    AccountId = accts.get(i).Id,
                                    Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID);
            orderList.add(order);
        }
        return orderList;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> constructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> orderItemList = new List<OrderItem>();
        for (Integer i = 0; i < cnt; i++) {
            OrderItem item = new OrderItem();
            item.Quantity = Constants.DEFAULT_ROWS;
            item.PricebookEntryId = pbes.get(i).Id;
            item.Product2Id = pbes.get(i).Product2Id;
            item.OrderId = ords.get(i).Id;
            item.UnitPrice = 250.0;
            orderItemList.add(item);
            }
        return orderItemList;

    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void insertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        insert constructCollaborationGroup();
        List<Product2> products = constructProducts(cnt);
        insert products;
        List<PricebookEntry> entries = constructPricebookEntries(products);
        insert entries;
        List<Account> accounts = constructAccounts(cnt);
        insert accounts;
        insert constructContacts(cnt, accounts);
        List<Order> orders = constructOrders(cnt, accounts);
        insert orders;
        insert constructOrderItems(cnt, entries, orders);
    }

    public static void verifyQuantityOrdered(Product2 originalProduct, 
                                                Product2 updatedProduct, 
                                                Integer qtyOrdered) {

        System.assertEquals(originalProduct.Quantity_Ordered__c + qtyOrdered, updatedProduct.Quantity_Ordered__c);
    }


}