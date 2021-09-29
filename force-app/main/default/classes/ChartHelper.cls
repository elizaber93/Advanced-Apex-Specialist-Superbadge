public without sharing class ChartHelper {

    @AuraEnabled
    public static List<ChartData> getInventory(){
        List<chartData> cht = new List<chartData>();
        //ToDo: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
        //  And return a list of chartData
        //  Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
        AggregateResult[] groupedResults = [SELECT  Family, 
                                                    SUM(Quantity_Remaining__c)quantity 
                                            FROM Product2 
                                            WHERE isActive = true 
                                            WITH SECURITY_ENFORCED
                                            GROUP BY Family];
        for (AggregateResult res :groupedResults) {
            cht.add(new ChartData(String.valueOf(res.get('Family')), (Decimal)res.get('quantity')));
        }
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}