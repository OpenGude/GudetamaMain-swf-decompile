package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.CupGachaDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.UsefulData;
   import gudetama.data.compati.UsefulDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.StringUtil;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class PurchaseShopDialog extends BaseScene
   {
       
      
      private var item:ItemParam;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var itemIcon:Image;
      
      private var lockIcon:Image;
      
      private var priceText:ColorTextField;
      
      private var priceIcon:Image;
      
      private var itemNameSprite:Sprite;
      
      private var itemNameText:ColorTextField;
      
      private var buyGroup:Sprite;
      
      private var buyButton:ContainerButton;
      
      private var lessImage:Image;
      
      private var sumiImage:Image;
      
      private var chargeGroup:Sprite;
      
      private var purchaseButton:SimpleImageButton;
      
      private var offerwallButton:SimpleImageButton;
      
      private var descText:ColorTextField;
      
      private var btnDetail:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      private var numPurchase:int;
      
      private var loadCount:int;
      
      public function PurchaseShopDialog(param1:ItemParam, param2:Function)
      {
         super(2);
         this.item = param1;
         this.callback = param2;
         numPurchase = 1;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:ItemParam, param2:Function) : void
      {
         Engine.pushScene(new PurchaseShopDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"PurchaseShopDialog",function(param1:Object):void
         {
            var _loc7_:Number = NaN;
            var _loc6_:* = NaN;
            displaySprite = param1.object;
            var _loc4_:Sprite;
            var _loc8_:Image = (_loc4_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("imgFrame") as Image;
            titleText = _loc4_.getChildByName("title") as ColorTextField;
            itemIcon = _loc4_.getChildByName("itemIcon") as Image;
            lockIcon = _loc4_.getChildByName("lock") as Image;
            itemNameSprite = _loc4_.getChildByName("spriteItemName") as Sprite;
            itemNameText = itemNameSprite.getChildByName("name") as ColorTextField;
            var _loc2_:Sprite = _loc4_.getChildByName("spritePrice") as Sprite;
            priceText = _loc2_.getChildByName("price") as ColorTextField;
            priceIcon = _loc2_.getChildByName("priceIcon") as Image;
            buyGroup = _loc4_.getChildByName("spriteBuy") as Sprite;
            buyButton = buyGroup.getChildByName("buyButton") as ContainerButton;
            buyButton.addEventListener("triggered",triggeredBuyButton);
            lessImage = buyGroup.getChildByName("less") as Image;
            sumiImage = buyGroup.getChildByName("sumi") as Image;
            chargeGroup = _loc4_.getChildByName("spriteCharge") as Sprite;
            purchaseButton = chargeGroup.getChildByName("purchaseButton") as SimpleImageButton;
            purchaseButton.addEventListener("triggered",triggeredPurchaseButton);
            offerwallButton = chargeGroup.getChildByName("offerwallButton") as SimpleImageButton;
            offerwallButton.addEventListener("triggered",triggeredOfferwallButton);
            var _loc5_:Sprite;
            descText = (_loc5_ = _loc4_.getChildByName("spriteBottom") as Sprite).getChildByName("desc") as ColorTextField;
            var _loc3_:Image = _loc5_.getChildByName("descMat") as Image;
            closeButton = _loc5_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            btnDetail = _loc5_.getChildByName("btnDetail") as ContainerButton;
            btnDetail.addEventListener("triggered",triggerdDetail);
            btnDetail.visible = item.kind == 19;
            if(item.kind == 19)
            {
               _loc6_ = _loc7_ = (_loc3_.width - closeButton.width - btnDetail.width) / 3;
               btnDetail.x = _loc6_;
               _loc6_ += btnDetail.width + _loc7_;
               closeButton.x = _loc6_;
               btnDetail.visible = true;
            }
            else
            {
               btnDetail.visible = false;
            }
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
         if(UserDataWrapper.wrapper.isAvailable(item))
         {
            setupPurchase();
         }
         else
         {
            setupLock();
         }
      }
      
      private function setupPurchase() : void
      {
         var def:Object = GudetamaUtil.getItemDef(item);
         var wrapper:UserDataWrapper = UserDataWrapper.wrapper;
         var isAvailable:Boolean = wrapper.isAvailable(item);
         var isAddable:Boolean = wrapper.isItemAddable(item);
         var isTutorial:Boolean = UserDataWrapper.wrapper.isCanStartNoticeFlag(2);
         var hasItem:Boolean = wrapper.hasItem(def.price);
         var isMetal:Boolean = def.price.kind == 1 || def.price.kind == 2;
         if(def is UsefulDef)
         {
            var usefulData:UsefulData = UserDataWrapper.usefulPart.getUseful(def.id);
            if(usefulData.nextAvailablePurchaseSec != -1)
            {
               var restSec:int = Math.max(0,usefulData.nextAvailablePurchaseSec - TimeZoneUtil.epochMillisToOffsetSecs());
               if(restSec > 0)
               {
                  isAddable = false;
               }
            }
         }
         titleText.text#2 = def.name;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemIconName(item.kind,item.id#2),function(param1:Texture):void
            {
               itemIcon.texture = param1;
               queue.taskDone();
            });
         });
         itemIcon.color = (!!isTutorial ? true : Boolean(hasItem && isAvailable)) ? 16777215 : 8421504;
         lockIcon.visible = false;
         itemNameSprite.visible = false;
         if(isMetal)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("home1@goldegg",function(param1:Texture):void
               {
                  priceIcon.texture = param1;
                  queue.taskDone();
               });
            });
            priceText.color = 11823887;
         }
         else if(def.price.kind == 0 || def.price.kind == 14)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("home1@gp",function(param1:Texture):void
               {
                  priceIcon.texture = param1;
                  queue.taskDone();
               });
            });
            priceText.color = 6711145;
         }
         var num:int = def.price.num > -1 ? def.price.num : 0;
         priceText.text#2 = StringUtil.getNumStringCommas(num);
         if(!checkPriceLimit(def.price))
         {
            isAddable = false;
            hasItem = false;
            isAvailable = false;
         }
         buyGroup.visible = true;
         buyButton.setEnableWithDrawCache(isAddable && hasItem && isAvailable || isTutorial);
         lessImage.visible = !!isTutorial ? false : Boolean(!hasItem || !isAvailable);
         sumiImage.visible = !isAddable;
         chargeGroup.visible = !hasItem && isMetal;
         offerwallButton.visible = UserDataWrapper.wrapper.isEnabledOfferwall();
         descText.text#2 = def.desc;
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,!!hasItem ? "pos0" : "pos1",false,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      private function checkPriceLimit(param1:ItemParam) : Boolean
      {
         if(param1.kind == 1 || param1.kind == 2 || param1.kind == 0 || param1.kind == 14)
         {
            return param1.num > -1;
         }
         return true;
      }
      
      private function setupLock() : void
      {
         var def:Object = GudetamaUtil.getItemDef(item);
         titleText.text#2 = GameSetting.getUIText("common.unlock.cond");
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemIconName(item.kind,item.id#2),function(param1:Texture):void
            {
               itemIcon.texture = param1;
               queue.taskDone();
            });
         });
         itemIcon.color = 4286611584;
         lockIcon.visible = true;
         itemNameSprite.visible = true;
         itemNameText.text#2 = def.name;
         if(def.price.kind == 1 || def.price.kind == 2)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("home1@goldegg",function(param1:Texture):void
               {
                  priceIcon.texture = param1;
                  queue.taskDone();
               });
            });
            priceText.color = 11823887;
         }
         else if(def.price.kind == 0 || def.price.kind == 14)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("home1@gp",function(param1:Texture):void
               {
                  priceIcon.texture = param1;
                  queue.taskDone();
               });
            });
            priceText.color = 6711145;
         }
         var num:int = def.price.num > -1 ? def.price.num : 0;
         priceText.text#2 = StringUtil.getNumStringCommas(num);
         buyGroup.visible = false;
         chargeGroup.visible = false;
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
         Engine.lockTouchInput(PurchaseShopDialog);
         setBackButtonCallback(backButtonCallback);
         if(UserDataWrapper.wrapper.isCanStartNoticeFlag(2))
         {
            closeButton.visible = false;
            setBackButtonCallback(null);
            setVisibleState(70);
         }
         else
         {
            setVisibleState(94);
         }
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            resumeNoticeTutorial(2,noticeTutorialAction,getGuideArrowPos);
            Engine.unlockTouchInput(PurchaseShopDialog);
         });
      }
      
      public function noticeTutorialAction(param1:int) : void
      {
         var index:int = param1;
         switch(int(index))
         {
            case 0:
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(50331859),function(param1:int):void
               {
                  ResidentMenuUI_Gudetama.addFreeMoney(param1,"start");
               });
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc2_:* = undefined;
         switch(int(param1) - 2)
         {
            case 0:
               return GudetamaUtil.getCenterPosAndWHOnEngine(buyButton);
            default:
               return _loc2_;
         }
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
            var udWrapper:UserDataWrapper = UserDataWrapper.wrapper;
            if(!(response[0] is ItemParam))
            {
               var realNum:int = response[0];
               udWrapper.setItemNumAtParam(item.id#2,item.kind,realNum);
            }
            else
            {
               udWrapper.addItem(item,response[1]);
               udWrapper.useItem(response[0] as ItemParam);
               ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
               SoundManager.playEffect("buy_item");
            }
            back(function():void
            {
               AcquiredKitchenwareDialog.show(function():void
               {
                  AcquiredRecipeNoteDialog.show(function():void
                  {
                     udWrapper.showCupGachaResults(udWrapper.getPlacedGudetamaId(),function():void
                     {
                        callback();
                     });
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
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      public function updateScene() : void
      {
         setup();
      }
      
      private function triggerdDetail() : void
      {
         var _loc1_:CupGachaDef = GameSetting.getCupGacha(item.id#2);
         ItemsShowDialog.show4cupGacha(_loc1_.prizes,_loc1_.oddses,null,GameSetting.getUIText("cupgacha.desc.prizelist"),GameSetting.getUIText("cupgacha.title.prizelist"));
      }
      
      override public function dispose() : void
      {
         removeEventListener("update_scene",updateScene);
         item = null;
         titleText = null;
         itemIcon = null;
         lockIcon = null;
         priceText = null;
         priceIcon = null;
         itemNameSprite = null;
         itemNameText = null;
         buyGroup = null;
         if(buyButton != null)
         {
            buyButton.removeEventListener("triggered",triggeredBuyButton);
            buyButton = null;
         }
         lessImage = null;
         sumiImage = null;
         chargeGroup = null;
         if(purchaseButton != null)
         {
            purchaseButton.removeEventListener("triggered",triggeredPurchaseButton);
            purchaseButton = null;
         }
         if(offerwallButton != null)
         {
            offerwallButton.removeEventListener("triggered",triggeredOfferwallButton);
            offerwallButton = null;
         }
         descText = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         btnDetail.removeEventListener("triggered",triggerdDetail);
         btnDetail = null;
         super.dispose();
      }
   }
}
