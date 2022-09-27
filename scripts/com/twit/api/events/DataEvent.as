package com.twit.api.events
{
   import flash.events.Event;
   
   public class DataEvent extends Event
   {
       
      
      public var data#2:Object;
      
      public function DataEvent(param1:String, param2:Object = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.data#2 = param2;
      }
   }
}
