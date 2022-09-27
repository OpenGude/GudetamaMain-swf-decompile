package gudetama.ui
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.CupGachaDef;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class CupGacahLineupDialog extends BaseScene
   {
       
      
      private var cupId:int;
      
      private var items:Array;
      
      private var oddses:Array;
      
      private var recipeIDlist:Array;
      
      private var callback:Function;
      
      private var msg:String;
      
      private var lblTitle:ColorTextField;
      
      private var title:String;
      
      private var imgCup:Image;
      
      private var collection:ListCollection;
      
      private var list:List;
      
      private var extractor:SpriteExtractor;
      
      private var cupExtractor:SpriteExtractor;
      
      private var rarityExtractor:SpriteExtractor;
      
      private var btnBack:ContainerButton;
      
      private var imgCupDefWidth:Number;
      
      public function CupGacahLineupDialog(param1:int, param2:Array, param3:Array, param4:Array, param5:Function, param6:String, param7:String)
      {
         super(2);
         this.cupId = param1;
         this.items = param2;
         this.oddses = param3;
         this.callback = param5;
         this.msg = param6;
         this.title = param7;
         recipeIDlist = param4;
         collection = new ListCollection();
      }
      
      public static function show(param1:int, param2:Array, param3:Array, param4:Array, param5:Function, param6:String, param7:String = "") : void
      {
         Engine.pushScene(new CupGacahLineupDialog(param1,param2,param4,param3,param5,param6,param7),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CupGacahLineupDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            lblTitle = _loc2_.getChildByName("title") as ColorTextField;
            var _loc3_:ColorTextField = _loc2_.getChildByName("message_field") as ColorTextField;
            btnBack = _loc2_.getChildByName("btn_back") as ContainerButton;
            list = _loc2_.getChildByName("list") as List;
            lblTitle.text#2 = title;
            imgCup = _loc2_.getChildByName("imgCup") as Image;
            imgCupDefWidth = imgCup.width;
            imgCup.visible = false;
            _loc3_.text#2 = msg;
            btnBack.addEventListener("triggered",backButtonCallback);
            displaySprite.visible = false;
            loadCupGachaImage();
         });
         Engine.setupLayoutForTask(queue,"_GetItemListItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         Engine.setupLayoutForTask(queue,"_CupListItem",function(param1:Object):void
         {
            cupExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         Engine.setupLayoutForTask(queue,"_CupRarityItem",function(param1:Object):void
         {
            rarityExtractor = SpriteExtractor.forGross(param1.object,param1);
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
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(ItemsShowDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         setup();
      }
      
      private function loadCupGachaImage() : void
      {
         var innerQueue:TaskQueue = new TaskQueue();
         innerQueue.addTask(function():void
         {
            TextureCollector.loadTexture("cupgude-" + cupId + "_close_s",function(param1:Texture):void
            {
               imgCup.texture = param1;
               imgCup.width = param1.width;
               imgCup.height = param1.height;
               imgCup.x += (lblTitle.width - lblTitle.textBounds.width) / 2 - (imgCup.width - imgCupDefWidth) / 2 - 5;
               imgCup.visible = true;
               innerQueue.taskDone();
            });
         });
         innerQueue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            addChild(displaySprite);
         });
         innerQueue.startTask();
      }
      
      private function setup() : void
      {
         initList();
         refresh();
         show();
      }
      
      private function initList() : void
      {
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 10;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         list.layout = layout;
         list.setItemRendererFactoryWithID("item",function():IListItemRenderer
         {
            return new GetItemListItemRenderer(extractor);
         });
         list.setItemRendererFactoryWithID("cup",function():IListItemRenderer
         {
            return new GetCupGachaListItemRenderer(cupExtractor);
         });
         list.setItemRendererFactoryWithID("rarity",function():IListItemRenderer
         {
            return new CupRarityListItemRenderer(rarityExtractor);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            return param1.name;
         };
         list.verticalScrollBarFactory = function():IScrollBar
         {
            var _loc1_:ScrollBar = new ScrollBar();
            _loc1_.trackLayoutMode = "single";
            return _loc1_;
         };
         list.selectedIndex = -1;
         list.dataProvider = collection;
         list.scrollBarDisplayMode = "fixedFloat";
         list.horizontalScrollPolicy = "off";
         list.verticalScrollPolicy = "auto";
         list.interactionMode = "touchAndScrollBars";
      }
      
      private function refresh() : void
      {
         collection.removeAll();
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         setupCups();
      }
      
      private function setupItems() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < items.length)
         {
            collection.addItem({
               "name":"item",
               "item":items[_loc1_]
            });
            _loc1_++;
         }
      }
      
      private function setupCups() : void
      {
         var _loc7_:* = NaN;
         var _loc9_:* = null;
         var _loc5_:int = 0;
         var _loc1_:* = null;
         var _loc3_:* = null;
         var _loc8_:int = 0;
         var _loc10_:* = null;
         var _loc2_:Number = NaN;
         var _loc6_:* = null;
         if(GameSetting.hasScreeningFlag(13))
         {
            _loc7_ = 0;
            if(oddses)
            {
               for each(var _loc4_ in oddses)
               {
                  _loc7_ += _loc4_;
               }
            }
            _loc9_ = [];
            _loc5_ = 0;
            while(_loc5_ < items.length)
            {
               _loc1_ = items[_loc5_];
               if(_loc1_.kind == 19)
               {
                  _loc3_ = GameSetting.getCupGacha(_loc1_.id#2);
                  _loc8_ = _loc9_.length;
                  while(_loc8_ < _loc3_.rarity + 1)
                  {
                     _loc9_.push(new CupRarityInfo(_loc8_));
                     _loc8_++;
                  }
                  _loc10_ = _loc9_[_loc3_.rarity];
                  _loc2_ = 100 * oddses[_loc5_] / _loc7_;
                  _loc10_.rate += _loc2_;
                  _loc10_.cups.push({
                     "name":"cup",
                     "item":_loc1_,
                     "rate":_loc2_
                  });
               }
               else
               {
                  _loc6_ = GameSetting.getGudetama(_loc1_.id#2);
                  _loc8_ = _loc9_.length;
                  while(_loc8_ < _loc6_.rarity + 1)
                  {
                     _loc9_.push(new CupRarityInfo(_loc8_));
                     _loc8_++;
                  }
                  _loc10_ = _loc9_[_loc6_.rarity];
                  _loc2_ = 100 * oddses[_loc5_] / _loc7_;
                  _loc10_.rate += _loc2_;
                  _loc10_.cups.push({
                     "name":"cup",
                     "item":_loc1_,
                     "rate":_loc2_
                  });
               }
               _loc5_++;
            }
            _loc5_ = _loc9_.length - 1;
            while(_loc5_ >= 0)
            {
               if((_loc10_ = _loc9_[_loc5_]).cups.length > 0)
               {
                  collection.addItem({
                     "name":"rarity",
                     "rarity":_loc10_.rarity,
                     "rate":0.0001 * Math.round(_loc10_.rate * 10000)
                  });
                  _loc8_ = 0;
                  while(_loc8_ < _loc10_.cups.length)
                  {
                     collection.addItem(_loc10_.cups[_loc8_]);
                     _loc8_++;
                  }
               }
               _loc5_--;
            }
         }
         else
         {
            _loc5_ = 0;
            while(_loc5_ < items.length)
            {
               collection.addItem({
                  "name":"cup",
                  "item":items[_loc5_],
                  "rate":0
               });
               _loc5_++;
            }
         }
      }
      
      private function show() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(ItemsShowDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         _backButtonCallback();
      }
      
      private function _backButtonCallback(param1:int = -1) : void
      {
         var _id:int = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(ItemsShowDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(ItemsShowDialog);
            Engine.popScene(scene);
            if(_id != -1)
            {
               callback(_id);
            }
         });
      }
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class GetItemListItemRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:GetItemUI;
   
   function GetItemListItemRenderer(param1:SpriteExtractor)
   {
      super(param1,null);
   }
   
   override protected function createItemUI() : void
   {
      itemUI = new GetItemUI(displaySprite);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override protected function disposeItemUI() : void
   {
      itemUI.dispose();
      itemUI = null;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class GetCupGachaListItemRenderer extends ListItemRendererBase
{
    
   
   private var cupGachaItemUI:GetCupGachaItemUI;
   
   function GetCupGachaListItemRenderer(param1:SpriteExtractor)
   {
      super(param1,null);
   }
   
   override protected function createItemUI() : void
   {
      cupGachaItemUI = new GetCupGachaItemUI(displaySprite);
   }
   
   override protected function commitData() : void
   {
      cupGachaItemUI.updateData(data#2);
   }
   
   override protected function disposeItemUI() : void
   {
      cupGachaItemUI.dispose();
      cupGachaItemUI = null;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class CupRarityListItemRenderer extends ListItemRendererBase
{
    
   
   private var cupRarityItemUI:CupRarityItemUI;
   
   function CupRarityListItemRenderer(param1:SpriteExtractor)
   {
      super(param1,null);
   }
   
   override protected function createItemUI() : void
   {
      cupRarityItemUI = new CupRarityItemUI(displaySprite);
   }
   
   override protected function commitData() : void
   {
      cupRarityItemUI.updateData(data#2);
   }
   
   override protected function disposeItemUI() : void
   {
      cupRarityItemUI.dispose();
      cupRarityItemUI = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.ItemParam;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class GetItemUI extends UIBase
{
    
   
   private var lblName:ColorTextField;
   
   private var lblNum:ColorTextField;
   
   private var icon:Image;
   
   function GetItemUI(param1:Sprite)
   {
      super(param1);
      lblName = param1.getChildByName("lblName") as ColorTextField;
      var _loc2_:ColorTextField = param1.getChildByName("lblToMail") as ColorTextField;
      _loc2_.visible = false;
      icon = param1.getChildByName("icon") as Image;
      var _loc3_:ColorTextField = param1.getChildByName("lblGet") as ColorTextField;
      _loc3_.text#2 = GameSetting.getUIText("common.get.num");
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      var item:ItemParam = data["item"] as ItemParam;
      TextureCollector.loadTextureRsrc(GudetamaUtil.getItemIconName(item.kind,item.id#2),function(param1:Texture):void
      {
         if(icon != null)
         {
            icon.texture = param1;
         }
      });
   }
   
   public function dispose() : void
   {
      lblName = null;
      lblNum = null;
      icon = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaData;
import gudetama.data.compati.ItemParam;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class GetCupGachaItemUI extends UIBase
{
    
   
   private var lblName:ColorTextField;
   
   private var lblNum:ColorTextField;
   
   private var icon:Image;
   
   private var rateText:ColorTextField;
   
   function GetCupGachaItemUI(param1:Sprite)
   {
      super(param1);
      lblName = param1.getChildByName("lblName") as ColorTextField;
      icon = param1.getChildByName("icon") as Image;
      var _loc2_:Sprite = param1.getChildByName("numGroup") as Sprite;
      var _loc3_:ColorTextField = _loc2_.getChildByName("lblGet") as ColorTextField;
      _loc3_.text#2 = GameSetting.getUIText("common.cook.num");
      lblNum = _loc2_.getChildByName("lblNum") as ColorTextField;
      var _loc4_:Sprite;
      rateText = (_loc4_ = param1.getChildByName("rateGroup") as Sprite).getChildByName("rate") as ColorTextField;
      if(GameSetting.hasScreeningFlag(13))
      {
         _loc2_.y = 61;
      }
      else
      {
         _loc2_.y = 75;
      }
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      var item:ItemParam = data.item as ItemParam;
      var rate:Number = data.rate;
      rateText.text#2 = StringUtil.format(GameSetting.getUIText("gachaLineup.rate"),rate);
      lblName.text#2 = GudetamaUtil.getItemName(item.kind,item.id#2);
      if(item.kind == 19)
      {
         var count:int = 0;
         lblNum.text#2 = String(count);
      }
      else if(item.kind == 7)
      {
         count = 0;
         var gudetamaData:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(item.id#2);
         if(gudetamaData != null)
         {
            count = UserDataWrapper.gudetamaPart.getGudetama(item.id#2).count;
         }
         lblNum.text#2 = String(count);
      }
      else
      {
         lblNum.text#2 = StringUtil.getNumStringCommas(item.num);
      }
      TextureCollector.loadTextureRsrc(GudetamaUtil.getItemIconName(item.kind,item.id#2),function(param1:Texture):void
      {
         if(icon != null)
         {
            icon.texture = param1;
         }
      });
   }
   
   public function dispose() : void
   {
      lblName = null;
      lblNum = null;
      icon = null;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class GetCupListItemRenderer extends ListItemRendererBase
{
    
   
   private var cupItemUI:GetCupItemUI;
   
   function GetCupListItemRenderer(param1:SpriteExtractor)
   {
      super(param1,null);
   }
   
   override protected function createItemUI() : void
   {
      cupItemUI = new GetCupItemUI(displaySprite);
   }
   
   override protected function commitData() : void
   {
      cupItemUI.updateData(data#2);
   }
   
   override protected function disposeItemUI() : void
   {
      cupItemUI.dispose();
      cupItemUI = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.CupGachaDef;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.ItemParam;
import gudetama.engine.TextureCollector;
import gudetama.ui.ItemsShowDialog;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class GetCupItemUI extends UIBase
{
    
   
   private var lblName:ColorTextField;
   
   private var icon:Image;
   
   private var rateText:ColorTextField;
   
   private var btnDetail:ContainerButton;
   
   private var item:ItemParam;
   
   private var completeImage:Image;
   
   private var cgDef:CupGachaDef;
   
   function GetCupItemUI(param1:Sprite)
   {
      super(param1);
      lblName = param1.getChildByName("lblName") as ColorTextField;
      icon = param1.getChildByName("icon") as Image;
      var _loc3_:Sprite = param1.getChildByName("completeSprite") as Sprite;
      completeImage = _loc3_.getChildByName("complete") as Image;
      completeImage.visible = false;
      var _loc2_:Sprite = param1.getChildByName("rateGroup") as Sprite;
      rateText = _loc2_.getChildByName("rate") as ColorTextField;
      if(GameSetting.hasScreeningFlag(13))
      {
         _loc2_.visible = true;
      }
      else
      {
         _loc2_.visible = false;
      }
      btnDetail = param1.getChildByName("btnDetail") as ContainerButton;
      btnDetail.addEventListener("triggered",btnDetailCallback);
   }
   
   private function btnDetailCallback() : void
   {
      ItemsShowDialog.show4cupGacha(cgDef.prizes,cgDef.oddses,null,GameSetting.getUIText("cupgacha.desc.prizelist"),GameSetting.getUIText("cupgacha.title.prizelist"));
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      var item:ItemParam = data.item as ItemParam;
      cgDef = GameSetting.getCupGacha(item.id#2);
      var rate:Number = data.rate;
      lblName.text#2 = GudetamaUtil.getItemName(item.kind,item.id#2);
      rateText.text#2 = StringUtil.format(GameSetting.getUIText("gachaLineup.rate"),rate);
      TextureCollector.loadTextureRsrc(GudetamaUtil.getItemIconName(item.kind,item.id#2),function(param1:Texture):void
      {
         if(icon != null)
         {
            icon.texture = param1;
         }
      });
      var i:int = 0;
      while(i < cgDef.prizes.length)
      {
         var item:ItemParam = cgDef.prizes[i];
         if(item.kind == 7)
         {
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(item.id#2);
            if(gudetamaDef != null)
            {
               var gudetamaId:int = gudetamaDef.id#2;
               if(UserDataWrapper.gudetamaPart.isCooked(gudetamaId))
               {
                  cookedCount++;
               }
               max++;
            }
         }
         i++;
      }
      if(cookedCount >= max)
      {
         completeImage.visible = true;
      }
      else
      {
         completeImage.visible = false;
      }
   }
   
   public function dispose() : void
   {
      icon = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;

class CupRarityItemUI extends UIBase
{
    
   
   private var stars:Array;
   
   private var rate:ColorTextField;
   
   function CupRarityItemUI(param1:Sprite)
   {
      var _loc3_:int = 0;
      stars = [];
      super(param1);
      var _loc2_:Sprite = param1.getChildByName("starGroup") as Sprite;
      _loc3_ = 0;
      while(_loc3_ < _loc2_.numChildren)
      {
         stars.push(_loc2_.getChildByName("star" + _loc3_) as Image);
         _loc3_++;
      }
      rate = param1.getChildByName("rate") as ColorTextField;
   }
   
   public function updateData(param1:Object) : void
   {
      var _loc2_:int = 0;
      if(!param1)
      {
         return;
      }
      _loc2_ = 0;
      while(_loc2_ < stars.length)
      {
         stars[_loc2_].visible = _loc2_ <= param1.rarity;
         _loc2_++;
      }
      rate.text#2 = StringUtil.format(GameSetting.getUIText("gachaLineup.rate"),param1.rate);
   }
   
   public function dispose() : void
   {
   }
}

class CupRarityInfo
{
    
   
   public var rarity:int;
   
   public var rate:Number = 0;
   
   public var cups:Array;
   
   function CupRarityInfo(param1:int)
   {
      cups = [];
      super();
      rarity = param1;
   }
}
