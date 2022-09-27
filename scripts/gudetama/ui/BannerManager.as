package gudetama.ui
{
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.PromotionBannerSettingDef;
   import gudetama.engine.DynamicTextureAtlas;
   import gudetama.engine.Engine;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import muku.display.ImageButton;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class BannerManager extends Sprite
   {
       
      
      private var currentEventLimitTime:Number;
      
      private var currentIndex:int;
      
      private var bannerSettingList:Array;
      
      private var updatetime:Number;
      
      private var bannerImagesAtlas:DynamicTextureAtlas;
      
      private var currentBannerSetting:PromotionBannerSettingDef;
      
      private var eventBannerID:String;
      
      private var bannerButton:ImageButton;
      
      private var bannerDefPosX:Number;
      
      private var parentHeight:Number;
      
      private var queue:TaskQueue;
      
      private var iconlist:Object;
      
      private var lastRestSec:int = 0;
      
      public function BannerManager(param1:ImageButton, param2:Object, param3:TaskQueue = null)
      {
         var _bannerButton:ImageButton = param1;
         var _map:Object = param2;
         var _queue:TaskQueue = param3;
         bannerSettingList = [];
         bannerImagesAtlas = new DynamicTextureAtlas();
         iconlist = {};
         super();
         bannerButton = _bannerButton;
         visible = false;
         bannerDefPosX = bannerButton.x;
         parentHeight = bannerButton.parent.height;
         queue = _queue;
         for(key in _map)
         {
            bannerSettingList.push(_map[key]);
         }
         bannerButton.addEventListener("triggered",function(param1:Event):void
         {
            var event:Event = param1;
            if(visible && currentBannerSetting)
            {
               var webURL:String = currentBannerSetting.webURL[Engine.platform];
               if(!webURL || webURL.length <= 0)
               {
                  webURL = currentBannerSetting.webURL[0];
               }
               if(currentBannerSetting.browserType == 1)
               {
                  navigateToURL(new URLRequest(webURL),"_blank");
               }
               else
               {
                  WebViewDialog.show(webURL);
               }
               var _loc3_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(239,currentBannerSetting.id#2),function(param1:*):void
               {
               });
            }
         });
         if(queue)
         {
            queue.addTask(function():void
            {
               setup();
            });
         }
         else
         {
            setup();
         }
         refresh();
      }
      
      private function setup() : void
      {
         var bannerSetupQueue:TaskQueue = new TaskQueue();
         loadBannerImages(bannerSetupQueue);
         bannerSetupQueue.registerOnProgress(function(param1:Number):void
         {
            var _loc3_:Number = NaN;
            var _loc2_:int = 0;
            if(param1 < 1)
            {
               return;
            }
            var _loc4_:Texture = getBannerTexture(getEventBannerID());
            bannerButton.topImage = _loc4_;
            if(_loc4_)
            {
               bannerButton.width = _loc4_.width;
               bannerButton.height = _loc4_.height;
               bannerButton.pivotX = 0.5 * _loc4_.width;
               var _loc5_:* = Engine;
               _loc3_ = Engine.stage2D.stageWidth * gudetama.engine.Engine.designWidth / bannerButton.width / Engine.stage2D.stageWidth;
               _loc2_ = parentHeight - _loc4_.height;
               bannerButton.y = _loc2_ + (bannerButton.height - bannerButton.height * _loc3_);
               bannerButton.scaleX = _loc3_;
               bannerButton.scaleY = _loc3_;
            }
            if(currentBannerSetting != null)
            {
               eventBannerID = currentBannerSetting.bannerID;
            }
            if(queue)
            {
               queue.taskDone();
            }
         });
         bannerSetupQueue.startTask();
      }
      
      public function loadBannerImages(param1:TaskQueue) : void
      {
         var _presetupQueue:TaskQueue = param1;
         bannerImagesAtlas.recreateLoadTask();
         _presetupQueue.addTask(function():void
         {
            var len:int = bannerSettingList.length;
            var i:int = 0;
            while(i < len)
            {
               var event:PromotionBannerSettingDef = PromotionBannerSettingDef(bannerSettingList[i]);
               if(!iconlist[event.bannerID])
               {
                  bannerImagesAtlas.loadSubTexBitmapData(event.bannerID);
                  iconlist[event.bannerID] = event.bannerID;
               }
               i++;
            }
            var createQueue:TaskQueue = new TaskQueue();
            bannerImagesAtlas.createTextureAtlas(createQueue);
            createQueue.registerOnProgress(function(param1:Number):void
            {
               if(param1 < 1)
               {
                  return;
               }
               _presetupQueue.taskDone();
            });
         });
      }
      
      public function getBannerTexture(param1:String) : Texture
      {
         return bannerImagesAtlas.getTexture(param1);
      }
      
      public function start() : void
      {
         if(bannerButton)
         {
            bannerButton.removeEventListener("enterFrame",onEnterFrame);
            bannerButton.addEventListener("enterFrame",onEnterFrame);
         }
      }
      
      private function onEnterFrame(param1:EnterFrameEvent) : void
      {
         try
         {
            update();
         }
         catch(e:Error)
         {
         }
      }
      
      public function update() : void
      {
         var _loc2_:* = null;
         if(!visible)
         {
            return;
         }
         var _loc1_:Number = UserDataWrapper.wrapper.getTimeZoneTimeInMillis() - UserDataWrapper.wrapper.getTimeZoneOffset();
         if(_loc1_ - updatetime > GameSetting.def.rule.eventBannerUpdateTime)
         {
            updatetime = _loc1_;
            _loc2_ = getEventBannerID();
            changeBannerTexture(_loc2_);
         }
      }
      
      public function getEventBannerID(param1:Boolean = false) : String
      {
         var _loc6_:* = null;
         if(bannerSettingList.length <= 0)
         {
            return null;
         }
         var _loc2_:int = TimeZoneUtil.epochMillisToOffsetSecs();
         var _loc3_:int = bannerSettingList.length;
         var _loc4_:String = null;
         var _loc5_:int = currentIndex;
         while(true)
         {
            if((_loc6_ = PromotionBannerSettingDef(bannerSettingList[_loc5_])).visible && _loc6_.limitTimeSecs > _loc2_ && (_loc6_.startTimeSecs == -1 || _loc6_.startTimeSecs < _loc2_))
            {
               if(currentBannerSetting == null || currentBannerSetting.id#2 != _loc6_.id#2)
               {
                  _loc4_ = getBannerID(_loc6_);
               }
            }
            if(_loc4_)
            {
               break;
            }
            _loc5_++;
            if(_loc3_ <= _loc5_)
            {
               _loc5_ = 0;
            }
            if(currentIndex == _loc5_)
            {
               currentIndex = _loc5_;
               if(currentBannerSetting != null && (currentBannerSetting.limitTimeSecs > _loc2_ && (currentBannerSetting.startTimeSecs == -1 || currentBannerSetting.startTimeSecs < _loc2_)))
               {
                  return currentBannerSetting.bannerID;
               }
               currentEventLimitTime = -1;
               currentBannerSetting = null;
            }
            continue;
            return null;
         }
         currentIndex = _loc5_;
         return _loc4_;
      }
      
      private function getBannerID(param1:PromotionBannerSettingDef, param2:Boolean = false) : String
      {
         if(!canShowCountry(param1))
         {
            return null;
         }
         if(param1.endTimeStr != null && param1.endTimeStr.length > 0)
         {
            if(!checkInbetweenLimitTime(param1.endTimeStr,true))
            {
               return null;
            }
         }
         else
         {
            currentEventLimitTime = param1.limitTimeSecs - TimeZoneUtil.epochMillisToOffsetSecs();
         }
         if(!param2)
         {
            currentBannerSetting = param1;
         }
         if(currentBannerSetting && visible)
         {
            BannerAdvertisingManager.updateCyberStepBannerShowingCount(currentBannerSetting.id#2);
         }
         return param1.bannerID;
      }
      
      private function checkInbetweenLimitTime(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc12_:Number = NaN;
         var _loc7_:String;
         var _loc4_:int = (_loc7_ = formatZero(Number(param1),4)).substr(0,2);
         var _loc5_:int = _loc7_.substr(2,2);
         var _loc6_:Date = UserDataWrapper.wrapper.getTimeZoneTime();
         var _loc10_:int = _loc7_ + "00";
         var _loc8_:int = _loc6_.getHours();
         var _loc9_:int = _loc6_.getMinutes();
         var _loc11_:int = _loc6_.getSeconds();
         var _loc3_:int = formatZero(_loc8_,2) + "" + formatZero(_loc9_,2) + "" + formatZero(_loc6_.getSeconds(),2);
         if(_loc3_ <= _loc10_)
         {
            if(param2)
            {
               _loc12_ = (_loc4_ - _loc8_) * 60 * 60 * 1000 + (_loc5_ - _loc9_) * 60 * 1000 + (0 - _loc11_ * 1000);
               currentEventLimitTime = UserDataWrapper.wrapper.getTimeZoneTimeInMillis() + _loc12_ - UserDataWrapper.wrapper.getTimeZoneOffset();
            }
            return true;
         }
         currentEventLimitTime = -1;
         currentBannerSetting = null;
         return false;
      }
      
      private function formatZero(param1:Number, param2:Number) : String
      {
         var _loc3_:String = String(param1);
         var _loc4_:int = 0;
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
      public function refresh() : void
      {
         updatetime = UserDataWrapper.wrapper.getTimeZoneTimeInMillis() - UserDataWrapper.wrapper.getTimeZoneOffset();
      }
      
      private function changeBannerTexture(param1:String) : void
      {
         var _loc2_:* = null;
         if(param1)
         {
            bannerButton.alpha = 1;
            bannerButton.visible = true;
            _loc2_ = getBannerTexture(param1);
            bannerButton.setTopImage(_loc2_);
         }
         else
         {
            bannerButton.visible = false;
         }
      }
      
      public function hasShowingBanner() : Boolean
      {
         return getEventBannerID(true) != null;
      }
      
      public function isSameBannerID(param1:*) : Boolean
      {
         if(eventBannerID == null)
         {
            return false;
         }
         return eventBannerID == param1;
      }
      
      private function canShowCountry(param1:PromotionBannerSettingDef) : Boolean
      {
         if(param1.allowCountriyCodes.indexOf(0) == -1 && param1.allowCountriyCodes.indexOf(Engine.getCountryCode()) == -1)
         {
            return false;
         }
         return param1.allowCountryLocales.indexOf("all") >= 0 || param1.allowCountryLocales.indexOf(Engine.getLocale()) >= 0;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(bannerButton != null)
         {
            bannerButton.visible = param1 && currentBannerSetting != null;
         }
      }
      
      override public function dispose() : void
      {
         if(bannerImagesAtlas)
         {
            bannerImagesAtlas.dispose();
            bannerImagesAtlas = null;
         }
         bannerSettingList = null;
         if(bannerButton)
         {
            bannerButton.removeEventListener("enterFrame",onEnterFrame);
            bannerButton = null;
         }
         super.dispose();
      }
   }
}
