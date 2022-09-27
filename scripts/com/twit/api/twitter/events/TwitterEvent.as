package com.twit.api.twitter.events
{
   import com.twit.api.events.DataEvent;
   
   public class TwitterEvent extends DataEvent
   {
      
      public static const COMPLETE:String = "complete";
       
      
      public var success:Boolean;
      
      public function TwitterEvent(param1:String, param2:Object = null, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param2,param4,param5);
         this.success = param3;
      }
   }
}
