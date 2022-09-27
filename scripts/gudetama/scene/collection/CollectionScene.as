package gudetama.scene.collection
{
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import muku.core.TaskQueue;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CollectionScene extends BaseScene
   {
      
      public static const TAB_GUDETAMA:int = 1;
      
      public static const TAB_VOICE:int = 0;
       
      
      private var loadCount:int;
      
      private var panelSprite:Sprite;
      
      private var gudetamaCollectionPanel:PicturebookCollectionPanel;
      
      private var voiceCollectionPanel:PicturebookCollectionPanel;
      
      private var tabGroup:TabGroup;
      
      private var selectedTab:int;
      
      public function CollectionScene(param1:int = 1)
      {
         super(0);
         selectedTab = param1;
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"CollectionLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            panelSprite = _loc3_.getChildByName("panelSprite") as Sprite;
            tabGroup = new TabGroup(_loc3_.getChildByName("tabGroup") as Sprite,triggeredTabGroup);
            var _loc2_:Sprite = panelSprite.getChildByName("stretchGudetamaSprite") as Sprite;
            gudetamaCollectionPanel = new PicturebookCollectionPanel(0);
            gudetamaCollectionPanel.setupProgress(queue,_loc2_.getChildByName("picturebookGudetamaSprite") as Sprite,setupLayoutForTask);
            gudetamaCollectionPanel.visible = true;
            var _loc4_:Sprite = panelSprite.getChildByName("stretchVoiceSprite") as Sprite;
            voiceCollectionPanel = new PicturebookCollectionPanel(1);
            voiceCollectionPanel.setupProgress(queue,_loc4_.getChildByName("picturebookVoiceSprite") as Sprite,setupLayoutForTask);
            voiceCollectionPanel.visible = false;
            displaySprite.visible = false;
            addChild(displaySprite);
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
      
      public function setupLayoutForTask(param1:TaskQueue, param2:Object, param3:Function) : void
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
         gudetamaCollectionPanel.init();
         voiceCollectionPanel.init();
      }
      
      override protected function addedToContainer() : void
      {
         gudetamaCollectionPanel.addedToContainer();
         voiceCollectionPanel.addedToContainer();
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         TweenAnimator.startItself(panelSprite,"default",false,function():void
         {
            if(selectedTab == 0)
            {
               nextPicturebook();
               tabGroup.onTouch(0);
            }
         });
         displaySprite.visible = true;
      }
      
      override protected function transitionOpenFinished() : void
      {
         var _loc1_:Boolean = processNoticeTutorial(3,noticeTutorialAction,getGuideArrowPos);
         if(_loc1_)
         {
            setBackButtonCallback(null);
            setVisibleState(70);
            gudetamaCollectionPanel.transitionOpenFinished();
            voiceCollectionPanel.transitionOpenFinished();
         }
         var _loc2_:Boolean = processNoticeTutorial(30,noticeTutorialAction);
         if(_loc2_)
         {
            setBackButtonCallback(null);
            setVisibleState(70);
            gudetamaCollectionPanel.transitionOpenFinished();
            voiceCollectionPanel.transitionOpenFinished();
         }
      }
      
      private function triggeredTabGroup(param1:int) : void
      {
         if(param1 == 1)
         {
            backPicturebook();
         }
         else
         {
            nextPicturebook();
         }
      }
      
      private function nextPicturebook() : void
      {
         voiceCollectionPanel.visible = true;
         gudetamaCollectionPanel.visible = false;
      }
      
      private function backPicturebook() : void
      {
         gudetamaCollectionPanel.visible = true;
         voiceCollectionPanel.visible = false;
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
         switch(int(param1))
         {
            case 0:
               setBackButtonCallback(backButtonCallback);
               setVisibleState(94);
               gudetamaCollectionPanel.noticeTutorialAction(param1);
               voiceCollectionPanel.noticeTutorialAction(param1);
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         return gudetamaCollectionPanel.getGuideArrowPos(param1);
      }
      
      private function backButtonCallback() : void
      {
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         gudetamaCollectionPanel.dispose();
         voiceCollectionPanel.dispose();
         super.dispose();
      }
   }
}

import gudetama.engine.SoundManager;
import gudetama.ui.UIBase;
import starling.display.Quad;
import starling.display.Sprite;

class TabGroup extends UIBase
{
    
   
   private var callback:Function;
   
   private var tabs:Sprite;
   
   private var tabUIs:Vector.<TabUI>;
   
   public var decorationQuad:Quad;
   
   function TabGroup(param1:Sprite, param2:Function)
   {
      var _loc5_:int = 0;
      var _loc3_:* = null;
      tabUIs = new Vector.<TabUI>();
      super(param1);
      this.callback = param2;
      tabs = param1.getChildByName("tabs") as Sprite;
      var _loc4_:Sprite = param1.getChildByName("quads") as Sprite;
      _loc5_ = 0;
      while(_loc5_ < tabs.numChildren)
      {
         _loc3_ = _loc4_.getChildAt(_loc5_) as Quad;
         tabUIs.push(new TabUI(tabs.getChildAt(_loc5_) as Sprite,_loc3_,_loc5_,onTouch));
         if(_loc5_ == 0)
         {
            decorationQuad = _loc3_;
         }
         _loc5_++;
      }
   }
   
   public function onTouch(param1:int, param2:Boolean = true) : void
   {
      var _loc3_:int = 0;
      _loc3_ = 0;
      while(_loc3_ < tabUIs.length)
      {
         tabUIs[_loc3_].setTouchable(_loc3_ != param1);
         _loc3_++;
      }
      tabs.swapChildrenAt(tabs.getChildIndex(tabUIs[param1].getDisplaySprite()),tabUIs.length - 1);
      if(param2)
      {
         SoundManager.playEffect("btn_ok");
      }
      callback(param1);
   }
   
   public function set touchable(param1:Boolean) : void
   {
      var _loc2_:int = 0;
      tabs.touchable = param1;
      _loc2_ = 0;
      while(_loc2_ < tabUIs.length)
      {
         tabUIs[_loc2_].touchable = param1;
         _loc2_++;
      }
   }
   
   public function dispose() : void
   {
      if(tabUIs)
      {
         for each(var _loc1_ in tabUIs)
         {
            _loc1_.dispose();
         }
         tabUIs.length = 0;
         tabUIs = null;
      }
   }
}

import gudetama.ui.UIBase;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;

class TabUI extends UIBase
{
    
   
   private var index:int;
   
   private var callback:Function;
   
   private var quad:Quad;
   
   function TabUI(param1:Sprite, param2:Quad, param3:int, param4:Function)
   {
      super(param1);
      this.quad = param2;
      this.index = param3;
      this.callback = param4;
      param2.addEventListener("touch",onTouch);
   }
   
   private function onTouch(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(quad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         callback(index);
      }
   }
   
   public function set touchable(param1:Boolean) : void
   {
      quad.touchable = param1;
      setTouchable(param1);
   }
   
   public function dispose() : void
   {
      if(quad)
      {
         quad.removeEventListener("touch",onTouch);
         quad = null;
      }
   }
}
