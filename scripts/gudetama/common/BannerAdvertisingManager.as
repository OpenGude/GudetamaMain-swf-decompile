package gudetama.common
{
   import flash.events.StatusEvent;
   import flash.events.TimerEvent;
   import flash.media.StageWebView;
   import flash.system.Capabilities;
   import flash.utils.Timer;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.engine.Engine;
   import gudetama.extensions.AdmobExtensions;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   
   public class BannerAdvertisingManager
   {
      
      public static const ADS_BANNER_NONE:int = -1;
      
      public static const ADS_BANNER_IMOBILE:int = 0;
      
      public static const ADS_BANNER_NEND:int = 1;
      
      public static const ADS_BANNER_FIVE:int = 2;
      
      public static const ADS_BANNER_IRONSOURCE:int = 3;
      
      public static const ADS_BANNER_PROMOTION:int = 4;
      
      public static const ADS_BANNER_ADMOB:int = 5;
      
      public static const ADS_BANNER_IMOBILE_EVENT:String = "banner";
      
      public static var webView:StageWebView;
      
      public static var canTouchBanner:Boolean = true;
      
      public static var currentBannerId:int = -1;
      
      private static var bannerAdsRoopCount:int = 0;
      
      private static var fiveExtension;
      
      private static var bannerTimer:Timer;
      
      public static var showCyberStepNum:uint = 0;
      
      public static var showCyberStepBannerNumMap:Object;
      
      private static var androidver:String;
      
      private static var initFinishCallback:Function;
      
      private static var currentInitID:int;
      
      private static var checkInitID:int;
      
      private static var initListMap:Object = {};
      
      private static var initTimer:Timer;
      
      private static var currentBannerIndex:int = 0;
      
      private static var roopCount:int = 0;
      
      private static var androidextension;
      
      private static var androidImobileReady:Boolean = false;
      
      private static var initImobile:Boolean = false;
      
      private static var fiveBannerWidth:Number = 320;
      
      private static var fiveBannerHeight:Number = 70;
      
      private static var fiveBannerRate:Number;
      
      private static var stageWidth:Number;
      
      private static var fiveFixedBannerHeight:Number;
      
      private static var fiveFixedBannerWidth:int;
      
      private static var fiveBannerPosX:int;
      
      private static var widthRaito:int = 0;
      
      private static var heightRaito:int = 0;
      
      private static var visible:Boolean = true;
       
      
      public function BannerAdvertisingManager()
      {
         super();
      }
      
      public static function setup(param1:Function) : void
      {
         if(param1)
         {
            initFinishCallback = param1;
         }
         initListMap[-1] = 2;
         initListMap[2] = 0;
         initListMap[0] = 1;
         initListMap[1] = 3;
         initListMap[3] = 5;
         initListMap[5] = -1;
         initCallback(-1);
      }
      
      public static function initCallback(param1:int) : void
      {
         if(!isNaN(initListMap[param1]))
         {
            currentInitID = initListMap[param1];
            delete initListMap[param1];
            initBannerCompany();
         }
      }
      
      private static function initBannerCompany() : void
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
               initImobileExtension();
               break;
            case 2:
               initNendExtension();
               break;
            case 3:
               initFiveExtension();
               break;
            case 4:
               initIronSourceExtension();
               break;
            case 6:
               initAdmobExtension();
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
      
      public static function showBannerAds(param1:Function = null) : void
      {
         var _loc5_:* = null;
         var _loc2_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:* = null;
         var _loc4_:* = null;
         var _loc6_:Boolean = false;
         if(!visible)
         {
            return;
         }
         hideAllBanner();
         if(!Engine.isJapanIp())
         {
            if(DataStorage.getLocalData().getBannerAdsRate("CyberStep") != 0 && showdisplayBannerCyberStep())
            {
               return;
            }
            return;
         }
         if(GameSetting.getRule().bannerCircle)
         {
            roopCount = 0;
            currentBannerIndex = 0;
            showNextBanner();
         }
         else
         {
            if(_loc5_ = DataStorage.getLocalData().getBannerAdsList())
            {
               _loc2_ = _loc5_.length;
               _loc7_ = 0;
               for(; _loc7_ < _loc2_; _loc7_++)
               {
                  _loc3_ = Math.floor(Math.random() * 100);
                  _loc3_ = Math.floor(Math.random() * 100);
                  _loc3_ += 1;
                  _loc8_ = _loc5_[_loc7_];
                  if(DataStorage.getLocalData().getBannerAdsRate(_loc8_) > _loc3_)
                  {
                     try
                     {
                        _loc4_ = "showdisplayBanner" + _loc8_;
                        if(_loc6_ = BannerAdvertisingManager[_loc4_]())
                        {
                           bannerAdsRoopCount = 0;
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
            if(!(_loc5_ && bannerAdsRoopCount < 3))
            {
               bannerAdsRoopCount = 0;
               if(DataStorage.getLocalData().getBannerAdsRate("Imobile") != 0 && showdisplayBannerImobile())
               {
                  return;
               }
               if(DataStorage.getLocalData().getBannerAdsRate("Nend") != 0 && showdisplayBannerNend())
               {
                  return;
               }
               if(DataStorage.getLocalData().getBannerAdsRate("Five") != 0 && showdisplayBannerFive())
               {
                  return;
               }
               if(DataStorage.getLocalData().getBannerAdsRate("Admob") != 0 && showdisplayBannerAdmob())
               {
                  return;
               }
               if(DataStorage.getLocalData().getBannerAdsRate("CyberStep") != 0 && showdisplayBannerCyberStep())
               {
                  return;
               }
               return;
            }
            bannerAdsRoopCount++;
            showBannerAds();
         }
      }
      
      private static function showNextBanner(param1:TimerEvent = null) : void
      {
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc5_:Boolean = false;
         var _loc3_:Array = DataStorage.getLocalData().getBannerAdsTimeRate();
         if(!_loc3_)
         {
            return;
         }
         var _loc2_:int = _loc3_.length;
         if(currentBannerIndex >= _loc2_)
         {
            currentBannerIndex = 0;
         }
         if(roopCount > _loc2_ * 2)
         {
            return;
         }
         if(!visible)
         {
            return;
         }
         try
         {
            hideAllBanner();
            if(_loc3_[currentBannerIndex].rate <= 0)
            {
               currentBannerIndex++;
               showNextBanner();
               return;
            }
            _loc6_ = _loc3_[currentBannerIndex].company;
            _loc4_ = "showdisplayBanner" + _loc6_;
            if(!(_loc5_ = DataStorage.getLocalData().isEnableBanner(_loc6_) && BannerAdvertisingManager[_loc4_]()))
            {
               currentBannerIndex++;
               roopCount++;
               showNextBanner();
               return;
            }
         }
         catch(e:Error)
         {
            currentBannerIndex++;
            if(roopCount > _loc2_ * 2)
            {
               return;
            }
            roopCount++;
            showNextBanner();
            return;
         }
         if(!bannerTimer)
         {
            bannerTimer = new Timer(_loc3_[currentBannerIndex].rate * 1000);
            bannerTimer.addEventListener("timer",showNextBanner);
            bannerTimer.start();
         }
         else
         {
            bannerTimer.delay = _loc3_[currentBannerIndex].rate * 1000;
         }
         currentBannerIndex++;
         roopCount = 0;
      }
      
      private static function initImobileExtension() : void
      {
      }
      
      public static function showdisplayBannerImobile(param1:Function = null, param2:Boolean = false) : Boolean
      {
         return false;
      }
      
      private static function onStatusImobile(param1:StatusEvent) : void
      {
         if(param1.level == "banner")
         {
            if(!initImobile)
            {
               initCallback(0);
            }
            if("true" == param1.code)
            {
               if(androidextension.hasEventListener("banner"))
               {
                  androidextension.removeEventListener("banner",onStatusImobile);
               }
               androidImobileReady = true;
               if(currentBannerId == -1)
               {
                  showBannerAds();
               }
            }
            else
            {
               androidImobileReady = false;
            }
         }
      }
      
      public static function initNendExtension() : void
      {
      }
      
      public static function showdisplayBannerNend(param1:Function = null) : Boolean
      {
         return true;
      }
      
      private static function onStatusNend() : void
      {
         if(currentBannerId == -1)
         {
            showBannerAds();
         }
      }
      
      public static function initFiveExtension() : void
      {
      }
      
      public static function showdisplayBannerFive(param1:Function = null, param2:Boolean = false) : Boolean
      {
         if(!param2 && currentBannerId == 2)
         {
            return true;
         }
         if(!fiveExtension)
         {
            return false;
         }
         var _loc3_:Boolean = fiveExtension.showAd(fiveBannerPosX,Engine.stage2D.stageHeight - fiveFixedBannerHeight);
         1;
         if(_loc3_)
         {
            currentBannerId = 2;
         }
         return _loc3_;
      }
      
      public static function getBannerRaito(param1:int, param2:int) : Number
      {
         var _loc3_:* = Engine;
         if(gudetama.engine.Engine.platform == 0 && Capabilities.os.indexOf("iPad") >= 0)
         {
            return 0.7;
         }
         return 1;
      }
      
      public static function initIronSourceExtension() : void
      {
      }
      
      public static function showdisplayBannerIronSource(param1:Function = null) : Boolean
      {
         return false;
      }
      
      public static function initAdmobExtension() : void
      {
         AdmobExtensions.setup(2);
      }
      
      public static function showdisplayBannerAdmob(param1:Function = null) : Boolean
      {
         if(currentBannerId == 5)
         {
            return true;
         }
         var _loc2_:Boolean = AdmobExtensions.showSmartBanner();
         if(_loc2_)
         {
            currentBannerId = 5;
         }
         return _loc2_;
      }
      
      public static function visibleBannerAdmob(param1:Boolean) : void
      {
         AdmobExtensions.visibleBanner(param1);
      }
      
      public static function showdisplayBannerCyberStep(param1:Function = null) : Boolean
      {
         if(currentBannerId == 4)
         {
            return true;
         }
         ResidentMenuUI_Gudetama.startFuddaBanner();
         if(ResidentMenuUI_Gudetama.canShowFuddaBanner())
         {
            currentBannerId = 4;
            ResidentMenuUI_Gudetama.visibleFuddaBanner(true);
            showCyberStepNum++;
            return true;
         }
         return false;
      }
      
      public static function updateCyberStepBannerShowingCount(param1:int) : void
      {
         var _loc2_:int = 0;
         if(param1 != -1)
         {
            if(!showCyberStepBannerNumMap)
            {
               showCyberStepBannerNumMap = {};
            }
            _loc2_ = !showCyberStepBannerNumMap[param1] ? 0 : showCyberStepBannerNumMap[param1];
            _loc2_ += 1;
            showCyberStepBannerNumMap[param1] = _loc2_;
         }
      }
      
      public static function hideAllBanner() : void
      {
         currentBannerId = -1;
         if(androidextension)
         {
            androidextension.visibleImobileBanner(false);
            if(androidImobileReady && androidextension.hasEventListener("banner"))
            {
               androidextension.removeEventListener("banner",onStatusImobile);
            }
         }
         if(webView)
         {
            webView.stage = null;
         }
         visibleBannerAdmob(false);
         ResidentMenuUI_Gudetama.visibleFuddaBanner(false);
      }
      
      public static function visibleBanner(param1:Boolean) : void
      {
         visible = param1;
         switch(int(currentBannerId))
         {
            case 0:
               break;
            case 1:
               break;
            case 2:
               if(param1)
               {
                  showdisplayBannerFive(null,true);
               }
               else if(fiveExtension)
               {
                  fiveExtension.clear();
               }
               break;
            case 3:
               break;
            case 4:
               ResidentMenuUI_Gudetama.visibleFuddaBanner(param1);
               break;
            case 5:
               visibleBannerAdmob(param1);
         }
         if(visible && Engine.isJapanIp() && GameSetting.getRule().bannerCircle)
         {
            roopCount = 0;
            currentBannerIndex = 0;
            showNextBanner();
         }
      }
      
      public static function getCurrentBannerId() : int
      {
         return currentBannerId;
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
