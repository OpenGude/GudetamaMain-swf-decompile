package gudetama.common
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.PromotionVideoDef;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.extensions.AdmobExtensions;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.MovieDialog;
   
   public class VideoAdvertisingManager
   {
      
      public static const ADS_VIDEO_NONE:int = -1;
      
      public static const ADS_VIDEO_MAIO:int = 0;
      
      public static const ADS_VIDEO_TAPJOY:int = 1;
      
      public static const ADS_VIDEO_NEND:int = 3;
      
      public static const ADS_VIDEO_UNITY_ADS:int = 4;
      
      public static const ADS_VIDEO_IRONSOURCE_ADS:int = 5;
      
      public static const ADS_VIDEO_SELF_ADS:int = 6;
      
      public static const ADS_VIDEO_CHARTBOOST_ADS:int = 7;
      
      public static const ADS_VIDEO_ADMOB_ADS:int = 8;
      
      public static const ADS_VIDEO_NUM:int = 9;
      
      public static var currentVideoID:int = -1;
      
      public static var isPriority:Boolean = false;
      
      private static var setupTimer:Timer;
      
      private static var setuped:Boolean = false;
      
      private static var isInit:Boolean = false;
      
      private static var callback:Function;
      
      private static var resultCallback:Function;
      
      private static var currentInitID:int;
      
      private static var checkInitID:int;
      
      private static var initMap:Object = {};
      
      private static var initTimer:Timer;
      
      private static var initFinishCallback:Function;
      
      private static var videoAdsRoopCount:int = 0;
      
      private static var debugVideoIndex:int;
      
      private static var unityAds;
       
      
      public function VideoAdvertisingManager()
      {
         super();
      }
      
      public static function setup(param1:Function = null, param2:Boolean = false) : void
      {
         if(!param2 && !DataStorage.getLocalData().canShowVideo())
         {
            if(param1)
            {
               param1();
            }
            initFinishCallback = null;
            return;
         }
         if(param1)
         {
            initFinishCallback = param1;
         }
         initFinishCallback = param1;
         if(!setuped)
         {
            setuped = true;
            if(Engine.isJapanIp())
            {
               initMap[-1] = 0;
               initMap[0] = 1;
               initMap[1] = 3;
               initMap[3] = 7;
               initMap[7] = 8;
               initMap[8] = 5;
            }
            else
            {
               initMap[-1] = 8;
               initMap[8] = 5;
            }
            initMap[5] = -1;
            initCallback(-1);
         }
      }
      
      public static function showVideoAds(param1:Function, param2:Function) : void
      {
         Engine.showLoading();
         callback = param1;
         resultCallback = param2;
         if(!isInit)
         {
            if(!setupTimer)
            {
               setupTimer = new Timer(!!Engine.isJapanIp() ? GameSetting.getRule().videoLodingIntervalMillisec : int(GameSetting.getRule().videoGlobalLodingIntervalMillisec));
            }
            else
            {
               setupTimer.removeEventListener("timer",setupTimerEvent);
               setupTimer.reset();
            }
            setupTimer.addEventListener("timer",setupTimerEvent);
            setupTimer.start();
         }
         else
         {
            if(setupTimer)
            {
               setupTimer.stop();
               setupTimer.removeEventListener("timer",setupTimerEvent);
               setupTimer = null;
            }
            _showVideoAds();
         }
      }
      
      private static function _showVideoAds() : void
      {
         var _loc7_:* = null;
         var _loc1_:int = 0;
         var _loc11_:int = 0;
         var _loc9_:* = null;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc10_:* = null;
         var _loc5_:* = null;
         var _loc6_:Array = DataStorage.getLocalData().getPriorityvideoAdsCompanyList();
         if(GameSetting.getRule().priorityMaxVideoCount > DataStorage.getLocalData().showedPriorityVideoCount && DataStorage.getLocalData().notEqualShowedPriorityVideoDate() && _loc6_ && _loc6_.length > 0)
         {
            _loc1_ = _loc6_.length;
            _loc11_ = 0;
            while(_loc11_ < _loc1_)
            {
               _loc7_ = _loc6_[_loc11_];
               if(DataStorage.getLocalData().getVideoAdsRate(_loc7_) > 0)
               {
                  _loc9_ = "showdisplay" + _loc7_;
                  if(VideoAdvertisingManager[_loc9_](callback,true))
                  {
                     videoAdsRoopCount = 0;
                     resultCallback(true,currentVideoID);
                     return;
                  }
               }
               _loc11_++;
            }
         }
         var _loc2_:Array = DataStorage.getLocalData().getVideoAdsList();
         var _loc3_:int = _loc2_.length;
         _loc8_ = 0;
         for(; _loc8_ < _loc3_; _loc8_++)
         {
            _loc4_ = Math.floor(Math.random() * 100);
            _loc4_ = (_loc4_ = Math.floor(Math.random() * 100)) + 1;
            _loc10_ = _loc2_[_loc8_];
            if(DataStorage.getLocalData().getVideoAdsRate(_loc10_) > _loc4_)
            {
               try
               {
                  _loc5_ = "showdisplay" + _loc10_;
                  if(VideoAdvertisingManager[_loc5_](callback))
                  {
                     videoAdsRoopCount = 0;
                     resultCallback(true,currentVideoID);
                     return;
                  }
               }
               catch(e:Error)
               {
                  continue;
               }
            }
         }
         delayLastedShowVideo();
      }
      
      public static function delayLastedShowVideo() : void
      {
         videoAdsRoopCount = 0;
         if(DataStorage.getLocalData().getVideoAdsRate("Maio") != 0 && showdisplayMaio(callback))
         {
            resultCallback(true,0);
            return;
         }
         if(DataStorage.getLocalData().getVideoAdsRate("Tapjoy") != 0 && showdisplayTapjoy(callback))
         {
            resultCallback(true,1);
            return;
         }
         if(DataStorage.getLocalData().getVideoAdsRate("Nend") != 0 && showdisplayNend(callback))
         {
            resultCallback(true,3);
            return;
         }
         if(DataStorage.getLocalData().getVideoAdsRate("UnityAds") != 0 && showdisplayUnityAds(callback))
         {
            resultCallback(true,4);
            return;
         }
         if(DataStorage.getLocalData().getVideoAdsRate("IronSource") != 0 && showdisplayIronSource(callback))
         {
            resultCallback(true,5);
            return;
         }
         if(DataStorage.getLocalData().getVideoAdsRate("Chartboost") != 0 && showdisplayChartboost(callback))
         {
            resultCallback(true,7);
            return;
         }
         if(DataStorage.getLocalData().getVideoAdsRate("Admob") != 0 && showdisplayAdmob(callback))
         {
            resultCallback(true,8);
            return;
         }
         if(showdisplayPromotionVideo(callback))
         {
            Logger.warn("Video advertisement was exhausted. japan ? " + Engine.isJapanIp());
            resultCallback(true,6);
            return;
         }
         Engine.hideLoading();
         MessageDialog.show(0,GameSetting.getUIText("advertising.video.error1"));
         resultCallback(false,-1);
      }
      
      public static function debugShowVideoAds(param1:Function = null) : Boolean
      {
         var _loc2_:Boolean = false;
         switch(int(debugVideoIndex))
         {
            case 0:
               if(showdisplayMaio(param1))
               {
                  _loc2_ = true;
               }
               break;
            case 1:
               if(showdisplayTapjoy(param1))
               {
                  _loc2_ = true;
               }
               break;
            case 3:
               if(showdisplayNend(param1))
               {
                  _loc2_ = true;
               }
               break;
            case 4:
               if(showdisplayUnityAds(param1))
               {
                  _loc2_ = true;
               }
               break;
            case 5:
               if(showdisplayIronSource(param1))
               {
                  _loc2_ = true;
               }
               break;
            case 7:
               if(showdisplayChartboost(param1))
               {
                  _loc2_ = true;
                  break;
               }
         }
         debugVideoIndex = (debugVideoIndex + 1) % 9;
         return _loc2_;
      }
      
      public static function initMaioExtension() : void
      {
      }
      
      public static function showdisplayMaio(param1:Function = null, param2:Boolean = false) : Boolean
      {
         return false;
      }
      
      public static function initTapjoyExtension() : void
      {
         initCallback(1);
      }
      
      public static function showdisplayTapjoy(param1:Function, param2:Boolean = false) : Boolean
      {
         return false;
      }
      
      public static function initUnityAdsExtension() : void
      {
      }
      
      public static function showdisplayUnityAds(param1:Function, param2:Boolean = false) : Boolean
      {
         var _finishCallback:Function = param1;
         var _isPriority:Boolean = param2;
         if(unityAds && unityAds.canShow())
         {
            sendShowingInfo(4,_isPriority,function():void
            {
               unityAds.displayAd(_finishCallback);
            });
            return true;
         }
         return false;
      }
      
      public static function initNendExtension() : void
      {
      }
      
      public static function showdisplayNend(param1:Function, param2:Boolean = false) : Boolean
      {
         return false;
      }
      
      public static function initIronSourceExtension() : void
      {
      }
      
      public static function showdisplayIronSource(param1:Function, param2:Boolean = false) : Boolean
      {
         return false;
      }
      
      public static function initAdmobExtension() : void
      {
         AdmobExtensions.setup(0,initCallback);
      }
      
      public static function showdisplayAdmob(param1:Function, param2:Boolean = false) : Boolean
      {
         var _finishCallback:Function = param1;
         var _isPriority:Boolean = param2;
         if(AdmobExtensions.canShowVideo())
         {
            sendShowingInfo(8,_isPriority,function():void
            {
               AdmobExtensions.showPendingRewardedVideo(_finishCallback);
            });
            return true;
         }
         return false;
      }
      
      public static function showdisplayPromotionVideo(param1:Function, param2:Boolean = false) : Boolean
      {
         var _finishCallback:Function = param1;
         var _isPriority:Boolean = param2;
         var list:Array = GameSetting.getRule().promotionVideoIdAndRatio;
         if(!list || list.length <= 0)
         {
            return false;
         }
         var sumRatio:int = 0;
         for each(idAndRatio in list)
         {
            var promotionVideoDef:PromotionVideoDef = GameSetting.getPromotionVideo(idAndRatio[0]);
            if(!(promotionVideoDef.locales && promotionVideoDef.locales.indexOf(Engine.getLocale()) < 0))
            {
               var sumRatio:int = sumRatio + idAndRatio[1];
            }
         }
         var id:int = -1;
         var r:int = Math.random() * (sumRatio + 1);
         var i:int = 0;
         while(i < list.length)
         {
            promotionVideoDef = GameSetting.getPromotionVideo(list[i][0]);
            if(!(promotionVideoDef.locales && promotionVideoDef.locales.indexOf(Engine.getLocale()) < 0))
            {
               var ratio:int = list[i][1];
               var r:int = r - ratio;
               if(r <= 0)
               {
                  id = list[i][0];
                  break;
               }
            }
            i++;
         }
         if(id < 0)
         {
            return false;
         }
         sendShowingInfo(6,_isPriority,function():void
         {
            MovieDialog.show(id,function():void
            {
               _finishCallback(0,false);
            });
         });
         return true;
      }
      
      public static function initChartBoostsExtension() : void
      {
      }
      
      public static function showdisplayChartboost(param1:Function, param2:Boolean = false) : Boolean
      {
         return false;
      }
      
      public static function onResume() : void
      {
      }
      
      public static function onPause() : void
      {
      }
      
      public static function resetCurrentVideoID() : void
      {
         currentVideoID = -1;
         isPriority = false;
      }
      
      public static function sendShowingInfo(param1:int, param2:Boolean, param3:Function) : void
      {
         var _id:int = param1;
         var _isPriority:Boolean = param2;
         var _callback:Function = param3;
         currentVideoID = _id;
         onPause();
         isPriority = _isPriority;
         Engine.showLoading(sendShowingInfo);
         var _loc4_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(237,_id),function(param1:*):void
         {
            Engine.hideLoading(sendShowingInfo);
            _callback();
         });
      }
      
      public static function initCallback(param1:int) : void
      {
         if(!isNaN(initMap[param1]))
         {
            currentInitID = initMap[param1];
            delete initMap[param1];
            initVideoCompany();
         }
      }
      
      private static function initVideoCompany() : void
      {
         var _loc2_:Boolean = true;
         switch(int(currentInitID) - -1)
         {
            case 0:
               isInit = true;
               _loc2_ = false;
               if(initFinishCallback)
               {
                  initFinishCallback();
               }
               initFinishCallback = null;
               break;
            case 1:
               initMaioExtension();
               break;
            case 2:
               initTapjoyExtension();
               break;
            case 4:
               initNendExtension();
               break;
            case 6:
               initIronSourceExtension();
               break;
            case 8:
               initChartBoostsExtension();
               break;
            case 9:
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
      
      private static function checkInitTimer() : void
      {
         if(initTimer)
         {
            initTimer.stop();
            initTimer.removeEventListener("timer",arguments.callee);
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
      
      private static function setupTimerEvent(param1:TimerEvent) : void
      {
         setupTimer.stop();
         setupTimer.removeEventListener("timer",setupTimerEvent);
         showVideoAds(callback,resultCallback);
      }
   }
}
