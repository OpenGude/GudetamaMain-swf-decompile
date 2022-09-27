package org.twit.oauth
{
   public class OAuthToken
   {
       
      
      private var _key:String;
      
      private var _secret:String;
      
      public function OAuthToken(param1:String = "", param2:String = "")
      {
         super();
         _key = param1;
         _secret = param2;
      }
      
      public function get key() : String
      {
         return _key;
      }
      
      public function set key(param1:String) : void
      {
         if(param1 != _key)
         {
            _key = param1;
         }
      }
      
      public function get secret() : String
      {
         return _secret;
      }
      
      public function set secret(param1:String) : void
      {
         if(param1 != _secret)
         {
            _secret = param1;
         }
      }
      
      public function get isEmpty() : Boolean
      {
         if(key.length == 0 && secret.length == 0)
         {
            return true;
         }
         return false;
      }
      
      public function toString() : String
      {
         return " _key : " + _key + " , _secret " + _secret;
      }
   }
}
