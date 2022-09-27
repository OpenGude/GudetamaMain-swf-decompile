package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class LessMoneyDialog extends BaseScene
   {
       
      
      private var lessMoney:int;
      
      private var titleText:ColorTextField;
      
      private var chargeButton:SimpleImageButton;
      
      private var closeButton:ContainerButton;
      
      public function LessMoneyDialog(param1:*)
      {
         super(2);
         lessMoney = param1;
      }
      
      public static function show(param1:int = 0) : void
      {
         Engine.pushScene(new LessMoneyDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"LessMoneyDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            if(lessMoney > 0)
            {
               titleText.text#2 = GameSetting.getUIText("lessMoney.detail").replace("%1",StringUtil.getNumStringCommas(lessMoney));
            }
            else
            {
               titleText.text#2 = GameSetting.getUIText("gacha.lessMoney.desc");
            }
            chargeButton = _loc2_.getChildByName("chargeButton") as SimpleImageButton;
            chargeButton.addEventListener("triggered",triggeredChargeButton);
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
         Engine.lockTouchInput(LessMoneyDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LessMoneyDialog);
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
         Engine.lockTouchInput(LessMoneyDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LessMoneyDialog);
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
            ResidentMenuUI_Gudetama.getInstance().showMoneyShop();
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         titleText = null;
         chargeButton.removeEventListener("triggered",triggeredChargeButton);
         chargeButton = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
