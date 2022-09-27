package gudetama.ui
{
   import flash.events.StageOrientationEvent;
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.common.VideoAdvertisingManager;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.StringUtil;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import starling.core.Starling;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   
   public class VideoAdConfirmDialog extends BaseScene
   {
      
      public static const RESULT_POSITIVE:int = 0;
      
      public static const RESULT_NEGATIVE:int = 1;
      
      public static const TYPE_CARNAVI:String = "start1";
      
      public static const TYPE_OTHER:String = "start2";
       
      
      private var type:String;
      
      private var title:String;
      
      private var message:String;
      
      private var caution:String;
      
      private var callback:Function;
      
      private var rest:int;
      
      private var residentMenuState:int;
      
      private var startCloseCallback:Function;
      
      private var titleText:ColorTextField;
      
      private var spineModel:SpineModel;
      
      private var bonusGroup:Sprite;
      
      private var bonusMessageText:ColorTextField;
      
      private var bonusCautionText:ColorTextField;
      
      private var bonusRestText:ColorTextField;
      
      private var otherGroup:Sprite;
      
      private var otherMessageText:ColorTextField;
      
      private var otherCautionText:ColorTextField;
      
      private var okButton:ContainerButton;
      
      private var cancelButton:ContainerButton;
      
      private var loadCount:int;
      
      private var isFocusLost:Boolean;
      
      private var isPendingAcquireReward:Boolean;
      
      private var alreadyShow:Boolean = false;
      
      private var videoShowing:Boolean = false;
      
      private var videoShowingSec:Number = 0;
      
      private var traceErrorSec:int;
      
      private var showMediuId:int = -1;
      
      private var choose:int = 1;
      
      public function VideoAdConfirmDialog(param1:String, param2:String, param3:String, param4:String, param5:Function, param6:int, param7:int, param8:Function)
      {
         super(2);
         VideoAdvertisingManager.setup(null,true);
         this.type = param1;
         this.title = param2;
         this.message = param3;
         this.caution = param4;
         this.callback = param5;
         this.rest = param6;
         this.residentMenuState = param7;
         this.traceErrorSec = GameSetting.getRule().videoTraceErrorSec;
         this.startCloseCallback = param8;
      }
      
      public static function show(param1:String, param2:String, param3:String, param4:String, param5:Function, param6:int = 0, param7:int = 94, param8:Function = null) : void
      {
         Engine.pushScene(new VideoAdConfirmDialog(param1,param2,param3,param4,param5,param6,param7,param8),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"VideoAdConfirmDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = dialogSprite.getChildByName("title") as ColorTextField;
            spineModel = dialogSprite.getChildByName("spineModel") as SpineModel;
            bonusGroup = dialogSprite.getChildByName("bonusGroup") as Sprite;
            bonusMessageText = bonusGroup.getChildByName("message") as ColorTextField;
            bonusCautionText = bonusGroup.getChildByName("caution") as ColorTextField;
            bonusRestText = bonusGroup.getChildByName("rest") as ColorTextField;
            otherGroup = dialogSprite.getChildByName("otherGroup") as Sprite;
            otherMessageText = otherGroup.getChildByName("message") as ColorTextField;
            otherCautionText = otherGroup.getChildByName("caution") as ColorTextField;
            cancelButton = dialogSprite.getChildByName("btn_cancel") as ContainerButton;
            cancelButton.enableDrawCache();
            cancelButton.addEventListener("triggered",triggeredCancelButton);
            okButton = dialogSprite.getChildByName("btn_ok") as ContainerButton;
            okButton.enableDrawCache();
            okButton.addEventListener("triggered",triggeredOkButton);
            displaySprite.visible = false;
            var _loc3_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GENERAL_GET_VIDEO_RATE),function(param1:String):void
            {
               DataStorage.getLocalData().setVideoAdsRate(param1);
               addChild(displaySprite);
            });
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
         });
         queue.startTask(onProgress);
      }
      
      private function setupLayoutForTask(param1:TaskQueue, param2:Object, param3:Function) : void
      {
         var queue:TaskQueue = param1;
         var layoutData:Object = param2;
         var callback:Function = param3;
         loadCount++;
         Engine.setupLayoutForTask(queue,layoutData,function(param1:Object):void
         {
            loadCount--;
            callback(param1);
            checkInit();
         });
      }
      
      private function addTask(param1:Function) : void
      {
         loadCount++;
         queue.addTask(param1);
      }
      
      private function taskDone() : void
      {
         loadCount--;
         checkInit();
         queue.taskDone();
      }
      
      private function checkInit() : void
      {
         if(loadCount > 0)
         {
            return;
         }
         init();
      }
      
      private function init() : void
      {
         setup();
      }
      
      private function setup() : void
      {
         titleText.text#2 = title;
         if(rest > 0)
         {
            bonusGroup.visible = true;
            bonusMessageText.text#2 = message;
            bonusCautionText.text#2 = caution;
            bonusRestText.text#2 = StringUtil.format(GameSetting.getUIText("videoAdConfirm.carnavi.rest"),rest);
            otherGroup.visible = false;
         }
         else
         {
            otherGroup.visible = true;
            otherMessageText.text#2 = message;
            otherCautionText.text#2 = caution;
            bonusGroup.visible = false;
         }
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.isIosPlatform() || true)
         {
            TweenAnimator.startItself(okButton,"ios");
            TweenAnimator.startItself(cancelButton,"ios");
         }
         else
         {
            TweenAnimator.startItself(okButton,"android");
            TweenAnimator.startItself(cancelButton,"android");
         }
         if(alreadyShow && Engine.stage2D.orientation != "default")
         {
            Engine.stage2D.setOrientation("default");
         }
         Engine.broadcastEventToSceneStackWith("update_scene");
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(VideoAdConfirmDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(residentMenuState);
         startUpdate();
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         spineModel.show();
         spineModel.changeAnimation(type,false,function():void
         {
            spineModel.changeAnimation(type + "_loop");
         });
         SoundManager.playEffect("lucky");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(VideoAdConfirmDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:int = 1) : void
      {
         var _choose:int = param1;
         SoundManager.resumeInApp();
         choose = _choose;
         super.backButtonCallback();
         setBackButtonCallback(null);
         if(startCloseCallback)
         {
            startCloseCallback(choose);
            startCloseCallback = null;
         }
         var _loc2_:* = Starling;
         starling.core.Starling.sCurrent.start();
         Engine.lockTouchInput(VideoAdConfirmDialog);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            if(alreadyShow)
            {
               fixRotation(true);
            }
            alreadyShow = false;
            Engine.unlockTouchInput(VideoAdConfirmDialog);
            Engine.popScene(scene);
            if(callback)
            {
               VideoAdvertisingManager.onResume();
               BannerAdvertisingManager.visibleBanner(true);
               callback(choose);
               callback = null;
            }
         });
      }
      
      protected function triggeredCancelButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      protected function triggeredOkButton(param1:Event) : void
      {
         var event:Event = param1;
         BannerAdvertisingManager.visibleBanner(false);
         showMediuId = -1;
         videoShowing = true;
         videoShowingSec = TimeZoneUtil.epochMillisToOffsetSecs();
         VideoAdvertisingManager.showVideoAds(videoCallback,function(param1:Boolean, param2:int):void
         {
            if(param1)
            {
               SoundManager.pauseInApp();
               Engine.lockTouchInput(VideoAdConfirmDialog);
               if(param2 != 6)
               {
                  var _loc3_:* = Starling;
                  starling.core.Starling.sCurrent.stop(true);
               }
            }
            else
            {
               videoShowing = false;
            }
         });
      }
      
      private function videoCallback(param1:int, param2:Boolean) : void
      {
         trace("show video medium " + param1 + ", skipped : " + param2);
         showMediuId = param1;
         alreadyShow = true;
         videoShowing = false;
         if(VideoAdvertisingManager.isPriority)
         {
            DataStorage.getLocalData().showedPriorityVideoCount++;
            if(GameSetting.getRule().priorityMaxVideoCount <= DataStorage.getLocalData().showedPriorityVideoCount)
            {
               DataStorage.getLocalData().setPriorityDate();
            }
         }
         VideoAdvertisingManager.resetCurrentVideoID();
         Engine.unlockTouchInput(VideoAdConfirmDialog);
         if(param2)
         {
            var _loc3_:* = Starling;
            starling.core.Starling.sCurrent.start();
            Engine.hideLoading();
            alreadyShow = false;
            BannerAdvertisingManager.visibleBanner(true);
            fixRotation();
            return;
         }
         if(!isFocusLost)
         {
            back(0);
         }
         else
         {
            isPendingAcquireReward = true;
         }
      }
      
      private function sendTimeCheckReport() : void
      {
         Logger.warn("Time has passed too much from revival of an Video : " + VideoAdvertisingManager.currentVideoID);
      }
      
      override protected function focusLost() : void
      {
         isFocusLost = true;
      }
      
      override protected function focusGainedFinish() : void
      {
         if(isPendingAcquireReward)
         {
            back(0);
            isPendingAcquireReward = false;
         }
         isFocusLost = false;
      }
      
      private function rotationFunction(param1:StageOrientationEvent = null) : void
      {
         if(Engine.stage2D.orientation != "default")
         {
            Engine.stage2D.removeEventListener("orientationChange",rotationFunction);
            Engine.stage2D.setOrientation("default");
         }
      }
      
      private function fixRotation(param1:Boolean = false) : void
      {
         if(showMediuId == 1)
         {
            if(Engine.stage2D.orientation != "default")
            {
               Engine.stage2D.setOrientation("default");
            }
         }
         else
         {
            Engine.stage2D.addEventListener("orientationChange",rotationFunction);
         }
      }
      
      override public function dispose() : void
      {
         titleText = null;
         spineModel = null;
         bonusGroup = null;
         bonusMessageText = null;
         bonusCautionText = null;
         bonusRestText = null;
         otherGroup = null;
         otherMessageText = null;
         otherCautionText = null;
         cancelButton.removeEventListener("triggered",triggeredCancelButton);
         cancelButton = null;
         okButton.removeEventListener("triggered",triggeredOkButton);
         okButton = null;
         BannerAdvertisingManager.visibleBanner(true);
         super.dispose();
      }
      
      public function startUpdate() : void
      {
         addEventListener("enterFrame",onEnterFrame);
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
         if(!videoShowing)
         {
            return;
         }
         if(VideoAdvertisingManager.currentVideoID == -1)
         {
            return;
         }
         var _loc1_:uint = TimeZoneUtil.epochMillisToOffsetSecs();
         if(_loc1_ - videoShowingSec > traceErrorSec)
         {
            removeEventListener("enterFrame",onEnterFrame);
            sendTimeCheckReport();
            videoShowing = false;
         }
      }
   }
}
