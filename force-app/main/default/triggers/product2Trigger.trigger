/**
 * @name product2Trigger
 * @description Trigger to notify staff of low levels of inventory
**/
trigger product2Trigger on Product2 (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (Trigger.isUpdate && Trigger.isAfter) {
        Product2Helper.afterUpdate(Trigger.New, Trigger.Old);
    }
}