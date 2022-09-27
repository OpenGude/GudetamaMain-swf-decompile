package org.twit.oauth
{
   import com.twit.utils.URLUtil;
   import flash.net.URLRequestHeader;
   import mx.utils.UIDUtil;
   
   public class OAuthRequest
   {
      
      public static const HTTP_METHOD_HEAD:String = "HEAD";
      
      public static const HTTP_METHOD_GET:String = "GET";
      
      public static const HTTP_METHOD_POST:String = "POST";
      
      public static const RESULT_TYPE_URL_STRING:String = "url";
      
      public static const RESULT_TYPE_POST:String = "post";
      
      public static const RESULT_TYPE_HEADER:String = "header";
       
      
      private var _httpMethod:String;
      
      private var _requestURL:String;
      
      private var _requestParams:Object;
      
      private var _consumer:OAuthConsumer;
      
      private var _token:OAuthToken;
      
      public function OAuthRequest(param1:String, param2:String, param3:Object = null, param4:OAuthConsumer = null, param5:OAuthToken = null)
      {
         super();
         _httpMethod = param1;
         _requestURL = param2;
         if(!param3)
         {
            param3 = {};
         }
         _requestParams = param3;
         _consumer = param4;
         _token = param5;
      }
      
      public function get httpMethod() : String
      {
         return _httpMethod;
      }
      
      public function set httpMethod(param1:String) : void
      {
         if(param1 != _httpMethod)
         {
            _httpMethod = param1;
         }
      }
      
      public function get requestURL() : String
      {
         return _requestURL;
      }
      
      public function set requestURL(param1:String) : void
      {
         if(param1 != _requestURL)
         {
            _requestURL = param1;
         }
      }
      
      public function get requestParams() : Object
      {
         return _requestParams;
      }
      
      public function set requestParams(param1:Object) : void
      {
         if(param1 != _requestParams)
         {
            _requestParams = param1;
         }
      }
      
      public function get consumer() : OAuthConsumer
      {
         return _consumer;
      }
      
      public function set consumer(param1:OAuthConsumer) : void
      {
         _consumer = param1;
      }
      
      public function get token() : OAuthToken
      {
         return _token;
      }
      
      public function set token(param1:OAuthToken) : void
      {
         _token = param1;
      }
      
      public function buildRequest(param1:IOAuthSignatureMethod, param2:String = "url", param3:String = "") : *
      {
         var _loc4_:* = false;
         var _loc7_:* = null;
         var _loc9_:* = null;
         var _loc5_:* = null;
         var _loc10_:* = null;
         var _loc11_:Date = new Date();
         var _loc12_:String = UIDUtil.getUID(_loc11_);
         _requestParams["oauth_nonce"] = _loc12_;
         _requestParams["oauth_timestamp"] = String(_loc11_.time).substring(0,10);
         _requestParams["oauth_consumer_key"] = _consumer.key;
         _requestParams["oauth_signature_method"] = param1.name;
         if(_token)
         {
            _requestParams["oauth_token"] = _token.key;
         }
         else if(_requestParams.hasOwnProperty("oauth_token"))
         {
            _loc4_ = delete _requestParams.oauth_token;
         }
         var _loc6_:String = param1.signRequest(this);
         _requestParams["oauth_signature"] = _loc6_;
         switch(param2)
         {
            case "url":
               return _requestURL + "?" + getParameters();
            case "post":
               return getParameters();
            case "header":
               _loc5_ = "";
               if(param3.length > 0)
               {
                  _loc5_ += "realm=\"" + param3 + "\"";
               }
               for(var _loc8_ in _requestParams)
               {
                  if(_loc8_.toString().indexOf("oauth") == 0)
                  {
                     _loc5_ += "," + _loc8_ + "=\"" + URLUtil.encode(_requestParams[_loc8_]) + "\"";
                  }
               }
               if(_loc5_.charAt(0) == ",")
               {
                  _loc5_ = "OAuth " + _loc5_.substr(1);
               }
               else
               {
                  _loc5_ = "OAuth " + _loc5_;
               }
               return new URLRequestHeader("Authorization",_loc5_);
            default:
               return;
         }
      }
      
      private function getSignableParameters() : String
      {
         var _loc2_:Array = [];
         for(var _loc1_ in _requestParams)
         {
            if(_loc1_ != "oauth_signature")
            {
               _loc2_.push(_loc1_ + "=" + URLUtil.encode(_requestParams[_loc1_].toString()));
            }
         }
         _loc2_.sort();
         return _loc2_.join("&");
      }
      
      private function getParameters() : String
      {
         var _loc2_:Array = [];
         for(var _loc1_ in _requestParams)
         {
            _loc2_.push(_loc1_ + "=" + URLUtil.encode(_requestParams[_loc1_].toString()));
         }
         _loc2_.sort();
         return _loc2_.join("&");
      }
      
      public function getSignableString() : String
      {
         var _loc1_:String = URLUtil.encode(_httpMethod.toUpperCase());
         _loc1_ += "&";
         _loc1_ += URLUtil.encode(_requestURL);
         _loc1_ += "&";
         return _loc1_ + URLUtil.encode(getSignableParameters());
      }
   }
}
