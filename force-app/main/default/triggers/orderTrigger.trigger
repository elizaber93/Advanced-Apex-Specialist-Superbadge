/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after update) {
    OrderHelper.afterUpdate(Trigger.New, Trigger.OldMap);   
}