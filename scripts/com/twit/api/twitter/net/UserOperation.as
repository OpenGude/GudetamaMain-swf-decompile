package com.twit.api.twitter.net
{
   import com.twit.api.twitter.data.TwitterUser;
   import flash.events.Event;
   
   public class UserOperation extends TwitterOperation
   {
       
      
      public function UserOperation(param1:String, param2:Boolean = true, param3:Object = null)
      {
         super(param1,param2,param3);
      }
      
      [Bindable]
      public function set user#2(param1:TwitterUser) : void
      {
         data#2 = param1;
      }
      
      public function get user#2() : TwitterUser
      {
         return data#2 as TwitterUser;
      }
      
      override protected function handleResult(param1:Event) : void
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         switch(resultFormat#2)
         {
            case "json":
               _loc3_ = getJSON();
               user#2 = new TwitterUser(_loc3_);
               break;
            case "xml":
               _loc2_ = getXML();
               if(_loc2_.name() == "status")
               {
                  user#2 = new TwitterUser(_loc2_);
               }
         }
         super.handleResult(param1);
      }
   }
}
