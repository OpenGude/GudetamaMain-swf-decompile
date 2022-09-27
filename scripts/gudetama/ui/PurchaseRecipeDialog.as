package gudetama.ui
{
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.RecipeNoteData;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class PurchaseRecipeDialog extends BaseScene
   {
       
      
      private var id:int;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var priceText:ColorTextField;
      
      private var tradeButton:ContainerButton;
      
      private var lessImage:Image;
      
      private var purchaseButton:ContainerButton;
      
      private var offerwallButton:ContainerButton;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var forceCallback:Boolean = false;
      
      public function PurchaseRecipeDialog(param1:int, param2:Function, param3:Boolean = false)
      {
         super(2);
         this.id = param1;
         this.callback = param2;
         this.forceCallback = param3;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:int, param2:Function, param3:Boolean = false) : void
      {
         Engine.pushScene(new PurchaseRecipeDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"PurchaseRecipeDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            priceText = _loc2_.getChildByName("price") as ColorTextField;
            tradeButton = _loc2_.getChildByName("tradeButton") as ContainerButton;
            tradeButton.addEventListener("triggered",triggeredTradeButton);
            lessImage = _loc2_.getChildByName("less") as Image;
            purchaseButton = _loc2_.getChildByName("purchaseButton") as ContainerButton;
            purchaseButton.addEventListener("triggered",triggeredPurchaseButton);
            offerwallButton = _loc2_.getChildByName("offerwallButton") as ContainerButton;
            offerwallButton.addEventListener("triggered",triggeredOfferwallButton);
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
            setup();
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
      
      private function setup() : void
      {
         var _loc1_:RecipeNoteDef = GameSetting.getRecipeNote(id);
         titleText.text#2 = StringUtil.replaceAll(_loc1_.name#2,"\n","");
         priceText.text#2 = _loc1_.price.toString();
         descText.text#2 = _loc1_.desc;
         offerwallButton.visible = UserDataWrapper.wrapper.isEnabledOfferwall();
         update();
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(PurchaseRecipeDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(PurchaseRecipeDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         back(!!forceCallback ? true : false);
      }
      
      private function back(param1:Boolean = false, param2:Boolean = false) : void
      {
         var callFunc:Boolean = param1;
         var _isClose:Boolean = param2;
         super.backButtonCallback();
         Engine.lockTouchInput(PurchaseRecipeDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(PurchaseRecipeDialog);
            Engine.popScene(scene);
            if(callFunc && callback)
            {
               callback(_isClose);
            }
         });
      }
      
      private function triggeredTradeButton(param1:Event) : void
      {
         var event:Event = param1;
         Engine.showLoading(PurchaseRecipeDialog);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217926,id),function(param1:Array):void
         {
            Engine.hideLoading(PurchaseRecipeDialog);
            var _loc2_:RecipeNoteData = param1[0];
            var _loc5_:Array = param1[1];
            var _loc3_:Array = param1[2];
            var _loc4_:Array = param1[3];
            var _loc6_:RecipeNoteDef = GameSetting.getRecipeNote(id);
            UserDataWrapper.recipeNotePart.addRecipeNote(_loc2_);
            UserDataWrapper.kitchenwarePart.addKitchenwares(_loc5_);
            UserDataWrapper.recipeNotePart.addRecipeNotes(_loc3_);
            UserDataWrapper.wrapper.addRecipes(_loc4_);
            ResidentMenuUI_Gudetama.consumeMetal(_loc6_.price);
            back(true);
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
         back(!!forceCallback ? true : false,true);
      }
      
      public function updateScene() : void
      {
         update();
      }
      
      private function update() : void
      {
         var _loc1_:RecipeNoteDef = GameSetting.getRecipeNote(id);
         if(UserDataWrapper.wrapper.getMetal() >= _loc1_.price)
         {
            lessImage.visible = false;
            tradeButton.setEnableWithDrawCache(true);
         }
         else
         {
            lessImage.visible = true;
            tradeButton.setEnableWithDrawCache(false);
         }
      }
      
      override public function dispose() : void
      {
         removeEventListener("update_scene",updateScene);
         titleText = null;
         priceText = null;
         lessImage = null;
         tradeButton.removeEventListener("triggered",triggeredTradeButton);
         tradeButton = null;
         purchaseButton.removeEventListener("triggered",triggeredPurchaseButton);
         purchaseButton = null;
         offerwallButton.removeEventListener("triggered",triggeredOfferwallButton);
         offerwallButton = null;
         descText = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
