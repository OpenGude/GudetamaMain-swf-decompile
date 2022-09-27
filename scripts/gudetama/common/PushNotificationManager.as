package gudetama.common
{
   import flash.events.RemoteNotificationEvent;
   import gudetama.engine.Engine;
   import starling.core.Starling;
   
   public class PushNotificationManager
   {
      
      private static var pushToken:String = null;
      
      private static var instance:PushNotificationManager = new PushNotificationManager();
       
      
      private var notifiedFunction:Function;
      
      private var pushNotifiedIos:PushNotificationIOS = null;
      
      public function PushNotificationManager()
      {
         super();
      }
      
      public static function register(param1:Function) : void
      {
         instance._register(param1);
      }
      
      public static function getPushToken() : String
      {
         return pushToken;
      }
      
      public static function hasPushToken() : Boolean
      {
         return pushToken != null;
      }
      
      public static function resetPushToken() : void
      {
         pushToken = null;
      }
      
      public static function isSupport() : Boolean
      {
         if(false)
         {
            return false;
         }
         var _loc1_:* = Engine;
         return gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0;
      }
      
      private function _register(param1:*) : void
      {
         var callback:* = param1;
         if(false)
         {
            callback("");
            return;
         }
         var pushEnable:Boolean = false;
         var _loc3_:* = Engine;
         if(gudetama.engine.Engine.platform == 1)
         {
            if(!pushToken)
            {
               NativeExtensions.registerPushNotificationForAndroid(function(param1:String):void
               {
                  pushEnable = true;
                  pushToken = param1;
                  callback(param1);
               });
               var _loc4_:* = Starling;
               (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
               {
                  if(pushEnable)
                  {
                     return;
                  }
                  pushToken = "";
                  callback(pushToken);
               },2);
            }
            else
            {
               callback(pushToken);
            }
         }
         else
         {
            var _loc5_:* = Engine;
            if(gudetama.engine.Engine.platform == 0)
            {
               if(!pushToken)
               {
                  pushNotifiedIos = new PushNotificationIOS(function(param1:RemoteNotificationEvent):void
                  {
                     pushEnable = true;
                     pushToken = param1.tokenId;
                     callback(pushToken);
                     pushNotifiedIos.removeTokenEvent();
                  });
                  var _loc6_:* = Starling;
                  (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
                  {
                     if(pushEnable)
                     {
                        return;
                     }
                     pushToken = "";
                     callback(pushToken);
                     pushNotifiedIos.removeTokenEvent();
                  },2);
               }
               else
               {
                  callback(pushToken);
               }
            }
         }
      }
   }
}

import flash.notifications.RemoteNotifier;
import flash.notifications.RemoteNotifierSubscribeOptions;

class PushNotificationIOS
{
    
   
   private var preferredStyle:Vector.<String>;
   
   private var notificationOption:RemoteNotifierSubscribeOptions;
   
   private var notifier:RemoteNotifier;
   
   private var tokenCallback:Function;
   
   function PushNotificationIOS(param1:Function)
   {
      preferredStyle = new Vector.<String>();
      notificationOption = new RemoteNotifierSubscribeOptions();
      notifier = new RemoteNotifier();
      super();
      tokenCallback = param1;
      preferredStyle.push("alert","sound","badge");
      notificationOption.notificationStyles = preferredStyle;
      notifier.addEventListener("token",param1);
      notifier.subscribe(notificationOption);
   }
   
   public function removeTokenEvent() : void
   {
      notifier.removeEventListener("token",tokenCallback);
   }
}
