package gudetama.ui
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.MetalShopDef;
   import gudetama.data.compati.MetalShopItemDef;
   import gudetama.data.compati.MonthlyPremiumBonusDef;
   import gudetama.data.compati.PurchasePresentDef;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class MetalShopDialog_Gudetama extends ChargeDialogBase
   {
       
      
      private var def:MetalShopDef;
      
      private var topExtractor:SpriteExtractor;
      
      private var extractor:SpriteExtractor;
      
      private var campaignExtractor:SpriteExtractor;
      
      private var offerwallExtractor:SpriteExtractor;
      
      private var monthlyExtractor:SpriteExtractor;
      
      private var rankCampaignExtractor:SpriteExtractor;
      
      private var list:List;
      
      private var backButton:ContainerButton;
      
      private var currentImagicaText:ColorTextField;
      
      private var collection:ListCollection;
      
      private var loadCount:int;
      
      private var monthlyPremiumBonus:MonthlyPremiumBonusDef;
      
      public function MetalShopDialog_Gudetama(param1:int, param2:Function)
      {
         collection = new ListCollection();
         super(2);
         this.def = GameSetting.getMetalShop(param1);
         this.callback = param2;
         chargeType = 2;
      }
      
      public static function show(param1:int, param2:Function = null) : void
      {
         if(Engine.containsSceneStack(MetalShopDialog_Gudetama))
         {
            return;
         }
         Engine.pushScene(new MetalShopDialog_Gudetama(param1,param2),0,true);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"MetalShopDialog_Gudetama",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            backButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            backButton.addEventListener("triggered",onCloseTriggered);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_TopPresentLogItem",function(param1:Object):void
         {
            topExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_MetalShopItem_Gudetama",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_MetalShopCampaignItem",function(param1:Object):void
         {
            campaignExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_MetalOfferwallItem",function(param1:Object):void
         {
            offerwallExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_MetalMonthlyItem",function(param1:Object):void
         {
            monthlyExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_MetalShopRankCampaignItem",function(param1:Object):void
         {
            rankCampaignExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         queue.addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GENERAL_PING),function(param1:Object):void
            {
               queue.taskDone();
            });
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
         layout.paddingLeft = 11;
         list.layout = layout;
         list.setItemRendererFactoryWithID("top",function():IListItemRenderer
         {
            return new TopUIListItemRenderer(topExtractor);
         });
         list.setItemRendererFactoryWithID("item",function():IListItemRenderer
         {
            return new ShopListItemRenderer(extractor,onItemTriggered);
         });
         list.setItemRendererFactoryWithID("offerwall",function():IListItemRenderer
         {
            return new OfferwallUIRenderer(offerwallExtractor);
         });
         list.setItemRendererFactoryWithID("monthly",function():IListItemRenderer
         {
            return new MonthlyUIRenderer(monthlyExtractor,onMonthlyTriggered);
         });
         list.setItemRendererFactoryWithID("campaign",function():IListItemRenderer
         {
            return new CampaignListItemRenderer(campaignExtractor,onItemTriggered);
         });
         list.setItemRendererFactoryWithID("rankcampaign",function():IListItemRenderer
         {
            return new RankCampaignListItemRenderer(rankCampaignExtractor,onItemTriggered);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            return param1.key;
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
         queue.addTask(function():void
         {
            loadPrice(def,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      override protected function makeList() : void
      {
         var _loc8_:* = null;
         var _loc2_:* = null;
         var _loc3_:int = 0;
         var _loc5_:* = null;
         var _loc1_:* = null;
         var _loc4_:* = null;
         collection.removeAll();
         collection.addItem({"key":"top"});
         if(UserDataWrapper.wrapper.isEnabledOfferwall() && OfferwallAdvertisingManager.canShowOfferwall())
         {
            collection.addItem({"key":"offerwall"});
         }
         if(UserDataWrapper.wrapper.isPurchasableMonthlyPremiumBonus())
         {
            _loc8_ = GameSetting.getMonthlyPremiumBonusTable();
            for(var _loc7_ in _loc8_)
            {
               _loc2_ = _loc8_[_loc7_] as MonthlyPremiumBonusDef;
               collection.addItem(makeDataMonthly(_loc2_,!!priceMap ? priceMap[_loc2_.item.product_id] : null));
            }
         }
         _loc3_ = 0;
         while(_loc3_ < def.items.length)
         {
            _loc5_ = checkOverlap(def.items[_loc3_]);
            if(UserDataWrapper.wrapper.isPurchasable(_loc5_))
            {
               if(GameSetting.checkLimit(_loc5_))
               {
                  if(!(!priceMap || !priceMap[_loc5_.product_id]))
                  {
                     collection.addItem(makeData(_loc5_,!!priceMap ? priceMap[_loc5_.product_id] : null));
                  }
               }
            }
            _loc3_++;
         }
         if(!UserDataWrapper.wrapper.isPurchasableMonthlyPremiumBonus())
         {
            _loc1_ = GameSetting.getMonthlyPremiumBonusTable();
            for(var _loc6_ in _loc1_)
            {
               _loc4_ = _loc1_[_loc6_] as MonthlyPremiumBonusDef;
               collection.addItem(makeDataMonthly(_loc4_,!!priceMap ? priceMap[_loc4_.item.product_id] : null));
            }
         }
         ResidentMenuUI_Gudetama.updateSale();
      }
      
      private function checkOverlap(param1:MetalShopItemDef) : MetalShopItemDef
      {
         if(!param1.overlap)
         {
            return param1;
         }
         if(!UserDataWrapper.wrapper.isPurchasable(param1.overlap))
         {
            return param1;
         }
         if(!GameSetting.checkLimit(param1.overlap))
         {
            return param1;
         }
         if(!priceMap || !priceMap[param1.overlap.product_id])
         {
            return param1;
         }
         return checkOverlap(param1.overlap);
      }
      
      private function makeData(param1:MetalShopItemDef, param2:String) : Object
      {
         var _loc3_:Object = {};
         var _loc4_:Array = getPrice(param1,param2);
         var _loc5_:String = "item";
         if(param1.campaign > 0)
         {
            _loc5_ = "campaign";
         }
         if(param1.info != -1)
         {
            _loc5_ = "rankcampaign";
         }
         _loc3_["key"] = _loc5_;
         _loc3_["metalShopItemDef"] = param1;
         _loc3_["price"] = _loc4_[0];
         _loc3_["mark"] = _loc4_[1];
         return _loc3_;
      }
      
      private function makeDataMonthly(param1:MonthlyPremiumBonusDef, param2:String) : Object
      {
         var _loc3_:Object = {};
         var _loc4_:Array = getPrice(param1.item,param2);
         _loc3_["key"] = "monthly";
         _loc3_["monthlyPremiumBonus"] = param1;
         _loc3_["price"] = _loc4_[0];
         _loc3_["mark"] = _loc4_[1];
         return _loc3_;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(MetalShopDialog_Gudetama);
         setBackButtonCallback(backButtonCallback);
         if(UserDataWrapper.wrapper.isCompletedTutorial())
         {
            setVisibleState(94);
         }
         else
         {
            setVisibleState(70);
         }
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(MetalShopDialog_Gudetama);
         });
      }
      
      private function onItemTriggered(param1:MetalShopItemDef) : void
      {
         purchase(param1);
      }
      
      private function onMonthlyTriggered(param1:MonthlyPremiumBonusDef) : void
      {
         this.monthlyPremiumBonus = param1;
         purchase(param1.item);
      }
      
      override protected function updateMonthlyPremiumBonusTime() : void
      {
         if(monthlyPremiumBonus == null)
         {
            return;
         }
         UserDataWrapper.wrapper.setFinishMonthlyBonusTimeSec(TimeZoneUtil.epochMillisToOffsetSecs() + monthlyPremiumBonus.validDays * 86400 - 10);
      }
      
      override protected function procPurchaseSuccess(param1:MetalShopItemDef) : void
      {
         var _loc2_:PurchasePresentDef = GameSetting.getPurchasePresent(param1.price);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:* = UserDataWrapper;
         gudetama.data.UserDataWrapper.wrapper._data.purchasePresentMap[_loc2_.id#2] = [param1.price];
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(MetalShopDialog_Gudetama);
         setBackButtonCallback(null);
         if(callback)
         {
            callback(-1);
         }
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MetalShopDialog_Gudetama);
            Engine.popScene(scene);
         });
      }
      
      private function onCloseTriggered(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         topExtractor = null;
         extractor = null;
         offerwallExtractor = null;
         list = null;
         collection = null;
         backButton.removeEventListener("triggered",onCloseTriggered);
         backButton = null;
         def = null;
         callback = null;
         for(var _loc1_ in priceMap)
         {
            delete priceMap[_loc1_];
         }
         priceMap = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class ShopListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var shopItemUI:ShopItemUI;
   
   function ShopListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      shopItemUI = new ShopItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      shopItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      shopItemUI.dispose();
      shopItemUI = null;
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.ItemParam;
import gudetama.data.compati.MetalShopItemDef;
import gudetama.data.compati.PurchasePresentDef;
import gudetama.data.compati.PurchasePresentItemDef;
import gudetama.engine.TextureCollector;
import gudetama.ui.LocalMessageDialog;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class ShopItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var iconImage:Image;
   
   private var numText:ColorTextField;
   
   private var priceText:ColorTextField;
   
   private var buyButton:ContainerButton;
   
   private var firstGroup:Sprite;
   
   private var bonusSprite:Sprite;
   
   protected var bonusText:ColorTextField;
   
   protected var metalShopItemDef:MetalShopItemDef;
   
   function ShopItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      iconImage = param1.getChildByName("icon") as Image;
      numText = param1.getChildByName("num") as ColorTextField;
      priceText = param1.getChildByName("price") as ColorTextField;
      buyButton = param1.getChildByName("buyButton") as ContainerButton;
      buyButton.addEventListener("triggered",onTriggered);
      firstGroup = param1.getChildByName("firstGroup") as Sprite;
      if(firstGroup)
      {
         firstGroup.visible = false;
      }
      bonusSprite = param1.getChildByName("bonusSprite") as Sprite;
      bonusSprite.visible = false;
      bonusText = bonusSprite.getChildByName("bonus") as ColorTextField;
   }
   
   public function updateData(param1:Object, param2:String = "") : void
   {
      var data:Object = param1;
      var _addkey:String = param2;
      if(!data)
      {
         return;
      }
      metalShopItemDef = data.metalShopItemDef as MetalShopItemDef;
      var num:int = metalShopItemDef.value + metalShopItemDef.bonus + metalShopItemDef.campaign;
      var purchasePresentDef:PurchasePresentDef = UserDataWrapper.wrapper.getPurchasePresent(metalShopItemDef.price);
      if(purchasePresentDef)
      {
         if(firstGroup)
         {
            firstGroup.visible = true;
         }
         bonusSprite.visible = true;
         var purchasePresentItemDef:PurchasePresentItemDef = purchasePresentDef.getItem(metalShopItemDef.price);
         bonusText.text#2 = purchasePresentItemDef.message;
         var item:ItemParam = purchasePresentItemDef.items[0];
         if(item.kind == 1 || item.kind == 2)
         {
            var num:int = num + item.num;
            numText.color = 14035737;
         }
         else
         {
            bonusSprite.visible = false;
            numText.color = 5000268;
         }
      }
      else
      {
         if(firstGroup)
         {
            firstGroup.visible = false;
         }
         bonusSprite.visible = metalShopItemDef.bonus > 0 || metalShopItemDef.campaign > 0;
         if(metalShopItemDef.bonus > 0 && metalShopItemDef.campaign > 0)
         {
            bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.campaign" + _addkey),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.bonus),StringUtil.getNumStringCommas(metalShopItemDef.campaign));
         }
         else if(metalShopItemDef.bonus > 0 && metalShopItemDef.campaign <= 0)
         {
            bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.bonus" + _addkey),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.bonus));
         }
         else if(metalShopItemDef.bonus <= 0 && metalShopItemDef.campaign > 0)
         {
            bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.bonus" + _addkey),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.campaign));
         }
         numText.color = 5000268;
      }
      TextureCollector.loadTexture("shop0@egg0" + metalShopItemDef.rsrc,function(param1:Texture):void
      {
         if(iconImage != null)
         {
            iconImage.texture = param1;
         }
      });
      numText.text#2 = StringUtil.format(GameSetting.getUIText("mult.mark"),StringUtil.getNumStringCommas(num));
      if(data.mark)
      {
         priceText.text#2 = StringUtil.format(data.mark,StringUtil.getNumStringCommas(data.price));
      }
      else
      {
         var isOneStore:Boolean = false;
         priceText.text#2 = StringUtil.format(GameSetting.getUIText(!!isOneStore ? "realmoney.mark.kr" : "realmoney.mark"),StringUtil.getNumStringCommas(data.price));
      }
   }
   
   private function onTriggered(param1:Event) : void
   {
      var event:Event = param1;
      if(firstGroup && firstGroup.visible)
      {
         LocalMessageDialog.show(1,GameSetting.getUIText("purchase.present.confirm"),function(param1:int):void
         {
            if(param1 == 0)
            {
               callback(metalShopItemDef);
               return;
            }
         },GameSetting.getUIText("common.caution"));
      }
      else
      {
         callback(metalShopItemDef);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      iconImage = null;
      numText = null;
      priceText = null;
      buyButton.removeEventListener("triggered",onTriggered);
      buyButton = null;
      firstGroup = null;
      bonusSprite = null;
      bonusText = null;
      metalShopItemDef = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class CampaignListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var campaignItemUI:CampaignItemUI;
   
   function CampaignListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      campaignItemUI = new CampaignItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      campaignItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      campaignItemUI.dispose();
      campaignItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.ItemParam;
import gudetama.data.compati.PurchasePresentDef;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Sprite;

class CampaignItemUI extends ShopItemUI
{
    
   
   private var campaignText:ColorTextField;
   
   private var itemSprite:Sprite;
   
   private var itemText:ColorTextField;
   
   function CampaignItemUI(param1:Sprite, param2:Function)
   {
      super(param1,param2);
      campaignText = param1.getChildByName("campaign") as ColorTextField;
      itemSprite = param1.getChildByName("itemSprite") as Sprite;
      itemText = itemSprite.getChildByName("item") as ColorTextField;
   }
   
   override public function updateData(param1:Object, param2:String = "") : void
   {
      var _loc5_:* = null;
      if(!param1)
      {
         return;
      }
      super.updateData(param1);
      campaignText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.label.campaign"),metalShopItemDef.limit,metalShopItemDef.campaign);
      var _loc4_:PurchasePresentDef;
      if(!(_loc4_ = UserDataWrapper.wrapper.getPurchasePresent(metalShopItemDef.price)))
      {
         if(metalShopItemDef.bonus > 0 && metalShopItemDef.campaign > 0)
         {
            bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.campaign"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.bonus),StringUtil.getNumStringCommas(metalShopItemDef.campaign));
         }
         else if(metalShopItemDef.bonus > 0 && metalShopItemDef.campaign <= 0)
         {
            bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.campaign.2"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.bonus));
         }
         else if(metalShopItemDef.bonus <= 0 && metalShopItemDef.campaign > 0)
         {
            bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.campaign.2"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.campaign));
         }
      }
      if(metalShopItemDef.items)
      {
         itemSprite.visible = true;
         _loc5_ = "";
         for each(var _loc3_ in metalShopItemDef.items)
         {
            if(_loc5_.length > 0)
            {
               _loc5_ += " ";
            }
            _loc5_ += GudetamaUtil.getItemParamNameAndMultNum(_loc3_);
         }
         itemText.text#2 = StringUtil.format(GameSetting.getUIText("add.mark"),_loc5_);
      }
      else
      {
         itemSprite.visible = false;
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class RankCampaignListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var rankCampaignItemUI:RankCampaignItemUI;
   
   function RankCampaignListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      rankCampaignItemUI = new RankCampaignItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      rankCampaignItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      rankCampaignItemUI.dispose();
      rankCampaignItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.ItemParam;
import gudetama.data.compati.PurchasePresentDef;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Sprite;

class RankCampaignItemUI extends ShopItemUI
{
    
   
   private var campaignText:ColorTextField;
   
   private var campaignSubText:ColorTextField;
   
   private var itemSprite:Sprite;
   
   private var itemText:ColorTextField;
   
   private var defBonusHeight:Number;
   
   private var bonusWidth:Number;
   
   private var bonusFontSize:Number;
   
   function RankCampaignItemUI(param1:Sprite, param2:Function)
   {
      super(param1,param2);
      campaignText = param1.getChildByName("campaign") as ColorTextField;
      campaignSubText = param1.getChildByName("campaign_sub") as ColorTextField;
      itemSprite = param1.getChildByName("itemSprite") as Sprite;
      itemText = itemSprite.getChildByName("item") as ColorTextField;
      bonusWidth = bonusText.width;
      bonusFontSize = bonusText.fontSize;
      defBonusHeight = bonusText.textBounds.height;
   }
   
   override public function updateData(param1:Object, param2:String = "") : void
   {
      var _loc9_:* = null;
      if(!param1)
      {
         return;
      }
      super.updateData(param1,".sp");
      var _loc8_:String = GameSetting.getUITextWithOutKey("shop.metal.label.campaign.ranklimit." + metalShopItemDef.info);
      campaignText.text#2 = StringUtil.format(!!_loc8_ ? _loc8_ : GameSetting.getUIText("shop.metal.label.campaign.ranklimit"),metalShopItemDef.limit,metalShopItemDef.campaign,metalShopItemDef.bonus,metalShopItemDef.ranklimit);
      var _loc5_:String = GameSetting.getUITextWithOutKey("shop.metal.label.campaign.ranklimit.sub." + metalShopItemDef.info);
      campaignSubText.text#2 = StringUtil.format(campaignSubText.text#2 = !!_loc5_ ? _loc5_ : GameSetting.getUITextWithOutKey("shop.metal.label.campaign.ranklimit.sub"),metalShopItemDef.limit,metalShopItemDef.campaign,metalShopItemDef.bonus,metalShopItemDef.ranklimit);
      var _loc4_:PurchasePresentDef;
      if(!(_loc4_ = UserDataWrapper.wrapper.getPurchasePresent(metalShopItemDef.price)))
      {
         if(metalShopItemDef.bonus > 0 && metalShopItemDef.campaign > 0)
         {
            bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.campaign.sp"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.bonus),StringUtil.getNumStringCommas(metalShopItemDef.campaign));
         }
         else if(metalShopItemDef.bonus > 0 && metalShopItemDef.campaign <= 0)
         {
            bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.campaign.2.sp"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.bonus));
         }
         else if(metalShopItemDef.bonus <= 0 && metalShopItemDef.campaign > 0)
         {
            bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.metal.campaign.2.sp"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.campaign));
         }
      }
      var _loc6_:String;
      if(_loc6_ = GameSetting.getUITextWithOutKey("shop.metal.lnfo.campaign.ranklimit." + metalShopItemDef.info))
      {
         itemSprite.visible = true;
         itemText.text#2 = _loc6_;
      }
      else if(metalShopItemDef.items)
      {
         itemSprite.visible = true;
         _loc9_ = "";
         for each(var _loc3_ in metalShopItemDef.items)
         {
            if(_loc9_.length > 0)
            {
               _loc9_ += " ";
            }
            _loc9_ += GudetamaUtil.getItemParamNameAndMultNum(_loc3_);
         }
         itemText.text#2 = StringUtil.format(GameSetting.getUIText("add.mark"),_loc9_);
      }
      else
      {
         itemSprite.visible = false;
      }
      var _loc7_:Number;
      if((_loc7_ = bonusText.textBounds.width) > bonusWidth - bonusFontSize)
      {
         bonusText.fontSize = Math.floor(bonusFontSize * (bonusWidth - bonusFontSize) / _loc7_);
      }
      else
      {
         bonusText.fontSize = bonusFontSize;
      }
      bonusText.y += defBonusHeight - bonusText.textBounds.height;
      defBonusHeight = bonusText.textBounds.height;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class OfferwallUIRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var offerwallUI:OfferwallUI;
   
   function OfferwallUIRenderer(param1:SpriteExtractor)
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
      offerwallUI = new OfferwallUI(displaySprite);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      offerwallUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      offerwallUI.dispose();
      offerwallUI = null;
      super.dispose();
   }
}

import gudetama.common.OfferwallAdvertisingManager;
import gudetama.ui.UIBase;
import muku.display.SimpleImageButton;
import starling.display.Sprite;
import starling.events.Event;

class OfferwallUI extends UIBase
{
    
   
   private var offerwallButton:SimpleImageButton;
   
   function OfferwallUI(param1:Sprite)
   {
      super(param1);
      offerwallButton = param1.getChildByName("offerwallButton") as SimpleImageButton;
      offerwallButton.addEventListener("triggered",triggeredButton);
   }
   
   private function triggeredButton(param1:Event) : void
   {
      OfferwallAdvertisingManager.showOfferwallAds();
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
   }
   
   public function dispose() : void
   {
      offerwallButton.removeEventListener("triggered",triggeredButton);
      offerwallButton = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.ui.MonthlyItemUI;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class MonthlyUIRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var monthlyUI:MonthlyItemUI;
   
   private var callback:Function;
   
   function MonthlyUIRenderer(param1:SpriteExtractor, param2:Function)
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
      monthlyUI = new MonthlyItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      monthlyUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      monthlyUI.dispose();
      monthlyUI = null;
      super.dispose();
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class TopUIListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var topUI:TopUI;
   
   function TopUIListItemRenderer(param1:SpriteExtractor)
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
      topUI = new TopUI(displaySprite);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      topUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      topUI.dispose();
      topUI = null;
      super.dispose();
   }
}

import gudetama.ui.UIBase;
import starling.display.Sprite;

class TopUI extends UIBase
{
    
   
   function TopUI(param1:Sprite)
   {
      super(param1);
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
   }
   
   public function dispose() : void
   {
   }
}
