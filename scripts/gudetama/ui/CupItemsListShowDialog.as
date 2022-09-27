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
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class CupItemsListShowDialog extends BaseScene
   {
       
      
      private var items:Array;
      
      private var recipeIDlist:Array;
      
      private var callback:Function;
      
      private var msg:String;
      
      private var collection:ListCollection;
      
      private var list:List;
      
      private var cupExtractor:SpriteExtractor;
      
      private var rarityExtractor:SpriteExtractor;
      
      private var btnBack:ContainerButton;
      
      public function CupItemsListShowDialog(param1:Object, param2:Function, param3:String)
      {
         super(2);
         this.items = [];
         createItemList(param1);
         this.callback = param2;
         this.msg = param3;
         collection = new ListCollection();
      }
      
      public static function show(param1:Object, param2:Function, param3:String) : void
      {
         Engine.pushScene(new CupItemsListShowDialog(param1,param2,param3),0,false);
      }
      
      private function createItemList(param1:Object) : void
      {
         var _loc3_:* = null;
         var _loc5_:* = null;
         var _loc4_:int = 0;
         var _loc2_:* = null;
         if(param1)
         {
            recipeIDlist = [];
            _loc3_ = [];
            for(var _loc6_ in param1)
            {
               recipeIDlist.push(_loc6_);
               _loc5_ = param1[_loc6_];
               _loc4_ = 0;
               while(_loc4_ < _loc5_.length)
               {
                  _loc2_ = _loc5_[_loc4_];
                  if(_loc3_.indexOf(_loc2_.id#2) == -1)
                  {
                     items.push(_loc2_);
                     _loc3_.push(_loc2_.id#2);
                  }
                  _loc4_++;
               }
            }
         }
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CupItemsListDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc3_:ColorTextField = _loc2_.getChildByName("message_field") as ColorTextField;
            btnBack = _loc2_.getChildByName("btn_back") as ContainerButton;
            list = _loc2_.getChildByName("list") as List;
            _loc3_.text#2 = msg;
            btnBack.addEventListener("triggered",backButtonCallback);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_CupListDetailItem",function(param1:Object):void
         {
            cupExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         Engine.setupLayoutForTask(queue,"_CupRarityListItem",function(param1:Object):void
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
         list.setItemRendererFactoryWithID("cup",function():IListItemRenderer
         {
            return new GetCupListItemRenderer(cupExtractor,_backButtonCallback);
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
         setupItems();
      }
      
      private function setupItems() : void
      {
         var _loc5_:* = NaN;
         var _loc7_:* = null;
         var _loc3_:int = 0;
         var _loc1_:* = null;
         var _loc2_:* = null;
         var _loc6_:int = 0;
         var _loc8_:* = null;
         var _loc4_:* = null;
         if(GameSetting.hasScreeningFlag(13))
         {
            _loc5_ = 0;
            _loc7_ = [];
            _loc3_ = 0;
            while(_loc3_ < items.length)
            {
               _loc1_ = items[_loc3_];
               if(_loc1_.kind == 19)
               {
                  _loc2_ = GameSetting.getCupGacha(_loc1_.id#2);
                  _loc6_ = _loc7_.length;
                  while(_loc6_ < _loc2_.rarity + 1)
                  {
                     _loc7_.push(new CupRarityInfo(_loc6_));
                     _loc6_++;
                  }
                  _loc8_ = _loc7_[_loc2_.rarity];
                  if(checkAddCupGacha(_loc2_))
                  {
                     _loc8_.cups.push({
                        "name":"cup",
                        "item":_loc1_,
                        "recipeIDlist":recipeIDlist
                     });
                  }
               }
               else
               {
                  _loc4_ = GameSetting.getGudetama(_loc1_.id#2);
                  _loc6_ = _loc7_.length;
                  while(_loc6_ < _loc4_.rarity + 1)
                  {
                     _loc7_.push(new CupRarityInfo(_loc6_));
                     _loc6_++;
                  }
                  (_loc8_ = _loc7_[_loc4_.rarity]).cups.push({
                     "name":"cup",
                     "item":_loc1_,
                     "recipeIDlist":recipeIDlist
                  });
               }
               _loc3_++;
            }
            _loc3_ = _loc7_.length - 1;
            while(_loc3_ >= 0)
            {
               if((_loc8_ = _loc7_[_loc3_]).cups.length > 0)
               {
                  collection.addItem({
                     "name":"rarity",
                     "rarity":_loc8_.rarity,
                     "rate":0.0001 * Math.round(_loc8_.rate * 10000)
                  });
                  _loc6_ = 0;
                  while(_loc6_ < _loc8_.cups.length)
                  {
                     collection.addItem(_loc8_.cups[_loc6_]);
                     _loc6_++;
                  }
               }
               _loc3_--;
            }
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < items.length)
            {
               collection.addItem({
                  "name":"cup",
                  "item":items[_loc3_],
                  "rate":0
               });
               _loc3_++;
            }
         }
      }
      
      private function checkAddCupGacha(param1:CupGachaDef) : Boolean
      {
         var _loc2_:Array = param1.enableCountryFlags;
         if(!_loc2_)
         {
            return true;
         }
         return _loc2_.indexOf(Engine.getCountryCode()) >= 0;
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

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class GetCupListItemRenderer extends ListItemRendererBase
{
    
   
   private var cupItemUI:GetCupItemUI;
   
   private var callback:Function;
   
   function GetCupListItemRenderer(param1:SpriteExtractor, param2:Function)
   {
      super(param1,null);
      callback = param2;
   }
   
   override protected function createItemUI() : void
   {
      cupItemUI = new GetCupItemUI(displaySprite,callback);
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
import gudetama.data.compati.CupGachaDef;
import gudetama.data.compati.ItemParam;
import gudetama.engine.TextureCollector;
import gudetama.ui.CupGacahLineupDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class GetCupItemUI extends UIBase
{
    
   
   private var lblName:ColorTextField;
   
   private var icon:Image;
   
   private var btnDetail:ContainerButton;
   
   private var item:ItemParam;
   
   private var cgDef:CupGachaDef;
   
   private var recipeIDlist:Array;
   
   private var callback:Function;
   
   function GetCupItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      callback = param2;
      lblName = param1.getChildByName("lblName") as ColorTextField;
      icon = param1.getChildByName("icon") as Image;
      btnDetail = param1.getChildByName("btnDetail") as ContainerButton;
      btnDetail.addEventListener("triggered",btnDetailCallback);
   }
   
   private function btnDetailCallback() : void
   {
      CupGacahLineupDialog.show(cgDef.rsrc,cgDef.prizes,recipeIDlist,cgDef.oddses,callback,GameSetting.getUIText("cupgacha.desc.prizelist"),cgDef.name#2);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      item = data.item as ItemParam;
      recipeIDlist = data.recipeIDlist;
      cgDef = GameSetting.getCupGacha(item.id#2);
      lblName.text#2 = GudetamaUtil.getItemName(item.kind,item.id#2);
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
      icon = null;
   }
}

import gudetama.ui.UIBase;
import starling.display.Image;
import starling.display.Sprite;

class CupRarityItemUI extends UIBase
{
    
   
   private var stars:Array;
   
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
