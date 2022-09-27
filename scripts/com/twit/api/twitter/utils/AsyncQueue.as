package com.twit.api.twitter.utils
{
   import com.twit.api.twitter.interfaces.ITwitterOperation;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import mx.collections.ArrayCollection;
   import mx.collections.Sort;
   
   public class AsyncQueue
   {
       
      
      protected var operationsQueue:ArrayCollection;
      
      protected var currentOperation:ITwitterOperation;
      
      protected var priorities:Dictionary;
      
      public function AsyncQueue()
      {
         super();
         operationsQueue = new ArrayCollection();
         priorities = new Dictionary();
         var sort:Sort = new Sort();
         sort.compareFunction = function(param1:Object, param2:Object, param3:Array = null):int
         {
            var _loc4_:Object = priorities[param1];
            var _loc5_:Object = priorities[param2];
            var _loc6_:int = _loc4_ != null ? int(_loc4_) : -1;
            var _loc7_:int = _loc5_ != null ? int(_loc5_) : -1;
            if(_loc6_ == -1 && _loc7_ == -1)
            {
               return 0;
            }
            if(_loc6_ == -1)
            {
               return 1;
            }
            if(_loc7_ == -1)
            {
               return -1;
            }
            if(_loc6_ > _loc7_)
            {
               return -1;
            }
            if(_loc6_ < _loc7_)
            {
               return 1;
            }
            return 0;
         };
         operationsQueue.sort = sort;
         operationsQueue.refresh();
      }
      
      public function executeOperation(param1:ITwitterOperation, param2:int = 5) : void
      {
         if(!param1)
         {
            return;
         }
         operationsQueue.addItem(param1);
         priorities[param1] = param2;
         operationsQueue.refresh();
         if(!currentOperation)
         {
            executeNextOperation();
         }
      }
      
      protected function executeNextOperation() : void
      {
         if(operationsQueue.length > 0)
         {
            currentOperation = operationsQueue.removeItemAt(0) as ITwitterOperation;
            delete priorities[currentOperation];
            currentOperation.addEventListener("complete",handleOperationComplete);
            currentOperation.execute();
         }
      }
      
      protected function handleOperationComplete(param1:Event) : void
      {
         currentOperation.removeEventListener("complete",handleOperationComplete);
         currentOperation = null;
         executeNextOperation();
      }
   }
}
