package org.twit.oauth
{
   public interface IOAuthSignatureMethod
   {
       
      
      function get name() : String;
      
      function signRequest(param1:OAuthRequest) : String;
   }
}
