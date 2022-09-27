package gudetama.scene.home
{
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.WebViewDialog;
   import muku.display.ContainerButton;
   import starling.display.DisplayObject;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class ContractDialog extends BaseScene
   {
       
      
      private var contractButton:ContainerButton;
      
      private var policyButton:ContainerButton;
      
      private var rawButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      public function ContractDialog()
      {
         super(2);
      }
      
      public static function show() : void
      {
         Engine.pushScene(new ContractDialog(),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"ContractDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            contractButton = _loc2_.getChildByName("btn_contract") as ContainerButton;
            contractButton.addEventListener("triggered",triggeredContractButton);
            policyButton = _loc2_.getChildByName("btn_policy") as ContainerButton;
            policyButton.addEventListener("triggered",triggeredPolicyButton);
            rawButton = _loc2_.getChildByName("btn_raw1") as ContainerButton;
            rawButton.addEventListener("triggered",triggeredTransactionsLawButton);
            closeButton = _loc2_.getChildByName("btn_close") as ContainerButton;
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
         Engine.lockTouchInput(ContractDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      private function initTween(param1:Function) : void
      {
         var callback:Function = param1;
         var twname:String = "default";
         if(Engine.getLocale() != "ja")
         {
            twname = "oversea";
            rawButton.visible = false;
         }
         TweenAnimator.startItself(displaySprite,twname,false,function(param1:DisplayObject):void
         {
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      override protected function transitionOpenFinished() : void
      {
         initTween(function():void
         {
            displaySprite.visible = true;
            TweenAnimator.startItself(displaySprite,"show",false,function():void
            {
               Engine.unlockTouchInput(ContractDialog);
            });
         });
      }
      
      private function triggeredContractButton(param1:Event) : void
      {
         WebViewDialog.show(GameSetting.getOtherText("url.tos"));
      }
      
      private function triggeredPolicyButton(param1:Event) : void
      {
         WebViewDialog.show(GameSetting.getOtherText("url.pp"));
      }
      
      private function triggeredTransactionsLawButton(param1:Event) : void
      {
         WebViewDialog.show(GameSetting.getOtherText("url.asct"));
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(ContractDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(ContractDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         contractButton.removeEventListener("triggered",triggeredContractButton);
         contractButton = null;
         policyButton.removeEventListener("triggered",triggeredPolicyButton);
         policyButton = null;
         rawButton.removeEventListener("triggered",triggeredTransactionsLawButton);
         rawButton = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
