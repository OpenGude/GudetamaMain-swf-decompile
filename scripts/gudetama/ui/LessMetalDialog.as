package gudetama.ui
{
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class LessMetalDialog extends BaseScene
   {
       
      
      private var lessMetal:int;
      
      private var needOfferwall:Boolean;
      
      private var chargeButton:SimpleImageButton;
      
      private var btnOfferwall:SimpleImageButton;
      
      private var closeButton:ContainerButton;
      
      public function LessMetalDialog(param1:int, param2:Boolean)
      {
         super(2);
         lessMetal = param1;
         this.needOfferwall = param2;
      }
      
      public static function show(param1:int = 0, param2:Boolean = false) : void
      {
         Engine.pushScene(new LessMetalDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"LessMetalDialog",function(param1:Object):void
         {
            var _loc3_:* = null;
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            if(lessMetal > 0)
            {
               _loc3_ = _loc2_.getChildByName("title") as ColorTextField;
               _loc3_.text#2 = GameSetting.getUIText("lessMetal.detail").replace("%1",StringUtil.getNumStringCommas(lessMetal));
            }
            chargeButton = _loc2_.getChildByName("chargeButton") as SimpleImageButton;
            chargeButton.addEventListener("triggered",triggeredChargeButton);
            btnOfferwall = _loc2_.getChildByName("btnOfferwall") as SimpleImageButton;
            btnOfferwall.addEventListener("triggered",triggeredOfferwall);
            if(!needOfferwall || !UserDataWrapper.wrapper.isEnabledOfferwall())
            {
               chargeButton.x = (_loc2_.width - chargeButton.width) / 2;
               btnOfferwall.visible = false;
            }
            closeButton = _loc2_.getChildByName("closeButton") as ContainerButton;
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
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(LessMetalDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LessMetalDialog);
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
         Engine.lockTouchInput(LessMetalDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LessMetalDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredChargeButton(param1:Event) : void
      {
         var event:Event = param1;
         back(function():void
         {
            ResidentMenuUI_Gudetama.getInstance().showMetalShop();
         });
      }
      
      private function triggeredOfferwall() : void
      {
         OfferwallAdvertisingManager.showOfferwallAds();
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         chargeButton.removeEventListener("triggered",triggeredChargeButton);
         chargeButton = null;
         btnOfferwall.removeEventListener("triggered",triggeredOfferwall);
         btnOfferwall = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
