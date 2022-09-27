package gudetama.scene.home
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.HomeDecoUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.DecorationDef;
   import gudetama.data.compati.UsefulDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.decoration.DecorationDetailDialog;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.UsefulDetailDialog;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.SimpleImageButton;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.Texture;
   
   public class UsefulAndDecorationListDialog extends BaseScene
   {
      
      private static const TAB_DECORATION:int = 0;
      
      private static const TAB_USEFUL:int = 1;
       
      
      private var tabGroup:TabGroup;
      
      private var list:List;
      
      private var btnGoShop:SimpleImageButton;
      
      private var decoQuad:Quad;
      
      private var decoBtnSprite:Sprite;
      
      private var usefulExtractor:SpriteExtractor;
      
      private var decorationExtractor:SpriteExtractor;
      
      protected var collection:ListCollection;
      
      private var loadCount:int;
      
      private var cachedRsrcNameMap:Object = null;
      
      private var rentalDecorationIds:Array;
      
      private var showDeco:Boolean = false;
      
      private var diffy:Number = 70;
      
      private var difflisty:Number = 40;
      
      private var diffHeight:Number = 80;
      
      private var rootClass:Class;
      
      public function UsefulAndDecorationListDialog(param1:Class)
      {
         collection = new ListCollection();
         super(2);
         cachedRsrcNameMap = {};
         addEventListener("update_scene",updateScene);
         rootClass = param1;
      }
      
      public static function show(param1:Class) : void
      {
         Engine.pushScene(new UsefulAndDecorationListDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"UsefulAndDecorationListDialog",function(param1:Object):void
         {
            var _loc2_:* = null;
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            tabGroup = new TabGroup(_loc3_.getChildByName("tabGroup") as Sprite,triggeredTabGroup);
            list = _loc3_.getChildByName("list") as List;
            btnGoShop = _loc3_.getChildByName("btnGoShop") as SimpleImageButton;
            btnGoShop.addEventListener("triggered",triggeredGoShop);
            decoBtnSprite = _loc3_.getChildByName("decobtn") as Sprite;
            decoQuad = _loc3_.getChildByName("deco_quad") as Quad;
            decoQuad.addEventListener("touch",triggeredHomeDecoButton);
            if(!HomeDecoUtil.enableHomeDeco())
            {
               decoBtnSprite.visible = false;
               decoQuad.visible = false;
               displaySprite.y -= diffy;
               (_loc3_.getChildByName("common1@frame01") as Image).height = (_loc3_.getChildByName("common1@frame01") as Image).height + diffHeight;
               btnGoShop.y += diffHeight;
               list.y += difflisty;
               list.height += diffHeight;
               _loc2_ = _loc3_.getChildByName("imgListBG") as Image;
               _loc2_.height += diffHeight;
               _loc2_.y += difflisty;
            }
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_UsefulListItem",function(param1:Object):void
         {
            usefulExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_DecorationListItem",function(param1:Object):void
         {
            decorationExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         preloadUsefulIconTextures();
         preloadDecorationImageTextures();
         queue.registerOnProgress(function(param1:Number):void
         {
         });
         queue.startTask(onProgress);
      }
      
      private function preloadUsefulIconTextures() : void
      {
         var _loc3_:* = null;
         var _loc1_:Object = UserDataWrapper.usefulPart.getUsefulMap();
         var _loc2_:Array = [];
         for(var _loc4_ in _loc1_)
         {
            _loc3_ = GameSetting.getUseful(_loc4_);
            if(!GameSetting.isPrivately(8,_loc4_))
            {
               if(_loc3_.isUsable(1))
               {
                  _preloadUsefulIconTexture(_loc4_);
               }
            }
         }
      }
      
      private function _preloadUsefulIconTexture(param1:int) : void
      {
         var id:int = param1;
         loadCount++;
         queue.addTask(function():void
         {
            loadTexture(GudetamaUtil.getItemIconName(8,id),function(param1:Texture):void
            {
               loadCount--;
               checkInit();
               queue.taskDone();
            });
         });
      }
      
      private function preloadDecorationImageTextures() : void
      {
         var _loc3_:* = null;
         var _loc2_:Object = UserDataWrapper.decorationPart.getAcquiredDecorationMap();
         var _loc1_:Object = {};
         for(var _loc5_ in _loc2_)
         {
            _loc3_ = GameSetting.getDecoration(_loc5_);
            if(!GameSetting.isPrivately(9,_loc5_))
            {
               _loc1_[_loc5_] = _loc5_;
            }
         }
         rentalDecorationIds = UserDataWrapper.eventPart.getRentalDecorationIds();
         for each(var _loc4_ in rentalDecorationIds)
         {
            _loc1_[_loc4_] = _loc4_;
         }
         for(_loc5_ in _loc1_)
         {
            _preloadDecorationImageTexture(_loc5_);
         }
      }
      
      private function _preloadDecorationImageTexture(param1:int) : void
      {
         var id:int = param1;
         loadCount++;
         queue.addTask(function():void
         {
            loadTexture(GudetamaUtil.getItemImageName(9,id),function(param1:Texture):void
            {
               loadCount--;
               checkInit();
               queue.taskDone();
            });
         });
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
         layout.horizontalGap = 8;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         layout.paddingLeft = 0;
         list.layout = layout;
         list.setItemRendererFactoryWithID("1",function():IListItemRenderer
         {
            return new UsefulListItemRenderer(usefulExtractor,scene,triggeredUsefulItemUI);
         });
         list.setItemRendererFactoryWithID("0",function():IListItemRenderer
         {
            return new DecorationListItemRenderer(decorationExtractor,scene,triggeredDecorationItemUI);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            return String(param1.type);
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
         setup();
      }
      
      private function setup() : void
      {
         tabGroup.onTouch(1,false);
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
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(UsefulAndDecorationListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(UsefulAndDecorationListDialog);
            var _loc1_:Boolean = resumeNoticeTutorial(7,null,getGuideArrowPos);
            if(!_loc1_)
            {
               _loc1_ = resumeNoticeTutorial(26,null,getGuideArrowPos);
            }
            if(!_loc1_)
            {
               _loc1_ = resumeNoticeTutorial(28,null,getGuideArrowPos);
               if(_loc1_)
               {
                  enableForTutorial(false);
               }
            }
         });
      }
      
      private function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc2_:* = undefined;
         switch(int(param1))
         {
            case 0:
               return GudetamaUtil.getCenterPosAndWHOnEngine(tabGroup.decorationQuad);
            case 1:
               _loc2_ = GudetamaUtil.getCenterPosAndWHOnEngine(tabGroup.decorationQuad);
               tabGroup.onTouch(0,false);
               triggeredTabGroup(0);
               return _loc2_;
            case 2:
               return GudetamaUtil.getCenterPosAndWHOnEngine(decoQuad);
            default:
               return _loc2_;
         }
      }
      
      private function enableForTutorial(param1:Boolean) : void
      {
         list.touchable = param1;
         tabGroup.touchable = param1;
         btnGoShop.touchable = param1;
      }
      
      public function loadTexture(param1:String, param2:Function) : void
      {
         TextureCollector.loadTexture(param1,param2);
         if(cachedRsrcNameMap != null)
         {
            cachedRsrcNameMap[param1] = param1;
         }
      }
      
      private function clearCache() : void
      {
         if(cachedRsrcNameMap != null)
         {
            for(var _loc1_ in cachedRsrcNameMap)
            {
               TextureCollector.clearAtName(_loc1_);
            }
            cachedRsrcNameMap = {};
         }
         TextureCollector.clearAtName("benri0");
      }
      
      private function triggeredUsefulItemUI(param1:int) : void
      {
         var id:int = param1;
         back(function():void
         {
            UsefulDetailDialog.show(id,rootClass,function():void
            {
               UsefulAndDecorationListDialog.show(rootClass);
            });
         });
      }
      
      private function triggeredDecorationItemUI(param1:int) : void
      {
         DecorationDetailDialog.show(param1,rentalDecorationIds.indexOf(param1) >= 0 && !UserDataWrapper.decorationPart.hasDecoration(param1));
      }
      
      private function triggeredTabGroup(param1:int) : void
      {
         if(param1 == 0)
         {
            setupDecoration();
         }
         else
         {
            setupUseful();
         }
      }
      
      private function setupDecoration() : void
      {
         var _loc4_:* = null;
         var _loc1_:Object = UserDataWrapper.decorationPart.getAcquiredDecorationMap();
         var _loc2_:Array = [];
         for(var _loc6_ in _loc1_)
         {
            _loc4_ = GameSetting.getDecoration(_loc6_);
            if(!GameSetting.isPrivately(9,_loc6_))
            {
               _loc2_.push(_loc6_);
            }
         }
         _loc2_.sort(ascendingKeyComparator);
         collection.removeAll();
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         var _loc3_:Array = UserDataWrapper.eventPart.getRentalDecorationIds();
         for each(var _loc5_ in _loc3_)
         {
            if(_loc2_.indexOf(_loc5_) < 0)
            {
               collection.addItem({
                  "type":0,
                  "id":_loc5_,
                  "rental":true
               });
            }
         }
         for each(_loc6_ in _loc2_)
         {
            collection.addItem({
               "type":0,
               "id":_loc6_,
               "rental":false
            });
         }
         TweenAnimator.startItself(displaySprite,"pos0");
      }
      
      private function setupUseful() : void
      {
         var _loc3_:* = null;
         var _loc1_:Object = UserDataWrapper.usefulPart.getUsefulMap();
         var _loc2_:Array = [];
         for(var _loc4_ in _loc1_)
         {
            _loc3_ = GameSetting.getUseful(_loc4_);
            if(!GameSetting.isPrivately(8,_loc4_))
            {
               if(_loc3_.isUsable(1))
               {
                  _loc2_.push(_loc4_);
               }
            }
         }
         _loc2_.sort(ascendingKeyComparator);
         collection.removeAll();
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         for each(_loc4_ in _loc2_)
         {
            collection.addItem({
               "type":1,
               "id":_loc4_
            });
         }
         if(GameSetting.getRule().usefulShopShortcut)
         {
            TweenAnimator.startItself(displaySprite,"pos1");
         }
         else
         {
            TweenAnimator.startItself(displaySprite,"pos0");
         }
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(UsefulAndDecorationListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(UsefulAndDecorationListDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function triggeredHomeDecoButton(param1:TouchEvent) : void
      {
         var event:TouchEvent = param1;
         var touch:Touch = event.getTouch(decoQuad);
         if(touch == null)
         {
            return;
         }
         if(touch.phase == "ended")
         {
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
            {
               Engine.switchScene(new HomeDecoScene(),1,0.5,true);
            });
         }
      }
      
      private function triggeredGoShop() : void
      {
         LocalMessageDialog.show(1,GameSetting.getUIText("common.confirm.go.shop"),function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 1)
            {
               return;
            }
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
            {
               Engine.switchScene(new ShopScene_Gudetama(3));
            });
         });
      }
      
      private function updateScene() : void
      {
         collection.updateAll();
      }
      
      override public function dispose() : void
      {
         if(tabGroup)
         {
            tabGroup.dispose();
            tabGroup = null;
         }
         list = null;
         btnGoShop.removeEventListener("triggered",triggeredGoShop);
         btnGoShop = null;
         decoQuad.removeEventListener("triggered",triggeredCloseButton);
         decoQuad = null;
         usefulExtractor = null;
         decorationExtractor = null;
         collection = null;
         clearCache();
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

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class UsefulListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:BaseScene;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var usefulItemUI:UsefulItemUI;
   
   function UsefulListItemRenderer(param1:SpriteExtractor, param2:BaseScene, param3:Function)
   {
      super();
      this.extractor = param1;
      this.scene = param2;
      this.callback = param3;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      usefulItemUI = new UsefulItemUI(displaySprite,scene,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      usefulItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      usefulItemUI.dispose();
      usefulItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.UserDataWrapper;
import gudetama.engine.BaseScene;
import gudetama.scene.home.UsefulAndDecorationListDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class UsefulItemUI extends UIBase
{
    
   
   private var scene:UsefulAndDecorationListDialog;
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var nameText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var id:int;
   
   function UsefulItemUI(param1:Sprite, param2:BaseScene, param3:Function)
   {
      super(param1);
      this.scene = param2 as UsefulAndDecorationListDialog;
      this.callback = param3;
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
      id = data.id;
      iconImage.visible = false;
      scene.loadTexture(GudetamaUtil.getItemIconName(8,id),function(param1:Texture):void
      {
         iconImage.visible = true;
         iconImage.texture = param1;
      });
      nameText.text#2 = GudetamaUtil.getItemName(8,id);
      numText.text#2 = UserDataWrapper.usefulPart.getNumUseful(id).toString();
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(id);
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

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class DecorationListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:BaseScene;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var decorationItemUI:DecorationItemUI;
   
   function DecorationListItemRenderer(param1:SpriteExtractor, param2:BaseScene, param3:Function)
   {
      super();
      this.extractor = param1;
      this.scene = param2;
      this.callback = param3;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      decorationItemUI = new DecorationItemUI(displaySprite,scene,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      decorationItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      if(decorationItemUI)
      {
         decorationItemUI.dispose();
         decorationItemUI = null;
      }
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.DecorationDef;
import gudetama.engine.BaseScene;
import gudetama.scene.home.UsefulAndDecorationListDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class DecorationItemUI extends UIBase
{
    
   
   private var scene:UsefulAndDecorationListDialog;
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var nameText:ColorTextField;
   
   private var iconImage:Image;
   
   private var rentalImage:Image;
   
   private var disabled:Sprite;
   
   private var id:int;
   
   function DecorationItemUI(param1:Sprite, param2:BaseScene, param3:Function)
   {
      super(param1);
      this.scene = param2 as UsefulAndDecorationListDialog;
      this.callback = param3;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      nameText = button.getChildByName("name") as ColorTextField;
      iconImage = button.getChildByName("icon") as Image;
      rentalImage = button.getChildByName("rental") as Image;
      disabled = button.getChildByName("disabled") as Sprite;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      id = data.id;
      var decorationDef:DecorationDef = GameSetting.getDecoration(id);
      nameText.text#2 = decorationDef.name#2;
      scene.loadTexture(GudetamaUtil.getItemImageName(9,id),function(param1:Texture):void
      {
         iconImage.texture = param1;
      });
      rentalImage.visible = data.rental;
      var currentId:int = UserDataWrapper.decorationPart.getCurrentDecorationId();
      if(currentId != id)
      {
         button.touchable = true;
         disabled.visible = false;
      }
      else
      {
         button.touchable = false;
         disabled.visible = true;
      }
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(id);
   }
   
   public function dispose() : void
   {
      if(button)
      {
         button.removeEventListener("triggered",triggeredButton);
         button = null;
      }
      nameText = null;
   }
}
