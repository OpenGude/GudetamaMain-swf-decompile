package gudetama.extensions
{
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.system.Capabilities;
   
   public class QnqNativeExtension extends EventDispatcher
   {
      
      public static const IADPOSITION_PORTRAIT_TOP:int = 0;
      
      public static const IADPOSITION_PORTRAIT_BOTTOM:int = 1;
      
      public static const IADPOSITION_LANDSCAPE_TOP:int = 2;
      
      public static const IADPOSITION_LANDSCAPE_BOTTOM:int = 3;
       
      
      private var context:ExtensionContext;
      
      private var iapCallback:Function;
      
      private var iadCallback:Function;
      
      private var ndbCallback:Function;
      
      private var logCallback:Function;
      
      public function QnqNativeExtension()
      {
         super();
         context = ExtensionContext.createExtensionContext("ccnative.ane","");
         context.addEventListener("status",onStatus);
      }
      
      public function getIdfv() : String
      {
         return context.call("getUIID") as String;
      }
      
      public function setupNDBCallback(param1:Function) : void
      {
         this.ndbCallback = param1;
      }
      
      public function setupLogCallback(param1:Function) : void
      {
         this.logCallback = param1;
      }
      
      public function showNativeDialog(param1:String, param2:String, param3:String, param4:String = null, param5:String = null) : Boolean
      {
         if(param5 != null)
         {
            return context.call("showNativeDialog",param1,param2,param3,param4,param5) as Boolean;
         }
         if(param4 != null)
         {
            return context.call("showNativeDialog",param1,param2,param3,param4) as Boolean;
         }
         return context.call("showNativeDialog",param1,param2,param3) as Boolean;
      }
      
      public function isNetworkAvailable() : Boolean
      {
         return true;
      }
      
      public function setupIAPCallback(param1:Function) : void
      {
         this.iapCallback = param1;
      }
      
      public function isIAPEnabled() : Boolean
      {
         return context.call("isIAPEnabled") as Boolean;
      }
      
      public function beginAppPurchase(param1:String) : Boolean
      {
         return context.call("beginAppPurchase",param1) as Boolean;
      }
      
      public function finishAppPurchase() : void
      {
         context.call("finishAppPurchase");
      }
      
      public function requestPriceList(param1:Array) : int
      {
         return context.call("getPriceList",param1) as int;
      }
      
      public function finishPriceList() : void
      {
         context.call("finishPriceList");
      }
      
      public function getAppPurchaseReceipt() : Object
      {
         return context.call("getAppPurchaseReceipt");
      }
      
      public function setupIADCallback(param1:Function) : void
      {
         this.iadCallback = param1;
      }
      
      public function createAdBanner(param1:int) : void
      {
         context.call("createAdBanner",param1);
      }
      
      public function showAdBanner() : void
      {
         context.call("showAdBanner");
      }
      
      public function hideAdBanner() : void
      {
         context.call("hideAdBanner");
      }
      
      public function removeAdBanner() : void
      {
         context.call("removeAdBanner");
      }
      
      public function getMacAddress() : String
      {
         return context.call("getMacAddress") as String;
      }
      
      public function dispose() : void
      {
         context.dispose();
      }
      
      public function get isAndroidOS() : Boolean
      {
         return Capabilities.manufacturer.indexOf("Android") > -1;
      }
      
      public function onStatus(param1:StatusEvent) : void
      {
         var _loc2_:String = param1.code.substr(0,3);
         if(_loc2_ == "iad" && iadCallback != null)
         {
            iadCallback(param1.code,param1.level);
         }
         else if(_loc2_ == "iap" && iapCallback != null)
         {
            iapCallback(param1.code,param1.level);
         }
         else if(_loc2_ == "ndb" && ndbCallback != null)
         {
            ndbCallback(param1.code,param1.level);
         }
         else if(_loc2_ == "log" && logCallback != null)
         {
            logCallback(param1.code,param1.level);
         }
      }
      
      public function setupAppPurchase() : void
      {
         context.call("setupAppPurchase");
      }
   }
}
