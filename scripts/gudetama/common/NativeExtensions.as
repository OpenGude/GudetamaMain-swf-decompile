package gudetama.common
{
   import flash.utils.getDefinitionByName;
   import gudetama.data.GameSetting;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.extensions.ARExtension;
   import gudetama.extensions.AndroidBillingExtensions;
   import gudetama.extensions.AppsFlyerExtensions;
   import gudetama.extensions.PushNotificationContext;
   import gudetama.extensions.QnqNativeExtension;
   import gudetama.extensions.ShareExtension;
   import muku.core.TaskQueue;
   
   public class NativeExtensions
   {
      
      public static const ANE_MOBILE:Boolean = true;
      
      private static var ext;
      
      private static var billing;
      
      private static var onStoreBilling;
      
      private static var arExt;
      
      private static var shareExt;
      
      private static var appsFlyer;
      
      private static var PushContext;
      
      private static var systemContext;
      
      {
         try
         {
            QnqNativeExtension;
            ext = new Class(getDefinitionByName("gudetama.extensions.QnqNativeExtension"))();
            if(ext)
            {
               ext.setupLogCallback(warn);
            }
         }
         catch(e:Error)
         {
            trace("CCNativeExtension couldn\'t initialize: " + e);
         }
         try
         {
            ARExtension;
            arExt = new Class(getDefinitionByName("gudetama.extensions.ARExtension"))();
            arExt.setDebugMode(true);
         }
         catch(e:Error)
         {
            trace("ARExtension couldn\'t initialize: " + e);
         }
         try
         {
            ShareExtension;
            shareExt = new Class(getDefinitionByName("gudetama.extensions.ShareExtension"))();
            shareExt.logEnabled = true;
         }
         catch(e:Error)
         {
            trace("ShareExtension couldn\'t initialize: " + e);
         }
         try
         {
            AppsFlyerExtensions;
            appsFlyer = Class(getDefinitionByName("gudetama.extensions.AppsFlyerExtensions"));
         }
         catch(e:Error)
         {
            trace("AppsFlyerExtensions couldn\'t initialize: " + e);
         }
         try
         {
            PushNotificationContext;
            PushContext = Class(getDefinitionByName("gudetama.extensions.PushNotificationContext"));
         }
         catch(e:Error)
         {
            trace("PushContext couldn\'t initialize: " + e);
         }
      }
      
      public function NativeExtensions()
      {
         super();
      }
      
      public static function setup() : void
      {
         if(PushContext)
         {
            PushContext.setup();
         }
         if(appsFlyer != null)
         {
            var _loc1_:* = Engine;
            if(gudetama.engine.Engine.platform == 0)
            {
               appsFlyer.setup("b8HJs3kgfcc25pDMsgXq9d","1347085394");
            }
            else
            {
               var _loc2_:* = Engine;
               if(gudetama.engine.Engine.platform == 1)
               {
                  appsFlyer.setup("b8HJs3kgfcc25pDMsgXq9d",null);
               }
            }
         }
         if(systemContext != null)
         {
            systemContext.setup();
         }
         if(onStoreBilling != null)
         {
            onStoreBilling.setup();
         }
      }
      
      public static function adsSetup(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         VideoAdvertisingManager.setup(function():void
         {
         });
         BannerAdvertisingManager.setup(function():void
         {
         });
         InterstitialAdvertisingManager.setup(queue,function():void
         {
         });
         OfferwallAdvertisingManager.setup(function():void
         {
         });
      }
      
      public static function prepareAndroidBilling() : void
      {
         if(billing == null)
         {
            try
            {
               AndroidBillingExtensions;
               billing = new Class(getDefinitionByName("gudetama.extensions.AndroidBillingExtensions"))();
            }
            catch(e:Error)
            {
               trace("AndroidBillingExtensions couldn\'t initialize: " + e);
            }
         }
      }
      
      public static function get AR() : *
      {
         return arExt;
      }
      
      public static function get Share() : *
      {
         return shareExt;
      }
      
      public static function getAppsFlyerUid() : String
      {
         if(appsFlyer == null)
         {
            return null;
         }
         return appsFlyer.getAppsFlyerUid();
      }
      
      public static function isEnableBannerByPlatformVersion(param1:String) : Boolean
      {
         var _loc2_:* = null;
         if(systemContext == null)
         {
            return true;
         }
         var _loc3_:* = Engine;
         if(gudetama.engine.Engine.platform == 1)
         {
            _loc2_ = "android_" + systemContext.getPlatformVersion();
         }
         else
         {
            _loc2_ = systemContext.getPlatformVersion();
         }
         return GameSetting.isEnableBannerByPlatformVersion(_loc2_,param1);
      }
      
      public static function getNativeIdfv(param1:Function) : void
      {
         var _loc2_:* = Engine;
         if(gudetama.engine.Engine.platform == 0 && ext != null)
         {
            param1(ext.getIdfv());
         }
         else
         {
            var _loc3_:* = Engine;
            if(gudetama.engine.Engine.platform == 1 && PushContext != null)
            {
               getAdvertisingId(param1);
            }
            else
            {
               param1("000000000000000000000000000000000000");
            }
         }
      }
      
      public static function trackEvent(param1:String, param2:String) : void
      {
         if(appsFlyer == null)
         {
            return;
         }
         appsFlyer.trackEvent(param1,param2);
      }
      
      public static function registerPushNotificationForAndroid(param1:Function) : void
      {
         if(PushContext == null)
         {
            param1("");
            return;
         }
         PushContext.register(param1);
      }
      
      public static function setKeepScreenFlag(param1:Boolean) : void
      {
         if(PushContext == null)
         {
            return;
         }
         var _loc2_:* = Engine;
         if(gudetama.engine.Engine.platform != 1)
         {
            return;
         }
         PushContext.setKeepScreenFlag(param1);
      }
      
      public static function getAdvertisingId(param1:Function) : void
      {
         var _loc2_:* = Engine;
         if(gudetama.engine.Engine.platform != 1)
         {
            return;
         }
         PushContext.getAdvertisingId(param1);
      }
      
      public static function purchase(param1:String, param2:Function) : int
      {
         var pid:String = param1;
         var callback:Function = param2;
         var isOneStore:Boolean = false;
         if(isOneStore)
         {
            purchaseOneStore(pid,function(param1:Boolean, param2:String):void
            {
               if(param1)
               {
                  callback(0,param2);
               }
               else
               {
                  callback(-3,param2);
               }
            });
         }
         else if(billing != null)
         {
            billing.setupPurchaseCallback(function(param1:String, param2:String, param3:String = ""):void
            {
               if(param1 == "iap_purchaseSucceeded")
               {
                  callback(0,param2,param3);
                  consume(pid);
               }
               else
               {
                  callback(-3,param2,param3);
               }
            });
            var result:Boolean = billing.beginAppPurchase(pid);
            if(!result)
            {
               return -4;
            }
         }
         else
         {
            if(ext == null)
            {
               return -1;
            }
            if(!ext.isIAPEnabled())
            {
               return -2;
            }
            ext.setupIAPCallback(function(param1:String, param2:String):void
            {
               callback(param1 == "iap_purchaseSucceeded" ? 0 : -3,ext.getAppPurchaseReceipt());
               ext.finishAppPurchase();
            });
            result = ext.beginAppPurchase(pid);
            if(!result)
            {
               return -4;
            }
         }
         return 0;
      }
      
      public static function getInventory(param1:Function) : void
      {
         if(billing != null)
         {
            billing.setupInventoryCallback(param1);
         }
         else
         {
            param1(null);
         }
      }
      
      public static function resetInventory() : void
      {
         if(billing != null)
         {
            billing.setupInventoryCallback(null);
         }
      }
      
      private static function dummy(param1:int) : void
      {
      }
      
      public static function consume(param1:String) : void
      {
         if(billing != null)
         {
            billing.consumeItem(param1);
         }
      }
      
      public static function details() : void
      {
         if(billing != null)
         {
            billing.loadItemDetails();
         }
      }
      
      public static function requestPriceList(param1:Array, param2:Function) : Boolean
      {
         var pids:Array = param1;
         var callback:Function = param2;
         var _loc3_:* = Engine;
         if(gudetama.engine.Engine.platform == 1)
         {
            if(billing == null)
            {
               return false;
            }
            billing.setupItemDetailCallback(callback);
            billing.loadItemDetails(pids);
            return true;
         }
         if(ext == null)
         {
            return false;
         }
         ext.setupIAPCallback(function(param1:String, param2:String):void
         {
            callback(param1 == "iap_priceList" ? 0 : -1,param2);
            ext.finishPriceList();
         });
         var result:int = ext.requestPriceList(pids);
         return result == 0;
      }
      
      public static function setupAppPurchase(param1:Function) : Boolean
      {
         var callback:Function = param1;
         var _loc2_:* = Engine;
         if(gudetama.engine.Engine.platform == 1 || !ext)
         {
            return false;
         }
         ext.setupIAPCallback(function(param1:String, param2:String):void
         {
            callback(param1 == "iap_purchaseSucceeded" ? 0 : -3,ext.getAppPurchaseReceipt());
         });
         ext.setupAppPurchase();
         return true;
      }
      
      public static function checkPushEnableByOs(param1:Function) : void
      {
         var _loc2_:* = Engine;
         if(!(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0))
         {
            param1(true);
            return;
         }
         if(!GameSetting.hasScreeningFlag(4))
         {
            param1(true);
            return;
         }
         var _loc3_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            gudetama.common.NativeExtensions.arExt.getPushNotificatePermissionStatus(param1);
            return;
         }
         if(PushContext != null)
         {
            PushContext.getPushEnable(param1);
         }
         else
         {
            param1(true);
         }
      }
      
      public static function warn(param1:String, param2:String) : void
      {
         Logger.warn("code:" + param1 + " level:" + param2);
      }
      
      public static function requestOneStorePurchaseList(param1:String, param2:Function) : void
      {
         if(!onStoreBilling)
         {
            return;
         }
         onStoreBilling.requestOneStorePurchaseList(param1,param2);
      }
      
      public static function purchaseOneStore(param1:String, param2:Function) : int
      {
         if(!onStoreBilling)
         {
            return -1;
         }
         onStoreBilling.requestPurchase(param1,param2);
         return -1;
      }
      
      public static function requestConsumeOneStore(param1:Function) : int
      {
         if(!onStoreBilling)
         {
            return -1;
         }
         onStoreBilling.requestConsume(param1);
         return -1;
      }
   }
}
