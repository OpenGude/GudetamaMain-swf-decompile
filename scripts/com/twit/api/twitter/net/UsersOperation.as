package com.twit.api.twitter.net
{
   import com.twit.api.twitter.data.TwitterUser;
   import com.twit.api.twitter.data.collections.UsersCollection;
   import flash.events.Event;
   import mx.collections.ArrayCollection;
   
   public class UsersOperation extends TwitterOperation
   {
       
      
      private var followers:Boolean;
      
      private var blocked:Boolean;
      
      public function UsersOperation(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = true, param5:Object = null)
      {
         super(param1,param4,param5);
         this.followers = param2;
         this.blocked = param3;
      }
      
      [Bindable]
      public function set users(param1:ArrayCollection) : void
      {
         data#2 = param1;
      }
      
      public function get users() : ArrayCollection
      {
         return data#2 as ArrayCollection;
      }
      
      override protected function handleResult(param1:Event) : void
      {
         var _loc5_:* = null;
         var _loc3_:* = null;
         var _loc6_:* = null;
         var _loc4_:* = null;
         switch(resultFormat#2)
         {
            case "json":
               _loc5_ = getJSON();
               _loc3_ = [];
               if(_loc5_ is Array || _loc5_["users"])
               {
                  if(_loc5_ is Array)
                  {
                     _loc3_ = _loc5_ as Array;
                     users = new ArrayCollection();
                  }
                  else if(_loc5_["users"])
                  {
                     _loc3_ = _loc5_["users"];
                     users = new UsersCollection();
                     UsersCollection(users).nextCursor = _loc5_["next_cursor_str"];
                     UsersCollection(users).previousCursor = _loc5_["previous_cursor_str"];
                  }
                  for each(var _loc2_ in _loc3_)
                  {
                     (_loc6_ = new TwitterUser(_loc2_)).isFollower = followers;
                     _loc6_.isBlocked = blocked;
                     users.addItem(_loc6_);
                  }
               }
               if(_loc5_["ids"])
               {
                  users = new UsersCollection(_loc5_["ids"]);
                  UsersCollection(users).nextCursor = _loc5_["next_cursor_str"];
                  UsersCollection(users).previousCursor = _loc5_["previous_cursor_str"];
               }
               break;
            case "xml":
               _loc4_ = getXML();
         }
         super.handleResult(param1);
      }
   }
}
