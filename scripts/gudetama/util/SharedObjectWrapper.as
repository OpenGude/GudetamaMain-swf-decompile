package gudetama.util
{
   import flash.events.NetStatusEvent;
   import flash.net.SharedObject;
   import gudetama.engine.Logger;
   
   public class SharedObjectWrapper
   {
      
      protected static var SUCCESS:uint = 0;
      
      protected static var PENDING:uint = 1;
      
      protected static var ERROR:uint = 2;
       
      
      public var data#2:Object;
      
      public var name#2:String;
      
      protected var _sharedObject:SharedObject;
      
      protected var _onComplete:Function;
      
      protected var _closeRequested:Boolean;
      
      public function SharedObjectWrapper()
      {
         super();
      }
      
      public function destroy() : void
      {
         _sharedObject = null;
         name#2 = null;
         data#2 = null;
         _onComplete = null;
         _closeRequested = false;
      }
      
      public function bind(param1:String) : Boolean
      {
         destroy();
         name#2 = param1;
         try
         {
            _sharedObject = SharedObject.getLocal(name#2);
         }
         catch(e:Error)
         {
            Logger.warn("SharedObject bind error",e.getStackTrace());
            destroy();
            return false;
         }
         data#2 = _sharedObject.data#2;
         return true;
      }
      
      public function close(param1:uint = 0, param2:Function = null) : Boolean
      {
         _closeRequested = true;
         return flush(param1,param2);
      }
      
      public function flush(param1:uint = 0, param2:Function = null) : Boolean
      {
         if(!checkBinding())
         {
            return false;
         }
         _onComplete = param2;
         var _loc3_:String = null;
         try
         {
            _loc3_ = _sharedObject.flush(param1);
         }
         catch(e:Error)
         {
            return onDone(ERROR);
         }
         if(_loc3_ == "pending")
         {
            _sharedObject.addEventListener("netStatus",onFlushStatus);
         }
         return onDone(_loc3_ == "flushed" ? SUCCESS : uint(PENDING));
      }
      
      public function erase() : Boolean
      {
         if(!checkBinding())
         {
            return false;
         }
         _sharedObject.clear();
         return true;
      }
      
      protected function onFlushStatus(param1:NetStatusEvent) : void
      {
         _sharedObject.removeEventListener("netStatus",onFlushStatus);
         onDone(param1.info.code == "SharedObject.Flush.Success" ? SUCCESS : uint(ERROR));
      }
      
      protected function onDone(param1:uint) : Boolean
      {
         switch(param1)
         {
            case PENDING:
               break;
            case ERROR:
         }
         if(_onComplete != null)
         {
            _onComplete(param1 == SUCCESS);
         }
         if(_closeRequested)
         {
            destroy();
         }
         return param1 == SUCCESS;
      }
      
      protected function checkBinding() : Boolean
      {
         if(_sharedObject == null)
         {
            return false;
         }
         return true;
      }
   }
}
