package com.facebook.graph.windows
{
   import com.facebook.graph.core.FacebookURLDefaults;
   import com.facebook.graph.utils.FacebookDataUtils;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.media.StageWebView;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   
   public class MobileLoginWindow extends Sprite
   {
       
      
      protected var loginRequest:URLRequest;
      
      protected var userClosedWindow:Boolean = true;
      
      private var webView:StageWebView;
      
      public var loginCallback:Function;
      
      private var showWebCallback:Function;
      
      public function MobileLoginWindow(param1:Function, param2:Function)
      {
         this.loginCallback = param1;
         this.showWebCallback = param2;
         super();
      }
      
      public function open(param1:String, param2:StageWebView, param3:Array = null, param4:String = "touch") : void
      {
         this.webView = param2;
         loginRequest = new URLRequest();
         loginRequest.method#2 = "GET";
         loginRequest.url#2 = FacebookURLDefaults.AUTH_URL + "?" + formatData(param1,param4,param3);
         showWindow(loginRequest);
      }
      
      protected function showWindow(param1:URLRequest) : void
      {
         webView.addEventListener("complete",handleLocationChange,false,0,true);
         webView.addEventListener("locationChange",handleLocationChange,false,0,true);
         webView.loadURL(param1.url#2);
      }
      
      protected function formatData(param1:String, param2:String, param3:Array = null) : URLVariables
      {
         var _loc4_:URLVariables;
         (_loc4_ = new URLVariables()).client_id = param1;
         _loc4_.redirect_uri = FacebookURLDefaults.LOGIN_SUCCESS_URL;
         _loc4_.display = param2;
         _loc4_.type = "user_agent";
         if(param3 != null)
         {
            _loc4_.scope = param3.join(",");
         }
         return _loc4_;
      }
      
      protected function handleLocationChange(param1:Event) : void
      {
         var _loc2_:String = webView.location#2;
         if(_loc2_.indexOf(FacebookURLDefaults.LOGIN_FAIL_URL) == 0 || _loc2_.indexOf(FacebookURLDefaults.LOGIN_FAIL_SECUREURL) == 0)
         {
            webView.removeEventListener("complete",handleLocationChange);
            webView.removeEventListener("locationChange",handleLocationChange);
            loginCallback(null,FacebookDataUtils.getURLVariables(_loc2_).error_reason);
            userClosedWindow = false;
            webView.dispose();
            webView = null;
         }
         else if(_loc2_.indexOf(FacebookURLDefaults.LOGIN_SUCCESS_URL) == 0 || _loc2_.indexOf(FacebookURLDefaults.LOGIN_SUCCESS_SECUREURL) == 0)
         {
            webView.removeEventListener("complete",handleLocationChange);
            webView.removeEventListener("locationChange",handleLocationChange);
            loginCallback(FacebookDataUtils.getURLVariables(_loc2_),null);
            userClosedWindow = false;
            webView.dispose();
            webView = null;
         }
         else if(_loc2_.indexOf(FacebookURLDefaults.AUTH_URL) != 0)
         {
            if(showWebCallback)
            {
               showWebCallback(true);
               showWebCallback = null;
            }
         }
      }
   }
}
