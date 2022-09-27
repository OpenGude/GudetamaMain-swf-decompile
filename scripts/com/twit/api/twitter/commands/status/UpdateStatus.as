package com.twit.api.twitter.commands.status
{
   import com.twit.api.twitter.net.StatusesOperation;
   
   public class UpdateStatus extends StatusesOperation
   {
      
      protected static const URL:String = "https://api.twitter.com/1.1/statuses/update.json";
       
      
      public function UpdateStatus(param1:String, param2:String = null)
      {
         super("https://api.twitter.com/1.1/statuses/update.json");
         resultFormat#2 = "json";
         method#2 = "POST";
         _requiresAuthentication = true;
         _apiRateLimited = false;
         param1 = param1.replace(/\r\n/g," ");
         param1 = param1.replace(/\n/g," ");
         param1 = param1.replace(/\r/g," ");
         parameters = {
            "status":param1,
            "in_reply_to_status_id":param2
         };
      }
   }
}
