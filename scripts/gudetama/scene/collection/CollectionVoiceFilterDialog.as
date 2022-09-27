package gudetama.scene.collection
{
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.MessageDialog;
   import muku.display.ContainerButton;
   import muku.display.ToggleButton;
   import muku.text.ColorTextField;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CollectionVoiceFilterDialog extends BaseScene
   {
      
      public static var TYPE_FILTER_ALL:int = 0;
      
      public static var TYPE_FILTER_OBTAIN:int = 1;
      
      public static var TYPE_FILTER_UNOBTAIN:int = 2;
       
      
      private var sources:Vector.<Object>;
      
      private var sortBtnList:Vector.<ContainerButton>;
      
      private var originSortAscending:Boolean = false;
      
      private var originSelectSortIndex:int;
      
      private var originFilterIndex:int;
      
      private var sortAscending:Boolean = false;
      
      private var selectSortIndex:int;
      
      private var filterIndex:int;
      
      private var toggleSortUIGroup:ToggleUIGroup;
      
      private var callback:Function;
      
      private var sortAscendingBtn:ToggleButton;
      
      private var homeGudetamaToggleBtn:ToggleButton;
      
      private var homeGudetamaToggleText:ColorTextField;
      
      private var homeGudetamaToggleImage:Image;
      
      private var oringalTextX:int;
      
      private var oringalTextY:int;
      
      private var oringalImageX:int;
      
      private var oringalImageY:int;
      
      private var sortAscendingText:ColorTextField;
      
      private var homeGudetamaToTop:Boolean;
      
      private var orignalHomeGudetamaToTop:Boolean;
      
      private var isEvent:Boolean;
      
      public function CollectionVoiceFilterDialog(param1:Boolean, param2:Boolean, param3:int, param4:int, param5:Boolean, param6:Function)
      {
         sortBtnList = new Vector.<ContainerButton>(4,true);
         super(1);
         this.isEvent = param1;
         this.selectSortIndex = param3;
         this.callback = param6;
         this.sortAscending = param2;
         filterIndex = param4;
         homeGudetamaToTop = param5;
         originSortAscending = sortAscending;
         originSelectSortIndex = selectSortIndex;
         originFilterIndex = filterIndex;
         orignalHomeGudetamaToTop = homeGudetamaToTop;
      }
      
      public static function show(param1:Boolean, param2:Boolean, param3:int, param4:int, param5:Boolean, param6:Function) : void
      {
         Engine.pushScene(new CollectionVoiceFilterDialog(param1,param2,param3,param4,param5,param6));
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"VoiceFilterDialogLayout",function(param1:Object):void
         {
            displaySprite = param1.object as Sprite;
            displaySprite.visible = false;
            var _loc5_:Sprite;
            var _loc2_:ContainerButton = (_loc5_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("changeBtn") as ContainerButton;
            _loc2_.addEventListener("triggered",triggeredChangeBtn);
            var _loc7_:ContainerButton;
            (_loc7_ = _loc5_.getChildByName("btn_back") as ContainerButton).addEventListener("triggered",backButtonCallback);
            var _loc6_:Sprite;
            sortAscendingBtn = (_loc6_ = _loc5_.getChildByName("sortBtnSprite") as Sprite).getChildByName("ascendingBtn") as ToggleButton;
            sortAscendingBtn.isSelected = sortAscending;
            sortAscendingText = _loc6_.getChildByName("ascending_colorTextField") as ColorTextField;
            if(sortAscendingBtn.isSelected)
            {
               sortAscendingText.text#2 = GameSetting.getUIText("collection.sort.descending");
            }
            else
            {
               sortAscendingText.text#2 = GameSetting.getUIText("collection.sort.ascending");
            }
            sortAscendingBtn.addEventListener("custom",changeEvent);
            toggleSortUIGroup = new ToggleUIGroup(_loc6_,isEvent,selectSortIndex,triggeredSelectSortBtn);
            var _loc4_:ToggleFilterUIGroup = new ToggleFilterUIGroup(_loc5_.getChildByName("flilterBtnSprite") as Sprite,filterIndex,"btn_fliter",triggeredToggleButtonCallback);
            var _loc3_:Sprite = _loc5_.getChildByName("homeBtnSprite") as Sprite;
            homeGudetamaToggleBtn = _loc3_.getChildByName("toggle_btn") as ToggleButton;
            homeGudetamaToggleBtn.isSelected = homeGudetamaToTop;
            homeGudetamaToggleBtn.addEventListener("custom",changeHomeGudetamaToggleEvent);
            homeGudetamaToggleText = _loc3_.getChildByName("colorTextField") as ColorTextField;
            oringalTextX = homeGudetamaToggleText.x;
            oringalTextY = homeGudetamaToggleText.y;
            homeGudetamaToggleImage = _loc3_.getChildByName("home_icon") as Image;
            oringalImageX = homeGudetamaToggleImage.x;
            oringalImageY = homeGudetamaToggleImage.y;
            fixHomeGudetamaBtnPos();
            addChild(displaySprite);
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         var _loc1_:ContainerButton = sortBtnList[selectSortIndex];
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show");
      }
      
      override public function backButtonCallback() : void
      {
         if(checkChangedState())
         {
            MessageDialog.show(2,GameSetting.getUIText("collection.filter.changed.confirmation"),function(param1:int):void
            {
               if(param1 == 0)
               {
                  _backButtonCallback();
                  return;
               }
            });
         }
         else
         {
            _backButtonCallback();
         }
      }
      
      private function _backButtonCallback() : void
      {
         super.backButtonCallback();
         setBackButtonCallback(null);
         sortAscendingBtn.removeEventListener("custom",changeEvent);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.popScene(scene);
            callback = null;
         });
      }
      
      private function triggeredChangeBtn(param1:Event) : void
      {
         var event:Event = param1;
         TweenAnimator.startItself(displaySprite,"hide",false,function(param1:DisplayObject):void
         {
            Engine.popScene(scene);
            if(callback)
            {
               callback(sortAscendingBtn.isSelected,selectSortIndex,filterIndex,homeGudetamaToggleBtn.isSelected);
               callback = null;
            }
         });
      }
      
      private function triggeredSelectSortBtn(param1:int) : void
      {
         selectSortIndex = param1;
      }
      
      public function triggeredToggleButtonCallback(param1:int) : void
      {
         filterIndex = param1;
      }
      
      private function changeHomeGudetamaToggleEvent() : void
      {
         SoundManager.playEffect("btn_normal");
         fixHomeGudetamaBtnPos();
      }
      
      private function fixHomeGudetamaBtnPos() : void
      {
         if(homeGudetamaToggleBtn.isSelected)
         {
            homeGudetamaToggleText.x = oringalTextX + 3;
            homeGudetamaToggleText.y = oringalTextY + 3;
            homeGudetamaToggleImage.x = oringalImageX + 3;
            homeGudetamaToggleImage.y = oringalImageY + 3;
         }
         else
         {
            homeGudetamaToggleText.x = oringalTextX;
            homeGudetamaToggleText.y = oringalTextY;
            homeGudetamaToggleImage.x = oringalImageX;
            homeGudetamaToggleImage.y = oringalImageY;
         }
      }
      
      private function changeEvent() : void
      {
         SoundManager.playEffect("btn_normal");
         if(sortAscendingBtn.isSelected)
         {
            sortAscendingText.text#2 = GameSetting.getUIText("collection.sort.descending");
         }
         else
         {
            sortAscendingText.text#2 = GameSetting.getUIText("collection.sort.ascending");
         }
      }
      
      private function checkChangedState() : Boolean
      {
         if(originSortAscending != sortAscendingBtn.isSelected)
         {
            return true;
         }
         if(originSelectSortIndex != selectSortIndex)
         {
            return true;
         }
         if(selectSortIndex != filterIndex)
         {
            return true;
         }
         if(orignalHomeGudetamaToTop != homeGudetamaToggleBtn.isSelected)
         {
            return true;
         }
         return false;
      }
   }
}

import feathers.core.ToggleGroup;
import gudetama.engine.TweenAnimator;
import muku.core.TaskQueue;
import starling.display.Sprite;

class ToggleFilterUIGroup
{
    
   
   private var displaySprite:Sprite;
   
   private var callback:Function;
   
   private var toggleGroup:ToggleGroup;
   
   private var toggleUIList:Vector.<ToggleFilterUI>;
   
   private var width:Number;
   
   function ToggleFilterUIGroup(param1:Sprite, param2:int, param3:String, param4:Function)
   {
      var _loc6_:int = 0;
      var _loc5_:* = false;
      toggleUIList = new Vector.<ToggleFilterUI>();
      super();
      this.displaySprite = param1;
      this.callback = param4;
      toggleGroup = new ToggleGroup();
      _loc6_ = 0;
      while(_loc6_ < param1.numChildren)
      {
         _loc5_ = (_loc6_ + 1 & param2) > 0;
         toggleUIList.push(new ToggleFilterUI(param1.getChildByName(param3 + _loc6_) as Sprite,triggeredButtonCallback,_loc6_,toggleGroup,_loc5_));
         _loc6_++;
      }
      width = param1.width;
   }
   
   public function setupWide(param1:TaskQueue) : void
   {
      var _loc3_:* = 0;
      var _loc2_:uint = toggleUIList.length;
      _loc3_ = uint(0);
      while(_loc3_ < _loc2_)
      {
         toggleUIList[_loc3_].setupWide(param1);
         _loc3_++;
      }
   }
   
   public function setVisible(param1:int, param2:Boolean) : void
   {
      toggleUIList[param1].setVisible(param2);
   }
   
   public function get length() : int
   {
      return toggleUIList.length;
   }
   
   public function setupLayout() : void
   {
      var _loc2_:int = 0;
      for each(var _loc1_ in toggleUIList)
      {
         if(_loc1_.isVisible())
         {
            _loc2_++;
         }
      }
      var _loc3_:int = 0;
      for each(_loc1_ in toggleUIList)
      {
         if(_loc1_.isVisible())
         {
            _loc1_.getDisplaySprite().x = (_loc3_ + 1) * (width - _loc2_ * _loc1_.getDisplaySprite().width) / (_loc2_ + 1) + _loc3_ * _loc1_.getDisplaySprite().width;
            _loc3_++;
         }
      }
   }
   
   public function setAllTouchable(param1:Boolean) : void
   {
      var _loc3_:* = 0;
      var _loc2_:uint = toggleUIList.length;
      _loc3_ = uint(0);
      while(_loc3_ < _loc2_)
      {
         toggleUIList[_loc3_].setTouchable(param1);
         _loc3_++;
      }
   }
   
   public function startTween(param1:*, param2:Boolean = false, param3:Function = null) : void
   {
      TweenAnimator.startItself(displaySprite,param1,param2,param3);
   }
   
   private function triggeredButtonCallback(param1:int) : void
   {
      select(param1);
   }
   
   public function select(param1:int) : void
   {
      var _loc3_:* = 0;
      var _loc4_:Boolean = false;
      for each(var _loc2_ in toggleUIList)
      {
         if(_loc2_.isVisible())
         {
            if(_loc4_ = _loc2_.isSelected())
            {
               _loc3_ |= _loc2_.getIndex() + 1;
            }
         }
      }
      toggleUIList[param1].setSelect(true);
      if(callback)
      {
         callback(_loc3_);
      }
   }
   
   public function dispose() : void
   {
      displaySprite = null;
      callback = null;
      toggleGroup.removeAllItems();
      toggleGroup = null;
      for each(var _loc1_ in toggleUIList)
      {
         _loc1_.dispose();
      }
      toggleUIList.length = 0;
      toggleUIList = null;
   }
}

import feathers.core.ToggleGroup;
import gudetama.engine.SoundManager;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.display.ToggleButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class ToggleFilterUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var index:int;
   
   private var button:ToggleButton;
   
   private var text:ColorTextField;
   
   private var oringalTextX:int;
   
   private var oringalTextY:int;
   
   function ToggleFilterUI(param1:Sprite, param2:Function, param3:int, param4:ToggleGroup, param5:Boolean)
   {
      super(param1);
      this.callback = param2;
      this.index = param3;
      button = param1.getChildByName("toggle_btn") as ToggleButton;
      text = param1.getChildByName("colorTextField") as ColorTextField;
      oringalTextX = text.x;
      oringalTextY = text.y;
      setSelected(param5);
      setSelect(param5);
      button.addEventListener("custom",chageEvent);
   }
   
   public function setupWide(param1:TaskQueue) : void
   {
      var queue:TaskQueue = param1;
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("profile0@btn_off",function(param1:Texture):void
         {
            button.defaultTexture = param1;
            button.width = param1.width;
            button.height = param1.height;
            text.width = param1.width;
            queue.taskDone();
         });
      });
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("profile0@btn_on",function(param1:Texture):void
         {
            button.selectedTexture = param1;
            queue.taskDone();
         });
      });
   }
   
   public function setSelect(param1:Boolean) : void
   {
      if(button.isSelected)
      {
         text.x = oringalTextX + 3;
         text.y = oringalTextY + 3;
      }
      else
      {
         text.x = oringalTextX;
         text.y = oringalTextY;
      }
   }
   
   public function setSelected(param1:Boolean) : void
   {
      button.isSelectedWithOutCustomEvent = param1;
   }
   
   public function isSelected() : Boolean
   {
      return button.isSelected;
   }
   
   public function getIndex() : int
   {
      return index;
   }
   
   private function triggered(param1:Event) : void
   {
      if(callback)
      {
         callback(index);
      }
   }
   
   private function chageEvent() : void
   {
      SoundManager.playEffect("btn_normal");
      if(callback)
      {
         callback(index);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggered);
      button = null;
      text = null;
   }
}

import feathers.core.ToggleGroup;
import gudetama.engine.TweenAnimator;
import muku.core.TaskQueue;
import starling.display.Sprite;

class ToggleUIGroup
{
    
   
   private var displaySprite:Sprite;
   
   private var callback:Function;
   
   private var toggleGroup:ToggleGroup;
   
   private var toggleUIList:Vector.<ToggleUI>;
   
   private var width:Number;
   
   private const sortButtonNum:int = 2;
   
   function ToggleUIGroup(param1:Sprite, param2:Boolean, param3:int, param4:Function)
   {
      var _loc5_:int = 0;
      toggleUIList = new Vector.<ToggleUI>();
      super();
      this.displaySprite = param1;
      this.callback = param4;
      toggleGroup = new ToggleGroup();
      _loc5_ = 0;
      while(_loc5_ < 2)
      {
         toggleUIList.push(new ToggleUI(param1.getChildByName("sortBtn" + _loc5_) as Sprite,param2,triggeredButtonCallback,_loc5_,param3,toggleGroup));
         _loc5_++;
      }
      width = param1.width;
   }
   
   public function setupWide(param1:TaskQueue) : void
   {
      var _loc3_:* = 0;
      var _loc2_:uint = toggleUIList.length;
      _loc3_ = uint(0);
      while(_loc3_ < _loc2_)
      {
         toggleUIList[_loc3_].setupWide(param1);
         _loc3_++;
      }
   }
   
   public function setVisible(param1:int, param2:Boolean) : void
   {
      toggleUIList[param1].setVisible(param2);
   }
   
   public function get length() : int
   {
      return toggleUIList.length;
   }
   
   public function setupLayout() : void
   {
      var _loc2_:int = 0;
      for each(var _loc1_ in toggleUIList)
      {
         if(_loc1_.isVisible())
         {
            _loc2_++;
         }
      }
      var _loc3_:int = 0;
      for each(_loc1_ in toggleUIList)
      {
         if(_loc1_.isVisible())
         {
            _loc1_.getDisplaySprite().x = (_loc3_ + 1) * (width - _loc2_ * _loc1_.getDisplaySprite().width) / (_loc2_ + 1) + _loc3_ * _loc1_.getDisplaySprite().width;
            _loc3_++;
         }
      }
   }
   
   public function setAllTouchable(param1:Boolean) : void
   {
      var _loc3_:* = 0;
      var _loc2_:uint = toggleUIList.length;
      _loc3_ = uint(0);
      while(_loc3_ < _loc2_)
      {
         toggleUIList[_loc3_].setTouchable(param1);
         _loc3_++;
      }
   }
   
   public function startTween(param1:*, param2:Boolean = false, param3:Function = null) : void
   {
      TweenAnimator.startItself(displaySprite,param1,param2,param3);
   }
   
   private function triggeredButtonCallback(param1:int) : void
   {
      select(param1);
   }
   
   public function select(param1:int) : void
   {
      var _loc2_:int = 0;
      toggleGroup.selectedIndex = param1;
      _loc2_ = 0;
      while(_loc2_ < toggleUIList.length)
      {
         toggleUIList[_loc2_].setSelect(_loc2_ == param1);
         _loc2_++;
      }
      if(callback)
      {
         callback(param1);
      }
   }
   
   public function dispose() : void
   {
      displaySprite = null;
      callback = null;
      toggleGroup.removeAllItems();
      toggleGroup = null;
      for each(var _loc1_ in toggleUIList)
      {
         _loc1_.dispose();
      }
      toggleUIList.length = 0;
      toggleUIList = null;
   }
}

import feathers.core.ToggleGroup;
import gudetama.data.GameSetting;
import gudetama.engine.SoundManager;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.display.ToggleButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class ToggleUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var index:int;
   
   private var button:ToggleButton;
   
   private var text:ColorTextField;
   
   private var oringalTextX:int;
   
   private var oringalTextY:int;
   
   function ToggleUI(param1:Sprite, param2:Boolean, param3:Function, param4:int, param5:int, param6:ToggleGroup)
   {
      super(param1);
      this.callback = param3;
      this.index = param4;
      button = param1.getChildByName("toggle_btn") as ToggleButton;
      button.toggleGroup = param6;
      button.addEventListener("triggered",triggered);
      if(param4 == param5)
      {
         button.isSelected = true;
      }
      text = param1.getChildByName("colorTextField") as ColorTextField;
      if(param2 && param4 == 0)
      {
         text.text#2 = GameSetting.getUIText("%collection.gudetama.sort.4");
      }
      oringalTextX = text.x;
      oringalTextY = text.y;
   }
   
   public function setupWide(param1:TaskQueue) : void
   {
      var queue:TaskQueue = param1;
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("profile0@btn_off",function(param1:Texture):void
         {
            button.defaultTexture = param1;
            button.width = param1.width;
            button.height = param1.height;
            text.width = param1.width;
            queue.taskDone();
         });
      });
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("profile0@btn_on",function(param1:Texture):void
         {
            button.selectedTexture = param1;
            queue.taskDone();
         });
      });
   }
   
   private function triggered(param1:Event) : void
   {
      SoundManager.playEffect("btn_normal");
      if(callback)
      {
         callback(index);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggered);
      button = null;
      text = null;
   }
}
