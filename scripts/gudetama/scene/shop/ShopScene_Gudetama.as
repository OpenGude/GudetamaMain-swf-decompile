package gudetama.scene.shop
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.controls.supportClasses.ListDataViewPort;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.SetItemDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.ItemShopDialog_Gudetama;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class ShopScene_Gudetama extends BaseScene
   {
       
      
      private var openSoonItemType:int = -1;
      
      private var list:List;
      
      private var extractor:SpriteExtractor;
      
      private var setItemExtractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var setItems:Array = null;
      
      private var loadCount:int;
      
      private var moveToId:int;
      
      public function ShopScene_Gudetama(param1:int = -1, param2:int = -1)
      {
         collection = new ListCollection();
         super(0);
         this.openSoonItemType = param1;
         moveToId = param2;
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
         addEventListener("update_scene",updateScene);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"ShopLayout_Gudetama",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_ShopItem_Gudetama",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_ShopSetItem",function(param1:Object):void
         {
            setItemExtractor = SpriteExtractor.forGross(param1.object,param1);
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
         layout.paddingTop = 18;
         layout.paddingLeft = 11;
         list.layout = layout;
         list.factoryIDFunction = function(param1:Object):String
         {
            if(param1.type == 7)
            {
               return "setitem";
            }
            return "other";
         };
         list.setItemRendererFactoryWithID("other",function():IListItemRenderer
         {
            return new MenuItemRenderer(extractor,showItemDialog);
         });
         list.setItemRendererFactoryWithID("setitem",function():IListItemRenderer
         {
            return new SetItemRenderer(setItemExtractor,showItemDialog);
         });
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
      
      private function getEnbaleSetItems() : Array
      {
         var _loc3_:* = null;
         var _loc1_:Array = null;
         var _loc5_:Object = GameSetting.def.setItemMap;
         var _loc2_:int = TimeZoneUtil.epochMillisToOffsetSecs();
         for(var _loc4_ in _loc5_)
         {
            _loc3_ = _loc5_[_loc4_];
            if(_loc3_.inTerm(_loc2_))
            {
               if(_loc3_.chargeItem != null)
               {
                  if(_loc3_.viewType == 1)
                  {
                     if(_loc1_ == null)
                     {
                        _loc1_ = [];
                     }
                     _loc1_.push(_loc3_);
                  }
               }
            }
         }
         return _loc1_;
      }
      
      private function setup() : void
      {
         var _loc2_:int = 0;
         collection.removeAll();
         var _loc1_:Boolean = GameSetting.existsDecorationPrice();
         setItems = getEnbaleSetItems();
         checkSetItem(true);
         var _loc3_:Array = GameSetting.getRule().shopItems;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(!(_loc3_[_loc2_] == 4 && (!GudetamaUtil.decorationEnbale() || !_loc1_)))
            {
               if(!(_loc3_[_loc2_] == 8 && !GudetamaUtil.cupGachaEnable()))
               {
                  collection.addItem({"type":_loc3_[_loc2_]});
               }
            }
            _loc2_++;
         }
         checkSetItem(false);
      }
      
      private function checkSetItem(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         if(setItems == null)
         {
            return;
         }
         _loc2_ = 0;
         while(_loc2_ < setItems.length)
         {
            _loc3_ = setItems[_loc2_];
            if(UserDataWrapper.wrapper.isBuyableSetItem(_loc3_) == param1)
            {
               collection.addItem({"type":7});
            }
            _loc2_++;
         }
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         displaySprite.visible = true;
         SoundManager.playMusic("Shop",-1);
         if(checkNoticeTutorial())
         {
            setVisibleState(70);
            list.verticalScrollPolicy = "off";
         }
         else if(openSoonItemType != -1)
         {
            showItemDialog(openSoonItemType);
         }
      }
      
      private function checkNoticeTutorial() : Boolean
      {
         var noticeFlag:int = isNoticeTutorial();
         if(noticeFlag != -1)
         {
            processNoticeTutorial(noticeFlag,noticeTutorialAction,getGuideArrowPos,function():void
            {
               Engine.unlockTouchInput(ShopScene_Gudetama);
            });
            return true;
         }
         return false;
      }
      
      private function isNoticeTutorial() : int
      {
         var _loc3_:* = 0;
         var _loc5_:Boolean = false;
         var _loc4_:UserDataWrapper = UserDataWrapper.wrapper;
         var _loc2_:Vector.<int> = new <int>[2,15,22];
         var _loc1_:uint = _loc2_.length;
         _loc3_ = uint(0);
         while(_loc3_ < _loc1_)
         {
            if(_loc5_ = _loc4_.isCanStartNoticeFlag(_loc2_[_loc3_]))
            {
               return _loc2_[_loc3_];
            }
            _loc3_++;
         }
         return -1;
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
         var _loc4_:Boolean = false;
         var _loc2_:* = null;
         var _loc6_:int = 0;
         var _loc3_:* = null;
         var _loc5_:* = null;
         loop1:
         switch(int(param1) - 1)
         {
            case 0:
               if(_loc4_ = isNoticeTutorial() != -1 ? true : false)
               {
                  _loc2_ = list.getChildAt(0) as ListDataViewPort;
                  while(true)
                  {
                     if(_loc6_ >= _loc2_.numChildren)
                     {
                        break loop1;
                     }
                     if(_loc2_.getChildAt(_loc6_) is MenuItemRenderer)
                     {
                        _loc3_ = _loc2_.getChildAt(_loc6_) as MenuItemRenderer;
                        if(!_loc3_.isUtensilType())
                        {
                           _loc3_.touchable = false;
                        }
                     }
                     else
                     {
                        (_loc5_ = _loc2_.getChildAt(_loc6_) as SetItemRenderer).touchable = false;
                     }
                     _loc6_++;
                  }
                  break;
               }
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc3_:* = undefined;
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:* = null;
         switch(int(param1))
         {
            case 0:
               _loc2_ = list.getChildAt(0) as ListDataViewPort;
               while(_loc5_ < _loc2_.numChildren)
               {
                  if(_loc2_.getChildAt(_loc5_) is MenuItemRenderer)
                  {
                     if((_loc4_ = _loc2_.getChildAt(_loc5_) as MenuItemRenderer).isUtensilType())
                     {
                        _loc3_ = _loc4_.getSpritePos();
                     }
                  }
                  _loc5_++;
               }
               return _loc3_;
            default:
               return _loc3_;
         }
      }
      
      override protected function removedPushedSceneFromContainer(param1:Event) : void
      {
         var _loc5_:int = 0;
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc2_:ListDataViewPort = list.getChildAt(0) as ListDataViewPort;
         while(_loc5_ < _loc2_.numChildren)
         {
            if(_loc2_.getChildAt(_loc5_) is MenuItemRenderer)
            {
               _loc3_ = _loc2_.getChildAt(_loc5_) as MenuItemRenderer;
               _loc3_.touchable = true;
            }
            else
            {
               (_loc4_ = _loc2_.getChildAt(_loc5_) as SetItemRenderer).touchable = true;
            }
            _loc5_++;
         }
         setVisibleState(94);
         super.removedPushedSceneFromContainer(param1);
      }
      
      private function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            var _loc1_:* = null;
            var _loc2_:* = null;
            if(getBackClass())
            {
               _loc1_ = getBackClass();
               _loc2_ = new _loc1_();
               _loc2_.subSceneObject = subSceneObject;
               Engine.switchScene(_loc2_);
               removeBackClass();
            }
            else
            {
               Engine.switchScene(new HomeScene());
            }
         });
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      private function showItemDialog(param1:int) : void
      {
         if(param1 == 0)
         {
            ResidentMenuUI_Gudetama.getInstance().showMetalShop();
         }
         else if(param1 == 1)
         {
            ResidentMenuUI_Gudetama.getInstance().showMoneyShop();
         }
         else if(param1 == 7)
         {
            ItemShopDialog_Gudetama.show(3,moveToId);
         }
         else
         {
            ItemShopDialog_Gudetama.show(param1,moveToId);
            if(list.verticalScrollPolicy == "off")
            {
               list.verticalScrollPolicy = "auto";
            }
         }
      }
      
      private function updateScene() : void
      {
         setup();
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         removeEventListener("update_scene",updateScene);
         list = null;
         extractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.common.GudetamaUtil;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class MenuItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var sprite:Sprite;
   
   private var item:MenuItemUI;
   
   function MenuItemRenderer(param1:SpriteExtractor, param2:Function)
   {
      super();
      this.extractor = param1;
      this.callback = param2;
   }
   
   override protected function initialize() : void
   {
      if(sprite == null)
      {
         sprite = extractor.duplicateAll() as Sprite;
         item = new MenuItemUI(sprite,callback);
         addChild(sprite);
      }
   }
   
   override protected function commitData() : void
   {
      if(!item)
      {
         return;
      }
      item.updateData(data#2);
   }
   
   override public function set data#2(param1:Object) : void
   {
      super.data#2 = param1;
      commitData();
   }
   
   public function isUtensilType() : Boolean
   {
      return item.isUtensilType();
   }
   
   public function getSpritePos() : Vector.<Number>
   {
      return GudetamaUtil.getCenterPosAndWHOnEngine(sprite);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      sprite = null;
      if(item)
      {
         item.dispose();
         item = null;
      }
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.MetalShopDef;
import gudetama.data.compati.MetalShopItemDef;
import gudetama.data.compati.PurchasePresentDef;
import gudetama.engine.SoundManager;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class MenuItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var sale:Image;
   
   private var pack:Image;
   
   private var type:int;
   
   function MenuItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("itemContainer") as ContainerButton;
      button.addEventListener("triggered",onTriggered);
      sale = button.getChildByName("sale") as Image;
      sale.visible = false;
      pack = button.getChildByName("pack") as Image;
      pack.visible = false;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      type = data.type;
      if(type == 0)
      {
         if(UserDataWrapper.wrapper.isNoticeMonthlyBonus())
         {
            sale.visible = false;
            TweenAnimator.startItself(pack,"pack");
            TweenAnimator.finishItself(pack);
            TweenAnimator.startItself(pack,"show");
         }
         else
         {
            sale.visible = isSale();
            TweenAnimator.startItself(pack,"none");
            TweenAnimator.finishItself(pack);
         }
      }
      var imageName:String = "shop0@btn" + StringUtil.decimalFormat("00",type + 1);
      TextureCollector.loadTexture(imageName,function(param1:Texture):void
      {
         if(button != null)
         {
            button.background = param1;
         }
      });
   }
   
   private function isSale() : Boolean
   {
      var _loc1_:* = null;
      for each(var _loc2_ in GameSetting.def.metalShopTable)
      {
         for each(var _loc3_ in _loc2_.items)
         {
            _loc1_ = GameSetting.getPurchasePresent(_loc3_.price);
            if(_loc1_ && !gudetama.data.UserDataWrapper.wrapper._data.purchasePresentMap[_loc1_.id#2])
            {
               return true;
            }
         }
      }
      return false;
   }
   
   private function onTriggered(param1:Event) : void
   {
      SoundManager.playEffect("btn_normal");
      callback(type);
   }
   
   public function isUtensilType() : Boolean
   {
      return 2 == type;
   }
   
   public function dispose() : void
   {
      if(button)
      {
         button.removeEventListener("triggered",onTriggered);
         button = null;
      }
      sale = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.common.GudetamaUtil;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class SetItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var sprite:Sprite;
   
   private var item:SetItemUI;
   
   function SetItemRenderer(param1:SpriteExtractor, param2:Function)
   {
      super();
      this.extractor = param1;
      this.callback = param2;
   }
   
   override protected function initialize() : void
   {
      if(sprite == null)
      {
         sprite = extractor.duplicateAll() as Sprite;
         item = new SetItemUI(sprite,callback);
         addChild(sprite);
      }
   }
   
   override protected function commitData() : void
   {
      if(!item)
      {
         return;
      }
      item.updateData(data#2);
   }
   
   override public function set data#2(param1:Object) : void
   {
      super.data#2 = param1;
      commitData();
   }
   
   public function getSpritePos() : Vector.<Number>
   {
      return GudetamaUtil.getCenterPosAndWHOnEngine(sprite);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      sprite = null;
      if(item)
      {
         item.dispose();
         item = null;
      }
      super.dispose();
   }
}

import gudetama.engine.SoundManager;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import starling.display.Sprite;
import starling.events.Event;

class SetItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var type:int;
   
   function SetItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("itemContainer") as ContainerButton;
      button.addEventListener("triggered",onTriggered);
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      type = param1.type;
   }
   
   private function onTriggered(param1:Event) : void
   {
      SoundManager.playEffect("btn_normal");
      callback(type);
   }
   
   public function dispose() : void
   {
      if(button)
      {
         button.removeEventListener("triggered",onTriggered);
         button = null;
      }
   }
}
