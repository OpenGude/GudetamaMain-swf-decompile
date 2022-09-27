package com.twit.api
{
   import com.twit.api.interfaces.IOperation;
   import flash.events.EventDispatcher;
   import mx.rpc.IResponder;
   
   public class Operation extends EventDispatcher implements IResponder, IOperation
   {
       
      
      public function Operation()
      {
         super();
      }
      
      public function execute() : void
      {
      }
      
      public function result(param1:Object) : void
      {
      }
      
      public function fault(param1:Object) : void
      {
      }
   }
}
