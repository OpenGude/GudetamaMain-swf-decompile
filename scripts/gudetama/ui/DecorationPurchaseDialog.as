package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class DecorationPurchaseDialog extends BaseScene
   {
       
      
      private var item:ItemParam;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var iconImage:Image;
      
      private var nameText:ColorTextField;
      
      private var priceText:ColorTextField;
      
      private var buyButton:ContainerButton;
      
      private var lessImage:Image;
      
      private var sumiImage:Image;
      
      private var purchaseButton:SimpleImageButton;
      
      private var offerwallButton:SimpleImageButton;
      
      private var purchaseMoneyButton:SimpleImageButton;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var numPurchase:int;
      
      private var loadCount:int;
      
      public function DecorationPurchaseDialog(param1:ItemParam, param2:Function)
      {
         super(2);
         this.item = param1;
         this.callback = param2;
         numPurchase = 1;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:ItemParam, param2:Function) : void
      {
         Engine.pushScene(new DecorationPurchaseDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"DecorationPurchaseDialog_1",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc4_:Sprite;
            titleText = (_loc4_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("title") as ColorTextField;
            iconImage = _loc4_.getChildByName("icon") as Image;
            var _loc2_:Sprite = _loc4_.getChildByName("itemNameGroup") as Sprite;
            nameText = _loc2_.getChildByName("name") as ColorTextField;
            var _loc3_:Sprite = _loc4_.getChildByName("priceGroup") as Sprite;
            priceText = _loc3_.getChildByName("price") as ColorTextField;
            var _loc7_:Sprite;
            buyButton = (_loc7_ = _loc4_.getChildByName("buyButtonGroup") as Sprite).getChildByName("buyButton") as ContainerButton;
            buyButton.addEventListener("triggered",triggeredBuyButton);
            lessImage = _loc7_.getChildByName("less") as Image;
            sumiImage = _loc7_.getChildByName("sumi") as Image;
            var _loc5_:Sprite;
            var _loc8_:Sprite;
            purchaseButton = (_loc5_ = (_loc8_ = _loc4_.getChildByName("chargeGroup") as Sprite).getChildByName("metalGroup") as Sprite).getChildByName("purchaseButton") as SimpleImageButton;
            purchaseButton.addEventListener("triggered",triggeredPurchaseButton);
            offerwallButton = _loc5_.getChildByName("offerwallButton") as SimpleImageButton;
            offerwallButton.addEventListener("triggered",triggeredOfferwallButton);
            var _loc9_:Sprite;
            purchaseMoneyButton = (_loc9_ = _loc8_.getChildByName("moneyGroup") as Sprite).getChildByName("purchaseMoneyButton") as SimpleImageButton;
            purchaseMoneyButton.addEventListener("triggered",triggeredPurchaseMoneyButton);
            var _loc6_:Sprite;
            descText = (_loc6_ = _loc4_.getChildByName("descGroup") as Sprite).getChildByName("desc") as ColorTextField;
            closeButton = _loc6_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
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
         setup();
      }
      
      private function setup() : void
      {
         var def:Object = GudetamaUtil.getItemDef(item);
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemImageName(item.kind,item.id#2),function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         priceText.text#2 = StringUtil.getNumStringCommas(def.price.num);
         if(def.price.kind == 1 || def.price.kind == 2)
         {
            TweenAnimator.startItself(displaySprite,"metal");
         }
         else if(def.price.kind == 0 || def.price.kind == 14)
         {
            TweenAnimator.startItself(displaySprite,"money");
         }
         TweenAnimator.finishItself(displaySprite);
         update();
      }
      
      private function update() : void
      {
         if(UserDataWrapper.wrapper.isAvailable(item))
         {
            updatePurchase();
         }
         else
         {
            updateLock();
         }
      }
      
      private function updatePurchase() : void
      {
         var def:Object = GudetamaUtil.getItemDef(item);
         var wrapper:UserDataWrapper = UserDataWrapper.wrapper;
         var isAddable:Boolean = wrapper.isItemAddable(item);
         var hasPrice:Boolean = wrapper.hasItem(def.price);
         var hasItem:Boolean = wrapper.hasItem(item);
         titleText.text#2 = def.name;
         buyButton.setEnableWithDrawCache(isAddable && hasPrice);
         lessImage.visible = !hasPrice;
         sumiImage.visible = !isAddable;
         offerwallButton.visible = UserDataWrapper.wrapper.isEnabledOfferwall();
         descText.text#2 = def.desc;
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,!isAddable || hasPrice ? "pos0" : "pos1",false,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      private function updateLock() : void
      {
         var def:Object = GudetamaUtil.getItemDef(item);
         titleText.text#2 = GameSetting.getUIText("common.unlock.cond");
         nameText.text#2 = def.name;
         descText.text#2 = def.conditionDesc;
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,"lock",false,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(DecorationPurchaseDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(DecorationPurchaseDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(PurchaseShopDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(PurchaseShopDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredBuyButton(param1:Event) : void
      {
         var event:Event = param1;
         Engine.showLoading(PurchaseShopDialog);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(50331664,[item.id#2,item.kind,numPurchase]),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(PurchaseShopDialog);
            if(!(response[0] is ItemParam))
            {
               var realNum:int = response[0];
               UserDataWrapper.wrapper.setItemNumAtParam(item.id#2,item.kind,realNum);
            }
            else
            {
               UserDataWrapper.wrapper.addItem(item,response[1]);
               UserDataWrapper.wrapper.useItem(response[0] as ItemParam);
               ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
               SoundManager.playEffect("buy_item");
            }
            back(function():void
            {
               AcquiredKitchenwareDialog.show(function():void
               {
                  AcquiredRecipeNoteDialog.show(function():void
                  {
                     callback();
                  });
               });
            });
         });
      }
      
      private function triggeredPurchaseButton(param1:Event) : void
      {
         ResidentMenuUI_Gudetama.getInstance().showMetalShop();
      }
      
      private function triggeredOfferwallButton(param1:Event) : void
      {
         OfferwallAdvertisingManager.showOfferwallAds();
      }
      
      private function triggeredPurchaseMoneyButton(param1:Event) : void
      {
         ResidentMenuUI_Gudetama.getInstance().showMoneyShop();
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      public function updateScene() : void
      {
         update();
      }
      
      override public function dispose() : void
      {
         removeEventListener("update_scene",updateScene);
         item = null;
         titleText = null;
         nameText = null;
         priceText = null;
         if(buyButton)
         {
            buyButton.removeEventListener("triggered",triggeredBuyButton);
            buyButton = null;
         }
         lessImage = null;
         sumiImage = null;
         if(purchaseButton)
         {
            purchaseButton.removeEventListener("triggered",triggeredPurchaseButton);
            purchaseButton = null;
         }
         if(offerwallButton)
         {
            offerwallButton.removeEventListener("triggered",triggeredOfferwallButton);
            offerwallButton = null;
         }
         if(purchaseMoneyButton)
         {
            purchaseMoneyButton.removeEventListener("triggered",triggeredPurchaseMoneyButton);
            purchaseMoneyButton = null;
         }
         descText = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
