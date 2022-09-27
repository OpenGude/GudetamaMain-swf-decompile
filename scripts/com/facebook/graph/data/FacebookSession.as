package com.facebook.graph.data
{
   public class FacebookSession
   {
       
      
      public var uid:String;
      
      public var user#2:Object;
      
      public var sessionKey:String;
      
      public var expireDate:Date;
      
      public var accessToken:String;
      
      public var secret:String;
      
      public var sig:String;
      
      public var availablePermissions:Array;
      
      public function FacebookSession()
      {
         super();
      }
      
      public function fromJSON(param1:Object) : void
      {
         if(param1 != null)
         {
            sessionKey = param1.session_key;
            expireDate = new Date(param1.expires);
            accessToken = param1.access_token;
            secret = param1.secret;
            sig = param1.sig;
            uid = param1.uid;
         }
      }
      
      public function toString() : String
      {
         return "[userId:" + uid + "]";
      }
   }
}
