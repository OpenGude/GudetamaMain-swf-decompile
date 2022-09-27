package org.twit.oauth
{
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.hash.HMAC;
   import com.hurlant.util.Base64;
   import com.hurlant.util.Hex;
   import com.twit.utils.URLUtil;
   import flash.utils.ByteArray;
   
   public class OAuthSignatureMethod_HMAC_SHA1 implements IOAuthSignatureMethod
   {
       
      
      public function OAuthSignatureMethod_HMAC_SHA1()
      {
         super();
      }
      
      public function get name#2() : String
      {
         return "HMAC-SHA1";
      }
      
      public function signRequest(param1:OAuthRequest) : String
      {
         var _loc5_:String = param1.getSignableString();
         var _loc6_:String = URLUtil.encode(param1.consumer.secret) + "&";
         if(param1.token)
         {
            _loc6_ += URLUtil.encode(param1.token.secret);
         }
         var _loc4_:HMAC = Crypto.getHMAC("sha1");
         var _loc8_:ByteArray = Hex.toArray(Hex.fromString(_loc6_));
         var _loc7_:ByteArray = Hex.toArray(Hex.fromString(_loc5_));
         var _loc2_:ByteArray = _loc4_.compute(_loc8_,_loc7_);
         return Base64.encodeByteArray(_loc2_);
      }
   }
}
