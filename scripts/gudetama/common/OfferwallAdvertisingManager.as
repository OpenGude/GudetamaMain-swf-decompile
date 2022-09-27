package gudetama.common
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gudetama.data.GameSetting;
   import gudetama.engine.Engine;
   import gudetama.ui.MessageDialog;
   
   public class OfferwallAdvertisingManager
   {
      
      public static const ADS_OFFERWALL_NONE:int = -1;
      
      public static const ADS_OFFERWALL_TAPJOY:int = 0;
      
      public static const ADS_OFFERWALL_IRONSOURCE:int = 1;
      
      private static var isJp:Boolean = true;
      
      private static var initFinishCallback:Function;
      
      private static var initListMap:Object = {};
      
      private static var currentInitID:int;
      
      private static var checkInitID:int;
      
      private static var initTimer:Timer;
       
      
      public function OfferwallAdvertisingManager()
      {
         super();
      }
      
      public static function setup(param1:Function) : void
      {
         isJp = Engine.isJapanIp();
         if(param1)
         {
            initFinishCallback = param1;
         }
         if(!isJp)
         {
            initListMap[-1] = 1;
            initListMap[1] = -1;
         }
         else
         {
            initListMap[-1] = 0;
            initListMap[0] = -1;
         }
         initCallback(-1);
      }
      
      public static function initCallback(param1:int) : void
      {
         if(!isNaN(initListMap[param1]))
         {
            currentInitID = initListMap[param1];
            delete initListMap[param1];
            initOfferwallCompany();
         }
      }
      
      private static function initOfferwallCompany() : void
      {
         var _loc2_:Boolean = true;
         switch(int(currentInitID) - -1)
         {
            case 0:
               _loc2_ = false;
               if(initFinishCallback)
               {
                  initFinishCallback();
               }
               initFinishCallback = null;
               break;
            case 1:
               initCallback(0);
               break;
            case 2:
               break;
            default:
               _loc2_ = false;
               if(initFinishCallback)
               {
                  initFinishCallback();
               }
               initFinishCallback = null;
         }
         if(_loc2_)
         {
            checkInitTimer();
         }
         else if(initTimer)
         {
            initTimer.stop();
            initTimer.removeEventListener("timer",arguments.callee);
            initTimer = null;
         }
      }
      
      private static function checkInitTimer() : void
      {
         if(initTimer)
         {
            initTimer.stop();
            initTimer.removeEventListener("timer",arguments.callee);
            initTimer = null;
         }
         initTimer = new Timer(3000);
         checkInitID = currentInitID;
         initTimer.addEventListener("timer",checkTimerEvent);
         initTimer.start();
      }
      
      private static function checkTimerEvent(param1:TimerEvent) : void
      {
         initTimer.stop();
         initTimer.removeEventListener("timer",checkTimerEvent);
         initTimer = null;
         if(checkInitID == currentInitID)
         {
            initCallback(currentInitID);
         }
      }
      
      public static function showOfferwallAds(param1:Function = null) : void
      {
         var _callback:Function = param1;
         if(isJp)
         {
            return;
         }
         MessageDialog.show(0,GameSetting.getUIText("offerwall.tapjoy.error1"),function(param1:int):void
         {
         });
      }
      
      public static function canShowOfferwall() : Boolean
      {
         if(isJp)
         {
            return false;
         }
         return false;
      }
      
      public static function getOfferwallPoint(param1:Function) : void
      {
         var _loc2_:Boolean = true;
         if(_loc2_)
         {
            if(isJp)
            {
               param1(0);
            }
         }
         else
         {
            param1(0);
         }
      }
   }
}
