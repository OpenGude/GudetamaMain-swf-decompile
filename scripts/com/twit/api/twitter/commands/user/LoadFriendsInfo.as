package com.twit.api.twitter.commands.user
{
   import com.twit.api.twitter.interfaces.IPagingOperation;
   import com.twit.api.twitter.net.UsersOperation;
   
   public class LoadFriendsInfo extends UsersOperation implements IPagingOperation
   {
      
      protected static const URL:String = "https://api.twitter.com/1.1/friends/list.json";
       
      
      public function LoadFriendsInfo(param1:String = null, param2:String = null, param3:String = "-1", param4:String = "200", param5:Boolean = true, param6:Boolean = true)
      {
         super("https://api.twitter.com/1.1/friends/list.json",false);
         resultFormat#2 = "json";
         method#2 = "GET";
         _requiresAuthentication = true;
         _apiRateLimited = true;
         parameters = {
            "user_id":param1,
            "screen_name":param2,
            "cursor":param3,
            "count":param4,
            "skip_status":param5,
            "include_user_entities":param6
         };
      }
      
      public function get cursor() : String
      {
         return parameters["cursor"];
      }
      
      public function set cursor(param1:String) : void
      {
         if(param1)
         {
            parameters["cursor"] = param1;
         }
         else if(parameters["cursor"])
         {
            delete parameters["cursor"];
         }
      }
   }
}
