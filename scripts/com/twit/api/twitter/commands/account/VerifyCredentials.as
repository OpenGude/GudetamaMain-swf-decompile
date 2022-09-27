package com.twit.api.twitter.commands.account
{
   import com.twit.api.twitter.net.UserOperation;
   
   public class VerifyCredentials extends UserOperation
   {
      
      protected static const URL:String = "https://api.twitter.com/1.1/account/verify_credentials.json";
       
      
      public function VerifyCredentials(param1:Boolean = true, param2:Boolean = false)
      {
         super("https://api.twitter.com/1.1/account/verify_credentials.json");
         resultFormat#2 = "json";
         method#2 = "GET";
         _requiresAuthentication = true;
         _apiRateLimited = false;
         this.parameters = {
            "include_entities":param1,
            "skip_status":param2
         };
      }
   }
}
