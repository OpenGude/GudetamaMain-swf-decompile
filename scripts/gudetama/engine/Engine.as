package gudetama.engine
{
   import avmplus.getQualifiedClassName;
   import feathers.controls.Button;
   import feathers.controls.Callout;
   import feathers.controls.ScrollBar;
   import feathers.controls.Slider;
   import feathers.controls.TextArea;
   import feathers.controls.TextInput;
   import feathers.core.PopUpManager;
   import flash.desktop.NativeApplication;
   import flash.display.BitmapData;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.filesystem.File;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundMixer;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import gestouch.core.Gestouch;
   import gestouch.extensions.starling.StarlingDisplayListAdapter;
   import gestouch.extensions.starling.StarlingTouchHitTester;
   import gestouch.gestures.SwipeGesture;
   import gestouch.input.NativeInputAdapter;
   import gudetama.common.DialogSystemMailChecker;
   import gudetama.common.EffectPlayerManager;
   import gudetama.common.GudetamaTextProcessor;
   import gudetama.common.NativeExtensions;
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.common.PushNotificationManager;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.LocalData;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GetItemResult;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.GuideTalkPanel;
   import gudetama.ui.ItemsGetDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.PopupBalloon;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.ImageUtil;
   import gudetama.util.JugglerEx;
   import muku.core.ApplicationContext;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.ParticleSystem;
   import muku.display.ToggleButton;
   import muku.text.PartialBitmapFont;
   import muku.util.ObjectUtil;
   import muku.util.SpineUtil;
   import muku.util.StarlingUtil;
   import starling.animation.DelayedCall;
   import starling.core.Starling;
   import starling.display.Button;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   import starling.events.KeyboardEvent;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.rendering.Painter;
   import starling.textures.ConcreteTexture;
   import starling.textures.Texture;
   import starling.utils.AssetManager;
   import starlingbuilder.engine.IUIBuilder;
   import starlingbuilder.engine.LayoutLoader;
   import starlingbuilder.engine.UIBuilder;
   import starlingbuilder.engine.localization.DefaultLocalization;
   import starlingbuilder.engine.localization.ILocalization;
   import starlingbuilder.engine.tween.ITweenBuilder;
   import starlingbuilder.engine.tween.TemplateTweenBuilder;
   import starlingbuilder.engine.util.StageUtil;
   
   public class Engine extends Sprite
   {
      
      public static const FINISHED_TRANSITION_EFFECT_OPEN:String = "finished_transition_open";
      
      public static const FINISHED_TRANSITION_EFFECT_CLOSE:String = "finished_transition_close";
      
      public static const ADDED_SCENE_TO_CONTAINER:String = "added_scene_to_container";
      
      public static const REMOVED_SCENE_FROM_CONTAINER:String = "removed_scene_from_container";
      
      public static const REFRESHED_SCENE_CONTAINER:String = "refreshed_scene_container";
      
      public static const PRESSED_BACK_FROM_CONTAINER:String = "pressed_back_from_container";
      
      public static const REMOVED_PUSHED_SCENE_FROM_CONTAINER:String = "removed_pushed_scene_from_container";
      
      public static const UPDATE_SCENE:String = "update_scene";
      
      private static const QUEUE_CALLBACK_INTERVAL:int = 90;
      
      private static const PING_LOCK:String = "ping_lock";
      
      private static var loadingTimeout:int;
      
      private static var nextTimeoutTime:uint;
      
      private static var singleton:Engine;
      
      public static var requestedFramerate:uint = 30;
      
      private static var designWidth:int;
      
      private static var designHeight:int;
      
      private static var designWidthMargin:int;
      
      private static var designHeightMargin:int;
      
      private static var _sceneX:int;
      
      private static var _sceneY:int;
      
      public static var stage2D:Stage;
      
      public static var now:uint;
      
      public static var elapsed:int;
      
      private static var suspendTime:uint;
      
      private static var suspendLostFocus:Boolean;
      
      private static var locale:String = "ja";
      
      private static var countryCode:int = 1;
      
      public static var currentTime:uint;
      
      public static var lastTime:uint;
      
      public static var serverTimeOffsetSec:int;
      
      private static var readlTimeJuggler:JugglerEx = new JugglerEx();
      
      public static var tweenJuggler:JugglerEx = new JugglerEx();
      
      private static var sequentialCallbacks:Vector.<Function> = new Vector.<Function>();
      
      private static var initialSceneClass:Class;
      
      private static var recoverSceneFunction:Function;
      
      public static var platform:int = -1;
      
      public static var applicationVersion:String;
      
      public static var mukuGlobal:MukuGlobal;
      
      private static var assetsDir:String = "assets";
      
      public static var uiBuilder:IUIBuilder;
      
      public static var assetManager:AssetManager;
      
      private static var inputLockMap:Dictionary = new Dictionary();
      
      private static var loadingLockMap:Dictionary = new Dictionary();
      
      private static var sceneBounds:Rectangle = new Rectangle();
      
      public static var suspendOnFocusLostEnabled:Boolean;
      
      private static var traceLogMap:Object;
      
      private static var errorSentCount:uint;
      
      private static var forceRecoverScene:Boolean = false;
      
      public static var switchSceneTime:int;
      
      private static var lastTransitionEffect:TransitionEffect;
      
      private static var oneStoreCallback:Function;
      
      private static var totalFps:int = 0;
      
      private static var totalCounter:int = 0;
      
      private static var calcAverageFpsDelayedCall:DelayedCall;
       
      
      private var focusGainedProcessing:Boolean;
      
      private var focusLostTime:int;
      
      private var focusGainedAdvanceTime:int;
      
      private var touchStageCallbacks:Vector.<Function>;
      
      private const imageUtilCls:Class = ImageUtil;
      
      private var _assetMediator:AssetMediator;
      
      private var sceneTransitioning:Boolean;
      
      private var nextScene:BaseScene;
      
      private var transitionProcessQueue:Vector.<BaseScene>;
      
      private var sceneContainer:Sprite;
      
      private var sceneStack:Vector.<BaseScene>;
      
      private var popSceneStack:Vector.<BaseScene>;
      
      private var captureBitmapData:BitmapData;
      
      private var captureImage:Image;
      
      private var maskObject:Quad;
      
      private var popupContainer:Sprite;
      
      private var transitionEffects:Vector.<TransitionEffect>;
      
      private var _interruptFunctionAtSwitchScene:Function;
      
      private var patImageTop:Image;
      
      private var patImageBottom:Image;
      
      private var patImageLeft:Image;
      
      private var patImageRight:Image;
      
      private var hardwareBackKeyFunction:Function;
      
      private var timeoutRepeatCall:DelayedCall;
      
      public function Engine()
      {
         touchStageCallbacks = new Vector.<Function>();
         transitionProcessQueue = new Vector.<BaseScene>();
         captureImage = new Image(Texture.empty(10,10));
         transitionEffects = new Vector.<TransitionEffect>();
         super();
         singleton = this;
         assetManager = new AssetManager();
         assetManager.verbose = false;
         _assetMediator = new AssetMediator(assetManager);
         gudetama.engine.Engine.singleton._assetMediator.file = File.applicationDirectory.resolvePath("rsrc/json/dummy.json");
         var localization:ILocalization = new DefaultLocalization(JSON.parse(new EmbeddedAssets.strings()),"en_US");
         uiBuilder = new UIBuilder(gudetama.engine.Engine.singleton._assetMediator,false,null,localization,new TemplateTweenBuilder());
         uiBuilder.localizationHandler = new LocalizationHandler();
         uiBuilder.displayObjectHandler = new DisplayObjectHandler();
         MukuGlobal.isBuilderMode();
         NativeApplication.nativeApplication.addEventListener("keyDown",onKeyDownNative);
         var loader:LayoutLoader = new LayoutLoader(EmbeddedLayouts,ParsedLayouts);
         TextArea.globalStyleProvider = new TextAreaStyleProvider();
         TextInput.globalStyleProvider = new TextInputStyleProvider();
         feathers.controls.Button.globalStyleProvider = new ButtonStyleProvider();
         Slider.globalStyleProvider = new SliderStyleProvider();
         ScrollBar.globalStyleProvider = new ScrollBarStyleProvider();
         sceneContainer = new Sprite();
         sceneStack = new Vector.<BaseScene>();
         popSceneStack = new Vector.<BaseScene>();
         addChildAt(sceneContainer,0);
         popupContainer = new Sprite();
         addChild(popupContainer);
         assetManager.enqueue(EmbeddedAssets);
         assetManager.loadQueue(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            assetManager.enqueue(File.applicationDirectory.resolvePath(assetsDir));
            var baseDir:File = File.applicationDirectory;
            var assetLoader:AssetLoaderWithOptions = new AssetLoaderWithOptions(assetManager,baseDir);
            assetManager.loadQueue(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               SoundManager.init(assetManager);
               var i:int = 0;
               while(i < 7)
               {
                  var effect:TransitionEffect = TransitionEffect.factory(i);
                  effect.setup();
                  transitionEffects.push(effect);
                  i++;
               }
               var scene:BaseScene = new initialSceneClass() as BaseScene;
               scene.processSetupProgress(function(param1:Number):void
               {
                  if(param1 < 1)
                  {
                     return;
                  }
                  sceneStack.push(scene);
                  refreshSceneContainer(scene);
                  hideLoading();
               });
            });
         });
         stage2D.addEventListener("deactivate",onFocusLost);
         stage2D.addEventListener("activate",onFocusGained);
         if(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0)
         {
            suspendOnFocusLostEnabled = true;
         }
         addEventListener("enterFrame",onEnterFrame);
         var _loc2_:* = Starling;
         starling.core.Starling.sCurrent.skipUnchangedFrames = true;
         EffectPlayerManager.setup();
      }
      
      public static function init(param1:Class, param2:Stage, param3:int, param4:int, param5:int, param6:String = null) : void
      {
         initialSceneClass = param1;
         trace("os",Capabilities.os,"mem",System.totalMemoryNumber / 1024);
         stage2D = param2;
         stage2D.frameRate = 60;
         designWidth = param3;
         designHeight = param4;
         designWidthMargin = param5;
         designHeightMargin = 0;
         if(param6)
         {
            assetsDir = param6;
         }
         var _loc9_:String = Capabilities.version;
         var _loc10_:String = Capabilities.os;
         if(_loc9_.substr(0,3) == "IOS" && _loc10_.substr(0,7) != "Windows")
         {
            platform = 0;
         }
         else if(_loc9_.substr(0,3) == "AND" && _loc10_.substr(0,7) != "Windows")
         {
            platform = 1;
         }
         else if(_loc10_.substr(0,7) == "Windows")
         {
            platform = 2;
         }
         else
         {
            platform = 3;
         }
         if(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0)
         {
         }
         var _loc7_:XML;
         var _loc11_:Namespace = (_loc7_ = NativeApplication.nativeApplication.applicationDescriptor).namespace();
         applicationVersion = _loc7_._loc11_::versionNumber;
         SoundMixer.audioPlaybackMode = "ambient";
         var _loc8_:Starling = new Starling(Engine,stage2D);
         var _loc14_:* = new NativeInputAdapter(stage2D);
         var _loc12_:* = Gestouch;
         if(gestouch.core.Gestouch._inputAdapter != _loc14_)
         {
            gestouch.core.Gestouch._inputAdapter = _loc14_;
            if(gestouch.core.Gestouch.inputAdapter)
            {
               gestouch.core.Gestouch.inputAdapter.touchesManager = gestouch.core.Gestouch.touchesManager;
               gestouch.core.Gestouch.inputAdapter.init();
            }
         }
         Gestouch.addDisplayListAdapter(DisplayObject,new StarlingDisplayListAdapter());
         var _loc13_:* = Starling;
         Gestouch.addTouchHitTester(new StarlingTouchHitTester(starling.core.Starling.sCurrent),-1);
         _loc8_.stage3D.addEventListener("context3DCreate",onContext3dCreated);
         _loc8_.addEventListener("rootCreated",onRootCreated);
         _loc8_.touchProcessor = new GudetamaTouchProcessor(_loc8_.stage);
         ApplicationContext.setApplicationTextControl(new GudetamaTextProcessor());
         loadingTimeout = gudetama.engine.Engine.platform == 1 ? 55000 : 42000;
         NativeExtensions.setup();
      }
      
      private static function onContext3dCreated(param1:flash.events.Event) : void
      {
         var e:flash.events.Event = param1;
         var _loc2_:* = Starling;
         starling.core.Starling.sCurrent.stage3D.removeEventListener("context3DCreate",onContext3dCreated);
         var _loc3_:* = Starling;
         starling.core.Starling.sCurrent.start();
         Texture.setErrorHandler(onTextureResourceErrorHandler);
         var _loc4_:* = Starling;
         starling.core.Starling.sCurrent.addEventListener("context3DCreate",function(param1:Event):void
         {
            Logger.info("DEVICE CONTEXT LOST",platform);
         });
      }
      
      private static function onRootCreated(param1:starling.events.Event) : void
      {
         var _loc2_:* = Starling;
         starling.core.Starling.sCurrent.removeEventListener("rootCreated",onRootCreated);
         singleton.rootAdded();
      }
      
      private static function onTextureResourceErrorHandler(param1:Error) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1.errorID == 3691)
         {
            Texture.setErrorHandler(null);
            Logger.error("error : {}, \nDumpRegister:\n{}",param1.getStackTrace(),ConcreteTexture.getDumpRegistrantTraces());
         }
         else
         {
            Logger.error(param1.getStackTrace());
         }
      }
      
      public static function getLocale() : String
      {
         return locale;
      }
      
      public static function setLocale(param1:String) : void
      {
         locale = param1;
      }
      
      public static function get sceneX() : int
      {
         return _sceneX;
      }
      
      public static function get sceneY() : int
      {
         return _sceneY;
      }
      
      public static function get sceneWidthMargin() : int
      {
         return designWidthMargin;
      }
      
      public static function get sceneWidth() : int
      {
         return designWidth;
      }
      
      public static function get sceneWidthAndMargin() : int
      {
         return designWidth + designWidthMargin * 2;
      }
      
      public static function get sceneHeight() : int
      {
         return designHeight;
      }
      
      public static function get sceneHeightMargin() : int
      {
         return designHeightMargin;
      }
      
      public static function get tweenBuilder() : ITweenBuilder
      {
         return uiBuilder.tweenBuilder;
      }
      
      public static function isMobilePlatform() : Boolean
      {
         return platform == 1 || platform == 0;
      }
      
      public static function isIosPlatform() : Boolean
      {
         return platform == 0;
      }
      
      public static function isAndroidPlatform() : Boolean
      {
         return platform == 1;
      }
      
      public static function getPlatform() : String
      {
         if(gudetama.engine.Engine.platform == 0)
         {
            return "ios";
         }
         if(gudetama.engine.Engine.platform == 1)
         {
            return "android";
         }
         return "android";
      }
      
      public static function isIosLayout() : Boolean
      {
         return gudetama.engine.Engine.platform == 0 || true;
      }
      
      public static function containsSceneContainer(param1:DisplayObject) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         return singleton.sceneContainer.contains(param1);
      }
      
      public static function containsSceneStack(param1:Class) : Boolean
      {
         var sceneClass:Class = param1;
         return singleton.sceneStack.some(function(param1:BaseScene, param2:int, param3:Vector.<BaseScene>):Boolean
         {
            return param1 is sceneClass;
         });
      }
      
      public static function getSceneFromStack(param1:Class) : BaseScene
      {
         var _loc3_:int = 0;
         var _loc2_:int = singleton.sceneStack.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(singleton.sceneStack[_loc3_] is param1)
            {
               return singleton.sceneStack[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public static function getSceneContainer() : Sprite
      {
         return singleton.sceneContainer;
      }
      
      public static function getPopupContainer() : Sprite
      {
         return singleton.popupContainer;
      }
      
      public static function setHardwareBackKeyFunction(param1:Function) : void
      {
         singleton.hardwareBackKeyFunction = param1;
      }
      
      public static function getHardwareBackKeyFunction() : Function
      {
         return singleton.hardwareBackKeyFunction;
      }
      
      public static function removeHardwareBackKeyFunction() : void
      {
         singleton.hardwareBackKeyFunction = null;
      }
      
      public static function suspend(param1:Boolean, param2:Boolean = false) : void
      {
         var _loc3_:uint = getTimer();
         if(param1)
         {
            suspendTime = _loc3_;
            suspendLostFocus = !param2;
         }
         else
         {
            suspendTime = 0;
            suspendLostFocus = false;
         }
         var _loc4_:* = Starling;
         starling.core.Starling.sCurrent.suspend(param1);
      }
      
      public static function isSuspended() : Boolean
      {
         return suspendTime > 0;
      }
      
      public static function addSequentialCallback(param1:Function) : void
      {
         sequentialCallbacks.push(param1);
      }
      
      public static function assertWithTraceLog(param1:Boolean, ... rest) : Boolean
      {
         if(param1)
         {
            return false;
         }
         traceLog(new Error("Assertion failed"),ObjectUtil.concatString(rest));
         return param1;
      }
      
      public static function assertWithError(param1:Boolean, ... rest) : void
      {
         if(param1)
         {
            return;
         }
         throw new Error("Assertion failed: " + ObjectUtil.concatString(rest));
      }
      
      public static function traceLog(param1:*, ... rest) : void
      {
         var _loc5_:* = null;
         var _loc4_:String = ObjectUtil.concatString(rest);
         var _loc3_:Boolean = true;
         if(param1 is Error)
         {
            param1 = (param1 as Error).getStackTrace();
            if(errorSentCount >= 3)
            {
               _loc3_ = false;
            }
            errorSentCount++;
         }
         if(_loc4_)
         {
            param1 += "\n" + _loc4_;
         }
         trace("Engine#traceLog",param1);
         if(_loc3_)
         {
            _loc5_ = param1.substr(0,100);
            if(traceLogMap == null)
            {
               traceLogMap = {};
            }
            if(!traceLogMap.hasOwnProperty("logHead"))
            {
               traceLogMap[_loc5_] = "DONE";
               HttpConnector.sendTraceLog(param1);
            }
         }
      }
      
      public static function get assetMediator() : AssetMediator
      {
         return singleton._assetMediator;
      }
      
      public static function getCoordGlobal(param1:DisplayObject, param2:int = 0, param3:int = 0) : Point
      {
         var _loc4_:Point;
         _loc4_.x = (_loc4_ = StarlingUtil.getCoordGlobal(param1,param2,param3)).x - _sceneX;
         _loc4_.y -= _sceneY;
         return _loc4_;
      }
      
      public static function addTouchStageCallback(param1:Function) : void
      {
         removeTouchStageCallback(param1);
         singleton.touchStageCallbacks.push(param1);
      }
      
      public static function removeTouchStageCallback(param1:Function) : void
      {
         if(singleton.touchStageCallbacks.indexOf(param1) >= 0)
         {
            singleton.touchStageCallbacks.removeAt(singleton.touchStageCallbacks.indexOf(param1));
         }
      }
      
      public static function showLoadingWithoutLock() : void
      {
         LoadingDialog.show();
      }
      
      public static function showLoading(param1:* = 0, param2:Boolean = false) : void
      {
         if(param2)
         {
            var _loc4_:Boolean = true;
            var _loc3_:* = LoadingDialog;
            gudetama.engine.LoadingDialog.instance.loadingMode = _loc4_;
         }
         LoadingDialog.show();
         lockTouchInput(param1);
         loadingLockMap[param1] = currentTime;
      }
      
      public static function hideLoading(param1:* = 0) : void
      {
         unlockTouchInput(param1);
         delete loadingLockMap[param1];
         var _loc4_:int = 0;
         var _loc3_:* = loadingLockMap;
         for(var _loc2_ in _loc3_)
         {
         }
         LoadingDialog.hide();
      }
      
      public static function hideLoadingForce(param1:* = false) : void
      {
         loadingLockMap = new Dictionary();
         LoadingDialog.hide();
      }
      
      public static function setRecoverSceneFunction(param1:Function) : void
      {
         recoverSceneFunction = param1;
      }
      
      public static function recoverScene() : void
      {
         procErrorOccurred();
         if(recoverSceneFunction)
         {
            recoverSceneFunction();
         }
      }
      
      public static function procErrorOccurred() : void
      {
         MessageDialog.removeAllStackedDialog();
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.cancel();
         Engine.unlockTouchInputForce();
         Engine.hideLoadingForce(true);
         Engine.suspend(false);
         RsrcManager.getInstance().cancelLoading();
      }
      
      public static function getSceneBounds() : Rectangle
      {
         return sceneBounds;
      }
      
      public static function getScene(param1:String) : BaseScene
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         _loc2_ = singleton.sceneStack.length - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = singleton.sceneStack[_loc2_];
            if(_loc3_.getType() != 3)
            {
               if(param1 == getQualifiedClassName(_loc3_))
               {
                  return _loc3_;
               }
            }
            _loc2_--;
         }
         return null;
      }
      
      public static function isTopScene(param1:BaseScene) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         _loc2_ = singleton.sceneStack.length - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = singleton.sceneStack[_loc2_];
            if(_loc3_.getType() != 3)
            {
               return _loc3_ == param1;
            }
            _loc2_--;
         }
         return false;
      }
      
      public static function getGuideTalkPanel() : GuideTalkPanel
      {
         var _loc3_:* = 0;
         var _loc1_:uint = singleton.sceneStack.length;
         var _loc2_:Vector.<BaseScene> = singleton.sceneStack;
         if(_loc1_ == 0)
         {
            return null;
         }
         _loc3_ = uint(0);
         while(_loc3_ < _loc1_)
         {
            if(_loc2_[_loc3_] is GuideTalkPanel)
            {
               return _loc2_[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public static function resumeGuideTalk(param1:Function = null, param2:Function = null) : Boolean
      {
         var _loc3_:GuideTalkPanel = getGuideTalkPanel();
         if(!_loc3_)
         {
            return false;
         }
         sceneMoveToMostFront(_loc3_);
         singleton.refreshSceneContainer(_loc3_);
         _loc3_.resumeGuideTalk(param1 == null ? _loc3_.getCallback() : param1,param2 == null ? _loc3_.getGuideArrowCallback() : param2);
         return true;
      }
      
      public static function setForceRecoverScene() : void
      {
         forceRecoverScene = true;
      }
      
      public static function set interruptFunctionAtSwitchScene(param1:Function) : void
      {
         singleton._interruptFunctionAtSwitchScene = param1;
      }
      
      public static function checkSwitchScene(param1:BaseScene) : Boolean
      {
         return true;
      }
      
      public static function switchScene(param1:BaseScene, param2:int = 1, param3:Number = 0.5, param4:* = false) : void
      {
         var scene:BaseScene = param1;
         var transition:int = param2;
         var delay:Number = param3;
         var leaveTutorialScene:* = param4;
         singleton.processInterruptFunctionAtSwitchScene(function():void
         {
            var _loc1_:* = null;
            gudetama.engine.Engine.singleton._interruptFunctionAtSwitchScene = _loc1_;
            setHardwareBackKeyFunction(null);
            if(forceRecoverScene)
            {
               forceRecoverScene = false;
               recoverScene();
            }
            else
            {
               singleton._switchScene(scene,transition,delay,leaveTutorialScene);
            }
         });
      }
      
      public static function clearCache() : void
      {
         PartialBitmapFont.disposeKeepBitmapData();
         TextureCollector.clearAll(0);
         AssetMediator.clearTextureCache();
         RsrcManager.clearCache();
         SpineUtil.clearCache();
      }
      
      public static function removeSpineCache(param1:String, param2:int = 0) : void
      {
         var _loc4_:Vector.<String>;
         if(!(_loc4_ = SpineUtil.removeCache(param1)))
         {
            return;
         }
         for each(var _loc3_ in _loc4_)
         {
            TextureCollector.clearAtName(param1,param2);
         }
      }
      
      public static function broadcastEventToSceneStackWith(param1:String, param2:Object = null) : void
      {
         for each(var _loc3_ in singleton.sceneStack)
         {
            _loc3_.broadcastEventWith(param1,param2);
         }
      }
      
      public static function pushScene(param1:BaseScene, param2:int = 0, param3:Boolean = true) : void
      {
         if(!singleton.checkSameScene(param1))
         {
            singleton._pushScene(param1,param2,param3);
         }
      }
      
      public static function dispatchEventToPreviousScene(param1:String) : void
      {
         singleton._dispatchEventToPreviousScene(param1);
      }
      
      public static function popScene(param1:DisplayObject = null, param2:int = 0, param3:Boolean = true) : void
      {
         singleton._popScene(param1,param2,param3);
      }
      
      public static function sceneMoveToMostFront(param1:DisplayObject) : void
      {
         singleton._sceneMoveToMostFront(param1);
      }
      
      public static function addPopUp(param1:DisplayObject, param2:Boolean = true) : void
      {
         PopUpManager.addPopUp(param1,param2);
         singleton.popSceneStack.push(param1);
      }
      
      public static function removePopUp(param1:DisplayObject = null, param2:Boolean = true, param3:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc5_:* = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:int = singleton.popSceneStack.length;
         if(param3)
         {
            var _loc10_:* = PopUpManager;
            _loc6_ = feathers.core.PopUpManager.forStarling(starling.core.Starling.current).root.numChildren;
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               var _loc11_:* = PopUpManager;
               if((_loc5_ = feathers.core.PopUpManager.forStarling(starling.core.Starling.current).root.getChildAt(_loc7_)) is BaseScene)
               {
                  if(PopUpManager.isPopUp(_loc5_))
                  {
                     if(_loc5_ is MessageDialog)
                     {
                        PopUpManager.removePopUp(_loc5_,false);
                     }
                     else
                     {
                        PopUpManager.removePopUp(_loc5_,param2);
                     }
                  }
               }
               _loc7_++;
            }
            _loc8_ = _loc9_ - 1;
            while(_loc8_ >= 0)
            {
               singleton.popSceneStack.removeAt(_loc8_);
               _loc8_--;
            }
         }
         else
         {
            if(param1 == null)
            {
               var _loc12_:* = PopUpManager;
               var _loc13_:* = PopUpManager;
               param1 = feathers.core.PopUpManager.forStarling(starling.core.Starling.current).root.getChildAt(feathers.core.PopUpManager.forStarling(starling.core.Starling.current).root.numChildren - 1);
            }
            if(PopUpManager.isPopUp(param1))
            {
               PopUpManager.removePopUp(param1,param2);
            }
            _loc4_ = _loc9_ - 1;
            while(_loc4_ >= 0)
            {
               if(singleton.popSceneStack[_loc4_] == param1)
               {
                  singleton.popSceneStack.removeAt(_loc4_);
               }
               _loc4_--;
            }
         }
      }
      
      public static function setupLayoutForTask(param1:TaskQueue, param2:Object, param3:Function, param4:int = 0) : void
      {
         var queue:TaskQueue = param1;
         var layoutData:Object = param2;
         var callback:Function = param3;
         var cacheMode:int = param4;
         MukuGlobal.setCurrentQueue(queue);
         queue.addTask(function():void
         {
            setupLayout(layoutData,function(param1:Object):void
            {
               callback(param1);
               queue.taskDone();
            },cacheMode);
         });
      }
      
      public static function setupLayout(param1:Object, param2:Function, param3:int = 0) : void
      {
         var layoutData:Object = param1;
         var callback:Function = param2;
         var cacheMode:int = param3;
         var mediator:AssetMediator = gudetama.engine.Engine.singleton._assetMediator;
         if(layoutData is String)
         {
            if((layoutData as String).indexOf("{") < 0)
            {
               var layoutName:String = layoutData as String;
               mediator.getLayoutData(layoutName,function(param1:Object):void
               {
                  setupLayout(param1,callback,cacheMode);
               });
               return;
            }
         }
         var collector:TextureCollector = new TextureCollector(layoutData,mediator);
         collector.preloadTextures(function(param1:Object):void
         {
            AssetMediator.setTextureCache(param1);
            var _loc2_:Object = Engine.uiBuilder.load(layoutData,false);
            AssetMediator.clearTextureCache();
            _loc2_["textureCache"] = param1;
            callback(_loc2_);
         },cacheMode);
      }
      
      public static function lockTouchInput(param1:*) : void
      {
         inputLockMap[param1] = currentTime;
         var _loc2_:* = Starling;
         (starling.core.Starling.sCurrent.touchProcessor as GudetamaTouchProcessor).lockTouchInput();
      }
      
      public static function unlockTouchInput(param1:*) : void
      {
         delete inputLockMap[param1];
         var _loc4_:int = 0;
         var _loc3_:* = inputLockMap;
         for(var _loc2_ in _loc3_)
         {
         }
         var _loc5_:* = Starling;
         (starling.core.Starling.sCurrent.touchProcessor as GudetamaTouchProcessor).unlockTouchInput();
      }
      
      public static function isTouchInputLocked() : Boolean
      {
         var _loc1_:* = Starling;
         return (starling.core.Starling.sCurrent.touchProcessor as GudetamaTouchProcessor).isTouchInputLocked();
      }
      
      public static function cancelTouches() : void
      {
         var _loc1_:* = Starling;
         (starling.core.Starling.sCurrent.touchProcessor as GudetamaTouchProcessor).cancelTouches();
      }
      
      public static function ping(param1:Function) : Boolean
      {
         var callback:Function = param1;
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         if(gudetama.net.HttpConnector.mainConnector.isResponseWaiting())
         {
            return false;
         }
         var sendTime:int = getTimer();
         var _loc4_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(59),function(param1:*):void
         {
            callback(getTimer() - sendTime);
         });
         return true;
      }
      
      public static function unlockTouchInputForce() : void
      {
         inputLockMap = new Dictionary();
         var _loc1_:* = Starling;
         (starling.core.Starling.sCurrent.touchProcessor as GudetamaTouchProcessor).unlockTouchInput();
      }
      
      public static function closeTransition(param1:Function, param2:int, param3:Boolean = false) : void
      {
         if(param2 == 0)
         {
            if(param1)
            {
               param1();
            }
            return;
         }
         var _loc4_:TransitionEffect = singleton.transitionEffects[param2];
         if(lastTransitionEffect)
         {
            if(lastTransitionEffect.priority && !param3)
            {
               if(param1)
               {
                  param1();
               }
               return;
            }
            if(lastTransitionEffect == _loc4_)
            {
               if(param3)
               {
                  lastTransitionEffect.priority = true;
               }
               if(param1)
               {
                  param1();
               }
               return;
            }
            lastTransitionEffect.finish(singleton);
            lastTransitionEffect.priority = false;
         }
         _loc4_.priority = param3;
         _loc4_.close(singleton,param1);
         lastTransitionEffect = _loc4_;
      }
      
      public static function openTransition(param1:Function, param2:int = -1, param3:Boolean = false) : void
      {
         var callback:Function = param1;
         var type:int = param2;
         var priority:Boolean = param3;
         hideLoading("ping_lock");
         if(!lastTransitionEffect)
         {
            if(callback)
            {
               callback();
            }
            return;
         }
         if(type < 0)
         {
            var transitionEffect:TransitionEffect = lastTransitionEffect;
         }
         else
         {
            transitionEffect = singleton.transitionEffects[type];
         }
         if(lastTransitionEffect.priority && !priority)
         {
            if(callback)
            {
               callback();
            }
            return;
         }
         if(type == 0)
         {
            if(callback)
            {
               callback();
            }
            return;
         }
         if(lastTransitionEffect != transitionEffect)
         {
            lastTransitionEffect.finish(singleton);
         }
         lastTransitionEffect = null;
         transitionEffect.priority = false;
         transitionEffect.open(singleton,function():void
         {
            singleton.resetMask();
            if(callback)
            {
               callback();
            }
         });
      }
      
      public static function sendReceiptForiOS(param1:Boolean, param2:Function) : void
      {
         var normal:Boolean = param1;
         var callback:Function = param2;
         _sendReceiptForiOS(normal,-1,function(param1:int):void
         {
            callback(param1);
         });
      }
      
      private static function _sendReceiptForiOS(param1:Boolean, param2:int, param3:Function) : void
      {
         var normal:Boolean = param1;
         var preferredCode:int = param2;
         var callback:Function = param3;
         if(!DataStorage.getLocalData().existsReceipt(UserDataWrapper.wrapper.getUid()))
         {
            if(callback)
            {
               callback(preferredCode);
            }
            return;
         }
         var receipt:String = DataStorage.getLocalData().getOldestReceipt(UserDataWrapper.wrapper.getUid());
         sendReceiptDirect(receipt,normal,function(param1:int):void
         {
            if(param1 != 21005)
            {
               DataStorage.getLocalData().shiftReceipt(UserDataWrapper.wrapper.getUid());
               DataStorage.saveLocalData();
            }
            var _loc3_:Array = [0,21005];
            var _loc4_:int = _loc3_.indexOf(param1) >= 0 ? _loc3_.indexOf(param1) : 2147483647;
            var _loc2_:int = _loc3_.indexOf(preferredCode) >= 0 ? _loc3_.indexOf(preferredCode) : 2147483647;
            if(_loc4_ < _loc2_)
            {
               preferredCode = param1;
            }
            _sendReceiptForiOS(normal,preferredCode,callback);
         });
      }
      
      public static function sendReceiptAndSetupCallbackOneStore(param1:Boolean, param2:Function, param3:Boolean = false) : void
      {
         var normal:Boolean = param1;
         var callback:Function = param2;
         var _isConsume:Boolean = param3;
         oneStoreCallback = callback;
         sendReceiptForOneStore(normal,function():void
         {
            oneStoreCallback();
         },_isConsume);
      }
      
      public static function sendReceiptForOneStore(param1:Boolean, param2:Function, param3:Boolean = false) : void
      {
         var normal:Boolean = param1;
         var callback:Function = param2;
         var _isConsume:Boolean = param3;
         _sendReceiptForOneStore(normal,-1,function(param1:int):void
         {
            NativeExtensions.requestConsumeOneStore(callbackConsumeOneStore);
         },_isConsume);
      }
      
      private static function callbackConsumeOneStore(param1:Boolean, param2:String) : void
      {
         var _result:Boolean = param1;
         var _receipt:String = param2;
         if(_receipt == "")
         {
            if(!_result)
            {
               MessageDialog.show(10,GameSetting.getUIText("purchase.error.3"),function():void
               {
                  if(oneStoreCallback)
                  {
                     oneStoreCallback();
                  }
               });
            }
            else if(oneStoreCallback)
            {
               oneStoreCallback();
            }
         }
         else
         {
            DataStorage.getLocalData().addReceipt(UserDataWrapper.wrapper.getUid(),_receipt);
            DataStorage.saveLocalData();
            Engine.hideLoading(_receipt);
            sendReceiptForOneStore(false,function():void
            {
               if(oneStoreCallback)
               {
                  oneStoreCallback();
               }
            },true);
         }
      }
      
      private static function _sendReceiptForOneStore(param1:Boolean, param2:int, param3:Function, param4:Boolean = false) : void
      {
         var normal:Boolean = param1;
         var preferredCode:int = param2;
         var callback:Function = param3;
         var _isConsume:Boolean = param4;
         if(!DataStorage.getLocalData().existsReceipt(UserDataWrapper.wrapper.getUid()))
         {
            if(callback)
            {
               callback(preferredCode);
            }
            return;
         }
         var receipt:String = DataStorage.getLocalData().getOldestReceipt(UserDataWrapper.wrapper.getUid());
         sendReceiptDirect(receipt,normal,function(param1:int):void
         {
            DataStorage.getLocalData().shiftReceipt(UserDataWrapper.wrapper.getUid());
            DataStorage.saveLocalData();
            var _loc3_:Array = [0,21005];
            var _loc4_:int = _loc3_.indexOf(param1) >= 0 ? _loc3_.indexOf(param1) : 2147483647;
            var _loc2_:int = _loc3_.indexOf(preferredCode) >= 0 ? _loc3_.indexOf(preferredCode) : 2147483647;
            if(_loc4_ < _loc2_)
            {
               preferredCode = param1;
            }
            _sendReceiptForOneStore(normal,preferredCode,callback);
         },_isConsume);
      }
      
      public static function sendReceiptDirect(param1:String, param2:Boolean, param3:Function, param4:Boolean = false) : void
      {
         var receipt:String = param1;
         var normal:Boolean = param2;
         var callback:Function = param3;
         var _isConsume:Boolean = param4;
         showLoading(sendReceiptDirect);
         var _loc5_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithIntAndArrayObject(23,!!_isConsume ? 0 : 1,receipt),function(param1:Array):void
         {
            var response:Array = param1;
            hideLoading(sendReceiptDirect);
            var code:int = response[0][0] as int;
            var addMetal:int = response[0][1] as int;
            var bonusMetal:int = response[0][2] as int;
            var addMoney:int = response[0][3] as int;
            var bonusMoney:int = response[0][4] as int;
            var getItemResults:Array = response[1];
            var _loc3_:* = UserDataWrapper;
            gudetama.data.UserDataWrapper.wrapper._data.setItemBuyMap = response[2];
            UserDataWrapper.wrapper.increaseNumPurchase(response[3]);
            if(code == 0)
            {
               if(addMetal > 0)
               {
                  UserDataWrapper.wrapper.addChargeMetal(addMetal);
               }
               if(bonusMetal > 0)
               {
                  UserDataWrapper.wrapper.addFreeMetal(bonusMetal);
               }
               if(addMetal + bonusMetal > 0)
               {
                  ResidentMenuUI_Gudetama.getInstance()._updateMetal();
               }
               if(addMoney > 0)
               {
                  UserDataWrapper.wrapper.addChargeMoney(addMoney);
               }
               if(bonusMoney > 0)
               {
                  UserDataWrapper.wrapper.addFreeMoney(bonusMoney);
               }
               if(addMoney + bonusMoney > 0)
               {
                  ResidentMenuUI_Gudetama.getInstance()._updateMoney();
               }
               if(!normal)
               {
                  LocalMessageDialog.show(0,GameSetting.getUIText("receipt.pending"),function(param1:int):void
                  {
                     var choose:int = param1;
                     showGetPurchaseItem(getItemResults,function():void
                     {
                        callback(code);
                     });
                  });
                  return;
               }
               if(getItemResults != null)
               {
                  showGetPurchaseItem(getItemResults,function():void
                  {
                     callback(code);
                  });
                  return;
               }
            }
            callback(code);
         });
      }
      
      public static function showGetPurchaseItem(param1:Array, param2:*) : void
      {
         var getItemResults:Array = param1;
         var callback:* = param2;
         if(getItemResults == null || getItemResults.length == 0)
         {
            if(callback != null)
            {
               callback();
            }
            return;
         }
         var func:Function = function():void
         {
            var _loc1_:UserDataWrapper = UserDataWrapper.wrapper;
            _loc1_.showCupGachaResults(_loc1_.getPlacedGudetamaId(),callback);
         };
         var i:int = 0;
         while(i < getItemResults.length)
         {
            var result:GetItemResult = getItemResults[i];
            if(!result.toMail)
            {
               UserDataWrapper.wrapper.addItem(result.item,result.param);
            }
            i++;
         }
         ItemsGetDialog.show(getItemResults,func,GameSetting.getUIText("setitem.buy.msg"),GameSetting.getUIText("setitem.buy.title"));
      }
      
      public static function checkPushToken(param1:Function = null) : void
      {
         var callback:Function = param1;
         if(!PushNotificationManager.isSupport() || PushNotificationManager.hasPushToken())
         {
            if(callback != null)
            {
               callback();
            }
            return;
         }
         PushNotificationManager.register(function(param1:String):void
         {
            var token:String = param1;
            if(token == null || token == "")
            {
               PushNotificationManager.resetPushToken();
               if(callback != null)
               {
                  callback();
               }
               return;
            }
            var localData:LocalData = DataStorage.getLocalData();
            if(localData.checkSamePushToken(token))
            {
               if(callback != null)
               {
                  callback();
               }
               return;
            }
            var _loc3_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(25,token),function(param1:*):void
            {
               if(param1 is Array)
               {
                  localData.setPushToken(token);
                  DataStorage.saveLocalData();
               }
               if(callback != null)
               {
                  callback();
               }
            });
         });
      }
      
      public static function procAppsFlyer(param1:Function = null) : void
      {
         var callback:Function = param1;
         var id:String = NativeExtensions.getAppsFlyerUid();
         var localData:LocalData = DataStorage.getLocalData();
         if(id == null || id == "" || localData.getAppsFlyerUid() == id)
         {
            if(callback != null)
            {
               callback();
            }
            return;
         }
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(119,id),function(param1:*):void
         {
            if(param1 is Array)
            {
               localData.setAppsFlyerUid(id);
               DataStorage.saveLocalData();
            }
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      public static function setDisabledExceptSpecificButton(param1:DisplayObjectContainer, param2:Boolean, ... rest) : void
      {
         _disableExceptSpecificButton(param1,param2,rest);
      }
      
      private static function _disableExceptSpecificButton(param1:DisplayObjectContainer, param2:Boolean, param3:Array) : DisplayObject
      {
         var parent:DisplayObjectContainer = param1;
         var b:Boolean = param2;
         var buttons:Array = param3;
         var _numChildren:int = parent.numChildren;
         var i:int = 0;
         while(i < _numChildren)
         {
            var child:DisplayObject = parent.getChildAt(i);
            if(buttons.some(function(param1:DisplayObject, param2:int, param3:Array):Boolean
            {
               return param1 == child;
            }))
            {
               if(child is ContainerButton)
               {
                  (child as ContainerButton).setEnableWithDrawCache(!b);
               }
               else if(child is starling.display.Button)
               {
                  (child as starling.display.Button).enabled = !b;
               }
            }
            else
            {
               if(child is ToggleButton || child is ContainerButton || child is starling.display.Button)
               {
                  if(child is ContainerButton)
                  {
                     (child as ContainerButton).setEnableWithDrawCache(b);
                  }
                  else if(child is starling.display.Button)
                  {
                     (child as starling.display.Button).enabled = b;
                  }
               }
               if(child is DisplayObjectContainer)
               {
                  var result:DisplayObject = _disableExceptSpecificButton(child as DisplayObjectContainer,b,buttons);
                  if(result)
                  {
                     return result;
                  }
               }
            }
            i++;
         }
         return null;
      }
      
      public static function startAggregateFps() : void
      {
         var _loc1_:* = Starling;
         if(!starling.core.Starling.sCurrent.showStats)
         {
            return;
         }
         var _loc2_:* = Starling;
         calcAverageFpsDelayedCall = (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).repeatCallWithoutPool(function():void
         {
            var _loc1_:* = Starling;
            totalFps += starling.core.Starling.sCurrent._statsDisplay.fps;
            totalCounter++;
         },0.1);
      }
      
      public static function finishAggregateFps() : void
      {
         var _loc1_:* = Starling;
         if(!starling.core.Starling.sCurrent.showStats)
         {
            return;
         }
         var _loc2_:* = Starling;
         Logger.info("totalFPS : {}, totalCounter : {}, average fps : {}, memory : {}",totalFps,totalCounter,totalFps / totalCounter,starling.core.Starling.sCurrent._statsDisplay.memory);
         var _loc3_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(calcAverageFpsDelayedCall);
         calcAverageFpsDelayedCall = null;
         totalFps = 0;
         totalCounter = 0;
      }
      
      public static function setSwipeGestureDefaultParam(param1:SwipeGesture) : void
      {
         param1.direction = 3;
         param1.minOffset = 2147483647;
         param1.minVelocity = 8 * Capabilities.screenDPI / 6 / 500;
      }
      
      public static function setCountryCode(param1:int) : void
      {
         countryCode = param1;
      }
      
      public static function isJapanIp() : Boolean
      {
         return countryCode == 1;
      }
      
      public static function getCountryCode() : int
      {
         return countryCode;
      }
      
      private function onKeyDownNative(param1:flash.events.KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 16777234)
         {
            case 0:
               break;
            case 4:
               param1.preventDefault();
               if(hardwareBackKeyFunction != null)
               {
                  if(inputLockMap != null)
                  {
                     var _loc4_:int = 0;
                     var _loc3_:* = inputLockMap;
                     for(var _loc2_ in _loc3_)
                     {
                        return;
                     }
                  }
                  if(loadingLockMap != null)
                  {
                     var _loc6_:int = 0;
                     var _loc5_:* = loadingLockMap;
                     for(_loc2_ in _loc5_)
                     {
                        return;
                     }
                  }
                  hardwareBackKeyFunction();
                  break;
               }
               break;
            case 13:
         }
      }
      
      private function fit() : void
      {
         var _loc1_:* = null;
         var _loc8_:* = Starling;
         var _loc4_:Starling = starling.core.Starling.sCurrent;
         var _loc7_:StageUtil;
         var _loc2_:Point = (_loc7_ = new StageUtil(stage2D,designWidth,designHeight)).getScaledStageSize();
         _loc4_.viewPort = new Rectangle(0,0,stage2D.stageWidth,stage2D.stageHeight);
         _loc4_.stage.stageWidth = _loc2_.x;
         _loc4_.stage.stageHeight = _loc2_.y;
         var _loc3_:Number = _loc4_.stage.stageWidth / designWidth;
         var _loc6_:Number = _loc4_.stage.stageHeight / designHeight;
         var _loc5_:Number = Math.min(_loc3_,_loc6_);
         if(_loc3_ != _loc6_)
         {
            if(_loc3_ < _loc6_)
            {
               _sceneY = (_loc4_.stage.stageHeight - designHeight) / 2;
               if(_sceneY > designHeightMargin)
               {
                  maskObject = new Quad(designWidth,designHeight + designHeightMargin * 2);
                  maskObject.x = _sceneX;
                  maskObject.y = _sceneY - designHeightMargin;
                  mask = maskObject;
               }
               sceneContainer.y = _sceneY;
            }
            else
            {
               _sceneX = (_loc4_.stage.stageWidth - designWidth) / 2;
               if(_sceneX > designWidthMargin)
               {
                  maskObject = new Quad(designWidth + designWidthMargin * 2,designHeight);
                  maskObject.x = _sceneX - designWidthMargin;
                  maskObject.y = _sceneY;
                  mask = maskObject;
               }
               sceneContainer.x = _sceneX;
            }
         }
         sceneBounds.setTo(sceneContainer.x,sceneContainer.y,designWidth + Math.min(sceneContainer.x,designWidthMargin) * 2,designHeight + Math.min(sceneContainer.y,designWidthMargin) * 2);
         captureImage.scaleX = _loc4_.stage.stageWidth / stage2D.stageWidth;
         captureImage.scaleY = _loc4_.stage.stageHeight / stage2D.stageHeight;
         if(_sceneX > designWidthMargin)
         {
            _loc1_ = StarlingUtil.getRectangleFromPool();
            _loc1_.setTo(0,0,128,96);
            patImageLeft = new Image(Texture.fromBitmap(new EmbeddedAssets.pat_png()));
            var _loc9_:* = Starling;
            patImageLeft.readjustSize(_sceneX - designWidthMargin,starling.core.Starling.sCurrent.stage.stageHeight);
            patImageLeft.tileGrid = _loc1_;
            patImageRight = new Image(Texture.fromBitmap(new EmbeddedAssets.pat_png()));
            patImageRight.x = _sceneX + designWidth + designWidthMargin;
            var _loc10_:* = Starling;
            patImageRight.readjustSize(_sceneX - designWidthMargin + 1,starling.core.Starling.sCurrent.stage.stageHeight);
            patImageRight.tileGrid = _loc1_;
            var _loc11_:* = Starling;
            starling.core.Starling.sCurrent.stage.addChild(patImageLeft);
            var _loc12_:* = Starling;
            starling.core.Starling.sCurrent.stage.addChild(patImageRight);
            Callout.stagePaddingLeft = _sceneX - designWidthMargin;
            Callout.stagePaddingRight = _sceneX - designWidthMargin;
         }
         if(_sceneY > designHeightMargin)
         {
            _loc1_ = StarlingUtil.getRectangleFromPool();
            _loc1_.setTo(0,0,128,96);
            patImageTop = new Image(Texture.fromBitmap(new EmbeddedAssets.pat_png()));
            patImageTop.readjustSize(designWidth + designWidthMargin * 2,_sceneY - designHeightMargin);
            patImageTop.tileGrid = _loc1_;
            patImageBottom = new Image(Texture.fromBitmap(new EmbeddedAssets.pat_png()));
            patImageBottom.y = _sceneY + designHeight + designHeightMargin;
            patImageBottom.readjustSize(designWidth + designWidthMargin * 2,_sceneY - designHeightMargin);
            patImageBottom.tileGrid = _loc1_;
            var _loc13_:* = Starling;
            starling.core.Starling.sCurrent.stage.addChild(patImageTop);
            var _loc14_:* = Starling;
            starling.core.Starling.sCurrent.stage.addChild(patImageBottom);
         }
      }
      
      private function onKeyUp(param1:starling.events.KeyboardEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc2_:* = null;
         if(param1.ctrlKey)
         {
            if(param1.keyCode == "T".charCodeAt(0))
            {
               if(param1.shiftKey)
               {
                  Logger.debug(ConcreteTexture.compareCapturedRegistrantTraces());
               }
               else
               {
                  Logger.debug(ConcreteTexture.getDumpRegistrantTraces());
               }
            }
            else if(param1.keyCode == "R".charCodeAt(0))
            {
               Logger.debug(ConcreteTexture.captureRegistrantTraces());
            }
            else if(param1.keyCode == "N".charCodeAt(0))
            {
               Logger.debug("numChildren: " + StarlingUtil.countChildren(this));
            }
            else if(param1.keyCode == "J".charCodeAt(0))
            {
               var _loc4_:* = Starling;
               Logger.debug("Starling.juggler: " + (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).objects.length);
            }
            else if(param1.keyCode == "P".charCodeAt(0))
            {
               var _loc5_:* = Starling;
               _loc3_ = (starling.core.Starling.sCurrent.touchProcessor as GudetamaTouchProcessor).toggleShowTouchTarget();
               Logger.debug(!!_loc3_ ? "<<< Tracing Touch started >>>" : ">>> Tracing Touch stopped <<<");
            }
         }
      }
      
      private function rootAdded() : void
      {
         var _loc1_:* = Starling;
         var _loc3_:* = starling.core.Starling.sCurrent.stage;
         var _loc2_:* = PopUpManager;
         feathers.core.PopUpManager.forStarling(starling.core.Starling.current).root = _loc3_;
         LoadingDialog.create();
         fit();
         stage.addEventListener("keyUp",onKeyUp);
         stage.addEventListener("touch",onTouch);
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         var _loc2_:Touch = param1.getTouch(stage);
         if(_loc2_)
         {
            for each(var _loc3_ in touchStageCallbacks)
            {
               _loc3_(_loc2_);
            }
         }
      }
      
      public function getTopScene() : BaseScene
      {
         if(sceneStack.length == 0)
         {
            return null;
         }
         return sceneStack[sceneStack.length - 1];
      }
      
      private function alterCapturedScreen() : void
      {
         if(!alterCapturedStackScene())
         {
            sceneContainer.removeChildren();
            return;
         }
         sceneContainer.removeChildren();
         sceneContainer.addChild(captureImage);
      }
      
      private function prePushSceneCapture() : void
      {
         var _loc4_:* = 0;
         var _loc6_:int = 0;
         var _loc5_:* = null;
         var _loc1_:* = null;
         var _loc3_:int = sceneStack.length;
         var _loc2_:* = 0;
         var _loc7_:* = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            if((_loc6_ = (sceneStack[_loc4_] as BaseScene).getType()) == 1)
            {
               _loc7_ = _loc4_;
            }
            if(_loc6_ == 0)
            {
               _loc2_ = _loc4_;
            }
            _loc4_++;
         }
         sceneContainer.removeChildren();
         _loc4_ = _loc2_;
         while(_loc4_ < _loc7_)
         {
            sceneContainer.addChild(sceneStack[_loc4_] as BaseScene);
            _loc4_++;
         }
         alterCapturedStackScene();
         sceneContainer.removeChildren();
         sceneContainer.addChild(captureImage);
      }
      
      private function alterCapturedStackScene() : Boolean
      {
         var _loc2_:* = Starling;
         var _loc1_:Starling = starling.core.Starling.sCurrent;
         if(captureBitmapData)
         {
            captureBitmapData.dispose();
            captureBitmapData = null;
         }
         captureImage.texture.dispose();
         captureBitmapData = drawStackSceneToBitmapData(captureBitmapData);
         if(!captureBitmapData)
         {
            return false;
         }
         captureImage.texture = Texture.fromBitmapData(captureBitmapData);
         captureImage.readjustSize();
         if(_sceneX > gudetama.engine.Engine.designWidthMargin)
         {
            captureImage.x = -gudetama.engine.Engine.designWidthMargin;
         }
         else
         {
            captureImage.x = -_sceneX;
         }
         if(_sceneY > gudetama.engine.Engine.designHeightMargin)
         {
            captureImage.y = 0;
         }
         return true;
      }
      
      private function drawStackSceneToBitmapData(param1:BitmapData = null) : BitmapData
      {
         var _loc12_:* = null;
         var _loc14_:* = Starling;
         var _loc13_:Starling = starling.core.Starling.sCurrent;
         var _loc15_:* = Starling;
         var _loc7_:Painter = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null;
         var _loc3_:Rectangle = _loc13_.viewPort;
         var _loc2_:Number = _loc13_.stage.stageWidth;
         var _loc11_:Number = _loc13_.stage.stageHeight;
         var _loc8_:Number = _loc3_.width / _loc2_;
         var _loc9_:Number = _loc3_.height / _loc11_;
         var _loc10_:Number = _loc7_.backBufferScaleFactor;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc4_:Rectangle = StarlingUtil.getRectangleFromPool();
         if((_loc12_ = sceneContainer.getBounds(sceneContainer.parent,_loc4_)).width <= 0)
         {
            return null;
         }
         if(_loc12_.height <= 0)
         {
            return null;
         }
         _loc12_.width = Math.min(_loc12_.width,designWidth + designWidthMargin * 2);
         _loc12_.height = Math.min(_loc12_.height,designHeight + designHeightMargin * 2);
         if(_sceneX > gudetama.engine.Engine.designWidthMargin)
         {
            _loc5_ = Number(_sceneX - gudetama.engine.Engine.designWidthMargin);
         }
         if(_sceneY > gudetama.engine.Engine.designHeightMargin)
         {
            _loc6_ = Number(_sceneY);
         }
         if(!param1)
         {
            param1 = new BitmapData(Math.ceil(_loc12_.width * _loc8_ * _loc10_),Math.ceil(_loc12_.height * _loc9_ * _loc10_));
         }
         _loc7_.clear();
         _loc7_.pushState();
         _loc7_.state.renderTarget = null;
         _loc7_.state.setModelviewMatricesToIdentity();
         _loc7_.setStateTo(sceneContainer.transformationMatrix);
         _loc7_.state.setProjectionMatrix(_loc5_,_loc6_,_loc7_.backBufferWidth / _loc8_,_loc7_.backBufferHeight / _loc9_,_loc2_,_loc11_,stage.cameraPosition);
         sceneContainer.render(_loc7_);
         _loc7_.finishMeshBatch();
         _loc7_.context.drawToBitmapData(param1);
         _loc7_.popState();
         return param1;
      }
      
      private function clearCapturedScreen() : void
      {
         removeChild(captureImage,true);
         captureImage.texture.dispose();
         if(captureBitmapData)
         {
            captureBitmapData.dispose();
            captureBitmapData = null;
         }
      }
      
      private function resetMask() : void
      {
         mask = maskObject;
      }
      
      private function processTimeoutManagement(param1:DisplayObject, param2:int = 0) : void
      {
         var scene:DisplayObject = param1;
         var count:int = param2;
         if(timeoutRepeatCall)
         {
            clearTimeoutManagement();
         }
         var _loc3_:* = Starling;
         timeoutRepeatCall = (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).repeatCallWithoutPool(function():void
         {
            if(nextScene != scene || !sceneTransitioning)
            {
               clearTimeoutManagement();
               return;
            }
            if(currentTime >= nextTimeoutTime)
            {
               clearTimeoutManagement();
               Engine.unlockTouchInputForce();
               Logger.info("processTimeoutManagement nextScene={}, count={}, rsrc={}, queue={}",nextScene,count,RsrcManager.getTraceString(),MukuGlobal.getTaskQueue().getTraceString());
               MessageDialog.show(13,GameSetting.getUIText("message.error.scene_timeout"),function(param1:int):void
               {
                  if(param1 == 0)
                  {
                     nextTimeoutTime = currentTime + loadingTimeout;
                     if(sceneTransitioning)
                     {
                        processTimeoutManagement(scene,count + 1);
                     }
                  }
                  else
                  {
                     if(nextScene != null)
                     {
                        nextScene.endQueue();
                     }
                     recoverScene();
                  }
               });
            }
         },1);
      }
      
      private function clearTimeoutManagement() : void
      {
         var _loc1_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(timeoutRepeatCall);
         timeoutRepeatCall = null;
      }
      
      private function processInterruptFunctionAtSwitchScene(param1:Function) : void
      {
         if(!_interruptFunctionAtSwitchScene)
         {
            param1();
         }
         else
         {
            _interruptFunctionAtSwitchScene(param1);
         }
      }
      
      private function _switchScene(param1:BaseScene, param2:int, param3:Number, param4:Boolean) : void
      {
         var scene:BaseScene = param1;
         var transition:int = param2;
         var delay:Number = param3;
         var leaveTutorialScene:Boolean = param4;
         switchSceneTime = now;
         if(sceneTransitioning)
         {
            var prevScene:BaseScene = transitionProcessQueue.shift();
            prevScene.cancelSetup();
            clearCapturedScreen();
            resetMask();
            prevScene = null;
         }
         if(transition == 0 && scene.getType() != 0 || transition == 3)
         {
            alterCapturedScreen();
         }
         tweenJuggler.purgeWithComplete();
         var removedScenes:Vector.<BaseScene> = new Vector.<BaseScene>();
         var length:int = sceneStack.length;
         var index:int = length - 1;
         while(index >= 0)
         {
            if(leaveTutorialScene && sceneStack[index] is GuideTalkPanel)
            {
               var tutorialScene:BaseScene = sceneStack.pop();
            }
            else
            {
               removedScenes.push(sceneStack.pop());
            }
            index--;
         }
         sceneStack.push(scene);
         if(tutorialScene != null)
         {
            sceneStack.push(tutorialScene);
         }
         nextScene = scene;
         sceneTransitioning = true;
         transitionProcessQueue.push(scene);
         nextTimeoutTime = currentTime + loadingTimeout;
         processTimeoutManagement(scene);
         if(transition != 3)
         {
            showLoading(0,true);
         }
         closeTransition(function():void
         {
            if(System.totalMemoryNumber > 10485760)
            {
               Logger.info("clearCache",Capabilities.os,ConcreteTexture.restoreDisabled,"mem",System.totalMemoryNumber / 1024,ConcreteTexture.getRegistrantCountText());
               if(!leaveTutorialScene)
               {
                  clearCache();
               }
            }
            var _loc5_:Boolean = false;
            var _loc2_:* = LoadingDialog;
            gudetama.engine.LoadingDialog.instance.loadingMode = _loc5_;
            EffectPlayerManager.disposeCache();
            ParticleSystem.disposeConfigPool();
            PopupBalloon.disposeCache();
            touchStageCallbacks.length = 0;
            if(transition != 3)
            {
               sceneContainer.removeChildren();
            }
            if(!(scene is HomeScene))
            {
               UserDataWrapper.wrapper.hideGudeId = 0;
            }
            popupContainer.removeChildren();
            for each(var _loc1_ in removedScenes)
            {
               _loc1_.removedFromStack();
            }
            removedScenes.length = 0;
            removedScenes = null;
            scene.dispatchEventWith("finished_transition_open");
            scene.processSetupProgress(createSwitchProgressFunction(scene,delay,transition,removedScenes));
         },transition);
      }
      
      private function createSwitchProgressFunction(param1:BaseScene, param2:Number, param3:int, param4:Vector.<BaseScene>) : Function
      {
         var scene:BaseScene = param1;
         var delay:Number = param2;
         var transition:int = param3;
         var removedScenes:Vector.<BaseScene> = param4;
         var transitionPriority:Boolean = !scene.needsManualTransition();
         return function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            clearTimeoutManagement();
            nextScene = null;
            transitionProcessQueue.shift();
            sceneTransitioning = false;
            refreshSceneContainer(scene);
            scene.dispatchEventWith("added_scene_to_container");
            clearCapturedScreen();
            ResidentMenuUI_Gudetama.updateCounter();
            updateMetalButtonEnabled();
            hideLoadingForce();
            var _loc2_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
            {
               openTransition(function():void
               {
                  scene.dispatchEventWith("finished_transition_close");
                  var _loc1_:* = Starling;
                  starling.core.Starling.sCurrent.skipUnchangedFrames = scene.isSkipUnchangedFrames();
                  stage2D.frameRate = scene.getSceneFrameRate();
               },-1,transitionPriority);
            },delay);
         };
      }
      
      private function checkSameScene(param1:BaseScene) : Boolean
      {
         var _loc2_:* = null;
         var _loc3_:Array = GameSetting.getRule().duplicateSceneCheckClasses;
         if(_loc3_)
         {
            _loc2_ = getQualifiedClassName(param1);
            if(_loc3_.indexOf(_loc2_) >= 0 && getQualifiedClassName(nextScene) == _loc2_)
            {
               Logger.error("DuplicateScene : " + _loc2_ + " : " + new Error().getStackTrace());
               return true;
            }
         }
         return false;
      }
      
      private function _pushScene(param1:BaseScene, param2:int, param3:Boolean) : void
      {
         var scene:BaseScene = param1;
         var transition:int = param2;
         var useLoading:Boolean = param3;
         nextScene = scene;
         sceneTransitioning = true;
         transitionProcessQueue.push(scene);
         nextTimeoutTime = currentTime + loadingTimeout;
         processTimeoutManagement(scene);
         sceneStack.push(scene);
         if(scene.getType() == 1)
         {
            prePushSceneCapture();
         }
         _sceneMoveToMostFront(ResidentMenuUI_Gudetama.getInstance());
         if(useLoading)
         {
            showLoading();
         }
         else
         {
            lockTouchInput(this);
         }
         closeTransition(function():void
         {
            cancelTouches();
            System.pauseForGCIfCollectionImminent(0);
            scene.dispatchEventWith("finished_transition_open");
            scene.processSetupProgress(createPushProgressFunction(scene,useLoading,transition));
         },transition);
      }
      
      private function createPushProgressFunction(param1:BaseScene, param2:Boolean, param3:int) : Function
      {
         var scene:BaseScene = param1;
         var useLoading:Boolean = param2;
         var transition:int = param3;
         var transitionPriority:Boolean = !scene.needsManualTransition();
         return function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            nextScene = null;
            transitionProcessQueue.shift();
            clearTimeoutManagement();
            sceneTransitioning = false;
            if(scene.getType() == 3)
            {
               sceneContainer.addChild(scene);
               sceneContainer.broadcastEventWith("refreshed_scene_container",{
                  "source":scene,
                  "fromPop":false
               });
               unlockTouchInputForce();
               hideLoadingForce();
            }
            else
            {
               refreshSceneContainer(scene);
            }
            updateMetalButtonEnabled();
            scene.dispatchEventWith("added_scene_to_container");
            openTransition(function():void
            {
               scene.dispatchEventWith("finished_transition_close");
               stage2D.frameRate = scene.getSceneFrameRate();
            },-1,transitionPriority);
         };
      }
      
      private function updateMetalButtonEnabled() : void
      {
         var _loc3_:int = 0;
         var _loc1_:* = null;
         var _loc2_:Boolean = false;
         _loc3_ = sceneStack.length - 1;
         while(_loc3_ >= 0)
         {
            _loc1_ = sceneStack[_loc3_];
            if(_loc1_.getType() == 0 || _loc1_.getType() == 1)
            {
               ResidentMenuUI_Gudetama.setEnabledMetalButton(!_loc1_.disabledUpperButton);
               ResidentMenuUI_Gudetama.setEnabledMoneyButton(!_loc1_.disabledUpperButton);
               return;
            }
            if(_loc1_.getType() == 2)
            {
               ResidentMenuUI_Gudetama.setEnabledMetalButton(false);
               ResidentMenuUI_Gudetama.setEnabledMoneyButton(false);
               return;
            }
            _loc3_--;
         }
         ResidentMenuUI_Gudetama.setEnabledMetalButton(true);
         ResidentMenuUI_Gudetama.setEnabledMoneyButton(true);
      }
      
      public function _dispatchEventToPreviousScene(param1:String) : void
      {
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc2_:* = null;
         var _loc5_:Boolean = false;
         _loc4_ = sceneStack.length - 1;
         while(_loc4_ >= 0)
         {
            _loc2_ = sceneStack[_loc4_];
            if(_loc2_.getType() != 3)
            {
               if(_loc5_)
               {
                  _loc3_ = _loc2_;
                  break;
               }
               _loc5_ = true;
            }
            _loc4_--;
         }
         if(_loc3_)
         {
            _loc3_.dispatchEventWith(param1);
         }
      }
      
      private function _popScene(param1:DisplayObject, param2:int, param3:Boolean) : void
      {
         var scene:DisplayObject = param1;
         var transition:int = param2;
         var dispose:Boolean = param3;
         closeTransition(function():void
         {
            var i:int = sceneStack.length - 1;
            while(i >= 0)
            {
               var stackedScene:BaseScene = sceneStack[i];
               if(stackedScene === scene)
               {
                  sceneStack.removeAt(i);
                  var popped:BaseScene = stackedScene;
                  break;
               }
               i--;
            }
            refreshSceneContainer(scene,true);
            if(popped)
            {
               popped.removedFromStack();
            }
            i = sceneStack.length - 1;
            while(i >= 0)
            {
               stackedScene = sceneStack[i];
               if(stackedScene.getType() != 3)
               {
                  var frontestScene:BaseScene = stackedScene;
                  break;
               }
               i--;
            }
            if(frontestScene)
            {
               frontestScene.dispatchEventWith("removed_pushed_scene_from_container");
            }
            updateMetalButtonEnabled();
            openTransition(function():void
            {
               scene.dispatchEventWith("removed_scene_from_container");
               var _loc1_:* = Starling;
               starling.core.Starling.sCurrent.skipUnchangedFrames = getTopScene().isSkipUnchangedFrames();
               stage2D.frameRate = getTopScene().getSceneFrameRate();
            },transition);
         },transition);
      }
      
      private function _sceneMoveToMostFront(param1:DisplayObject) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         if(param1 == null)
         {
            return;
         }
         _loc3_ = sceneStack.length - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ = sceneStack[_loc3_];
            if(_loc2_ === param1)
            {
               sceneStack.removeAt(_loc3_);
               break;
            }
            _loc3_--;
         }
         sceneStack.push(param1);
      }
      
      private function refreshSceneContainer(param1:DisplayObject, param2:Boolean = false) : void
      {
         var _loc6_:* = 0;
         var _loc7_:int = 0;
         var _loc9_:* = null;
         var _loc4_:* = null;
         sceneContainer.removeChildren();
         popupContainer.removeChildren();
         var _loc3_:int = sceneStack.length;
         var _loc5_:* = 0;
         var _loc8_:* = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc3_)
         {
            if((_loc7_ = (sceneStack[_loc6_] as BaseScene).getType()) == 1)
            {
               _loc8_ = _loc6_;
            }
            if(_loc7_ == 0)
            {
               _loc5_ = _loc6_;
            }
            _loc6_++;
         }
         if(0 < _loc8_ && _loc5_ < _loc8_)
         {
            _loc6_ = _loc5_;
            while(_loc6_ < _loc8_)
            {
               sceneContainer.addChild(sceneStack[_loc6_] as BaseScene);
               _loc6_++;
            }
            alterCapturedStackScene();
            sceneContainer.removeChildren();
            sceneContainer.addChild(captureImage);
            _loc6_ = _loc8_;
            while(_loc6_ < _loc3_)
            {
               _loc9_ = sceneStack[_loc6_] as BaseScene;
               if((sceneStack[_loc6_] as BaseScene).getType() == 2 || (sceneStack[_loc6_] as BaseScene).getType() == 4)
               {
                  (_loc4_ = new Quad(designWidth,designHeight,0)).alpha = 0;
                  _loc4_.x = _loc9_.x;
                  sceneContainer.addChild(_loc4_);
               }
               sceneContainer.addChild(_loc9_);
               _loc6_++;
            }
         }
         else
         {
            _loc6_ = _loc5_;
            while(_loc6_ < _loc3_)
            {
               _loc9_ = sceneStack[_loc6_] as BaseScene;
               if((sceneStack[_loc6_] as BaseScene).getType() == 2 || (sceneStack[_loc6_] as BaseScene).getType() == 4)
               {
                  (_loc4_ = new Quad(designWidth,designHeight,0)).alpha = 0;
                  _loc4_.x = _loc9_.x;
                  sceneContainer.addChild(_loc4_);
               }
               sceneContainer.addChild(_loc9_);
               _loc6_++;
            }
         }
         sceneContainer.broadcastEventWith("refreshed_scene_container",{
            "source":param1,
            "fromPop":param2
         });
         unlockTouchInputForce();
         hideLoadingForce();
      }
      
      private function onEnterFrame(param1:EnterFrameEvent) : void
      {
         try
         {
            update();
         }
         catch(e:Error)
         {
            traceLog(e);
         }
      }
      
      private function update() : void
      {
         var _loc2_:* = null;
         lastTime = currentTime;
         currentTime = getTimer();
         if(suspendTime > 0)
         {
            elapsed = 0;
         }
         else
         {
            elapsed = currentTime - lastTime;
            if(elapsed <= 0)
            {
               return;
            }
         }
         if(elapsed > 10000)
         {
            Logger.info("too long elapsed",elapsed,currentTime,lastTime,suspendTime);
            elapsed = 10000;
         }
         elapsed *= Starling.timeScale;
         now += elapsed;
         var _loc3_:Number = (currentTime - lastTime) * 0.001;
         var _loc1_:Number = elapsed * 0.001;
         if(_loc1_ > 0)
         {
            if(!sceneTransitioning)
            {
               for each(var _loc4_ in sceneStack)
               {
                  _loc4_.advanceTime(_loc1_);
               }
            }
            var _loc7_:* = LoadingDialog;
            if(gudetama.engine.LoadingDialog.instance)
            {
               LoadingDialog.advanceTime(_loc1_);
            }
            if(tweenJuggler)
            {
               tweenJuggler.advanceTime(_loc1_);
            }
         }
         if(_loc3_ > 0)
         {
            if(readlTimeJuggler)
            {
               readlTimeJuggler.advanceTime(_loc3_);
            }
            SoundManager.advanceTime(_loc3_);
         }
         do
         {
            _loc2_ = sequentialCallbacks.shift();
            if(!_loc2_)
            {
               break;
            }
            _loc2_();
         }
         while(currentTime + 90 > getTimer());
         
      }
      
      protected function onFocusLost(param1:flash.events.Event) : void
      {
         var _loc2_:* = null;
         if(suspendOnFocusLostEnabled)
         {
            if(!isSuspended())
            {
               suspend(true,true);
            }
            SoundManager.pause();
            for each(_loc2_ in sceneStack)
            {
               _loc2_.onFocusLost(param1);
            }
            for each(_loc2_ in popSceneStack)
            {
               _loc2_.onFocusLost(param1);
            }
         }
         DataStorage.saveLocalData();
      }
      
      protected function onFocusGained(param1:flash.events.Event) : void
      {
         var event:flash.events.Event = param1;
         addSequentialCallback(function():void
         {
            if(gudetama.engine.Engine.platform == 1)
            {
               var _loc1_:* = Starling;
               starling.core.Starling.sCurrent.setRequiresRedraw();
            }
            DialogSystemMailChecker.onFocusGained();
         });
         if(suspendOnFocusLostEnabled)
         {
            if(!focusGainedProcessing)
            {
               var finishFocusGainedCallback:* = function():void
               {
                  SoundManager.resume();
                  if(!suspendLostFocus)
                  {
                     suspend(false);
                     checkConnectedSession();
                  }
                  currentTime = lastTime = getTimer();
                  var _loc3_:* = Starling;
                  starling.core.Starling.sCurrent._frameTimestamp = currentTime / 1000;
                  for each(var _loc2_ in sceneStack)
                  {
                     _loc2_.onFocusGainedFinish(event);
                  }
                  for each(var _loc1_ in popSceneStack)
                  {
                     _loc1_.onFocusGainedFinish(event);
                  }
                  focusGainedProcessing = false;
               };
               focusGainedProcessing = true;
               for each(scene in sceneStack)
               {
                  scene.onFocusGainedStart(event);
               }
               var topScene:BaseScene = getTopScene();
               var usesGradualFocusGained:Boolean = topScene && topScene.usesGradualFocusGained();
               if(usesGradualFocusGained)
               {
                  if(!processAdvanceTimeOnFocusGained(finishFocusGainedCallback))
                  {
                     SoundManager.resume();
                     if(!suspendLostFocus)
                     {
                        suspend(false);
                        checkConnectedSession();
                     }
                     currentTime = lastTime = getTimer();
                     var _loc5_:* = Starling;
                     starling.core.Starling.sCurrent._frameTimestamp = currentTime / 1000;
                     for each(scene in sceneStack)
                     {
                        scene.onFocusGainedInterrupt();
                     }
                     focusGainedProcessing = false;
                  }
               }
               else
               {
                  finishFocusGainedCallback();
               }
            }
            else
            {
               focusLostTime = getTimer() - focusGainedAdvanceTime;
            }
         }
      }
      
      private function checkConnectedSession() : void
      {
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         if(!gudetama.net.HttpConnector.mainConnector.isLoggedIn())
         {
            return;
         }
         showLoading("ping_lock");
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(59),function(param1:Object):void
         {
            var response:Object = param1;
            hideLoading("ping_lock");
            OfferwallAdvertisingManager.getOfferwallPoint(function(param1:int):void
            {
               var _num:int = param1;
               if(_num > 0)
               {
                  showLoading(checkConnectedSession);
                  var _loc2_:* = HttpConnector;
                  if(gudetama.net.HttpConnector.mainConnector == null)
                  {
                     gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
                  }
                  gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(229,_num),function(param1:Array):void
                  {
                     hideLoading(checkConnectedSession);
                     var _loc2_:int = param1[0];
                     if(_loc2_ > 0)
                     {
                        ResidentMenuUI_Gudetama.addFreeMetal(_loc2_);
                     }
                  });
               }
            });
         });
      }
      
      private function processAdvanceTimeOnFocusGained(param1:Function) : Boolean
      {
         var finishedCallback:Function = param1;
         var exec:* = function():void
         {
            var _loc1_:Number = NaN;
            var _loc2_:* = null;
            while(focusLostTime > 0)
            {
               if(RsrcManager.getInstance().isLoading())
               {
                  readlTimeJuggler.delayCall(exec,0.1);
                  break;
               }
               elapsed = Math.min(focusLostTime,100) * Starling.timeScale;
               focusGainedAdvanceTime += elapsed;
               now += elapsed;
               _loc1_ = elapsed * 0.001;
               for each(var _loc3_ in sceneStack)
               {
                  _loc3_.advanceTimeOnFocusGained(_loc1_,focusGainedAdvanceTime);
               }
               tweenJuggler.advanceTime(_loc1_);
               var _loc6_:* = Starling;
               starling.core.Starling.sCurrent.advanceTime(_loc1_);
               while(true)
               {
                  _loc2_ = sequentialCallbacks.shift();
                  if(!_loc2_)
                  {
                     break;
                  }
                  _loc2_();
               }
               focusLostTime -= 100;
            }
            if(focusLostTime <= 0)
            {
               finishedCallback();
            }
         };
         focusLostTime = getTimer() - suspendTime;
         if(focusLostTime > GameSetting.def.rule.focusGainedLimitTimeMinites * 60 * 1000)
         {
            return false;
         }
         focusGainedAdvanceTime = suspendTime;
         exec();
         return true;
      }
   }
}

import flash.utils.Dictionary;
import starling.display.DisplayObject;
import starlingbuilder.engine.IDisplayObjectHandler;

class DisplayObjectHandler implements IDisplayObjectHandler
{
    
   
   function DisplayObjectHandler()
   {
      super();
   }
   
   public function onCreate(param1:DisplayObject, param2:Dictionary) : void
   {
      var _loc3_:Object = param2[param1];
      if(_loc3_.hasOwnProperty("tweenData"))
      {
         param1.userObject.tweenData = _loc3_.tweenData;
      }
      if(_loc3_.hasOwnProperty("effectData"))
      {
         param1.userObject.effectData = _loc3_.effectData;
      }
   }
}

import feathers.controls.TextInput;
import feathers.core.IFeathersControl;
import feathers.skins.IStyleProvider;
import starling.display.Quad;

class TextInputStyleProvider implements IStyleProvider
{
    
   
   function TextInputStyleProvider()
   {
      super();
   }
   
   public function applyStyles(param1:IFeathersControl) : void
   {
      var _loc2_:TextInput = param1 as TextInput;
      _loc2_.textEditorProperties = {
         "fontFamily":"std",
         "fontSize":30,
         "color":3355443,
         "fontWeight":"bold",
         "textAlign":"center"
      };
      _loc2_.gap = 10;
      if(_loc2_.width == 0)
      {
         _loc2_.width = 180;
      }
      if(_loc2_.height == 0)
      {
         _loc2_.height = 50;
      }
      _loc2_.backgroundSkin = new Quad(_loc2_.width,_loc2_.height,4294967295);
   }
}

import feathers.controls.TextArea;
import feathers.core.IFeathersControl;
import feathers.skins.IStyleProvider;
import flash.text.TextFormat;
import starling.display.Quad;

class TextAreaStyleProvider implements IStyleProvider
{
    
   
   private var textFormat:TextFormat;
   
   function TextAreaStyleProvider()
   {
      super();
   }
   
   public function applyStyles(param1:IFeathersControl) : void
   {
      var _loc2_:TextArea = param1 as TextArea;
      if(textFormat == null)
      {
         textFormat = new TextFormat("std",30,3355443);
      }
      _loc2_.textEditorProperties.textFormat = textFormat;
      if(_loc2_.width == 0)
      {
         _loc2_.width = 180;
      }
      if(_loc2_.height == 0)
      {
         _loc2_.height = 50;
      }
      _loc2_.backgroundSkin = new Quad(_loc2_.width,_loc2_.height,4294967295);
   }
}

import feathers.controls.Button;
import feathers.core.IFeathersControl;
import feathers.skins.IStyleProvider;
import feathers.text.BitmapFontTextFormat;
import muku.text.PartialBitmapFont;
import starling.display.Quad;
import starling.text.BitmapFont;

class ButtonStyleProvider implements IStyleProvider
{
    
   
   private var bitmapFont:BitmapFont;
   
   private var textFormat:BitmapFontTextFormat;
   
   function ButtonStyleProvider()
   {
      super();
   }
   
   public function applyStyles(param1:IFeathersControl) : void
   {
      var _loc2_:Button = param1 as Button;
      if(textFormat == null)
      {
         bitmapFont = PartialBitmapFont.createFont("std",14);
         textFormat = new BitmapFontTextFormat(bitmapFont,14,16777215,"center");
      }
      _loc2_.defaultLabelProperties = {"textFormat":textFormat};
      if(_loc2_.width != 0 && _loc2_.height != 0)
      {
         _loc2_.defaultSkin = new Quad(10,10,4281545523);
         _loc2_.downSkin = new Quad(10,10,4284900966);
      }
      _loc2_.paddingBottom = 6;
      _loc2_.scaleWhenDown = 1.1;
   }
}

import feathers.controls.Slider;
import feathers.core.IFeathersControl;
import feathers.skins.IStyleProvider;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.scene.ar.ARScene;
import muku.core.TaskQueue;
import starling.display.Image;
import starling.display.Quad;
import starling.textures.Texture;

class SliderStyleProvider implements IStyleProvider
{
    
   
   function SliderStyleProvider()
   {
      super();
   }
   
   public function applyStyles(param1:IFeathersControl) : void
   {
      var target:IFeathersControl = param1;
      var slider:Slider = target as Slider;
      var setupStyle:Function = function():void
      {
         var _loc1_:* = null;
         if(slider.direction == "horizontal")
         {
            slider.thumbProperties = {"defaultSkin":new Image(thmubTexture)};
            _loc1_ = new ImageSkin(minimumTrackTexture);
            _loc1_.scale9Grid = new Rectangle(12,10,1,1);
            slider.minimumTrackProperties = {
               "defaultSkin":_loc1_,
               "scaleWhenDown":1
            };
            slider.trackLayoutMode = "split";
            _loc1_ = new ImageSkin(maximumTrackTexture);
            _loc1_.scale9Grid = new Rectangle(maximumTrackTexture.width / 2,maximumTrackTexture.height / 2,1,1);
            slider.maximumTrackProperties = {
               "defaultSkin":_loc1_,
               "scaleWhenDown":1
            };
         }
         else
         {
            slider.thumbProperties = {
               "defaultSkin":new Quad(30,15,16711680),
               "downSkin":new Quad(34,19,16746632)
            };
            slider.minimumTrackProperties = {
               "defaultSkin":new Quad(8,100,65518),
               "downSkin":new Quad(8,100,8973994),
               "scaleWhenDown":1
            };
         }
      };
      var queue:TaskQueue = new TaskQueue();
      var useScene:Class = slider.userObject["scene"] as Class;
      if(useScene == ARScene)
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("ar0@light",function(param1:Texture):void
            {
               thmubTexture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("ar0@bar_light01",function(param1:Texture):void
            {
               maximumTrackTexture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("ar0@bar_light02",function(param1:Texture):void
            {
               minimumTrackTexture = param1;
               queue.taskDone();
            });
         });
      }
      else
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("setting0@soundbtn",function(param1:Texture):void
            {
               thmubTexture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("setting0@soundbar01",function(param1:Texture):void
            {
               minimumTrackTexture = param1;
               queue.taskDone();
            });
         });
         var maximumTrackTexture:Texture = Engine.assetManager.getTexture("assets-empty");
      }
      queue.registerOnProgress(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
         setupStyle();
      });
      queue.startTask();
   }
}

import feathers.controls.BasicButton;
import feathers.controls.ScrollBar;
import feathers.core.IFeathersControl;
import feathers.skins.IStyleProvider;
import flash.geom.Rectangle;
import gudetama.engine.Engine;
import gudetama.scene.ar.ARScene;
import gudetama.scene.home.HomeDecoScene;
import starling.display.Image;
import starling.textures.Texture;

class ScrollBarStyleProvider implements IStyleProvider
{
    
   
   private var scrollBar:ScrollBar;
   
   function ScrollBarStyleProvider()
   {
      super();
   }
   
   public function applyStyles(param1:IFeathersControl) : void
   {
      var target:IFeathersControl = param1;
      scrollBar = target as ScrollBar;
      var useScene:Class = scrollBar.userObject["scene"] as Class;
      if(ARScene == useScene)
      {
         var frontTextureName:String = "assets-scrollbar04";
         var backTextureName:String = "assets-scrollbar03";
      }
      else if(HomeDecoScene == useScene)
      {
         frontTextureName = "assets-scrollbar_front";
         backTextureName = "assets-scrollbar03";
      }
      else
      {
         frontTextureName = "assets-scrollbar_front";
         backTextureName = "assets-scrollbar_back";
      }
      scrollBar.thumbFactory = function():BasicButton
      {
         var _loc3_:Texture = Engine.assetManager.getTexture(frontTextureName);
         var _loc2_:BasicButton = new BasicButton();
         var _loc1_:Image = new Image(_loc3_);
         _loc1_.scale9Grid = new Rectangle(11,22,1,2);
         _loc2_.defaultSkin = _loc1_;
         return _loc2_;
      };
      scrollBar.paddingTop = 1;
      scrollBar.paddingBottom = 1;
      scrollBar.minimumTrackFactory = function():BasicButton
      {
         var _loc3_:Texture = Engine.assetManager.getTexture(backTextureName);
         var _loc2_:BasicButton = new BasicButton();
         var _loc1_:Image = new Image(_loc3_);
         _loc1_.scale9Grid = new Rectangle(11,22,1,2);
         _loc2_.defaultSkin = _loc1_;
         return _loc2_;
      };
   }
}
