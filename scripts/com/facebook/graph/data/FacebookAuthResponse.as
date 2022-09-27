package com.facebook.graph.data
{
   public class FacebookAuthResponse
   {
       
      
      public var uid:String;
      
      public var expireDate:Date;
      
      public var accessToken:String;
      
      public var signedRequest:String;
      
      public function FacebookAuthResponse()
      {
         super();
      }
      
      public function fromJSON(param1:Object) : void
      {
         if(param1 != null)
         {
            expireDate = new Date();
            expireDate.setTime(expireDate.time + param1.expiresIn * 1000);
            accessToken = param1.access_token || param1.accessToken;
            signedRequest = param1.signedRequest;
            uid = param1.userID;
         }
      }
      
      public function toString() : String
      {
         return "[userId:" + uid + "]";
      }
   }
}
