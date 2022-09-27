package gudetama.scene.kitchen
{
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CookingRepairDialog extends BaseScene
   {
       
      
      private var value:int;
      
      private var callback:Function;
      
      private var costText:ColorTextField;
      
      private var useButton:ContainerButton;
      
      private var shortageImage:Image;
      
      private var chargeButton:SimpleImageButton;
      
      private var offerwallButton:SimpleImageButton;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function CookingRepairDialog(param1:int, param2:Function)
      {
         super(2);
         this.value = param1;
         this.callback = param2;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:int, param2:Function) : void
      {
         Engine.pushScene(new CookingRepairDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"CookingRepairDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            costText = _loc2_.getChildByName("cost") as ColorTextField;
            useButton = _loc2_.getChildByName("useButton") as ContainerButton;
            useButton.addEventListener("triggered",triggeredUseButton);
            shortageImage = _loc2_.getChildByName("shortage") as Image;
            chargeButton = _loc2_.getChildByName("chargeButton") as SimpleImageButton;
            chargeButton.addEventListener("triggered",triggeredChargeButton);
            offerwallButton = _loc2_.getChildByName("offerwallButton") as SimpleImageButton;
            offerwallButton.addEventListener("triggered",triggeredOfferwallButton);
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
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
         costText.text#2 = StringUtil.getNumStringCommas(value);
         updateScene();
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
         });
      }
      
      protected function triggeredUseButton(param1:Event) : void
      {
         back(true);
      }
      
      private function triggeredChargeButton(param1:Event) : void
      {
         ResidentMenuUI_Gudetama.getInstance().showMetalShop();
      }
      
      private function triggeredOfferwallButton(param1:Event) : void
      {
         OfferwallAdvertisingManager.showOfferwallAds();
      }
      
      protected function triggeredCloseButton(param1:Event) : void
      {
         back(false);
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
      
      private function updateScene() : void
      {
         var _loc1_:Boolean = UserDataWrapper.wrapper.hasMetal(value);
         TweenAnimator.startItself(displaySprite,!!_loc1_ ? "pos0" : "pos1");
         TweenAnimator.finishItself(displaySprite);
         useButton.setEnableWithDrawCache(_loc1_);
         shortageImage.visible = !_loc1_;
         chargeButton.visible = !_loc1_;
         offerwallButton.visible = UserDataWrapper.wrapper.isEnabledOfferwall() && !_loc1_;
      }
      
      override public function dispose() : void
      {
         costText = null;
         if(useButton)
         {
            useButton.removeEventListener("triggered",triggeredUseButton);
            useButton = null;
         }
         shortageImage = null;
         if(chargeButton)
         {
            chargeButton.removeEventListener("triggered",triggeredChargeButton);
            chargeButton = null;
         }
         if(offerwallButton)
         {
            offerwallButton.removeEventListener("triggered",triggeredOfferwallButton);
            offerwallButton = null;
         }
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
