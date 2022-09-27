package gudetama.ui
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.NativeExtensions;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.MetalShopDef;
   import gudetama.data.compati.MetalShopItemDef;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class MoneyShopDialog extends ChargeDialogBase
   {
       
      
      private var def:MetalShopDef;
      
      private var extractor:SpriteExtractor;
      
      private var offerwallExtractor:SpriteExtractor;
      
      private var list:List;
      
      private var backButton:ContainerButton;
      
      private var currentImagicaText:ColorTextField;
      
      private var collection:ListCollection;
      
      private var loadCount:int;
      
      public function MoneyShopDialog(param1:int, param2:Function)
      {
         collection = new ListCollection();
         super(2);
         this.def = GameSetting.getMetalShop(param1);
         this.callback = param2;
         chargeType = 1;
      }
      
      public static function show(param1:int, param2:Function = null) : void
      {
         if(Engine.containsSceneStack(MoneyShopDialog))
         {
            return;
         }
         Engine.pushScene(new MoneyShopDialog(param1,param2),0,true);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"MoneyShopDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            backButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            backButton.addEventListener("triggered",onCloseTriggered);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_MoneyShopItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
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
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new ShopListItemRenderer(extractor,onItemTriggered);
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
            priceMap = {};
            var productIdList:Array = [];
            for each(item in def.items)
            {
               productIdList.push(item.product_id);
               if(debug)
               {
                  priceMap[item.product_id] = item.price;
               }
            }
            var isOneStore:Boolean = false;
            if(isOneStore)
            {
               var allItems:Vector.<String> = Vector.<String>(productIdList);
               NativeExtensions.requestOneStorePurchaseList(allItems.join(","),function(param1:Boolean, param2:String):void
               {
                  var _loc3_:* = null;
                  var _loc4_:int = 0;
                  var _loc6_:* = null;
                  if(param1)
                  {
                     _loc3_ = param2.split(",");
                     _loc4_ = _loc3_.length;
                     for each(var _loc5_ in _loc3_)
                     {
                        _loc6_ = _loc5_.split(":");
                        priceMap[_loc6_[0]] = _loc6_[1];
                     }
                     makeList();
                  }
                  else
                  {
                     MessageDialog.show(10,GameSetting.getUIText("pricelist.error.1"),null);
                  }
                  queue.taskDone();
               });
            }
            else if(debug)
            {
               makeList();
               queue.taskDone();
            }
            else
            {
               var _loc4_:* = Engine;
               if(gudetama.engine.Engine.platform == 0)
               {
                  var extEnabled:Boolean = NativeExtensions.requestPriceList(productIdList,function(param1:int, param2:String):void
                  {
                     var _loc3_:* = null;
                     var _loc5_:* = null;
                     if(param1 >= 0)
                     {
                        param2 = param2.substring(1);
                        _loc3_ = param2.split("/");
                        for each(var _loc4_ in _loc3_)
                        {
                           _loc5_ = _loc4_.split(":");
                           priceMap[_loc5_[0]] = _loc5_[1];
                        }
                        makeList();
                     }
                     else
                     {
                        MessageDialog.show(10,GameSetting.getUIText("pricelist.error." + Math.abs(param1)),null);
                     }
                     queue.taskDone();
                  });
                  if(!extEnabled)
                  {
                     queue.taskDone();
                  }
               }
               else
               {
                  var _loc5_:* = Engine;
                  if(gudetama.engine.Engine.platform == 1)
                  {
                     var buillingEnabled:Boolean = NativeExtensions.requestPriceList(productIdList,function(param1:int, param2:Array):void
                     {
                        var _loc3_:* = null;
                        var _loc4_:int = 0;
                        var _loc5_:* = null;
                        if(param1 >= 0)
                        {
                           _loc3_ = null;
                           _loc4_ = 0;
                           while(_loc4_ < param2.length)
                           {
                              _loc3_ = param2[_loc4_];
                              if(_loc3_ != null)
                              {
                                 _loc5_ = _loc3_.split(":");
                                 priceMap[_loc5_[0]] = _loc5_[1];
                              }
                              _loc4_++;
                           }
                           makeList();
                        }
                        else
                        {
                           MessageDialog.show(10,GameSetting.getUIText("pricelist.error." + Math.abs(param1)),null);
                        }
                        queue.taskDone();
                     });
                     if(!buillingEnabled)
                     {
                        queue.taskDone();
                     }
                  }
               }
            }
         });
      }
      
      private function makeList() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = null;
         collection.removeAll();
         _loc1_ = 0;
         while(_loc1_ < def.items.length)
         {
            _loc2_ = def.items[_loc1_];
            collection.addItem(makeData(_loc2_,!!priceMap ? priceMap[_loc2_.product_id] : null));
            _loc1_++;
         }
      }
      
      private function makeData(param1:MetalShopItemDef, param2:String) : Object
      {
         var _loc3_:Object = {};
         var _loc4_:Array = getPrice(param1,param2);
         _loc3_["key"] = "item";
         _loc3_["metalShopItemDef"] = param1;
         _loc3_["price"] = _loc4_[0];
         _loc3_["mark"] = _loc4_[1];
         return _loc3_;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(MoneyShopDialog);
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
            Engine.unlockTouchInput(MoneyShopDialog);
         });
      }
      
      public function onItemTriggered(param1:MetalShopItemDef) : void
      {
         purchase(param1);
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(MoneyShopDialog);
         setBackButtonCallback(null);
         if(callback)
         {
            callback(-1);
         }
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MoneyShopDialog);
            Engine.popScene(scene);
         });
      }
      
      private function onCloseTriggered(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
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
import gudetama.data.compati.MetalShopItemDef;
import gudetama.ui.LocalMessageDialog;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class ShopItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var numText:ColorTextField;
   
   private var priceText:ColorTextField;
   
   private var buyButton:ContainerButton;
   
   private var bonusGroup:Sprite;
   
   private var bonusText:ColorTextField;
   
   private var metalShopItemDef:MetalShopItemDef;
   
   function ShopItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      numText = param1.getChildByName("num") as ColorTextField;
      priceText = param1.getChildByName("price") as ColorTextField;
      buyButton = param1.getChildByName("buyButton") as ContainerButton;
      buyButton.addEventListener("triggered",onTriggered);
      bonusGroup = param1.getChildByName("bonusSprite") as Sprite;
      bonusText = bonusGroup.getChildByName("bonus") as ColorTextField;
   }
   
   public function updateData(param1:Object) : void
   {
      var _loc3_:Boolean = false;
      if(!param1)
      {
         return;
      }
      metalShopItemDef = param1.metalShopItemDef as MetalShopItemDef;
      var _loc2_:int = metalShopItemDef.value + metalShopItemDef.bonus + metalShopItemDef.campaign;
      numText.text#2 = StringUtil.getNumStringCommas(_loc2_);
      if(param1.mark)
      {
         priceText.text#2 = StringUtil.format(param1.mark,StringUtil.getNumStringCommas(param1.price));
      }
      else
      {
         _loc3_ = false;
         priceText.text#2 = StringUtil.format(GameSetting.getUIText(!!_loc3_ ? "realmoney.mark.kr" : "realmoney.mark"),StringUtil.getNumStringCommas(param1.price));
      }
      bonusGroup.visible = metalShopItemDef.bonus > 0 || metalShopItemDef.campaign > 0;
      bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.money.bonus"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.bonus));
      if(metalShopItemDef.bonus > 0 && metalShopItemDef.campaign > 0)
      {
         bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.money.campaign"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.bonus),StringUtil.getNumStringCommas(metalShopItemDef.campaign));
      }
      else if(metalShopItemDef.bonus > 0 && metalShopItemDef.campaign <= 0)
      {
         bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.money.bonus"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.bonus));
      }
      else if(metalShopItemDef.bonus <= 0 && metalShopItemDef.campaign > 0)
      {
         bonusText.text#2 = StringUtil.format(GameSetting.getUIText("shop.money.bonus"),StringUtil.getNumStringCommas(metalShopItemDef.value),StringUtil.getNumStringCommas(metalShopItemDef.campaign));
      }
   }
   
   private function onTriggered(param1:Event) : void
   {
      if(!UserDataWrapper.wrapper.isMoneyAddable(metalShopItemDef.value + metalShopItemDef.bonus + metalShopItemDef.campaign))
      {
         LocalMessageDialog.show(0,GameSetting.getUIText("moneyShop.over.desc"),null,GameSetting.getUIText("moneyShop.over.title"));
         return;
      }
      callback(metalShopItemDef);
   }
   
   public function dispose() : void
   {
      callback = null;
      numText = null;
      priceText = null;
      buyButton.removeEventListener("triggered",onTriggered);
      buyButton = null;
      bonusGroup = null;
      bonusText = null;
      metalShopItemDef = null;
   }
}
