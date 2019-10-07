/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after Update) {
    if ( Trigger.New != null ){
         OrderHelper.AfterUpdate(Trigger.new, Trigger.old);  
    }
}