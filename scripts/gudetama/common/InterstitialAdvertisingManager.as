package gudetama.common
{
   import flash.events.StatusEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.engine.Engine;
   import gudetama.ui.InterstitialManager;
   import gudetama.ui.InterstitialUI;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import starling.display.Sprite;
   
   public class InterstitialAdvertisingManager
   {
      
      public static const ADS_INTER_NONE:int = -1;
      
      public static const ADS_INTER_IMOBILE:int = 0;
      
      public static const ADS_INTER_NEND:int = 1;
      
      public static const ADS_INTER_IRONSOURCE:int = 2;
      
      private static var androidextension;
      
      public static var showCyberstepInterMap:Object;
      
      private static var initFinishCallback:Function;
      
      private static var currentInitID:int;
      
      private static var checkInitID:int;
      
      private static var initListMap:Object = {};
      
      private static var initTimer:Timer;
      
      private static var initAndroidImobile:Boolean = false;
      
      private static var setuped:Boolean = false;
      
      private static var imobileInterstitialUI:ImobileInterstitialUI;
       
      
      private var lastshowtime:int;
      
      public function InterstitialAdvertisingManager()
      {
         super();
      }
      
      public static function setup(param1:TaskQueue, param2:Function) : void
      {
         var queue:TaskQueue = param1;
         var _initFinishCallback:Function = param2;
         if(setuped)
         {
            return;
         }
         setuped = true;
         initFinishCallback = _initFinishCallback;
         Engine.setupLayoutForTask(queue,"ImobileInterstitialDialogLayout",function(param1:Object):void
         {
            imobileInterstitialUI = new ImobileInterstitialUI(param1.object as Sprite,removeImobileInterstitial);
            if(!Engine.isJapanIp())
            {
               initListMap[-1] = 2;
               initListMap[2] = -1;
            }
            else
            {
               initListMap[-1] = 0;
               initListMap[0] = 1;
               initListMap[1] = -1;
            }
            initCallback(-1);
         },1);
      }
      
      public static function initCallback(param1:int) : void
      {
         if(!isNaN(initListMap[param1]))
         {
            currentInitID = initListMap[param1];
            delete initListMap[param1];
            initInterCompany();
         }
      }
      
      private static function initInterCompany() : void
      {
         trace("initInterCompany currentInitID : " + currentInitID);
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
               initImobileExtension();
               break;
            case 2:
               initNendExtension();
               break;
            case 3:
               initIronSourceExtension();
               break;
            default:
               _loc2_ = false;
               if(initFinishCallback)
               {
                  initFinishCallback();
               }
               initFinishCallback = null;
               trace("ERROR unkown next id : " + currentInitID);
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
      
      public static function showInterstitialAds(param1:Function = null) : void
      {
         var _loc7_:* = null;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:* = null;
         var _loc4_:* = null;
         if(checkInterstitialInterval())
         {
            if(!Engine.isJapanIp())
            {
               if(GameSetting.getInitOtherInt("global.ad.interstitial",1) != 0)
               {
                  if(showdisplayInterstitialIronSource())
                  {
                     DataStorage.getLocalData().setInterstitialIntervalSecs(TimeZoneUtil.epochMillisToOffsetSecs());
                  }
               }
               return;
            }
            if(_loc7_ = DataStorage.getLocalData().getInterstitialAdsList())
            {
               _loc2_ = _loc7_.length;
               _loc5_ = 0;
               for(; _loc5_ < _loc2_; _loc5_++)
               {
                  _loc3_ = Math.floor(Math.random() * 100);
                  _loc3_ = Math.floor(Math.random() * 100);
                  _loc3_ += 1;
                  _loc6_ = _loc7_[_loc5_];
                  if(DataStorage.getLocalData().getInterstitialAdsRate(_loc6_) > _loc3_)
                  {
                     try
                     {
                        _loc4_ = "showdisplayInterstitial" + _loc6_;
                        if(InterstitialAdvertisingManager[_loc4_]())
                        {
                           DataStorage.getLocalData().setInterstitialIntervalSecs(TimeZoneUtil.epochMillisToOffsetSecs());
                           return;
                        }
                     }
                     catch(e:Error)
                     {
                        continue;
                     }
                  }
               }
            }
         }
      }
      
      private static function checkInterstitialInterval() : Boolean
      {
         var _loc1_:int = DataStorage.getLocalData().getInterstitialIntervalSecs();
         var _loc3_:int = !!Engine.isJapanIp() ? GameSetting.def.rule.interstitiaIntervalSecs : int(GameSetting.def.rule.interstitiaIntervalGlobalSecs);
         if(_loc3_ == -1)
         {
            return false;
         }
         var _loc2_:uint = TimeZoneUtil.epochMillisToOffsetSecs();
         if(_loc1_ == 0)
         {
            return true;
         }
         if(_loc2_ - _loc1_ > _loc3_)
         {
            return true;
         }
         return false;
      }
      
      private static function initImobileExtension() : void
      {
      }
      
      public static function showdisplayInterstitialImobile(param1:Function = null) : Boolean
      {
         var _loc3_:* = Engine;
         if(gudetama.engine.Engine.platform != 0)
         {
         }
         var _loc2_:Array = GameSetting.getRule().imobileInterstitialAndroidPlacement;
         var _loc4_:* = Engine;
         if(gudetama.engine.Engine.platform == 1)
         {
            _loc2_ = GameSetting.getRule().imobileInterstitialAndroidPlacement;
         }
         else
         {
            _loc2_ = GameSetting.getRule().imobileInterstitialIOSPlacement;
         }
         if(!_loc2_)
         {
            return false;
         }
         if(_loc2_.length != 3)
         {
            return false;
         }
         if(_loc2_[0].length <= 0)
         {
            return false;
         }
         var _loc5_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            return imobileInterstitialUI.show(_loc2_);
         }
         if(androidextension)
         {
            if(androidextension.displayImobileInterstitial(_loc2_[0],_loc2_[1],_loc2_[2],false))
            {
               androidextension.visibleImobileInterstitial(true);
               imobileInterstitialUI.show(null,false);
               return true;
            }
            androidextension.displayImobileInterstitial(_loc2_[0],_loc2_[1],_loc2_[2],true);
            removeImobileInterstitial();
            return false;
         }
         return false;
      }
      
      private static function removeImobileInterstitial() : void
      {
      }
      
      private static function onStatus(param1:StatusEvent) : void
      {
         if(param1.level == "inline")
         {
            if("isReady" == param1.code)
            {
               if(!initAndroidImobile)
               {
                  initAndroidImobile = true;
                  initCallback(0);
               }
            }
         }
      }
      
      public static function initNendExtension() : void
      {
      }
      
      public static function showdisplayInterstitialNend() : Boolean
      {
         return false;
      }
      
      public static function initIronSourceExtension() : void
      {
      }
      
      public static function showdisplayInterstitialIronSource() : Boolean
      {
         return false;
      }
      
      public static function showdisplayInterstitialCyberStep(param1:Function = null) : Boolean
      {
         if(InterstitialManager.canShow(GameSetting.def.interTable))
         {
            InterstitialUI.show(null,showCyberStepInterInfoFunction);
            return true;
         }
         return false;
      }
      
      private static function showCyberStepInterInfoFunction(param1:int) : void
      {
         if(!showCyberstepInterMap)
         {
            showCyberstepInterMap = {};
         }
         if(showCyberstepInterMap[param1])
         {
            showCyberstepInterMap[param1] += 1;
         }
         else
         {
            showCyberstepInterMap[param1] = 1;
         }
      }
      
      private static function checkInitTimer() : void
      {
         if(initTimer)
         {
            initTimer.stop();
            initTimer.removeEventListener("timer",checkTimerEvent);
            initTimer = null;
         }
         initTimer = new Timer(10000);
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
   }
}

import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import muku.display.ContainerButton;
import starling.display.Sprite;
import starling.events.Event;

class ImobileInterstitialUI extends BaseScene
{
    
   
   private var closeBtn:ContainerButton;
   
   private var closeCallback:Function;
   
   private var isIOS:Boolean = false;
   
   function ImobileInterstitialUI(param1:Sprite, param2:Function)
   {
      super(1);
      this.displaySprite = param1;
      this.closeCallback = param2;
      closeBtn = param1.getChildByName("closeBtn") as ContainerButton;
      closeBtn.addEventListener("triggered",triggeredCloseBtn);
      param1.visible = false;
      addChild(param1);
   }
   
   public function show(param1:Array, param2:Boolean = true) : Boolean
   {
      isIOS = param2;
      return false;
   }
   
   public function hide() : void
   {
      displaySprite.visible = false;
      Engine.removePopUp(this,false);
   }
   
   override protected function focusGainedFinish() : void
   {
      if(closeCallback && !isIOS)
      {
         closeCallback();
      }
   }
   
   private function triggeredCloseBtn(param1:Event) : void
   {
      if(closeCallback)
      {
         closeCallback();
      }
   }
}
