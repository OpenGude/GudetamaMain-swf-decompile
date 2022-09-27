package com.twit.api.twitter.oauth
{
   import com.twit.api.twitter.oauth.events.OAuthTwitterEvent;
   import flash.net.URLRequestHeader;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.http.HTTPService;
   import org.twit.oauth.OAuthConsumer;
   import org.twit.oauth.OAuthRequest;
   import org.twit.oauth.OAuthSignatureMethod_HMAC_SHA1;
   import org.twit.oauth.OAuthToken;
   import starling.events.EventDispatcher;
   
   public class OAuthTwitterConnection extends EventDispatcher
   {
      
      private static const REQUEST_TOKEN_URL:String = "https://api.twitter.com/oauth/request_token";
      
      private static const ACCESS_TOKEN_URL:String = "https://api.twitter.com/oauth/access_token";
      
      private static const AUTHORIZE_URL:String = "https://api.twitter.com/oauth/authorize";
       
      
      public var consumer:OAuthConsumer;
      
      public var requestToken:OAuthToken;
      
      public var accessToken:OAuthToken;
      
      private var _authorized:Boolean = false;
      
      private var signatureMethod:OAuthSignatureMethod_HMAC_SHA1;
      
      private var userId:String;
      
      private var screenName:String;
      
      public function OAuthTwitterConnection()
      {
         consumer = new OAuthConsumer();
         requestToken = new OAuthToken();
         accessToken = new OAuthToken();
         signatureMethod = new OAuthSignatureMethod_HMAC_SHA1();
         super();
      }
      
      public function get authorizeURL() : String
      {
         if(requestToken.key == null || requestToken.key == "")
         {
            return null;
         }
         return "https://api.twitter.com/oauth/authorize?oauth_token=" + requestToken.key;
      }
      
      public function get authorized() : Boolean
      {
         return _authorized;
      }
      
      public function set authorized(param1:Boolean) : void
      {
         _authorized = param1;
      }
      
      public function grantAccess(param1:String) : void
      {
         if(_authorized)
         {
            return;
         }
         getAccessToken(param1);
      }
      
      public function get twitterUserId() : String
      {
         return userId;
      }
      
      public function get twitterScreenName() : String
      {
         return screenName;
      }
      
      public function setConsumer(param1:String, param2:String) : void
      {
         consumer.key = param1;
         consumer.secret = param2;
      }
      
      public function setAccessToken(param1:String, param2:String) : void
      {
         if(_authorized)
         {
            return;
         }
         accessToken.key = param1;
         accessToken.secret = param2;
      }
      
      public function hasAccessToken() : Boolean
      {
         if(accessToken.key && accessToken.key.length > 0 && accessToken.secret && accessToken.secret.length > 0)
         {
            return true;
         }
         return false;
      }
      
      public function setRequestToken(param1:String, param2:String) : void
      {
         requestToken.key = param1;
         requestToken.secret = param2;
      }
      
      public function authorize(param1:String, param2:String, param3:String = null) : void
      {
         if(_authorized)
         {
            return;
         }
         consumer.key = param1;
         consumer.secret = param2;
         var _loc4_:Object = null;
         if(param3)
         {
            _loc4_ = {"oauth_callback":param3};
         }
         getRequestToken(_loc4_);
      }
      
      private function getRequestToken(param1:Object = null) : void
      {
         if(_authorized)
         {
            return;
         }
         var _loc3_:OAuthRequest = new OAuthRequest("GET","https://api.twitter.com/oauth/request_token",param1,consumer);
         var _loc4_:String = _loc3_.buildRequest(signatureMethod);
         var _loc2_:HTTPService = new HTTPService();
         _loc2_.url#2 = _loc4_;
         _loc2_.addEventListener("result",handleRequestToken);
         _loc2_.addEventListener("fault",handleRequestTokenError);
         _loc2_.resultFormat#2 = "text";
         _loc2_.send();
      }
      
      private function handleRequestToken(param1:ResultEvent) : void
      {
         var _loc4_:int = 0;
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc5_:Array = param1.result.toString().split("&");
         _loc4_ = 0;
         while(_loc4_ < _loc5_.length)
         {
            _loc3_ = _loc5_[_loc4_];
            _loc2_ = _loc3_.split("=");
            if(_loc2_.length == 2)
            {
               switch(_loc2_[0])
               {
                  case "oauth_token":
                     requestToken.key = _loc2_[1];
                     break;
                  case "oauth_token_secret":
                     requestToken.secret = _loc2_[1];
               }
            }
            _loc4_++;
         }
         dispatchEvent(new OAuthTwitterEvent("requestTokenReceived",requestToken.key));
      }
      
      private function handleRequestTokenError(param1:FaultEvent) : void
      {
         dispatchEvent(new OAuthTwitterEvent("requestTokenError",param1.fault.message));
      }
      
      private function getAccessToken(param1:String) : void
      {
         if(_authorized)
         {
            return;
         }
         var _loc3_:OAuthRequest = new OAuthRequest("GET","https://api.twitter.com/oauth/access_token",{"oauth_verifier":param1},consumer,requestToken);
         var _loc4_:String = _loc3_.buildRequest(signatureMethod);
         var _loc2_:HTTPService = new HTTPService();
         _loc2_.url#2 = _loc4_;
         _loc2_.addEventListener("result",handleAccessToken);
         _loc2_.addEventListener("fault",handleAccessTokenError);
         _loc2_.resultFormat#2 = "text";
         _loc2_.send();
      }
      
      private function handleAccessToken(param1:ResultEvent) : void
      {
         var _loc4_:int = 0;
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc5_:Array = param1.result.toString().split("&");
         _loc4_ = 0;
         while(_loc4_ < _loc5_.length)
         {
            _loc3_ = _loc5_[_loc4_];
            _loc2_ = _loc3_.split("=");
            if(_loc2_.length == 2)
            {
               switch(_loc2_[0])
               {
                  case "oauth_token":
                     accessToken.key = _loc2_[1];
                     break;
                  case "oauth_token_secret":
                     accessToken.secret = _loc2_[1];
                     break;
                  case "user_id":
                     userId = _loc2_[1];
                     break;
                  case "screen_name":
                     screenName = _loc2_[1];
               }
            }
            _loc4_++;
         }
         _authorized = true;
         dispatchEvent(new OAuthTwitterEvent("authorized"));
      }
      
      private function handleAccessTokenError(param1:FaultEvent) : void
      {
         dispatchEvent(new OAuthTwitterEvent("accessTokenError",param1.fault.message));
      }
      
      public function createOAuthHeader(param1:String, param2:String, param3:Object = null) : URLRequestHeader
      {
         var _loc5_:OAuthRequest;
         return (_loc5_ = new OAuthRequest(param1,param2,param3,consumer,accessToken)).buildRequest(signatureMethod,"header",param2) as URLRequestHeader;
      }
      
      public function resetOAuthParam() : void
      {
         consumer = new OAuthConsumer();
         accessToken = new OAuthToken();
         requestToken = new OAuthToken();
      }
   }
}
