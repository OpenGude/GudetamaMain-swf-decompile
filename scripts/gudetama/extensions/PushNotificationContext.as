package gudetama.extensions
{
   import gudetama.engine.Engine;
   
   public class PushNotificationContext
   {
       
      
      public function PushNotificationContext()
      {
         super();
      }
      
      public static function setup() : void
      {
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.platform != 1)
         {
            return;
         }
         PushNotificationANE.setup();
      }
      
      public static function register(param1:*) : void
      {
         var callback:* = param1;
         var pushtokenfunction:Function = function(param1:PushNotificationEvent):void
         {
            callback(param1.token);
            PushNotificationANE.instance.removeEventListener("permissiongivenwithtokenevent",pushtokenfunction);
         };
         PushNotificationANE.instance.addEventListener("permissiongivenwithtokenevent",pushtokenfunction);
         PushNotificationANE.getPushToken();
      }
      
      public static function setNotifiedCallBack(param1:Function) : void
      {
         PushNotificationANE.instance.addEventListener("comingFromNotificationEvent",param1);
      }
      
      public static function setKeepScreenFlag(param1:Boolean) : void
      {
         PushNotificationANE.setKeepScreenFlag(param1);
      }
      
      public static function getAdvertisingId(param1:Function) : void
      {
         var callback:Function = param1;
         var advfunction:Function = function(param1:PushNotificationEvent):void
         {
            callback(param1.token);
            PushNotificationANE.instance.removeEventListener("getadvertisingid",advfunction);
         };
         PushNotificationANE.instance.addEventListener("getadvertisingid",advfunction);
         PushNotificationANE.getAdvertisingId();
      }
      
      public static function getPushEnable(param1:Function) : void
      {
         var callback:Function = param1;
         var func:Function = function(param1:PushNotificationEvent):void
         {
            callback(param1.token == "true");
            PushNotificationANE.instance.removeEventListener("pushEnable",func);
         };
         PushNotificationANE.instance.addEventListener("pushEnable",func);
         PushNotificationANE.getPushEnable();
      }
      
      private function advertisingIDCallback(param1:PushNotificationEvent) : void
      {
      }
   }
}
