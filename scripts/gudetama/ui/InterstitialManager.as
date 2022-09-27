package gudetama.ui
{
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.PromotionInterstitialSettingDef;
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
   
   public class InterstitialManager extends Sprite
   {
       
      
      private var currentIndex:int;
      
      private var updatetime:Number;
      
      private var interImagesAtlas:DynamicTextureAtlas;
      
      private var currentInterSetting:PromotionInterstitialSettingDef;
      
      private var eventInterID:String;
      
      private var interButton:ImageButton;
      
      private var interDefPosX:Number;
      
      private var intervalsec:int;
      
      private var iconlist:Object;
      
      private var lastRestSec:int = 0;
      
      public function InterstitialManager(param1:ImageButton, param2:Object, param3:Function, param4:TaskQueue)
      {
         var _interButton:ImageButton = param1;
         var _map:Object = param2;
         var _close:Function = param3;
         var _queue:TaskQueue = param4;
         interImagesAtlas = new DynamicTextureAtlas();
         iconlist = {};
         super();
         interButton = _interButton;
         interDefPosX = interButton.x;
         var currentTime:int = TimeZoneUtil.epochMillisToOffsetSecs();
         currentInterSetting = canShow(_map);
         if(!currentInterSetting)
         {
            _close();
            return;
         }
         intervalsec = currentInterSetting.intervalSec + 1000;
         interButton.addEventListener("triggered",function(param1:Event):void
         {
            var event:Event = param1;
            if(visible && currentInterSetting)
            {
               var webURL:String = currentInterSetting.webURL[Engine.platform];
               if(!webURL || webURL.length < 0)
               {
                  webURL = currentInterSetting.webURL[0];
               }
               if(currentInterSetting.browserType == 1)
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
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(243,currentInterSetting.id#2),function(param1:*):void
               {
               });
               _close();
            }
         });
         _queue.addTask(function():void
         {
            var interSetupQueue:TaskQueue = new TaskQueue();
            loadInterImages(interSetupQueue);
            interSetupQueue.registerOnProgress(function(param1:Number):void
            {
               if(param1 < 1)
               {
                  return;
               }
               var _loc2_:String = getEventInterID();
               interButton.topImage = getInterTexture(_loc2_);
               if(currentInterSetting != null)
               {
                  eventInterID = _loc2_;
               }
               _queue.taskDone();
            });
            interSetupQueue.startTask();
         });
         refresh();
      }
      
      private static function checkInbetweenLimitTime(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc7_:* = NaN;
         var _loc13_:Number = NaN;
         var _loc11_:String;
         var _loc4_:int = (_loc11_ = formatZero(Number(param1),4)).substr(0,2);
         var _loc5_:int = _loc11_.substr(2,2);
         var _loc6_:Date = UserDataWrapper.wrapper.getTimeZoneTime();
         var _loc12_:int = _loc11_ + "00";
         var _loc8_:int = _loc6_.getHours();
         var _loc9_:int = _loc6_.getMinutes();
         var _loc10_:int = _loc6_.getSeconds();
         var _loc3_:int = formatZero(_loc8_,2) + "" + formatZero(_loc9_,2) + "" + formatZero(_loc6_.getSeconds(),2);
         if(_loc3_ <= _loc12_)
         {
            if(param2)
            {
               _loc13_ = (_loc4_ - _loc8_) * 60 * 60 * 1000 + (_loc5_ - _loc9_) * 60 * 1000 + (0 - _loc10_ * 1000);
               _loc7_ = Number(UserDataWrapper.wrapper.getTimeZoneTimeInMillis() + _loc13_ - UserDataWrapper.wrapper.getTimeZoneOffset());
            }
            return true;
         }
         _loc7_ = -1;
         return false;
      }
      
      private static function formatZero(param1:Number, param2:Number) : String
      {
         var _loc3_:String = String(param1);
         var _loc4_:int = 0;
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
      private static function canShowCountry(param1:PromotionInterstitialSettingDef) : Boolean
      {
         if(param1.allowCountriyCodes.indexOf(0) == -1 && param1.allowCountriyCodes.indexOf(Engine.getCountryCode()) == -1)
         {
            return false;
         }
         return param1.allowCountryLocales.indexOf("all") >= 0 || param1.allowCountryLocales.indexOf(Engine.getLocale()) >= 0;
      }
      
      public static function canShow(param1:Object) : PromotionInterstitialSettingDef
      {
         var _loc3_:* = null;
         var _loc6_:* = null;
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc2_:int = TimeZoneUtil.epochMillisToOffsetSecs();
         for(_loc6_ in param1)
         {
            _loc4_ = Math.floor(Math.random() * 100);
            _loc4_ = (_loc4_ = Math.floor(Math.random() * 100)) + 1;
            _loc5_ = param1[_loc6_];
            if(canShowCountry(_loc5_))
            {
               if(_loc5_.endTimeStr != null && _loc5_.endTimeStr.length > 0)
               {
                  if(!checkInbetweenLimitTime(_loc5_.endTimeStr,true))
                  {
                     continue;
                  }
               }
               _loc3_ = _loc5_;
               if(_loc5_.visible && _loc5_.limitTimeSecs > _loc2_ && (_loc5_.startTimeSecs == -1 || _loc5_.startTimeSecs < _loc2_))
               {
                  if(_loc5_.rate != 0 && _loc5_.rate > _loc4_)
                  {
                     break;
                  }
               }
               else
               {
                  _loc3_ = null;
               }
            }
         }
         return _loc3_;
      }
      
      public function loadInterImages(param1:TaskQueue) : void
      {
         var _presetupQueue:TaskQueue = param1;
         interImagesAtlas.recreateLoadTask();
         _presetupQueue.addTask(function():void
         {
            var len:int = currentInterSetting.imageIDs.length;
            var i:int = 0;
            while(i < len)
            {
               if(!iconlist[currentInterSetting.imageIDs[i]])
               {
                  interImagesAtlas.loadSubTexBitmapData(currentInterSetting.imageIDs[i]);
                  iconlist[currentInterSetting.imageIDs[i]] = currentInterSetting.imageIDs[i];
               }
               i++;
            }
            var createQueue:TaskQueue = new TaskQueue();
            interImagesAtlas.createTextureAtlas(createQueue);
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
      
      public function getInterTexture(param1:String) : Texture
      {
         return interImagesAtlas.getTexture(param1);
      }
      
      public function start() : void
      {
         interButton.addEventListener("enterFrame",onEnterFrame);
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
         if(_loc1_ - updatetime > intervalsec)
         {
            updatetime = _loc1_;
            _loc2_ = getEventInterID();
            changeInterTexture(_loc2_);
         }
      }
      
      public function getEventInterID(param1:Boolean = false) : String
      {
         if(currentInterSetting.imageIDs.length <= 0)
         {
            return null;
         }
         if(currentInterSetting.imageIDs.length == 1)
         {
            return currentInterSetting.imageIDs[0];
         }
         var _loc2_:int = currentInterSetting.imageIDs.length;
         var _loc4_:String = null;
         var _loc3_:int = currentIndex;
         do
         {
            _loc3_++;
            if(_loc2_ <= _loc3_)
            {
               _loc3_ = 0;
            }
         }
         while(currentIndex == _loc3_);
         
         currentIndex = _loc3_;
         return currentInterSetting.imageIDs[_loc3_];
      }
      
      public function getCurrnetInterSetting() : PromotionInterstitialSettingDef
      {
         return currentInterSetting;
      }
      
      public function refresh() : void
      {
         updatetime = UserDataWrapper.wrapper.getTimeZoneTimeInMillis() - UserDataWrapper.wrapper.getTimeZoneOffset();
      }
      
      private function changeInterTexture(param1:String) : void
      {
         if(param1)
         {
            interButton.alpha = 1;
            interButton.visible = true;
            interButton.topImage = getInterTexture(param1);
         }
         else
         {
            interButton.visible = false;
         }
      }
      
      public function hasShowingInter() : Boolean
      {
         return getEventInterID(true) != null;
      }
      
      public function isSameInterID(param1:*) : Boolean
      {
         if(eventInterID == null)
         {
            return false;
         }
         return eventInterID == param1;
      }
      
      override public function dispose() : void
      {
         interImagesAtlas.dispose();
         interImagesAtlas = null;
         interButton.removeEventListener("enterFrame",onEnterFrame);
         interButton = null;
         super.dispose();
      }
   }
}
