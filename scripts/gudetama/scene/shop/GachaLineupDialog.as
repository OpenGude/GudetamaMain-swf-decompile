package gudetama.scene.shop
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.GachaDef;
   import gudetama.data.compati.ScreeningGachaItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class GachaLineupDialog extends BaseScene
   {
       
      
      private var id:int;
      
      private var titleText:ColorTextField;
      
      private var lineupDescText:ColorTextField;
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var labelExtractor:SpriteExtractor;
      
      private var itemExtractor:SpriteExtractor;
      
      private var kindMap:Object;
      
      private var collection:ListCollection;
      
      private var loadCount:int;
      
      public function GachaLineupDialog(param1:int)
      {
         kindMap = {};
         collection = new ListCollection();
         super(1);
         this.id = param1;
      }
      
      public static function show(param1:int) : void
      {
         Engine.pushScene(new GachaLineupDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"GachaLineupDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            lineupDescText = _loc2_.getChildByName("desc") as ColorTextField;
            list = _loc2_.getChildByName("list") as List;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_GachaLineupLabel",function(param1:Object):void
         {
            labelExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_GachaLineupItem",function(param1:Object):void
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
         layout.paddingTop = 10;
         layout.paddingLeft = 13.5;
         list.layout = layout;
         list.setItemRendererFactoryWithID("label",function():IListItemRenderer
         {
            return new LabelListItemRenderer(labelExtractor);
         });
         list.setItemRendererFactoryWithID("item",function():IListItemRenderer
         {
            return new ItemListItemRenderer(itemExtractor);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            return param1.name;
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
         var gachaDef:GachaDef = GameSetting.getGacha(id);
         titleText.text#2 = gachaDef.name#2;
         setupItems();
         setupGroup();
         lineupDescText.text#2 = gachaDef.lineupDesc;
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,"pos" + (!!gachaDef.lineupDesc ? 1 : 0),false,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      private function setupItems() : void
      {
         var _loc2_:GachaDef = GameSetting.getGacha(id);
         for each(var _loc1_ in _loc2_.screeningItems)
         {
            if(!kindMap[_loc1_.item.kind])
            {
               kindMap[_loc1_.item.kind] = new Vector.<ScreeningGachaItemParam>();
            }
            kindMap[_loc1_.item.kind].push(_loc1_);
         }
      }
      
      private function setupGroup() : void
      {
         var _loc7_:int = 0;
         var _loc8_:* = undefined;
         var _loc4_:GachaDef;
         var _loc6_:Array = (_loc4_ = GameSetting.getGacha(id)).gachaLineupPrioritizedKinds;
         var _loc5_:Array = [];
         for(var _loc3_ in kindMap)
         {
            _loc7_ = -1;
            if(_loc6_)
            {
               _loc7_ = _loc6_.indexOf(_loc3_);
            }
            _loc5_.push([_loc3_,_loc7_]);
         }
         _loc5_.sort(ascendingKindComparator);
         for each(var _loc2_ in _loc5_)
         {
            _loc8_ = kindMap[_loc2_[0]];
            collection.addItem({
               "name":"label",
               "kind":_loc2_[0],
               "rate":_loc4_.getRateAtKind(_loc2_[0])
            });
            for each(var _loc1_ in _loc8_)
            {
               collection.addItem({
                  "name":"item",
                  "item":_loc1_
               });
            }
         }
      }
      
      private function ascendingKindComparator(param1:Array, param2:Array) : Number
      {
         if(param1[1] >= 0 && param2[1] >= 0)
         {
            if(param1[1] > param2[1])
            {
               return 1;
            }
            if(param1[1] < param2[1])
            {
               return -1;
            }
         }
         else
         {
            if(param1[1] >= 0 && param2[1] < 0)
            {
               return -1;
            }
            if(param1[1] < 0 && param2[1] >= 0)
            {
               return 1;
            }
         }
         if(param1[0] > param2[0])
         {
            return 1;
         }
         if(param1[0] < param2[0])
         {
            return -1;
         }
         return 0;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(GachaConfirmDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(GachaConfirmDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(GachaConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(GachaConfirmDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         var _loc1_:* = undefined;
         titleText = null;
         lineupDescText = null;
         list = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         labelExtractor = null;
         itemExtractor = null;
         if(kindMap)
         {
            for(var _loc2_ in kindMap)
            {
               _loc1_ = kindMap[_loc2_];
               _loc1_.length = 0;
               delete kindMap[_loc2_];
            }
            kindMap = null;
         }
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class LabelListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var labelUI:LabelUI;
   
   function LabelListItemRenderer(param1:SpriteExtractor)
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
      labelUI = new LabelUI(displaySprite);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      labelUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      labelUI.dispose();
      labelUI = null;
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Sprite;

class LabelUI extends UIBase
{
    
   
   private var labelText:ColorTextField;
   
   private var rateGroup:Sprite;
   
   private var rateText:ColorTextField;
   
   function LabelUI(param1:Sprite)
   {
      super(param1);
      labelText = param1.getChildByName("label") as ColorTextField;
      rateGroup = param1.getChildByName("rateGroup") as Sprite;
      rateText = rateGroup.getChildByName("rate") as ColorTextField;
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      labelText.text#2 = GameSetting.getUIText("gachaLineup.label." + param1.kind);
      rateGroup.visible = GameSetting.getRule().gachaRateScreeningLevel >= 1;
      rateText.text#2 = StringUtil.format(GameSetting.getUIText("gachaLineup.rate"),param1.rate / 100);
   }
   
   public function dispose() : void
   {
      labelText = null;
      rateGroup = null;
      rateText = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class ItemListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var itemUI:ItemUI;
   
   function ItemListItemRenderer(param1:SpriteExtractor)
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
      itemUI = new ItemUI(displaySprite);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      itemUI.dispose();
      itemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.ScreeningGachaItemParam;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class ItemUI extends UIBase
{
    
   
   private var iconImage:Image;
   
   private var newImage:Image;
   
   private var pickupImage:Image;
   
   private var nameText:ColorTextField;
   
   private var rateGroup:Sprite;
   
   private var rateText:ColorTextField;
   
   private var checkSprite:Sprite;
   
   private var checkImage:Image;
   
   private var cookedImage:Image;
   
   function ItemUI(param1:Sprite)
   {
      super(param1);
      iconImage = param1.getChildByName("icon") as Image;
      newImage = param1.getChildByName("new") as Image;
      pickupImage = param1.getChildByName("pickup") as Image;
      nameText = param1.getChildByName("name") as ColorTextField;
      rateGroup = param1.getChildByName("rateGroup") as Sprite;
      rateText = rateGroup.getChildByName("rate") as ColorTextField;
      checkSprite = param1.getChildByName("checkSprite") as Sprite;
      checkImage = checkSprite.getChildByName("check") as Image;
      cookedImage = param1.getChildByName("cooked") as Image;
      cookedImage.visible = false;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      var item:ScreeningGachaItemParam = data.item;
      iconImage.visible = false;
      TextureCollector.loadTexture(GudetamaUtil.getItemIconName(item.item.kind,item.item.id#2),function(param1:Texture):void
      {
         iconImage.visible = true;
         iconImage.texture = param1;
      });
      newImage.visible = item.newFlag;
      pickupImage.visible = item.pickupFlag;
      nameText.text#2 = GudetamaUtil.getItemParamName(item.item);
      rateGroup.visible = GameSetting.getRule().gachaRateScreeningLevel >= 2;
      rateText.text#2 = StringUtil.format(GameSetting.getUIText("gachaLineup.rate"),item.rate / 100);
      if(item.item.kind == 6)
      {
         checkSprite.visible = true;
         checkImage.visible = UserDataWrapper.gudetamaPart.hasRecipe(item.item.id#2);
         nameText.width = 273;
      }
      else if(item.item.kind == 12)
      {
         checkSprite.visible = true;
         checkImage.visible = UserDataWrapper.wrapper.hasAvatar(item.item.id#2);
         nameText.width = 273;
      }
      else if(item.item.kind == 9)
      {
         checkSprite.visible = true;
         checkImage.visible = UserDataWrapper.decorationPart.hasDecoration(item.item.id#2);
         nameText.width = 273;
      }
      else if(item.item.kind == 7)
      {
         checkSprite.visible = false;
         cookedImage.visible = UserDataWrapper.gudetamaPart.isCooked(item.item.id#2);
         nameText.width = 273;
      }
      else
      {
         checkSprite.visible = false;
         nameText.width = 323;
      }
   }
   
   public function dispose() : void
   {
      newImage = null;
      pickupImage = null;
      nameText = null;
      rateGroup = null;
      rateText = null;
      checkSprite = null;
      checkImage = null;
   }
}
