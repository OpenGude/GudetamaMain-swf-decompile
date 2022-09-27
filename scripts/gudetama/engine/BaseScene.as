package gudetama.engine
{
   import flash.events.Event;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.ui.GuideTalkPanel;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.JugglerEx;
   import muku.core.TaskQueue;
   import starling.animation.Juggler;
   import starling.display.DisplayObject;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class BaseScene extends Sprite implements SceneControl
   {
      
      public static const TYPE_COVER_ALL:int = 0;
      
      public static const TYPE_CAPTURED_COVER:int = 1;
      
      public static const TYPE_MODAL:int = 2;
      
      public static const TYPE_FREE:int = 3;
      
      public static const TYPE_MODAL_COVER:int = 4;
      
      protected static const UPPER_UI:int = 1;
      
      protected static const UNDER_UI:int = 2;
      
      protected static const PRESENT_UI:int = 4;
      
      protected static const CHAT_UI:int = 8;
      
      protected static const MISSION_UI:int = 16;
      
      protected static const MASK_ALL_OFF:int = 0;
      
      protected static const MASK_ALL:int = 31;
       
      
      protected var displaySprite:Sprite;
      
      protected var queue:TaskQueue;
      
      protected var scene:BaseScene;
      
      protected var scenePermanent:Boolean;
      
      public var juggler:JugglerEx;
      
      protected var type:int;
      
      protected var currentBackButtonCallback:Function;
      
      protected var currentRoomButtonCallback:Function;
      
      private var currentVisibleState:int;
      
      public var disabledUpperButton:Boolean;
      
      private var backClass:Class = null;
      
      public var subSceneObject:Object;
      
      private var beforePopupBackButtonCallback:Function;
      
      public function BaseScene(param1:int)
      {
         juggler = new JugglerEx();
         super();
         setBackButtonCallback(null);
         scene = this;
         type = param1;
         queue = new TaskQueue();
         setRoomButtonCallback(null);
         removeBackClass();
         subSceneObject = null;
         addEventListener("added_scene_to_container",addedToContainerEventHandler);
         addEventListener("finished_transition_open",transitionCloseFinishedHandler);
         addEventListener("finished_transition_close",transitionOpenFinishedHandler);
         addEventListener("removed_pushed_scene_from_container",removedPushedSceneFromContainer);
         addEventListener("pressed_back_from_container",pressedBackFromContainer);
      }
      
      public function addBackClass(param1:Class, param2:Object = null) : BaseScene
      {
         if(param1)
         {
            backClass = param1;
            subSceneObject = param2;
         }
         return this;
      }
      
      public function getBackClass() : Class
      {
         return backClass;
      }
      
      public function removeBackClass() : void
      {
         backClass = null;
         subSceneObject = null;
      }
      
      public function getSceneJuggler() : Juggler
      {
         return juggler;
      }
      
      public function getSceneFrameRate() : Number
      {
         return Engine.requestedFramerate;
      }
      
      override public function dispose() : void
      {
         removeEventListener("added_scene_to_container",addedToContainerEventHandler);
         removeEventListener("finished_transition_open",transitionCloseFinishedHandler);
         removeEventListener("finished_transition_close",transitionOpenFinishedHandler);
         super.dispose();
      }
      
      public function processSetupProgress(param1:Function) : void
      {
         if(scenePermanent)
         {
            setupProgressForPermanent(param1);
         }
         else
         {
            setupProgress(param1);
         }
      }
      
      protected function setupProgress(param1:Function) : void
      {
      }
      
      protected function setupProgressForPermanent(param1:Function) : void
      {
      }
      
      public function needsLoadingTips() : Boolean
      {
         return false;
      }
      
      public function needsForceClearCache() : Boolean
      {
         return false;
      }
      
      public function needsManualTransition() : Boolean
      {
         return false;
      }
      
      public function disposeForCache() : void
      {
      }
      
      public function cancelSetup() : void
      {
      }
      
      public function endQueue() : void
      {
         queue.end();
      }
      
      public function onFocusLost(param1:flash.events.Event) : void
      {
         focusLost();
      }
      
      public function onFocusGainedStart(param1:flash.events.Event) : void
      {
      }
      
      public function onFocusGainedFinish(param1:flash.events.Event) : void
      {
         focusGainedFinish();
      }
      
      public function onFocusGainedInterrupt() : void
      {
      }
      
      public function advanceTime(param1:Number) : void
      {
         juggler.advanceTime(param1);
         UserDataWrapper.eventPart.advanceTime();
      }
      
      public function advanceTimeOnFocusGained(param1:Number, param2:int) : void
      {
         juggler.advanceTime(param1);
      }
      
      public function isPermanentScene() : Boolean
      {
         return scenePermanent;
      }
      
      public function usesGradualFocusGained() : Boolean
      {
         return false;
      }
      
      public function isSkipUnchangedFrames() : Boolean
      {
         return true;
      }
      
      public function getType() : int
      {
         return type;
      }
      
      public function setType(param1:int) : void
      {
         type = param1;
      }
      
      public function removedFromStack() : void
      {
         if(!scenePermanent)
         {
            try
            {
               dispose();
            }
            catch(e:Error)
            {
               Logger.error("removedFromStack",e);
            }
         }
      }
      
      private function addedToContainerEventHandler(param1:starling.events.Event) : void
      {
         addedToContainer();
      }
      
      protected function addedToContainer() : void
      {
      }
      
      private function transitionCloseFinishedHandler(param1:starling.events.Event) : void
      {
         transitionCloseFinished();
      }
      
      protected function transitionCloseFinished() : void
      {
      }
      
      private function transitionOpenFinishedHandler(param1:starling.events.Event) : void
      {
         transitionOpenFinished();
      }
      
      protected function transitionOpenFinished() : void
      {
      }
      
      protected function focusLost() : void
      {
      }
      
      protected function focusGainedFinish() : void
      {
      }
      
      public function backButtonCallback() : void
      {
         Engine.dispatchEventToPreviousScene("pressed_back_from_container");
      }
      
      protected function pressedBackFromContainer(param1:starling.events.Event) : void
      {
         setVisibleState(currentVisibleState);
      }
      
      protected function removedPushedSceneFromContainer(param1:starling.events.Event) : void
      {
         setBackButtonCallback(currentBackButtonCallback);
         setRoomButtonCallback(currentRoomButtonCallback);
      }
      
      protected function setBackButtonCallback(param1:Function) : void
      {
         ResidentMenuUI_Gudetama.setBackButtonCallback(param1);
         Engine.setHardwareBackKeyFunction(param1);
         currentBackButtonCallback = param1;
      }
      
      protected function setRoomButtonCallback(param1:Function) : void
      {
         ResidentMenuUI_Gudetama.setRoomButtonCallback(param1);
         currentRoomButtonCallback = param1;
      }
      
      protected function showResidentMenuUI(param1:int) : void
      {
         ResidentMenuUI_Gudetama.show(param1);
         currentVisibleState = param1;
      }
      
      protected function setVisibleState(param1:int) : void
      {
         ResidentMenuUI_Gudetama.setVisibleState(param1);
         currentVisibleState = param1;
      }
      
      public function processNoticeTutorial(param1:int, param2:Function = null, param3:Function = null, param4:Function = null) : Boolean
      {
         if(!UserDataWrapper.wrapper.isCanStartNoticeFlag(param1))
         {
            return false;
         }
         var _loc5_:int = param1 + 1000;
         if(Engine.getGuideTalkPanel())
         {
            Engine.resumeGuideTalk(param2,param3);
         }
         else
         {
            GuideTalkPanel.showNoticeTutorial(param1,GameSetting.def.guideTalkTable[_loc5_],param2,param3,param4);
         }
         return true;
      }
      
      public function resumeNoticeTutorial(param1:*, param2:Function = null, param3:Function = null) : Boolean
      {
         if(!UserDataWrapper.isInitialized() || !UserDataWrapper.wrapper.isCanStartNoticeFlag(param1))
         {
            return false;
         }
         var _loc4_:Boolean;
         if(!(_loc4_ = Engine.resumeGuideTalk(param2,param3)))
         {
            Logger.warn("warn : failed resumeGuideTalk() in " + this);
         }
         return _loc4_;
      }
      
      public function addPopup(param1:DisplayObject, param2:Function = null) : void
      {
         beforePopupBackButtonCallback = Engine.getHardwareBackKeyFunction();
         setBackButtonCallback(param2);
         Engine.addPopUp(param1);
      }
      
      public function removePopup(param1:DisplayObject, param2:Boolean = true) : void
      {
         Engine.removePopUp(param1,param2);
         setBackButtonCallback(beforePopupBackButtonCallback);
      }
   }
}
