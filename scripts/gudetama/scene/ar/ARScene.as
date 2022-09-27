package gudetama.scene.ar
{
   import feathers.controls.supportClasses.ListDataViewPort;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.system.System;
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.NativeExtensions;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.LocalData;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.Packet;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.ar.ui.ARGudetamaStampItemRenderer;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.GuideTalkPanel;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.ManuallySpineButton;
   import muku.display.SimpleImageButton;
   import muku.display.ToggleButton;
   import muku.util.StarlingUtil;
   import starling.animation.DelayedCall;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.display.Sprite3D;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.rendering.Painter;
   import starling.textures.ConcreteTexture;
   import starling.textures.Texture;
   import starling.utils.deg2rad;
   
   public class ARScene extends BaseScene
   {
      
      public static const MAX_AR_TARGET_SCALE:Number = 2.8;
      
      private static var uniqueCounter:uint = 0;
       
      
      private var cameraLayer:Sprite;
      
      private var cameraImage:Image;
      
      private var modelContainer:Sprite;
      
      private var touchTextItemExtractor:SpriteExtractor;
      
      private var uiLayer:Sprite;
      
      private var homeBtn:ContainerButton;
      
      private var captureBtn:SimpleImageButton;
      
      private var lightingBtn:SimpleImageButton;
      
      private var changeCameraBtn:SimpleImageButton;
      
      private var arOnOffBtn:ContainerButton;
      
      private var toggleAR:ToggleButton;
      
      private var startScreenRecordBtn:SimpleImageButton;
      
      private var stopScreenRecordBtn:SimpleImageButton;
      
      private var capturedDialog:ARCapturedDialog;
      
      private var gudetamaListManager:GudetamaListManager;
      
      private var showGudetamaListBtn:SimpleImageButton;
      
      private var gudetamaStampListExtractor:SpriteExtractor;
      
      private var gudetamaExtractor:SpriteExtractor;
      
      private var gudetamaMap:Object;
      
      private var selectedUniqueId:int;
      
      private var editUI:EditUI;
      
      private var lightingManager:LightingManager;
      
      private var trackingManager:TrackingManager;
      
      private var facing:Boolean;
      
      private var enabledRecognizer:Boolean;
      
      private var captured:Boolean;
      
      private var startedScreenRecording:Boolean;
      
      private var cameraImageOffsetXY:Point;
      
      private var shareBonusItem:ItemParam;
      
      private var sortRepeatDelayedCall:DelayedCall;
      
      private var firstARRecognized:Boolean;
      
      private var repeatDelayedCall:DelayedCall;
      
      private var lostGudetamaList:Vector.<GudetamaView>;
      
      public function ARScene()
      {
         gudetamaMap = {};
         lostGudetamaList = new Vector.<GudetamaView>();
         super(0);
         uniqueCounter = 0;
      }
      
      public static function show() : BaseScene
      {
         var _loc1_:ARScene = new ARScene();
         Engine.switchScene(_loc1_);
         return _loc1_;
      }
      
      public static function generateUniqueID() : uint
      {
         return ++uniqueCounter;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(capturedDialog)
         {
            capturedDialog.dispose();
            capturedDialog = null;
         }
         for(var _loc1_ in gudetamaMap)
         {
            (gudetamaMap[_loc1_] as GudetamaView).dispose();
            gudetamaMap[_loc1_] = null;
            delete gudetamaMap[_loc1_];
         }
         touchTextItemExtractor = null;
         if(trackingManager)
         {
            trackingManager.dispose();
            trackingManager = null;
         }
         if(sortRepeatDelayedCall)
         {
            sortRepeatDelayedCall.dispatchEventWith("removeFromJuggler");
            sortRepeatDelayedCall = null;
         }
         ResidentMenuUI_Gudetama.setSkipUnchangedFrames(true);
         ResidentMenuUI_Gudetama.setSceneFrameRate(Engine.requestedFramerate);
      }
      
      override public function isSkipUnchangedFrames() : Boolean
      {
         return false;
      }
      
      override protected function focusLost() : void
      {
         if(captured)
         {
            return;
         }
         if(startedScreenRecording && !gudetama.common.NativeExtensions.arExt.isIgnorePause())
         {
            stopScreenRecord();
         }
         var _loc2_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.pause();
      }
      
      override protected function focusGainedFinish() : void
      {
         if(captured)
         {
            return;
         }
         var _loc1_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.resume();
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var preQueue:TaskQueue = new TaskQueue();
         Engine.setupLayoutForTask(preQueue,"ARLayout",function(param1:Object):void
         {
            displaySprite = param1.object as Sprite;
            cameraLayer = displaySprite.getChildByName("cameraLayer") as Sprite;
            cameraImage = cameraLayer.getChildByName("cameraImage") as Image;
            cameraImage.touchable = true;
            cameraImage.addEventListener("touch",touchedCameraImage);
            var _loc2_:Sprite = cameraLayer.getChildByName("arContainer") as Sprite;
            modelContainer = _loc2_.getChildByName("gudetamaContainer") as Sprite;
            uiLayer = displaySprite.getChildByName("uiLayer") as Sprite;
            changeCameraBtn = uiLayer.getChildByName("changeCameraBtn") as SimpleImageButton;
            changeCameraBtn.addEventListener("triggered",triggeredChangeCamera);
            captureBtn = uiLayer.getChildByName("captureBtn") as SimpleImageButton;
            captureBtn.addEventListener("triggered",triggeredCapturedBtn);
            homeBtn = uiLayer.getChildByName("homeBtn") as ContainerButton;
            homeBtn.addEventListener("triggered",triggeredGotoHomeButton);
            arOnOffBtn = uiLayer.getChildByName("arOnOffBtn") as ContainerButton;
            arOnOffBtn.addEventListener("triggered",triggeredSwitchAR);
            toggleAR = arOnOffBtn.getChildByName("toggle") as ToggleButton;
            toggleAR.touchable = false;
            toggleAR.isSelected = true;
            enabledRecognizer = true;
            startedScreenRecording = false;
            startScreenRecordBtn = uiLayer.getChildByName("startRecordBtn") as SimpleImageButton;
            startScreenRecordBtn.addEventListener("triggered",triggeredStartScreenRecord);
            stopScreenRecordBtn = uiLayer.getChildByName("stopRecordBtn") as SimpleImageButton;
            stopScreenRecordBtn.addEventListener("triggered",triggeredStopScreenRecord);
            stopScreenRecordBtn.visible = false;
            showGudetamaListBtn = uiLayer.getChildByName("gudetamaListBtn") as SimpleImageButton;
            showGudetamaListBtn.addEventListener("triggered",triggeredGudetamaList);
            gudetamaListManager = new GudetamaListManager(scene as ARScene,uiLayer.getChildByName("gudetamaListContainer") as Sprite);
            lightingBtn = uiLayer.getChildByName("lightingBtn") as SimpleImageButton;
            lightingBtn.addEventListener("triggered",triggeredlighting);
            lightingManager = new LightingManager(scene as ARScene,uiLayer.getChildByName("lightingContainer") as Sprite,cameraImage);
            lightingManager.setFilter(cameraImage);
            editUI = new EditUI(scene as ARScene,_loc2_.getChildByName("editSprite") as Sprite);
            editUI.visible = false;
            trackingManager = new TrackingManager(scene as ARScene,_loc2_.getChildByName("targetMarker") as Sprite3D);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(preQueue,"_ARCapturedDialogLayout",function(param1:Object):void
         {
            capturedDialog = new ARCapturedDialog(param1.object as Sprite);
         });
         Engine.setupLayoutForTask(preQueue,"_TouchText",function(param1:Object):void
         {
            touchTextItemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         Engine.setupLayoutForTask(preQueue,"_ARGudetamaStampListItem",function(param1:Object):void
         {
            gudetamaStampListExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         Engine.setupLayoutForTask(preQueue,"_ARGudetama",function(param1:Object):void
         {
            gudetamaExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         preQueue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setup(onProgress);
         });
         preQueue.startTask();
      }
      
      private function setup(param1:Function) : void
      {
         var onProgress:Function = param1;
         gudetamaListManager.setupList(gudetamaStampListExtractor);
         Engine.setupLayoutForTask(queue,"_ARStamp",function(param1:Object):void
         {
            capturedDialog.setStampExtractor(SpriteExtractor.forGross(param1.object,param1));
            capturedDialog.setStampListExtractor(gudetamaStampListExtractor);
         });
         queue.addTask(function():void
         {
            var _loc1_:* = NativeExtensions;
            gudetama.common.NativeExtensions.arExt.initAR(function():void
            {
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            var packet:Packet = PacketUtil.create(PACKET_GET_SHARE_BONUS_PARAM);
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(packet,function(param1:Object):void
            {
               shareBonusItem = !!param1 ? param1[0] as ItemParam : null;
               queue.taskDone();
            });
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            var _loc2_:* = NativeExtensions;
            gudetama.common.NativeExtensions.arExt.start(cameraImage);
            var _loc3_:* = NativeExtensions;
            cameraImageOffsetXY = gudetama.common.NativeExtensions.arExt.getCameraImageOffsetXY();
            var _loc4_:* = NativeExtensions;
            gudetama.common.NativeExtensions.arExt.resetRecognizer();
            trackingManager.setVisibleTargetMarker(true);
            trackingManager.setup();
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         captured = false;
         displaySprite.visible = true;
         setVisibleState(0);
         addEventListener("enterFrame",update);
         ResidentMenuUI_Gudetama.setSkipUnchangedFrames(isSkipUnchangedFrames());
         processNoticeTutorial(14,noticeTutorialAction,getGuideArrowPos);
         var localData:LocalData = DataStorage.getLocalData();
         if(!localData.isARMode())
         {
            enabledRecognizer = false;
            switchARMode(enabledRecognizer);
         }
         firstARRecognized = false;
         if(shareBonusItem)
         {
            firstARRecognized = true;
            SnsShareDialog.showShareBonus(shareBonusItem,GameSetting.getUIText("ar.shareRecommend.msg"),function():void
            {
               firstARRecognized = false;
            });
         }
         setBackButtonCallback(triggeredHardwareBackKey);
         var _loc2_:* = Starling;
         sortRepeatDelayedCall = (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).repeatCallWithoutPool(function():void
         {
            if(!enabledRecognizer)
            {
               return;
            }
            if(modelContainer.numChildren <= 1)
            {
               return;
            }
            modelContainer.sortChildren(function(param1:DisplayObject, param2:DisplayObject):int
            {
               if(param1.userObject.cameraDistance < param2.userObject.cameraDistance)
               {
                  return 1;
               }
               if(param1.userObject.cameraDistance > param2.userObject.cameraDistance)
               {
                  return -1;
               }
               return 0;
            });
         },1);
      }
      
      private function dropGudetamaAtFirstARRecognized() : void
      {
         if(isPlaceableGudetama())
         {
            var gudetamaId:int = UserDataWrapper.wrapper.getPlacedGudetamaId();
            gudetamaListManager.notifyAddedGudetama(gudetamaId);
            createGudetama(gudetamaId,function(param1:GudetamaView):void
            {
            },true);
            firstARRecognized = true;
         }
      }
      
      private function update(param1:EnterFrameEvent) : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc7_:* = NativeExtensions;
         var _loc4_:ARParam;
         if(!(_loc4_ = gudetama.common.NativeExtensions.arExt.update()))
         {
            return;
         }
         var _loc5_:Object = _loc4_.targetMap;
         for(var _loc6_ in _loc5_)
         {
            _loc2_ = _loc5_[_loc6_] as TargetData;
            _loc3_ = gudetamaMap[_loc2_.id#2];
            if(_loc3_)
            {
               _loc3_.update(_loc2_,_loc4_);
            }
         }
         trackingManager.update(_loc4_);
         if(!firstARRecognized)
         {
            dropGudetamaAtFirstARRecognized();
         }
      }
      
      private function triggeredHardwareBackKey() : void
      {
         if(startedScreenRecording)
         {
            var _loc1_:* = NativeExtensions;
            gudetama.common.NativeExtensions.arExt.stopScreenRecording();
            startedScreenRecording = false;
            Engine.setHardwareBackKeyFunction(null);
            changeScreenRecordingUI(false);
         }
         else if(gudetamaListManager.isShow())
         {
            gudetamaListManager.hide();
         }
         else if(lightingManager.isShow())
         {
            lightingManager.hide();
         }
         else
         {
            triggeredGotoHomeButton(null);
         }
      }
      
      private function triggeredGudetamaList(param1:Event) : void
      {
         if(lightingManager.isShow())
         {
            lightingManager.hide();
         }
         gudetamaListManager.show();
         trackingManager.setVisibleTargetMarker(enabledRecognizer && !facing);
         resumeNoticeTutorial(14,noticeTutorialAction,getGuideArrowPos);
      }
      
      private function triggeredlighting(param1:Event) : void
      {
         var event:Event = param1;
         if(gudetamaListManager.isShow())
         {
            gudetamaListManager.hide(function():void
            {
               trackingManager.setVisibleTargetMarker(false);
               lightingManager.show();
            });
         }
         else
         {
            lightingManager.show();
         }
      }
      
      private function touchedCameraImage(param1:TouchEvent) : void
      {
         var _loc2_:* = null;
         var _loc3_:Touch = param1.getTouch(cameraImage,"ended");
         if(_loc3_)
         {
            if(gudetamaListManager.isShow())
            {
               gudetamaListManager.hide();
               trackingManager.setVisibleTargetMarker(false);
            }
            if(lightingManager.isShow())
            {
               lightingManager.hide();
            }
            if(editUI.visible)
            {
               _loc2_ = gudetamaMap[selectedUniqueId] as GudetamaView;
               if(_loc2_)
               {
                  _loc2_.hideGrid();
               }
               editUI.visible = false;
               editUI.setView(null);
               selectedUniqueId = -1;
            }
         }
      }
      
      private function triggeredChangeCamera(param1:Event) : void
      {
         var event:Event = param1;
         Engine.closeTransition(function():void
         {
            BannerAdvertisingManager.hideAllBanner();
            juggler.delayCall(function():void
            {
               resetPlacedGudetama();
               trackingManager.reset();
               facing = !facing;
               var _loc1_:* = NativeExtensions;
               gudetama.common.NativeExtensions.arExt.changeCamera(facing);
               trackingManager.setup();
               trackingManager.setFacing(facing);
               if(facing)
               {
                  enabledRecognizer = false;
                  switchARMode(enabledRecognizer);
               }
               else
               {
                  var localData:LocalData = DataStorage.getLocalData();
                  if(enabledRecognizer != localData.isARMode())
                  {
                     enabledRecognizer = localData.isARMode();
                     switchARMode(enabledRecognizer);
                  }
               }
               juggler.delayCall(function():void
               {
                  Engine.openTransition(null,1);
                  BannerAdvertisingManager.showBannerAds();
               },1);
            },1);
         },1);
      }
      
      private function triggeredCapturedBtn(param1:Event) : void
      {
         var event:Event = param1;
         if(gudetamaListManager.getCurrentPlacedNum() <= 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("%ar.notCapture.notPlacedGudetama"),null,null,68);
            return;
         }
         uiLayer.touchable = false;
         editUI.visible = false;
         editUI.setView(null);
         var view:GudetamaView = gudetamaMap[selectedUniqueId] as GudetamaView;
         if(view)
         {
            view.hideGrid();
         }
         selectedUniqueId = -1;
         Engine.lockTouchInput(ARScene);
         Logger.info("triggered AR Capture os : {}, restoreDisabled:{}, mem : {}, RegistrantCount:{}",Capabilities.os,ConcreteTexture.restoreDisabled,System.totalMemoryNumber / 1024,ConcreteTexture.getRegistrantCountText());
         Engine.showLoading();
         var _loc3_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.captureRequest(function(param1:BitmapData, param2:Number, param3:Boolean):void
         {
            var stillBitmapData:BitmapData = param1;
            var cameraImageRot:Number = param2;
            var changeWidthHeight:Boolean = param3;
            var _loc4_:* = NativeExtensions;
            gudetama.common.NativeExtensions.arExt.pause();
            var resultBitmapData:BitmapData = processCapturedComposition(stillBitmapData,cameraImageRot,changeWidthHeight);
            captured = true;
            removeEventListener("enterFrame",update);
            Engine.unlockTouchInput(ARScene);
            capturedDialog.show(resultBitmapData,cameraImageRot,function(param1:Boolean):void
            {
               uiLayer.touchable = true;
               if(param1)
               {
                  resetPlacedGudetama();
                  var _loc3_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.arExt.finish();
               }
               else
               {
                  for(var _loc2_ in gudetamaMap)
                  {
                     view = gudetamaMap[_loc2_] as GudetamaView;
                     if(view)
                     {
                        modelContainer.addChild(view.getDisplayObject());
                     }
                  }
                  captured = false;
                  addEventListener("enterFrame",update);
                  var _loc6_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.arExt.resume();
               }
            });
         });
      }
      
      private function triggeredResetBtn(param1:Event) : void
      {
         resetPlacedGudetama();
         trackingManager.reset();
         var _loc2_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.resetRecognizer();
         LocalMessageDialog.show(9,GameSetting.getUIText("ar.gudetama.reset.msg"),null,GameSetting.getUIText("ar.gudetama.reset.title"),68);
         trackingManager.setup();
      }
      
      public function resetPlacedGudetama() : void
      {
         var _loc1_:* = null;
         for(var _loc2_ in gudetamaMap)
         {
            _loc1_ = gudetamaMap[_loc2_] as GudetamaView;
            var _loc3_:* = NativeExtensions;
            gudetama.common.NativeExtensions.arExt.removeTarget(_loc2_);
            _loc1_.dispose();
            gudetamaMap[_loc2_] = null;
            delete gudetamaMap[_loc2_];
            gudetamaListManager.notifyRemovedGudetama(_loc1_.getGudetamaID(),true);
         }
         editUI.visible = false;
         selectedUniqueId = -1;
      }
      
      private function triggeredGotoHomeButton(param1:Event) : void
      {
         var event:Event = param1;
         Engine.lockTouchInput(ARScene);
         removeEventListener("enterFrame",update);
         resetPlacedGudetama();
         var _loc2_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.finish();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.unlockTouchInput(ARScene);
            if(UserDataWrapper.wrapper.isCompletedTutorial())
            {
               Engine.switchScene(new HomeScene());
            }
            else
            {
               Engine.switchScene(new HomeScene(),1,0.5,true);
            }
         });
      }
      
      private function triggeredRemoveGudetama(param1:Event) : void
      {
         removeGudetama(selectedUniqueId);
         editUI.visible = false;
         selectedUniqueId = -1;
      }
      
      private function triggeredSwitchAR(param1:Event) : void
      {
         enabledRecognizer = !enabledRecognizer;
         switchARMode(enabledRecognizer);
         var _loc2_:LocalData = DataStorage.getLocalData();
         _loc2_.setARMode(enabledRecognizer);
         DataStorage.saveLocalData();
      }
      
      private function switchARMode(param1:Boolean) : void
      {
         toggleAR.isSelected = enabledRecognizer;
         var _loc2_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.toggleRecognizer(enabledRecognizer);
         trackingManager.modifiedEnableRecognizer(enabledRecognizer);
         if(enabledRecognizer && gudetamaListManager.isShow())
         {
            trackingManager.setVisibleTargetMarker(true);
         }
         else
         {
            trackingManager.setVisibleTargetMarker(false);
         }
      }
      
      private function triggeredStartScreenRecord(param1:Event) : void
      {
         var event:Event = param1;
         if(gudetamaListManager.getCurrentPlacedNum() <= 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("%ar.notCapture.notPlacedGudetama"),null,null,68);
            return;
         }
         ARScreenRecordConfirmDialog.show(function(param1:Boolean):void
         {
            if(!param1)
            {
               return;
            }
            startScreenRecord();
         });
      }
      
      private function triggeredStopScreenRecord(param1:Event) : void
      {
         stopScreenRecord();
      }
      
      private function startScreenRecord() : void
      {
         startedScreenRecording = true;
         changeScreenRecordingUI(true,function():void
         {
            var _loc1_:* = NativeExtensions;
            if(gudetama.common.NativeExtensions.arExt.isSupportedScreenRecording())
            {
               var _loc2_:* = NativeExtensions;
               gudetama.common.NativeExtensions.arExt.startScreenRecording(function(param1:String, param2:Boolean):void
               {
                  var moviePath:String = param1;
                  var canceled:Boolean = param2;
                  if(canceled)
                  {
                     startedScreenRecording = false;
                     changeScreenRecordingUI(false);
                  }
                  else
                  {
                     Engine.showLoading(ARScene);
                     var _loc3_:* = Starling;
                     (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
                     {
                        SnsShareDialog.showShareVideo(moviePath,1,true);
                        Engine.hideLoading(ARScene);
                     },2);
                  }
               });
            }
         });
      }
      
      private function stopScreenRecord() : void
      {
         startedScreenRecording = false;
         var _loc1_:* = NativeExtensions;
         if(gudetama.common.NativeExtensions.arExt.isSupportedScreenRecording())
         {
            var _loc2_:* = NativeExtensions;
            gudetama.common.NativeExtensions.arExt.stopScreenRecording();
         }
         changeScreenRecordingUI(false);
      }
      
      private function changeScreenRecordingUI(param1:Boolean, param2:Function = null) : void
      {
         var on:Boolean = param1;
         var callback:Function = param2;
         var len:int = uiLayer.numChildren;
         var i:int = 0;
         while(i < len)
         {
            uiLayer.getChildAt(i).visible = !on;
            i++;
         }
         lightingManager.setVisible(false);
         gudetamaListManager.setVisible(false);
         if(on)
         {
            stopScreenRecordBtn.visible = true;
            trackingManager.setVisibleTargetMarker(false);
            TweenAnimator.startItself(uiLayer,"recordOn");
            var _loc4_:* = NativeExtensions;
            if(!gudetama.common.NativeExtensions.arExt.isSupportedScreenRecording())
            {
               var _loc5_:* = Engine;
               LocalMessageDialog.show(0,GameSetting.getUIText("%ar.screenRecord.msg.invalid." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))),null,null,1);
               return;
            }
            if(callback)
            {
               callback();
            }
            if(selectedUniqueId >= 0)
            {
               var view:GudetamaView = gudetamaMap[selectedUniqueId] as GudetamaView;
               if(view)
               {
                  view.hideGrid();
               }
               editUI.visible = false;
               editUI.setView(null);
               selectedUniqueId = -1;
            }
            BannerAdvertisingManager.hideAllBanner();
         }
         else
         {
            BannerAdvertisingManager.showBannerAds();
            TweenAnimator.startItself(uiLayer,"recordOff",false,function(param1:DisplayObject):void
            {
               stopScreenRecordBtn.visible = false;
            });
         }
         var _loc6_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.adjustCameraImage(facing,on);
      }
      
      public function createGudetama(param1:int, param2:Function, param3:Boolean = false) : void
      {
         var gid:int = param1;
         var callback:Function = param2;
         var visibleTargetMark:Boolean = param3;
         var uid:uint = generateUniqueID();
         var _loc5_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.addTarget(uid);
         var base:Sprite = gudetamaExtractor.duplicateAll() as Sprite;
         var gudetamaBtn:ManuallySpineButton = base.getChildAt(0) as ManuallySpineButton;
         var gudetamaView:GudetamaView = new GudetamaView(gudetamaBtn);
         gudetamaView.init(this,gid,uid,touchTextItemExtractor,function():void
         {
            var _loc1_:* = null;
            modelContainer.addChild(gudetamaBtn);
            gudetamaMap[uid] = gudetamaView;
            if(enabledRecognizer)
            {
               _loc1_ = trackingManager.getTargetPosition();
               var _loc2_:* = NativeExtensions;
               gudetama.common.NativeExtensions.arExt.unproject(uid,_loc1_.x,_loc1_.y);
               var _loc3_:* = NativeExtensions;
               gudetama.common.NativeExtensions.arExt.startAppearance(uid);
            }
            else
            {
               gudetamaBtn.x = cameraImage.width * 0.5;
               gudetamaBtn.y = cameraImage.height * 0.5;
            }
            callback(gudetamaView);
            trackingManager.setVisibleTargetMarker(visibleTargetMark);
         });
      }
      
      public function setSelectedGudetama(param1:int) : void
      {
         var _loc2_:* = null;
         if(selectedUniqueId == param1 || isRecording())
         {
            return;
         }
         selectedUniqueId = param1;
         for(var _loc3_ in gudetamaMap)
         {
            if(_loc3_ != param1)
            {
               _loc2_ = gudetamaMap[_loc3_] as GudetamaView;
               _loc2_.hideGrid();
            }
         }
         _loc2_ = gudetamaMap[param1] as GudetamaView;
         _loc2_.showGrid(editUI);
         if(!enabledRecognizer)
         {
            modelContainer.setChildIndex(_loc2_.getDisplayObject(),modelContainer.numChildren - 1);
         }
      }
      
      public function removeGudetama(param1:int) : void
      {
         var _loc2_:GudetamaView = gudetamaMap[param1] as GudetamaView;
         var _loc3_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.removeTarget(param1);
         _loc2_.dispose();
         gudetamaMap[param1] = null;
         delete gudetamaMap[param1];
         gudetamaListManager.notifyRemovedGudetama(_loc2_.getGudetamaID(),false);
      }
      
      private function processCapturedComposition(param1:BitmapData, param2:Number, param3:Boolean) : BitmapData
      {
         var capturedBitmapData:BitmapData = param1;
         var cameraImageRot:Number = param2;
         var changeWidthHeight:Boolean = param3;
         var capturedTexture:Texture = Texture.fromBitmapData(capturedBitmapData);
         var capturedImage:Image = new Image(capturedTexture);
         if(changeWidthHeight)
         {
            var capturedWidth:Number = capturedTexture.height;
            var capturedHeight:Number = capturedTexture.width;
         }
         else
         {
            capturedWidth = capturedTexture.width;
            capturedHeight = capturedTexture.height;
            capturedImage.rotation = deg2rad(cameraImageRot);
            if(cameraImageRot == 90)
            {
               capturedImage.x = capturedHeight;
               capturedImage.y = 0;
            }
            else if(cameraImageRot == 270)
            {
               capturedImage.x = capturedHeight;
               capturedImage.y = capturedWidth;
               if(facing)
               {
                  capturedImage.scaleY *= -1;
               }
            }
            else if(cameraImageRot == 180)
            {
               capturedImage.x = 0;
               capturedImage.y = 0;
            }
            else if(isFacing())
            {
               capturedImage.x = capturedHeight;
               capturedImage.y = capturedWidth;
               capturedImage.rotation = deg2rad(-90);
               capturedImage.scaleY *= -1;
            }
            else
            {
               capturedImage.x = capturedHeight;
               capturedImage.y = 0;
               capturedImage.rotation = deg2rad(90);
            }
         }
         lightingManager.setFilter(capturedImage);
         var canvas:Sprite = new Sprite();
         canvas.addChild(capturedImage);
         var map:Object = {};
         for(key in gudetamaMap)
         {
            var view:GudetamaView = gudetamaMap[key] as GudetamaView;
            var dObj:DisplayObject = view.getDisplayObject();
            dObj.userObject["key"] = key;
            map[key] = modelContainer.getChildIndex(dObj);
         }
         var offsetX:Number = cameraImageOffsetXY.x / cameraImage.width;
         for(key in gudetamaMap)
         {
            view = gudetamaMap[key] as GudetamaView;
            dObj = view.getDisplayObject();
            canvas.addChild(dObj);
            dObj.x = capturedHeight * (view.screenPosX + offsetX);
            dObj.y = capturedWidth * view.screenPosY;
            var _loc7_:* = Engine;
            dObj.scaleX = dObj.scaleX * capturedHeight / gudetama.engine.Engine.designWidth;
            var _loc8_:* = Engine;
            dObj.scaleY = dObj.scaleY * capturedWidth / (gudetama.engine.Engine.designWidth * (capturedWidth / capturedHeight));
            dObj.visible = true;
         }
         canvas.sortChildren(function(param1:DisplayObject, param2:DisplayObject):int
         {
            if(map[param1.userObject.key] > map[param2.userObject.key])
            {
               return 1;
            }
            if(map[param1.userObject.key] < map[param2.userObject.key])
            {
               return -1;
            }
            return 0;
         });
         var _loc11_:* = Starling;
         var _starling:Starling = starling.core.Starling.sCurrent;
         var _loc12_:* = Starling;
         var painter:Painter = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null;
         var viewPort:Rectangle = _starling.viewPort;
         var stageWidth:Number = viewPort.width;
         var stageHeight:Number = viewPort.height;
         var sectionResult:BitmapData = new BitmapData(stageWidth,stageHeight,true,0);
         var sectionResultRect:Rectangle = StarlingUtil.getRectangleFromPool();
         sectionResultRect.setTo(0,0,stageWidth,stageHeight);
         var result:BitmapData = new BitmapData(capturedHeight,capturedWidth,false,0);
         var point:Point = StarlingUtil.getPointFromPool();
         var i:int = 0;
         while(i < Math.ceil(capturedHeight / stageWidth))
         {
            var j:int = 0;
            while(j < Math.ceil(capturedWidth / stageHeight))
            {
               canvas.x = -i * stageWidth;
               canvas.y = -j * stageHeight;
               painter.clear();
               painter.pushState();
               painter.state.renderTarget = null;
               painter.state.setModelviewMatricesToIdentity();
               painter.setStateTo(canvas.transformationMatrix);
               painter.state.setProjectionMatrix(0,0,stageWidth,stageHeight,stageWidth,stageHeight,stage.cameraPosition);
               canvas.render(painter);
               painter.finishMeshBatch();
               painter.context.drawToBitmapData(sectionResult);
               painter.popState();
               point.setTo(i * stageWidth,j * stageHeight);
               result.copyPixels(sectionResult,sectionResultRect,point);
               j++;
            }
            i++;
         }
         sectionResult.dispose();
         sectionResult = null;
         lightingManager.setFilter(cameraImage);
         return result;
      }
      
      public function autoResetRecognizer() : void
      {
         for(key in gudetamaMap)
         {
            var view:GudetamaView = gudetamaMap[key] as GudetamaView;
            var _loc2_:* = NativeExtensions;
            gudetama.common.NativeExtensions.arExt.removeTarget(key);
            lostGudetamaList.push(view);
            gudetamaMap[key] = null;
            delete gudetamaMap[key];
            gudetamaListManager.notifyRemovedGudetama(view.getGudetamaID(),true);
         }
         editUI.visible = false;
         selectedUniqueId = -1;
         trackingManager.reset();
         var _loc5_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.resetRecognizer();
         trackingManager.setup();
         repeatDelayedCall = getSceneJuggler().repeatCallWithoutPool(function():void
         {
            var _loc2_:* = null;
            var _loc5_:int = 0;
            var _loc1_:* = 0;
            var _loc4_:Number = NaN;
            if(!trackingManager.isTracking())
            {
               return;
            }
            if(repeatDelayedCall)
            {
               repeatDelayedCall.dispatchEventWith("removeFromJuggler");
               repeatDelayedCall = null;
            }
            var _loc3_:int = lostGudetamaList.length;
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc2_ = lostGudetamaList[_loc5_];
               _loc1_ = uint(generateUniqueID());
               var _loc6_:* = NativeExtensions;
               gudetama.common.NativeExtensions.arExt.addTarget(_loc1_);
               _loc2_.setUniqueId(_loc1_);
               gudetamaListManager.notifyAddedGudetama(_loc2_.getGudetamaID());
               if(_loc2_.screenPosX >= 0 && _loc2_.screenPosY >= 0 && _loc2_.screenPosX <= 1 && _loc2_.screenPosY <= 1)
               {
                  var _loc7_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.arExt.unproject(_loc1_,_loc2_.screenPosX,_loc2_.screenPosY);
               }
               else
               {
                  _loc4_ = (cameraImage.width / 2 - cameraImageOffsetXY.x) / cameraImage.width;
                  var _loc8_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.arExt.unproject(_loc1_,_loc4_,0.5);
               }
               gudetamaMap[_loc1_] = _loc2_;
               _loc5_++;
            }
            lostGudetamaList.length = 0;
         },0.3);
      }
      
      public function getCameraImage() : Image
      {
         return cameraImage;
      }
      
      public function enabledRecognizerAR() : Boolean
      {
         return enabledRecognizer;
      }
      
      public function isRecording() : Boolean
      {
         return startedScreenRecording;
      }
      
      public function isFacing() : Boolean
      {
         return facing;
      }
      
      public function getCameraImageOffset() : Point
      {
         return cameraImageOffsetXY;
      }
      
      public function setEnableCaptureAndRecordBtn(param1:Boolean) : void
      {
      }
      
      public function isPlaceableGudetama() : Boolean
      {
         return trackingManager.isPlaceableGudetama() || !enabledRecognizerAR();
      }
      
      public function noticeTutorialAction(param1:int) : void
      {
         var index:int = param1;
         switch(int(index))
         {
            case 0:
               if(!UserDataWrapper.wrapper.isCompletedTutorial())
               {
                  var guide:GuideTalkPanel = Engine.getGuideTalkPanel();
                  guide.setFinishCallback(function():void
                  {
                     touchable = false;
                     var progress:int = UserDataWrapper.wrapper.getTutorialProgress() + 1;
                     var _loc2_:* = HttpConnector;
                     if(gudetama.net.HttpConnector.mainConnector == null)
                     {
                        gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
                     }
                     gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(PACKET_CHECK_AND_START_TUTORIAL_GUIDE,progress),function(param1:Object):void
                     {
                        var response:Object = param1;
                        GuideTalkPanel.showTutorial(GameSetting.def.guideTalkTable[progress],noticeTutorialAction,null,function():void
                        {
                           touchable = true;
                        });
                     });
                  });
                  break;
               }
               break;
            case 1:
               enableButton4Tutorial();
               homeBtn.touchable = true;
               break;
            case 2:
               enableButton4Tutorial();
               showGudetamaListBtn.touchable = true;
               break;
            case 3:
               enableButton4Tutorial();
               break;
            case 4:
               enableButton4Tutorial();
               captureBtn.touchable = true;
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc3_:* = undefined;
         var _loc2_:* = null;
         var _loc4_:* = null;
         switch(int(param1))
         {
            case 0:
               return GudetamaUtil.getCenterPosAndWHOnEngine(showGudetamaListBtn);
            case 1:
               _loc2_ = gudetamaListManager.getList().getChildAt(0) as ListDataViewPort;
               if((_loc4_ = _loc2_.getChildAt(0) as ARGudetamaStampItemRenderer) != null)
               {
                  return GudetamaUtil.getCenterPosAndWHOnEngine(_loc4_);
               }
               break;
            case 3:
               _loc3_ = GudetamaUtil.getCenterPosAndWHOnEngine(homeBtn);
               break;
            default:
               break;
            case 2:
               return GudetamaUtil.getCenterPosAndWHOnEngine(captureBtn);
         }
         return _loc3_;
      }
      
      private function enableButton4Tutorial() : void
      {
         homeBtn.touchable = false;
         captureBtn.touchable = false;
         showGudetamaListBtn.touchable = false;
         lightingBtn.touchable = false;
         changeCameraBtn.touchable = false;
      }
   }
}

import flash.geom.Point;
import flash.geom.Rectangle;
import gestouch.events.GestureEvent;
import gestouch.gestures.SwipeGesture;
import gudetama.common.NativeExtensions;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.TouchEventParam;
import gudetama.engine.Engine;
import gudetama.engine.SoundManager;
import gudetama.engine.TweenAnimator;
import gudetama.scene.ar.ARScene;
import gudetama.scene.home.ui.TouchTextGroup;
import gudetama.util.SpriteExtractor;
import muku.core.TaskQueue;
import muku.display.ManuallySpineButton;
import muku.util.StarlingUtil;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.utils.MathUtil;
import starling.utils.deg2rad;

class GudetamaView
{
   
   private static const CTRL_BTN_SIZE:Number = 50.0;
   
   private static const GUDETAMA_ANIMATION_MIN:Number = deg2rad(45);
   
   private static const GUDETAMA_ANIMATION_MAX:Number = deg2rad(135);
    
   
   private var uniqueId:int;
   
   private var gudetamaId:int;
   
   private var control:ARScene;
   
   private var view:ManuallySpineButton;
   
   private var touchTextSprite:Sprite;
   
   private var touchTextGroup:TouchTextGroup;
   
   private var scaleOffset:Number;
   
   private var lockTouchEvent:Boolean;
   
   private var firstCameraDistance:Number;
   
   private var rotateOffset:Number;
   
   private var editUI:EditUI;
   
   private var screenPosRateX:Number;
   
   private var screenPosRateY:Number;
   
   private var swipe:SwipeGesture;
   
   private var currentLocate:Point;
   
   function GudetamaView(param1:ManuallySpineButton)
   {
      super();
      view = param1;
      rotateOffset = 0;
      scaleOffset = 1;
   }
   
   public function dispose() : void
   {
      touchTextGroup.dispose();
      view.removeFromParent(true);
      control = null;
      if(swipe)
      {
         swipe.dispose();
         swipe = null;
      }
   }
   
   public function get screenPosX() : Number
   {
      return screenPosRateX;
   }
   
   public function get screenPosY() : Number
   {
      return screenPosRateY;
   }
   
   public function getDisplayObject() : DisplayObject
   {
      return view;
   }
   
   public function getGudetamaID() : int
   {
      return gudetamaId;
   }
   
   public function getUniqueID() : int
   {
      return uniqueId;
   }
   
   public function getScaleOffset() : Number
   {
      return scaleOffset;
   }
   
   public function setScaleOffset(param1:Number) : void
   {
      scaleOffset = param1;
   }
   
   public function getRotateOffset() : Number
   {
      return rotateOffset;
   }
   
   public function setRotateOffset(param1:Number) : void
   {
      rotateOffset = param1;
   }
   
   public function isAnimation() : Boolean
   {
      return touchTextGroup.isShow() || view.isTweening();
   }
   
   public function setUniqueId(param1:int) : void
   {
      uniqueId = param1;
   }
   
   public function init(param1:ARScene, param2:int, param3:uint, param4:SpriteExtractor, param5:Function) : void
   {
      var control:ARScene = param1;
      var gid:int = param2;
      var uid:uint = param3;
      var extractor:SpriteExtractor = param4;
      var callback:Function = param5;
      this.control = control;
      gudetamaId = gid;
      uniqueId = uid;
      firstCameraDistance = 0;
      view.setStopPropagation(true);
      view.setTouchMovedCancel(true);
      view.addEventListener("triggered",triggeredGudetamaButton);
      view.addEventListener("touch",touchedGudetamaButton);
      touchTextSprite = view.getChildByName("touchTextGroup") as Sprite;
      touchTextGroup = new TouchTextGroup(touchTextSprite);
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
      var queue:TaskQueue = new TaskQueue();
      view.setup(queue,gudetamaDef.id#2);
      queue.startTask(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
         setupTouchText(gudetamaDef.id#2,extractor,callback);
      });
      swipe = new SwipeGesture(view);
      swipe.minVelocity = 80;
      swipe.direction = 12;
      swipe.addEventListener("gestureRecognized",function(param1:GestureEvent):void
      {
         if(!control.isRecording())
         {
            return;
         }
         var _loc2_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.startAppearance(uid);
      });
   }
   
   private function setupTouchText(param1:int, param2:SpriteExtractor, param3:Function) : void
   {
      var id:int = param1;
      var extractor:SpriteExtractor = param2;
      var callback:Function = param3;
      var queue:TaskQueue = new TaskQueue();
      var spineRect:Rectangle = StarlingUtil.getRectangleFromPool();
      spineRect = view.getSpineBounds(spineRect);
      touchTextGroup.setup(queue,id,extractor,spineRect);
      queue.startTask(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
         callback();
         control.setSelectedGudetama(uniqueId);
      });
   }
   
   public function update(param1:TargetData, param2:ARParam) : void
   {
      var _loc6_:int = 0;
      var _loc3_:Number = NaN;
      var _loc5_:Number = NaN;
      var _loc7_:* = null;
      if(param2.sceneMappingState == 2 && firstCameraDistance == 0)
      {
         firstCameraDistance = param1.cameraDistance;
      }
      var _loc4_:Image = control.getCameraImage();
      if(control.enabledRecognizerAR())
      {
         screenPosRateX = param1.screenPosX;
         screenPosRateY = param1.screenPosY;
         var _loc9_:* = NativeExtensions;
         if((_loc6_ = gudetama.common.NativeExtensions.arExt.getCameraImageRot()) == 90)
         {
            view.x = _loc4_.width * screenPosRateX;
            view.y = _loc4_.height * screenPosRateY;
         }
         else if(_loc6_ == 180)
         {
            view.x = _loc4_.width * screenPosRateX;
            view.y = _loc4_.height * screenPosRateY;
         }
         else if(_loc6_ == 270)
         {
            view.x = _loc4_.width * screenPosRateX;
            view.y = _loc4_.height * screenPosRateY;
         }
         else
         {
            view.x = _loc4_.width * screenPosRateX;
            view.y = _loc4_.height * screenPosRateY;
         }
         if(firstCameraDistance > 0)
         {
            _loc3_ = 1 / param1.cameraDistance;
            view.scale = MathUtil.min(2.8,scaleOffset * _loc3_ * 0.05);
         }
         else
         {
            view.scale = 0;
         }
         view.rotation = param2.cameraRot.z + rotateOffset;
         _loc5_ = ((_loc5_ = MathUtil.clamp(param1.theta,GUDETAMA_ANIMATION_MIN,GUDETAMA_ANIMATION_MAX)) - GUDETAMA_ANIMATION_MIN) / (GUDETAMA_ANIMATION_MAX - GUDETAMA_ANIMATION_MIN);
         view.setManuallySpineTime(_loc5_);
         view.userObject.cameraDistance = param1.cameraDistance;
      }
      else
      {
         screenPosRateX = view.x / _loc4_.width;
         screenPosRateY = view.y / _loc4_.height;
         view.scale = scaleOffset;
         view.rotation = rotateOffset;
         view.setManuallySpineTime(0.5);
      }
      var _loc8_:Rectangle = StarlingUtil.getRectangleFromPool();
      _loc8_ = view.getSpineBounds(_loc8_);
      touchTextGroup.updateRect(_loc8_);
      touchTextSprite.x = _loc8_.width / 2;
      if(control.enabledRecognizerAR())
      {
         view.visible = param2.recognized;
         view.touchable = !param1.appearance;
         if(editUI)
         {
            editUI.visible = !touchTextGroup.isShow() && !view.isTweening() && param2.recognized && !param1.appearance;
         }
         if(param2.recognized && param1.landingSound)
         {
            TweenAnimator.startTween(view.getSpineDisplayObject(),"GUDETAMA_RELEASED",null);
            SoundManager.playEffect("put_egg");
         }
      }
      else
      {
         view.visible = true;
      }
      if(editUI)
      {
         (_loc7_ = StarlingUtil.getRectangleFromPool()).setTo(view.x,view.y,view.width,view.height);
         if(view.scale < 0.6)
         {
            _loc7_.width = _loc7_.width / view.scale * 0.6;
            _loc7_.height = _loc7_.height / view.scale * 0.6;
         }
         else if(view.width > view.height)
         {
            _loc7_.setTo(view.x,view.y,view.width,view.height);
            if(view.width > 450)
            {
               _loc7_.width = 450;
               _loc7_.height = view.height / view.scale * (450 / (view.width / view.scale));
            }
         }
         else if(view.width <= view.height)
         {
            _loc7_.setTo(view.x,view.y,view.width,view.height);
            if(view.height > 450)
            {
               _loc7_.height = view.width / view.scale * (450 / (view.height / view.scale));
               _loc7_.width = 450;
            }
         }
         editUI.update(_loc7_,view.rotation);
      }
   }
   
   public function showGrid(param1:EditUI) : void
   {
      editUI = param1;
      editUI.visible = true;
      editUI.setView(this);
   }
   
   public function hideGrid() : void
   {
      editUI = null;
   }
   
   private function touchedGudetamaButton(param1:TouchEvent) : void
   {
      var _loc5_:* = null;
      var _loc3_:* = null;
      var _loc2_:* = null;
      var _loc9_:* = null;
      var _loc4_:Number = NaN;
      var _loc8_:Number = NaN;
      var _loc6_:int = 0;
      var _loc7_:* = null;
      if(isAnimation() || control.isRecording())
      {
         return;
      }
      if(_loc5_ = param1.getTouch(view,"began"))
      {
         currentLocate = null;
      }
      if(_loc5_ = param1.getTouch(view,"moved"))
      {
         control.setSelectedGudetama(uniqueId);
         _loc3_ = control.getCameraImage();
         _loc2_ = StarlingUtil.getPointFromPool();
         _loc9_ = StarlingUtil.getPointFromPool();
         var _loc10_:* = Engine;
         if(!(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0) || !control.enabledRecognizerAR())
         {
            _loc2_ = _loc5_.getLocation(view.parent,_loc2_);
            _loc9_ = _loc5_.getPreviousLocation(view.parent,_loc9_);
            view.x += _loc2_.x - _loc9_.x;
            view.y += _loc2_.y - _loc9_.y;
            return;
         }
         _loc5_.getLocation(_loc3_,_loc2_);
         _loc5_.getPreviousLocation(_loc3_,_loc9_);
         if(!currentLocate)
         {
            currentLocate = new Point();
            currentLocate.setTo(view.x,view.y);
         }
         var _loc11_:* = NativeExtensions;
         _loc6_ = gudetama.common.NativeExtensions.arExt.getCameraImageRot();
         var _loc12_:* = Starling;
         _loc7_ = starling.core.Starling.sCurrent.viewPort;
         if(_loc6_ == 90)
         {
            currentLocate.y += _loc2_.x - _loc9_.x;
            if(control.isFacing())
            {
               currentLocate.x += _loc2_.y - _loc9_.y;
            }
            else
            {
               currentLocate.x += _loc9_.y - _loc2_.y;
            }
            _loc4_ = currentLocate.x / _loc3_.width * _loc7_.width / _loc7_.width;
            _loc8_ = currentLocate.y / _loc3_.height * _loc7_.height / _loc7_.height;
         }
         else if(_loc6_ == 180)
         {
            currentLocate.y += _loc2_.x - _loc9_.x;
            currentLocate.x += _loc9_.y - _loc2_.y;
            _loc4_ = 1 - currentLocate.x / _loc3_.texture.width;
            _loc8_ = currentLocate.y / _loc3_.texture.height;
         }
         else if(_loc6_ == 270)
         {
            currentLocate.y += _loc9_.x - _loc2_.x;
            currentLocate.x += _loc9_.y - _loc2_.y;
            _loc4_ = currentLocate.x / _loc3_.width * _loc7_.width / _loc7_.width;
            _loc8_ = currentLocate.y / _loc3_.height * _loc7_.height / _loc7_.height;
         }
         else
         {
            if(control.isFacing())
            {
               currentLocate.x += _loc9_.y - _loc2_.y;
               currentLocate.y += _loc9_.x - _loc2_.x;
            }
            else
            {
               currentLocate.x += _loc9_.y - _loc2_.y;
               currentLocate.y += _loc2_.x - _loc9_.x;
            }
            _loc4_ = currentLocate.x / _loc3_.width * _loc7_.width / _loc7_.width;
            _loc8_ = currentLocate.y / _loc3_.height * _loc7_.height / _loc7_.height;
         }
         var _loc13_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.unproject(uniqueId,_loc4_,_loc8_);
      }
      if(_loc5_ = param1.getTouch(view,"ended"))
      {
         currentLocate = null;
      }
   }
   
   private function triggeredGudetamaButton(param1:Event) : void
   {
      control.setSelectedGudetama(uniqueId);
      touchTextGroup.show();
      playGudetamaSE();
      var _loc2_:TouchEventParam = UserDataWrapper.wrapper.getNextTouchEvent();
      if(!_loc2_)
      {
         return;
      }
      if(!lockTouchEvent)
      {
         processPlayVoice(_loc2_);
      }
   }
   
   public function processPlayVoice(param1:TouchEventParam) : void
   {
      var _loc3_:int = 0;
      if(!param1.isPlayVoice())
      {
         return;
      }
      var _loc2_:GudetamaDef = GameSetting.getGudetama(gudetamaId);
      if(param1.voice == -1)
      {
         _loc3_ = 0;
         if(UserDataWrapper.gudetamaPart.isUnlockedVoice(_loc2_.id#2,_loc3_))
         {
         }
      }
      else if(param1.voice == -2)
      {
         _loc3_ = 1;
      }
   }
   
   public function playGudetamaSE() : void
   {
      if(Math.random() > 0.5)
      {
         SoundManager.playEffect("put_egg");
      }
      else
      {
         SoundManager.playEffect("tap_nisetama");
      }
   }
}

import feathers.controls.IScrollBar;
import feathers.controls.List;
import feathers.controls.ScrollBar;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.TiledRowsLayout;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaData;
import gudetama.engine.TweenAnimator;
import gudetama.scene.ar.ARExpansionDialog;
import gudetama.scene.ar.ARScene;
import gudetama.scene.ar.ui.ARGudetamaStampItemRenderer;
import gudetama.ui.LocalMessageDialog;
import gudetama.util.SpriteExtractor;
import muku.display.ContainerButton;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class GudetamaListManager
{
    
   
   private var control:ARScene;
   
   private var listContainer:Sprite;
   
   private var list:List;
   
   private var collection:ListCollection;
   
   private var resetBtn:ContainerButton;
   
   private var plusBtn:SimpleImageButton;
   
   private var placedGudetamaNumText:ColorTextField;
   
   private var currentPlaceNum:int;
   
   private var placeCountMap:Object;
   
   function GudetamaListManager(param1:ARScene, param2:Sprite)
   {
      super();
      this.control = param1;
      this.listContainer = param2;
      listContainer.visible = false;
      list = listContainer.getChildByName("list") as List;
      (listContainer.getChildByName("bg_mat") as Image).touchable = true;
      (listContainer.getChildByName("bar_mat") as Image).touchable = true;
      resetBtn = listContainer.getChildByName("resetBtn") as ContainerButton;
      resetBtn.addEventListener("triggered",triggeredResetGudetama);
      resetBtn.enableDrawCache(true,false,true);
      resetBtn.enabled = false;
      var _loc3_:Sprite = listContainer.getChildByName("plusContainer") as Sprite;
      plusBtn = _loc3_.getChildByName("plusBtn") as SimpleImageButton;
      plusBtn.addEventListener("triggered",triggeredGudetamaPlus);
      placedGudetamaNumText = _loc3_.getChildByName("numText") as ColorTextField;
      collection = new ListCollection();
      currentPlaceNum = 0;
      placeCountMap = {};
      updatePlaceNum();
   }
   
   public function setupList(param1:SpriteExtractor) : void
   {
      var extractor:SpriteExtractor = param1;
      var map:Object = UserDataWrapper.gudetamaPart.getGudetamaMap();
      for(key in map)
      {
         var gudetamaData:GudetamaData = map[key] as GudetamaData;
         if(gudetamaData.num > 0)
         {
            placeCountMap[key] = gudetamaData.num;
            collection.push({
               "gudetamaId":key,
               "countMap":placeCountMap
            });
         }
      }
      (collection.data#2 as Array).sort(function(param1:Object, param2:Object):int
      {
         var _loc4_:int = GameSetting.getGudetama(param1.gudetamaId).number;
         var _loc3_:int = GameSetting.getGudetama(param2.gudetamaId).number;
         return _loc4_ - _loc3_;
      });
      var layout:TiledRowsLayout = new TiledRowsLayout();
      layout.verticalAlign = "center";
      layout.horizontalAlign = "left";
      layout.useSquareTiles = false;
      layout.requestedColumnCount = 6;
      layout.horizontalGap = 15;
      layout.verticalGap = 5;
      list.layout = layout;
      list.hasElasticEdges = false;
      list.autoHideBackground = true;
      list.itemRendererFactory = function():IListItemRenderer
      {
         var _loc1_:ARGudetamaStampItemRenderer = new ARGudetamaStampItemRenderer(extractor);
         _loc1_.addEventListener("triggered",triggeredGudetamaItemEvent);
         return _loc1_;
      };
      list.verticalScrollBarFactory = function():IScrollBar
      {
         var _loc1_:ScrollBar = new ScrollBar();
         _loc1_.userObject["scene"] = ARScene;
         return _loc1_;
      };
      list.scrollBarDisplayMode = "fixed";
      list.horizontalScrollPolicy = "off";
      list.interactionMode = "touchAndScrollBars";
      list.dataProvider = collection;
      list.validate();
   }
   
   public function getCurrentPlacedNum() : int
   {
      return currentPlaceNum;
   }
   
   public function isShow() : Boolean
   {
      return listContainer.visible;
   }
   
   public function show() : void
   {
      if(isShow())
      {
         hide();
      }
      else
      {
         listContainer.visible = listContainer.touchable = true;
         TweenAnimator.startItself(listContainer.parent,"showGudetamaList");
      }
   }
   
   public function hide(param1:Function = null) : void
   {
      var callback:Function = param1;
      TweenAnimator.startItself(listContainer.parent,"hide",false,function(param1:DisplayObject):void
      {
         listContainer.visible = listContainer.touchable = false;
         if(callback)
         {
            callback();
         }
      });
   }
   
   public function setVisible(param1:Boolean) : void
   {
      listContainer.visible = listContainer.touchable = param1;
   }
   
   private function triggeredResetGudetama(param1:Event) : void
   {
      control.resetPlacedGudetama();
      LocalMessageDialog.show(9,GameSetting.getUIText("ar.gudetama.reset.msg"),null,GameSetting.getUIText("ar.gudetama.reset.title"),68);
   }
   
   private function triggeredGudetamaItemEvent(param1:Event) : void
   {
      var event:Event = param1;
      var data:Object = event.data#2;
      if(!data || isAlreadyPlaceMax() || placeCountMap[data.gudetamaId] <= 0 || !control.isPlaceableGudetama())
      {
         return;
      }
      notifyAddedGudetama(data.gudetamaId);
      control.createGudetama(data.gudetamaId,function(param1:GudetamaView):void
      {
         var view:GudetamaView = param1;
         hide(function():void
         {
            control.resumeNoticeTutorial(14,control.noticeTutorialAction,control.getGuideArrowPos);
         });
      });
   }
   
   public function notifyAddedGudetama(param1:int) : void
   {
      currentPlaceNum++;
      updatePlaceNum();
      placeCountMap[param1]--;
      collection.updateAll();
      resetBtn.enableDrawCache(true,false,false);
      resetBtn.enabled = true;
      control.setEnableCaptureAndRecordBtn(true);
   }
   
   public function notifyRemovedGudetama(param1:int, param2:Boolean) : void
   {
      if(currentPlaceNum > 0)
      {
         currentPlaceNum--;
      }
      updatePlaceNum();
      placeCountMap[param1]++;
      if(param2)
      {
         if(currentPlaceNum <= 0)
         {
            collection.updateAll();
            resetBtn.enableDrawCache(true,false,true);
            resetBtn.enabled = false;
            control.setEnableCaptureAndRecordBtn(false);
         }
      }
      else
      {
         collection.updateAll();
         if(currentPlaceNum <= 0)
         {
            resetBtn.enableDrawCache(true,false,true);
            resetBtn.enabled = false;
            control.setEnableCaptureAndRecordBtn(false);
         }
      }
   }
   
   private function triggeredGudetamaPlus(param1:Event) : void
   {
      var event:Event = param1;
      var _loc2_:* = UserDataWrapper;
      var maxPlace:int = GameSetting.getRule().placeArGudetamaNumTable[gudetama.data.UserDataWrapper.wrapper._data.placeGudetamaExpansionCount];
      var _loc4_:* = UserDataWrapper;
      if(GameSetting.getRule().placeArGudetamaNumTable.length - 1 <= gudetama.data.UserDataWrapper.wrapper._data.placeGudetamaExpansionCount)
      {
         LocalMessageDialog.show(2,GameSetting.getUIText("ar.gudetama.expansion.fullMsg"),null,GameSetting.getUIText("ar.gudetama.expansion.title"),68);
         return;
      }
      ARExpansionDialog.show(0,function(param1:Boolean):void
      {
         if(!param1)
         {
            return;
         }
         updatePlaceNum();
      });
   }
   
   private function updatePlaceNum() : void
   {
      var _loc2_:* = UserDataWrapper;
      var _loc1_:int = GameSetting.getRule().placeArGudetamaNumTable[gudetama.data.UserDataWrapper.wrapper._data.placeGudetamaExpansionCount];
      placedGudetamaNumText.text#2 = currentPlaceNum.toString() + "/" + _loc1_.toString();
   }
   
   private function isAlreadyPlaceMax() : Boolean
   {
      var _loc2_:* = UserDataWrapper;
      var _loc1_:int = GameSetting.getRule().placeArGudetamaNumTable[gudetama.data.UserDataWrapper.wrapper._data.placeGudetamaExpansionCount];
      return currentPlaceNum >= _loc1_;
   }
   
   public function getList() : List
   {
      return list;
   }
}

import feathers.controls.Slider;
import gudetama.engine.TweenAnimator;
import gudetama.scene.ar.ARScene;
import muku.display.ContainerButton;
import muku.display.RGBAToBGRAStyle;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class LightingManager
{
    
   
   private var control:ARScene;
   
   private var lightingContainer:Sprite;
   
   private var slider:Slider;
   
   private var colorOffsetStyle:RGBAToBGRAStyle;
   
   function LightingManager(param1:ARScene, param2:Sprite, param3:Image)
   {
      super();
      this.control = param1;
      colorOffsetStyle = new RGBAToBGRAStyle();
      lightingContainer = param2;
      lightingContainer.visible = lightingContainer.touchable = false;
      slider = lightingContainer.getChildByName("slider") as Slider;
      slider.direction = "horizontal";
      slider.trackLayoutMode = "split";
      slider.userObject["scene"] = ARScene;
      slider.addEventListener("change",changedLightingSlider);
      slider.value = 0;
      var _loc4_:ContainerButton;
      (_loc4_ = lightingContainer.getChildByName("resetBtn") as ContainerButton).addEventListener("triggered",triggeredResetLighting);
      (lightingContainer.getChildByName("bg_mat") as Image).touchable = true;
      (lightingContainer.getChildByName("bar_mat") as Image).touchable = true;
   }
   
   public function dispose() : void
   {
      if(colorOffsetStyle)
      {
         colorOffsetStyle = null;
      }
   }
   
   public function setFilter(param1:Image) : void
   {
      param1.style = colorOffsetStyle;
   }
   
   public function isShow() : Boolean
   {
      return lightingContainer.visible;
   }
   
   public function show() : void
   {
      if(isShow())
      {
         hide();
      }
      else
      {
         lightingContainer.visible = lightingContainer.touchable = true;
         TweenAnimator.startItself(lightingContainer.parent,"showLighting");
      }
   }
   
   public function hide() : void
   {
      TweenAnimator.startItself(lightingContainer.parent,"hide",false,function(param1:DisplayObject):void
      {
         lightingContainer.visible = lightingContainer.touchable = false;
      });
   }
   
   public function setVisible(param1:Boolean) : void
   {
      lightingContainer.visible = lightingContainer.touchable = param1;
   }
   
   public function reset() : void
   {
      slider.value = 0;
      colorOffsetStyle.setTo(0,0,0);
   }
   
   private function changedLightingSlider(param1:Event) : void
   {
      var _loc2_:Number = slider.value;
      colorOffsetStyle.setTo(_loc2_,_loc2_,_loc2_);
   }
   
   private function triggeredResetLighting(param1:Event) : void
   {
      reset();
   }
}

import flash.geom.Point;
import flash.geom.Rectangle;
import gudetama.engine.Logger;
import gudetama.scene.ar.ARScene;
import muku.display.SimpleImageButton;
import muku.util.StarlingUtil;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.utils.MathUtil;

class EditUI
{
   
   public static const MAX_FRAME_SIZE:Number = 450.0;
   
   private static const CTRL_BTN_OFFSET:Number = 46.0;
    
   
   private var control:ARScene;
   
   private var displaySprite:Sprite;
   
   private var frame:Image;
   
   private var removeBtn:SimpleImageButton;
   
   private var ctrlLeftTopBtn:Quad;
   
   private var ctrlLeftBottomBtn:Quad;
   
   private var ctrlRightBottomBtn:Quad;
   
   private var view:GudetamaView;
   
   private var startDistance:Number;
   
   function EditUI(param1:ARScene, param2:Sprite)
   {
      super();
      this.control = param1;
      displaySprite = param2;
      frame = displaySprite.getChildByName("frame") as Image;
      removeBtn = displaySprite.getChildByName("removeBtn") as SimpleImageButton;
      removeBtn.setStopPropagation(true);
      removeBtn.addEventListener("triggered",triggeredRemoveBtn);
      ctrlLeftTopBtn = displaySprite.getChildByName("ctrlLeftTopBtn") as Quad;
      ctrlLeftTopBtn.touchable = true;
      ctrlLeftTopBtn.addEventListener("touch",touchedCtrlBtn);
      ctrlLeftBottomBtn = displaySprite.getChildByName("ctrlLeftBottomBtn") as Quad;
      ctrlLeftBottomBtn.touchable = true;
      ctrlLeftBottomBtn.addEventListener("touch",touchedCtrlBtn);
      ctrlRightBottomBtn = displaySprite.getChildByName("ctrlRightBottomBtn") as Quad;
      ctrlRightBottomBtn.touchable = true;
      ctrlRightBottomBtn.addEventListener("touch",touchedCtrlBtn);
   }
   
   public function get visible() : Boolean
   {
      return displaySprite.visible;
   }
   
   public function set visible(param1:Boolean) : void
   {
      displaySprite.visible = param1;
   }
   
   public function setView(param1:GudetamaView) : void
   {
      view = param1;
   }
   
   public function update(param1:Rectangle, param2:Number) : void
   {
      var _loc3_:Point = StarlingUtil.getPointFromPool();
      _loc3_.setTo(param1.width + 60,param1.height + 60);
      frame.width = _loc3_.x;
      frame.height = _loc3_.y;
      removeBtn.x = _loc3_.x - 30;
      removeBtn.y = 30;
      ctrlLeftTopBtn.x = 46;
      ctrlLeftTopBtn.y = 46;
      ctrlLeftBottomBtn.x = 46;
      ctrlLeftBottomBtn.y = _loc3_.y - 46;
      ctrlRightBottomBtn.x = _loc3_.x - 46;
      ctrlRightBottomBtn.y = _loc3_.y - 46;
      displaySprite.x = param1.x;
      displaySprite.y = param1.y;
      displaySprite.pivotX = _loc3_.x * 0.5;
      displaySprite.pivotY = _loc3_.y * 0.5;
      displaySprite.rotation = param2;
   }
   
   private function triggeredRemoveBtn(param1:Event) : void
   {
      visible = false;
      if(!view)
      {
         return;
      }
      control.removeGudetama(view.getUniqueID());
   }
   
   private function touchedCtrlBtn(param1:TouchEvent) : void
   {
      var _loc10_:* = null;
      var _loc7_:* = null;
      var _loc9_:* = null;
      var _loc5_:* = null;
      var _loc2_:* = null;
      var _loc3_:Number = NaN;
      var _loc6_:* = null;
      var _loc8_:Number = NaN;
      var _loc4_:Number = NaN;
      try
      {
         param1.stopPropagation();
         if(!view || view.isAnimation())
         {
            return;
         }
         _loc10_ = view.getDisplayObject();
         _loc2_ = param1.target as Quad;
         if(_loc7_ = param1.getTouch(_loc2_,"began"))
         {
            _loc10_ = view.getDisplayObject();
            (_loc9_ = StarlingUtil.getPointFromPool()).setTo(_loc10_.x,_loc10_.y);
            _loc5_ = StarlingUtil.getPointFromPool();
            _loc7_.getLocation(_loc10_.parent,_loc5_);
            startDistance = StarlingUtil.distance(_loc9_.x,_loc9_.y,_loc5_.x,_loc5_.y) * 2 / view.getScaleOffset();
         }
         if(_loc7_ = param1.getTouch(_loc2_,"moved"))
         {
            _loc10_ = view.getDisplayObject();
            (_loc9_ = StarlingUtil.getPointFromPool()).setTo(_loc10_.x,_loc10_.y);
            _loc5_ = StarlingUtil.getPointFromPool();
            _loc7_.getLocation(_loc10_.parent,_loc5_);
            _loc3_ = Math.atan2(_loc9_.y - _loc5_.y,_loc9_.x - _loc5_.x);
            _loc6_ = StarlingUtil.getPointFromPool();
            _loc7_.getPreviousLocation(_loc10_.parent,_loc6_);
            _loc8_ = Math.atan2(_loc9_.y - _loc6_.y,_loc9_.x - _loc6_.x);
            view.setRotateOffset(view.getRotateOffset() + (_loc3_ - _loc8_));
            _loc4_ = StarlingUtil.distance(_loc9_.x,_loc9_.y,_loc5_.x,_loc5_.y) * 2;
            view.setScaleOffset(MathUtil.min(1 / (startDistance / _loc4_),5));
            control.setSelectedGudetama(view.getUniqueID());
         }
      }
      catch(e:Error)
      {
         Logger.warn("EditUI.touchedCtrlBtn Error event:" + param1 + " target:" + _loc10_ + " control:" + control + " trace:" + e.getStackTrace());
      }
   }
}

import flash.geom.Point;
import gudetama.common.NativeExtensions;
import gudetama.engine.Engine;
import gudetama.scene.ar.ARScene;
import muku.text.ColorTextField;
import muku.util.StarlingUtil;
import starling.animation.DelayedCall;
import starling.display.Image;
import starling.display.Sprite3D;
import starling.utils.MathUtil;

class TrackingManager
{
   
   private static const STATE_IDLE:int = 0;
   
   private static const STATE_SEARCH:int = 1;
   
   private static const STATE_TRACKING:int = 2;
   
   private static const STATE_LOCALIZE:int = 3;
   
   private static const STATE_LOCALIZE_IMPOSSIBLE:int = 4;
   
   private static const AR_LOST_LIMIT_TIME:Number = 4000;
   
   private static const AR_LOST_EFFECT_START_TIME:Number = 1500;
   
   public static const AR_STATE_SERACH_PLANE:int = 1;
   
   public static const AR_STATE_CAMERA_MOVE:int = 2;
   
   public static const AR_STATE_GUDETAMA_POSITION:int = 3;
   
   public static const AR_STATE_GUDETAMA_PLACE:int = 4;
   
   public static const AR_STATE_ADSUTMENT_TRANSFORM:int = 5;
   
   public static const AR_STATE_SHOOTABLE:int = 6;
   
   public static const AR_STATE_NOT_PLACEABLE:int = 7;
    
   
   private var control:ARScene;
   
   private var trackingState:int;
   
   private var message:ColorTextField;
   
   private var targetMarker:Sprite3D;
   
   private var markImage:Image;
   
   private var targetMarkId:int;
   
   private var firstCameraDistance:Number;
   
   private var screenPosRateX:Number;
   
   private var screenPosRateY:Number;
   
   private var delayedCall:DelayedCall;
   
   private var debugDelayedCall:DelayedCall;
   
   private var trackingLostTime:uint;
   
   private var facing:Boolean;
   
   function TrackingManager(param1:ARScene, param2:Sprite3D)
   {
      super();
      this.control = param1;
      this.targetMarker = param2;
      targetMarkId = -1;
      facing = false;
      param2.visible = false;
      markImage = param2.getChildByName("markImage") as Image;
   }
   
   public function dispose() : void
   {
      if(delayedCall)
      {
         delayedCall.dispatchEventWith("removeFromJuggler");
         delayedCall = null;
      }
      if(debugDelayedCall)
      {
         debugDelayedCall.dispatchEventWith("removeFromJuggler");
         debugDelayedCall = null;
      }
   }
   
   public function getTargetPosition() : Point
   {
      var _loc1_:Point = StarlingUtil.getPointFromPool();
      _loc1_.setTo(screenPosRateX,screenPosRateY);
      return _loc1_;
   }
   
   public function reset() : void
   {
      if(targetMarkId > 0)
      {
         var _loc1_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.removeTarget(targetMarkId);
      }
      firstCameraDistance = 0;
      trackingLostTime = 0;
   }
   
   public function setup() : void
   {
      targetMarkId = ARScene.generateUniqueID();
      var _loc1_:* = NativeExtensions;
      gudetama.common.NativeExtensions.arExt.addTarget(targetMarkId);
      firstCameraDistance = 0;
      trackingLostTime = 0;
   }
   
   public function setFacing(param1:Boolean) : void
   {
      facing = param1;
   }
   
   public function modifiedEnableRecognizer(param1:Boolean) : void
   {
      if(param1)
      {
         reset();
         targetMarkId = ARScene.generateUniqueID();
         var _loc2_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.addTarget(targetMarkId);
      }
   }
   
   public function isPlaceableGudetama() : Boolean
   {
      return firstCameraDistance != 0;
   }
   
   public function isTracking() : Boolean
   {
      return trackingState == 2;
   }
   
   public function update(param1:ARParam) : void
   {
      var _loc5_:* = null;
      var _loc7_:int = 0;
      var _loc4_:Number = NaN;
      var _loc2_:* = null;
      var _loc6_:Number = NaN;
      if(targetMarkId < 0)
      {
         return;
      }
      var _loc3_:TargetData = param1.targetMap[targetMarkId] as TargetData;
      if(!_loc3_)
      {
         return;
      }
      trackingState = param1.sceneMappingState;
      if(trackingState == 2 && !facing && control.enabledRecognizerAR() && targetMarker.visible)
      {
         if(firstCameraDistance == 0)
         {
            firstCameraDistance = _loc3_.cameraDistance;
         }
         _loc5_ = control.getCameraImage();
         screenPosRateX = _loc3_.screenPosX;
         screenPosRateY = _loc3_.screenPosY;
         var _loc8_:* = NativeExtensions;
         if((_loc7_ = gudetama.common.NativeExtensions.arExt.getCameraImageRot()) == 90)
         {
            targetMarker.x = _loc5_.width * screenPosRateX;
            targetMarker.y = _loc5_.height * screenPosRateY;
         }
         else if(_loc7_ == 180)
         {
            targetMarker.x = _loc5_.width * (1 - screenPosRateX);
            targetMarker.y = _loc5_.height * (1 - screenPosRateY);
         }
         else if(_loc7_ == 270)
         {
            targetMarker.x = _loc5_.width * (1 - screenPosRateX);
            targetMarker.y = _loc5_.height * screenPosRateY;
         }
         else
         {
            targetMarker.x = _loc5_.width * screenPosRateX;
            targetMarker.y = _loc5_.height * screenPosRateY;
         }
         targetMarker.rotationX = param1.cameraRot.x;
         targetMarker.rotationY = param1.cameraRot.y;
         targetMarker.rotationZ = param1.cameraRot.z;
         if(firstCameraDistance > 0)
         {
            _loc4_ = 1 / _loc3_.cameraDistance;
            targetMarker.scale = MathUtil.min(2.8,_loc4_ * 0.05);
         }
         else
         {
            targetMarker.scale = 0;
         }
         _loc2_ = control.getCameraImageOffset();
         _loc6_ = (_loc5_.width / 2 - _loc2_.x) / _loc5_.width;
         var _loc9_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.unproject(targetMarkId,_loc6_,0.5);
      }
      if(control.enabledRecognizerAR())
      {
         if(trackingState == 4 || trackingState == 3)
         {
            trackingLostTime += Engine.elapsed;
         }
         else
         {
            if(trackingLostTime > 1500)
            {
               Engine.hideLoading();
            }
            trackingLostTime = 0;
         }
         if(trackingLostTime > 1500)
         {
            Engine.showLoadingWithoutLock();
         }
         if(trackingLostTime > 4000)
         {
            control.autoResetRecognizer();
            trackingLostTime = 0;
            Engine.hideLoading();
         }
         if(param1.recognized)
         {
            markImage.color = 16777215;
         }
         else
         {
            markImage.color = 16711680;
         }
      }
   }
   
   public function setVisibleTargetMarker(param1:Boolean) : void
   {
      targetMarker.visible = param1;
   }
   
   private function isVisibleTargetMarker() : Boolean
   {
      if(facing)
      {
         return false;
      }
      if(!control.enabledRecognizerAR())
      {
         return false;
      }
      return true;
   }
}
