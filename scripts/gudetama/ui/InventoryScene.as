package gudetama.ui
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.scene.profile.ProfileScene;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class InventoryScene extends BaseScene
   {
      
      private static const TYPE_METAL:String = "metal";
      
      private static const TYPE_ITEM:String = "item";
      
      private static const INDEX_METAL:int = 0;
      
      private static const INDEX_USEFUL:int = 1;
      
      private static const INDEX_STAMP:int = 2;
       
      
      private var toggleUIGroup:ToggleUIGroup;
      
      private var list:List;
      
      private var metalExtractor:SpriteExtractor;
      
      private var itemExtractor:SpriteExtractor;
      
      private var loadCount:int;
      
      private var collection:ListCollection;
      
      private var listEmptyText:ColorTextField;
      
      private var currentIndex:int;
      
      public function InventoryScene()
      {
         collection = new ListCollection();
         super(2);
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
         addEventListener("update_scene",updateScene);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"InventoryLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            toggleUIGroup = new ToggleUIGroup(_loc2_.getChildByName("tabGroup") as Sprite,triggeredToggleButtonCallback);
            list = _loc2_.getChildByName("list") as List;
            listEmptyText = _loc2_.getChildByName("listEmptyText") as ColorTextField;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_InventoryMetal",function(param1:Object):void
         {
            metalExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_InventoryItem",function(param1:Object):void
         {
            itemExtractor = SpriteExtractor.forGross(param1.object,param1);
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
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 10;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         list.layout = layout;
         list.setItemRendererFactoryWithID("metal",function():IListItemRenderer
         {
            return new InventoryListMetalRenderer(metalExtractor);
         });
         list.setItemRendererFactoryWithID("item",function():IListItemRenderer
         {
            return new InventoryListItemRenderer(itemExtractor,triggeredInventoryItemUICallback);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            return param1.type;
         };
         list.selectedIndex = -1;
         list.dataProvider = collection;
         list.verticalScrollBarFactory = function():IScrollBar
         {
            var _loc1_:ScrollBar = new ScrollBar();
            _loc1_.trackLayoutMode = "single";
            return _loc1_;
         };
         list.scrollBarDisplayMode = "fixedFloat";
         list.horizontalScrollPolicy = "off";
         list.verticalScrollPolicy = "auto";
         list.interactionMode = "touchAndScrollBars";
         toggleUIGroup.select(0);
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         displaySprite.visible = true;
      }
      
      private function setup(param1:int) : void
      {
         switch(int(param1))
         {
            case 0:
               setupMetal();
               break;
            case 1:
               setupUseful();
               break;
            case 2:
               setupStamp();
         }
         currentIndex = param1;
      }
      
      private function setupMetal() : void
      {
         collection.removeAll();
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         collection.addItem({"type":"metal"});
         listEmptyText.visible = false;
      }
      
      private function setupUseful() : void
      {
         var _loc2_:int = 0;
         collection.removeAll();
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         var _loc1_:Object = UserDataWrapper.usefulPart.getUsefulMap();
         var _loc3_:Array = [];
         for(var _loc4_ in _loc1_)
         {
            if(!GameSetting.isPrivately(8,_loc4_))
            {
               _loc3_.push(_loc4_);
            }
         }
         _loc3_.sort(ascendingKeyComparator);
         for each(_loc4_ in _loc3_)
         {
            _loc2_ = UserDataWrapper.usefulPart.getUseful(_loc4_).num;
            if(_loc2_ != 0)
            {
               collection.addItem({
                  "type":"item",
                  "kind":8,
                  "id":_loc4_,
                  "num":_loc2_
               });
            }
         }
         listEmptyText.visible = collection.length <= 0;
      }
      
      private function setupStamp() : void
      {
         var _loc2_:int = 0;
         collection.removeAll();
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         var _loc3_:Object = UserDataWrapper.stampPart.getStampMap();
         var _loc1_:Array = [];
         for(var _loc4_ in _loc3_)
         {
            if(!GameSetting.isPrivately(11,_loc4_))
            {
               _loc1_.push(_loc4_);
            }
         }
         _loc1_.sort(ascendingKeyComparator);
         for each(_loc4_ in _loc1_)
         {
            _loc2_ = UserDataWrapper.stampPart.getNumStamp(_loc4_);
            if(_loc2_ != 0)
            {
               collection.addItem({
                  "type":"item",
                  "kind":11,
                  "id":_loc4_,
                  "num":_loc2_
               });
            }
         }
         listEmptyText.visible = collection.length <= 0;
      }
      
      private function ascendingKeyComparator(param1:int, param2:int) : Number
      {
         if(param1 > param2)
         {
            return 1;
         }
         if(param1 < param2)
         {
            return -1;
         }
         return 0;
      }
      
      private function triggeredInventoryItemUICallback(param1:int, param2:int) : void
      {
         switch(int(param1) - 8)
         {
            case 0:
               processUseful(param2);
               break;
            case 3:
               processStamp(param2);
         }
      }
      
      private function processUseful(param1:int) : void
      {
         UsefulDetailDialog.show(param1,null);
      }
      
      private function processStamp(param1:int) : void
      {
         StampDetailDialog.show(param1);
      }
      
      private function triggeredToggleButtonCallback(param1:int) : void
      {
         SoundManager.playEffect("btn_normal");
         setup(param1);
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(145,function():void
         {
            Engine.switchScene(new ProfileScene());
         });
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      private function updateScene() : void
      {
         setup(currentIndex);
      }
      
      override public function dispose() : void
      {
         if(toggleUIGroup)
         {
            toggleUIGroup.dispose();
            toggleUIGroup = null;
         }
         list = null;
         metalExtractor = null;
         itemExtractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.core.ToggleGroup;
import starling.display.Sprite;

class ToggleUIGroup
{
    
   
   private var callback:Function;
   
   private var toggleGroup:ToggleGroup;
   
   private var toggleUIList:Vector.<ToggleUI>;
   
   function ToggleUIGroup(param1:Sprite, param2:Function)
   {
      var _loc3_:int = 0;
      toggleUIList = new Vector.<ToggleUI>();
      super();
      this.callback = param2;
      toggleGroup = new ToggleGroup();
      _loc3_ = 0;
      while(_loc3_ < param1.numChildren)
      {
         toggleUIList.push(new ToggleUI(param1.getChildByName("btn_tab" + _loc3_) as Sprite,triggeredButtonCallback,_loc3_,toggleGroup));
         _loc3_++;
      }
   }
   
   private function triggeredButtonCallback(param1:int) : void
   {
      if(toggleGroup.selectedIndex == param1)
      {
         return;
      }
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
import gudetama.ui.UIBase;
import muku.display.ToggleButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class ToggleUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var index:int;
   
   private var button:ToggleButton;
   
   private var text:ColorTextField;
   
   function ToggleUI(param1:Sprite, param2:Function, param3:int, param4:ToggleGroup)
   {
      super(param1);
      this.callback = param2;
      this.index = param3;
      button = param1.getChildByName("toggle_btn") as ToggleButton;
      button.toggleGroup = param4;
      button.addEventListener("triggered",triggered);
      text = param1.getChildByName("text") as ColorTextField;
   }
   
   public function setSelect(param1:Boolean) : void
   {
      text.color = !!param1 ? 5521974 : 16777215;
   }
   
   private function triggered(param1:Event) : void
   {
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

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class InventoryListMetalRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var inventoryMetalUI:InventoryMetalUI;
   
   function InventoryListMetalRenderer(param1:SpriteExtractor)
   {
      super();
      this.extractor = param1;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      inventoryMetalUI = new InventoryMetalUI(displaySprite);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      inventoryMetalUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      inventoryMetalUI.dispose();
      inventoryMetalUI = null;
      super.dispose();
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class InventoryMetalUI extends UIBase
{
    
   
   private var chargeText:ColorTextField;
   
   private var freeText:ColorTextField;
   
   private var subText:ColorTextField;
   
   private var lblGpCharge:ColorTextField;
   
   private var lblGpFree:ColorTextField;
   
   private var chargeButton:SimpleImageButton;
   
   private var btnGp:SimpleImageButton;
   
   function InventoryMetalUI(param1:Sprite)
   {
      super(param1);
      chargeText = param1.getChildByName("charge") as ColorTextField;
      freeText = param1.getChildByName("free") as ColorTextField;
      subText = param1.getChildByName("sub") as ColorTextField;
      lblGpCharge = param1.getChildByName("lblGpCharge") as ColorTextField;
      lblGpFree = param1.getChildByName("lblGpFree") as ColorTextField;
      chargeButton = param1.getChildByName("chargeButton") as SimpleImageButton;
      chargeButton.addEventListener("triggered",triggeredChargeButton);
      btnGp = param1.getChildByName("btnGp") as SimpleImageButton;
      btnGp.addEventListener("triggered",triggeredGp);
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      chargeText.text#2 = StringUtil.getNumStringCommas(UserDataWrapper.wrapper.getChargeMetal());
      freeText.text#2 = StringUtil.getNumStringCommas(UserDataWrapper.wrapper.getFreeMetal());
      subText.text#2 = StringUtil.getNumStringCommas(UserDataWrapper.wrapper.getSubMetal());
      lblGpCharge.text#2 = StringUtil.getNumStringCommas(UserDataWrapper.wrapper.getChargeMoney());
      lblGpFree.text#2 = StringUtil.getNumStringCommas(UserDataWrapper.wrapper.getFreeMoney());
   }
   
   private function triggeredChargeButton(param1:Event) : void
   {
      ResidentMenuUI_Gudetama.getInstance().showMetalShop();
   }
   
   private function triggeredGp() : void
   {
      ResidentMenuUI_Gudetama.getInstance().showMoneyShop();
   }
   
   public function dispose() : void
   {
      chargeText = null;
      freeText = null;
      subText = null;
      lblGpCharge = null;
      lblGpFree = null;
      chargeButton.removeEventListener("triggered",triggeredChargeButton);
      chargeButton = null;
      btnGp.removeEventListener("triggered",triggeredGp);
      btnGp = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class InventoryListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var inventoryItemUI:InventoryItemUI;
   
   function InventoryListItemRenderer(param1:SpriteExtractor, param2:Function)
   {
      super();
      this.extractor = param1;
      this.callback = param2;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      inventoryItemUI = new InventoryItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      inventoryItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      inventoryItemUI.dispose();
      inventoryItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class InventoryItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var nameText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var kind:int;
   
   private var id:int;
   
   function InventoryItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      iconImage = button.getChildByName("icon") as Image;
      nameText = button.getChildByName("name") as ColorTextField;
      numText = button.getChildByName("num") as ColorTextField;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      kind = data.kind;
      id = data.id;
      var num:int = data.num;
      iconImage.visible = false;
      TextureCollector.loadTexture(GudetamaUtil.getItemIconName(kind,id),function(param1:Texture):void
      {
         iconImage.visible = true;
         iconImage.texture = param1;
      });
      nameText.text#2 = GudetamaUtil.getItemName(kind,id);
      numText.text#2 = num.toString();
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(kind,id);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      nameText = null;
      numText = null;
   }
}
