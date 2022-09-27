package gudetama.scene.kitchen
{
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CookingRetryDialog extends BaseScene
   {
       
      
      private var value:int;
      
      private var callback:Function;
      
      private var spineModel:SpineModel;
      
      private var costText:ColorTextField;
      
      private var messageText:ColorTextField;
      
      private var chargeButton:SimpleImageButton;
      
      private var offerwallButton:SimpleImageButton;
      
      private var okButton:ContainerButton;
      
      private var cancelButton:ContainerButton;
      
      private var shortageImage:Image;
      
      private var loadCount:int;
      
      public function CookingRetryDialog(param1:int, param2:Function)
      {
         super(2);
         this.value = param1;
         this.callback = param2;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:int, param2:Function) : void
      {
         Engine.pushScene(new CookingRetryDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"CookingRetryDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            spineModel = _loc2_.getChildByName("spineModel") as SpineModel;
            costText = _loc2_.getChildByName("cost") as ColorTextField;
            messageText = _loc2_.getChildByName("message") as ColorTextField;
            chargeButton = _loc2_.getChildByName("chargeButton") as SimpleImageButton;
            chargeButton.addEventListener("triggered",triggeredChargeButton);
            offerwallButton = _loc2_.getChildByName("offerwallButton") as SimpleImageButton;
            offerwallButton.addEventListener("triggered",triggeredOfferwallButton);
            okButton = _loc2_.getChildByName("btn_ok") as ContainerButton;
            okButton.addEventListener("triggered",triggeredOkButton);
            cancelButton = _loc2_.getChildByName("btn_cancel") as ContainerButton;
            cancelButton.addEventListener("triggered",triggeredCancelButton);
            shortageImage = _loc2_.getChildByName("shortage") as Image;
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
         costText.text#2 = StringUtil.getNumStringCommas(value);
         messageText.text#2 = StringUtil.format(GameSetting.getUIText("cookingRetry.desc"),value);
         updateScene();
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.isIosPlatform() || true)
         {
            TweenAnimator.startItself(okButton,"ios");
            TweenAnimator.startItself(cancelButton,"ios");
            TweenAnimator.startItself(shortageImage,"ios");
         }
         else
         {
            TweenAnimator.startItself(okButton,"android");
            TweenAnimator.startItself(cancelButton,"android");
            TweenAnimator.startItself(shortageImage,"android");
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CookingRetryDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(78);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CookingRetryDialog);
            spineModel.show();
            spineModel.changeAnimation("retry_chance_start",false,function():void
            {
               spineModel.changeAnimation("finish_loop");
            });
         });
      }
      
      private function triggeredChargeButton(param1:Event) : void
      {
         ResidentMenuUI_Gudetama.getInstance().showMetalShop();
      }
      
      private function triggeredOfferwallButton(param1:Event) : void
      {
         OfferwallAdvertisingManager.showOfferwallAds();
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:Boolean = false) : void
      {
         var positive:Boolean = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(CookingRetryDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CookingRetryDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback(positive);
            }
         });
      }
      
      protected function triggeredCancelButton(param1:Event) : void
      {
         back(false);
      }
      
      protected function triggeredOkButton(param1:Event) : void
      {
         back(true);
      }
      
      private function updateScene() : void
      {
         var _loc1_:Boolean = UserDataWrapper.wrapper.hasMetal(value);
         TweenAnimator.startItself(displaySprite,!!_loc1_ ? "pos0" : "pos1");
         TweenAnimator.finishItself(displaySprite);
         shortageImage.visible = !_loc1_;
         chargeButton.visible = !_loc1_;
         offerwallButton.visible = UserDataWrapper.wrapper.isEnabledOfferwall() && !_loc1_;
         okButton.setEnableWithDrawCache(_loc1_);
      }
      
      override public function dispose() : void
      {
         spineModel = null;
         costText = null;
         messageText = null;
         chargeButton.removeEventListener("triggered",triggeredChargeButton);
         chargeButton = null;
         offerwallButton.removeEventListener("triggered",triggeredOfferwallButton);
         offerwallButton = null;
         cancelButton.removeEventListener("triggered",triggeredCancelButton);
         cancelButton = null;
         okButton.removeEventListener("triggered",triggeredOkButton);
         okButton = null;
         shortageImage = null;
         super.dispose();
      }
   }
}
