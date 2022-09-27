package com.twit.api.twitter.net
{
   import com.twit.api.twitter.data.TwitterStatus;
   import flash.events.Event;
   
   public class StatusesOperation extends TwitterOperation
   {
       
      
      private var isMention:Boolean = false;
      
      public function StatusesOperation(param1:String, param2:Boolean = true, param3:Object = null, param4:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      [Bindable]
      public function get status#2() : TwitterStatus
      {
         return data#2 as TwitterStatus;
      }
      
      public function set status#2(param1:TwitterStatus) : void
      {
         data#2 = param1;
      }
      
      override protected function handleResult(param1:Event) : void
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         switch(resultFormat#2)
         {
            case "json":
               _loc3_ = getJSON();
               status#2 = new TwitterStatus(_loc3_);
               break;
            case "xml":
               _loc2_ = getXML();
               if(_loc2_.name() == "status")
               {
                  status#2 = new TwitterStatus(_loc2_);
               }
         }
         super.handleResult(param1);
      }
   }
}
