package gudetama.extensions
{
   import com.milkmangames.nativeextensions.AdMob;
   import com.milkmangames.nativeextensions.events.AdMobErrorEvent;
   import com.milkmangames.nativeextensions.events.AdMobEvent;
   import gudetama.data.GameSetting;
   import gudetama.engine.Engine;
   
   public class AdmobExtensions
   {
      
      public static const TYPE_VIDEO:int = 0;
      
      public static const TYPE_INTER:int = 1;
      
      public static const TYPE_BANNER:int = 2;
      
      private static var type:int;
      
      private static var isBanner:Boolean = false;
      
      private static var isInit:Boolean = false;
      
      private static var isShowAd:Boolean = false;
      
      private static var isInitVideo:Boolean = false;
      
      private static var isWaiting:Boolean = false;
      
      private static var initVideoCallback:Function;
      
      private static var initInterCallback:Function;
      
      private static var initBannerCallback:Function;
      
      private static var finishCallback:Function;
      
      private static var video_key:String;
       
      
      public function AdmobExtensions()
      {
         super();
      }
      
      public static function setup(param1:int, param2:Function = null) : void
      {
         var _loc3_:* = null;
         type = param1;
         if(param1 == 2)
         {
            isBanner = true;
         }
         var _loc4_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            _loc3_ = GameSetting.def.rule.admobBannerIOSId;
         }
         else
         {
            _loc3_ = GameSetting.def.rule.admobBannerAndroidId;
         }
         var _loc5_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            video_key = GameSetting.def.rule.admobVideoIOSId;
         }
         else
         {
            video_key = GameSetting.def.rule.admobVideoAndroidId;
         }
         log("setup AdMob..." + _loc3_);
         if(!AdMob.isSupported)
         {
            log("AdMob is not supported on this platform.");
            return;
         }
         if(!isInit)
         {
            AdMob.init(_loc3_);
            log("initializing AdMob...");
            log("AdMob v4.11.1 Initialized!");
            AdMob.addEventListener("FAILED_TO_RECEIVE_AD",onFailedReceiveAd);
            AdMob.addEventListener("RECEIVED_AD",onReceiveAd);
            AdMob.addEventListener("SCREEN_PRESENTED",onScreenPresented);
            AdMob.addEventListener("SCREEN_DISMISSED",onScreenDismissed);
            AdMob.addEventListener("LEAVE_APPLICATION",onLeaveApplication);
            isInit = true;
         }
         if(param1 == 2)
         {
            initBannerCallback = param2;
            if(!_loc3_ || _loc3_.length <= 0)
            {
               if(initBannerCallback)
               {
                  initBannerCallback();
               }
            }
         }
         if(param1 == 0)
         {
            initVideoCallback = param2;
            if(video_key && video_key.length > 0)
            {
               if(!isInitVideo)
               {
                  AdMob.addEventListener("REWARDED_VIDEO_CLOSED",onRewardedVideoClosed);
                  AdMob.addEventListener("REWARDED_VIDEO_OPENED",onRewardedVideoOpened);
                  AdMob.addEventListener("REWARDED_VIDEO_STARTED",onRewardedVideoStarted);
                  AdMob.addEventListener("REWARDED_VIDEO_REWARDED",onRewardedVideoRewarded);
                  preloadRewardedVideoAd();
                  isInitVideo = true;
               }
            }
            else if(initVideoCallback)
            {
               initVideoCallback(8);
            }
         }
      }
      
      public static function isInitVideoFunction() : Boolean
      {
         return isInitVideo;
      }
      
      private static function destroyAd() : void
      {
         log("Destroying ad.");
         AdMob.destroyAd();
         log("->ad destroyed");
      }
      
      public static function showSmartBanner() : Boolean
      {
         if(isShowAd)
         {
            visibleBanner(true);
            log("->visible smart banner.");
            return true;
         }
         if(isWaiting)
         {
            return false;
         }
         if(isInit)
         {
            log("->display smart banner.");
            AdMob.showAd("SMART_BANNER","LEFT","BOTTOM");
            log("Requested show smart banner.");
            isWaiting = true;
            return true;
         }
         log("dose not init .");
         return false;
      }
      
      public static function visibleBanner(param1:Boolean) : void
      {
         if(isInit && isShowAd)
         {
            AdMob.setVisibility(param1);
         }
      }
      
      private static function showAdTopLeft() : void
      {
         log("->display ad top left...");
         AdMob.showAd("BANNER","LEFT","TOP");
         log("Requested show ad top left.");
         isShowAd = true;
      }
      
      private static function showAdTopRight() : void
      {
         log("->display ad top right...");
         AdMob.showAd("BANNER","RIGHT","TOP");
         log("Requested show ad top right.");
         isShowAd = true;
      }
      
      private static function showAdBottomCenter() : void
      {
         log("->display ad bottom center...");
         AdMob.showAd("BANNER","CENTER","BOTTOM");
         log("Requested show ad bottom center.");
         isShowAd = true;
      }
      
      private static function refreshAd() : void
      {
         log("Refreshing banner ad.");
         AdMob.refreshAd();
      }
      
      private static function showInterstitialAd() : void
      {
         log("Loading interstitial..");
         try
         {
            AdMob.loadInterstitial("interstitial ad unit id here",true);
         }
         catch(e:Error)
         {
            log("Can\'t load right now- did you wait for the old interstitial to finish?");
            return;
         }
         log("Waiting for interstitial to auto-show.");
      }
      
      private static function preloadInterstitialAd() : void
      {
         log("Preoading interstitial..");
         try
         {
            AdMob.loadInterstitial("interstitial ad unit id here",false);
         }
         catch(e:Error)
         {
            log("Can\'t load right now- did you wait for the old interstitial to finish?");
            return;
         }
         log("Waiting for interstitial to preload.");
      }
      
      private static function showPendingInterstitial() : void
      {
         var _loc1_:Boolean = AdMob.isInterstitialReady();
         if(!_loc1_)
         {
            log("The interstitial is not yet preloaded!");
            return;
         }
         log("Showing preloaded interstitial.");
         AdMob.showPendingInterstitial();
      }
      
      public static function showRewardedVideoAd() : void
      {
         log("Loading rewarded video..");
         try
         {
            AdMob.loadRewardedVideo(video_key,true);
         }
         catch(e:Error)
         {
            log("Can\'t load right now- did you wait for the old rewarded video to finish?");
            return;
         }
         log("Waiting for rewarded video to auto-show");
      }
      
      public static function preloadRewardedVideoAd() : void
      {
         log("Preloading rewarded video..");
         try
         {
            AdMob.loadRewardedVideo(video_key,false);
         }
         catch(e:Error)
         {
            log("Can\'t load right now- did you wait for the old rewarded video to finish?");
            return;
         }
         log("Waiting for rewarded video to preload.");
      }
      
      public static function canShowVideo(param1:Function = null) : Boolean
      {
         return Boolean(AdMob.isRewardedVideoReady());
      }
      
      public static function showPendingRewardedVideo(param1:Function) : void
      {
         var _loc2_:Boolean = AdMob.isRewardedVideoReady();
         if(!_loc2_)
         {
            log("The rewarded video is not yet preloaded!");
            preloadRewardedVideoAd();
            return;
         }
         finishCallback = param1;
         log("Showing preloaded rewarded video.");
         AdMob.showPendingRewardedVideo();
         log("Waiting for rewarded video display...");
      }
      
      private static function onFailedReceiveAd(param1:AdMobErrorEvent) : void
      {
         log("ERROR receiving ad, reason: \'" + param1.text#2 + "\'");
         isWaiting = false;
      }
      
      private static function onReceiveAd(param1:AdMobEvent) : void
      {
         log("Received ad:" + param1.isInterstitial + ":" + param1.dimensions);
         if(isBanner)
         {
            isShowAd = true;
            isWaiting = false;
         }
      }
      
      private static function onScreenPresented(param1:AdMobEvent) : void
      {
         log("Screen Presented.");
      }
      
      private static function onScreenDismissed(param1:AdMobEvent) : void
      {
         log("Screen Dismissed.");
      }
      
      private static function onLeaveApplication(param1:AdMobEvent) : void
      {
         log("Leave Application.");
      }
      
      private static function onRewardedVideoOpened(param1:AdMobEvent) : void
      {
         log("Rewarded video opened.");
      }
      
      private static function onRewardedVideoClosed(param1:AdMobEvent) : void
      {
         log("Rewarded video closed.");
         preloadRewardedVideoAd();
         if(finishCallback)
         {
            finishCallback(8,true);
            finishCallback = null;
         }
      }
      
      private static function onRewardedVideoStarted(param1:AdMobEvent) : void
      {
         log("Rewarded video started.");
      }
      
      private static function onRewardedVideoRewarded(param1:AdMobEvent) : void
      {
         log("Reward amount " + param1.rewardAmount + " won for type " + param1.rewardType);
         preloadRewardedVideoAd();
         if(finishCallback)
         {
            finishCallback(8,false);
            finishCallback = null;
         }
      }
      
      private static function log(param1:String) : void
      {
         trace("[AdMobExample] " + param1);
      }
   }
}
