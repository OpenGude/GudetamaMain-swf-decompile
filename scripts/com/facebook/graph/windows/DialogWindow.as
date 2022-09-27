package com.facebook.graph.windows
{
   import com.facebook.graph.core.FacebookURLDefaults;
   import com.facebook.graph.utils.FacebookDataUtils;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.media.StageWebView;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.utils.describeType;
   
   public class DialogWindow extends Sprite
   {
       
      
      protected var request:URLRequest;
      
      protected var userClosedWindow:Boolean = true;
      
      private var webView:StageWebView;
      
      public var callback:Function;
      
      public function DialogWindow(param1:Function)
      {
         this.callback = param1;
         super();
      }
      
      public function open(param1:String, param2:String, param3:StageWebView, param4:*) : void
      {
         this.webView = param3;
         request = new URLRequest();
         request.method#2 = "GET";
         request.url#2 = FacebookURLDefaults.DIALOG_URL + param1 + "?" + formatData(param2,"touch",param4);
         showWindow(request);
      }
      
      protected function showWindow(param1:URLRequest) : void
      {
         webView.addEventListener("complete",handleLocationChange,false,0,true);
         webView.addEventListener("locationChange",handleLocationChange,false,0,true);
         webView.loadURL(param1.url#2);
      }
      
      protected function formatData(param1:String, param2:String, param3:*) : URLVariables
      {
         var _loc4_:URLVariables;
         (_loc4_ = toUrlVariables(param3)).app_id = param1;
         _loc4_.redirect_uri = FacebookURLDefaults.LOGIN_SUCCESS_URL;
         _loc4_.display = param2;
         return _loc4_;
      }
      
      private function toUrlVariables(param1:*) : URLVariables
      {
         var _loc6_:* = null;
         var _loc4_:URLVariables = new URLVariables();
         var _loc5_:XML = describeType(param1);
         for each(var _loc2_ in _loc5_.variable)
         {
            _loc6_ = _loc2_.@name;
            if(null != param1[_loc6_])
            {
               _loc4_[_loc6_] = param1[_loc6_];
            }
         }
         for(var _loc3_ in param1)
         {
            if(null != param1[_loc3_])
            {
               _loc4_[_loc3_] = param1[_loc3_];
            }
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
            userClosedWindow = false;
            webView.dispose();
            webView = null;
            callback(null,FacebookDataUtils.getURLVariables(_loc2_).error_reason);
         }
         else if(_loc2_.indexOf(FacebookURLDefaults.LOGIN_SUCCESS_URL) == 0 || _loc2_.indexOf(FacebookURLDefaults.LOGIN_SUCCESS_SECUREURL) == 0)
         {
            webView.removeEventListener("complete",handleLocationChange);
            webView.removeEventListener("locationChange",handleLocationChange);
            userClosedWindow = false;
            webView.dispose();
            webView = null;
            callback(FacebookDataUtils.getURLVariables(_loc2_),null);
         }
      }
   }
}
