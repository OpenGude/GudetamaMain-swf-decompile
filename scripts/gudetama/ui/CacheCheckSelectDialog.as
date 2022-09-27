package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.TweenAnimator;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CacheCheckSelectDialog extends BaseScene
   {
       
      
      private var fromTitle:Boolean;
      
      private var btnYes:ContainerButton;
      
      private var btnNo:ContainerButton;
      
      private var btnDel:ContainerButton;
      
      public function CacheCheckSelectDialog(param1:Boolean)
      {
         super(2);
         this.fromTitle = param1;
      }
      
      public static function show(param1:Boolean) : void
      {
         Engine.pushScene(new CacheCheckSelectDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CacheCheckSelectDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            btnYes = _loc2_.getChildByName("btn0") as ContainerButton;
            btnYes.alphaWhenDisabled = 0.5;
            btnYes.addEventListener("triggered",triggeredYesButton);
            btnNo = _loc2_.getChildByName("btn1") as ContainerButton;
            btnNo.alphaWhenDisabled = 0.5;
            btnNo.addEventListener("triggered",triggeredNoButton);
            btnDel = _loc2_.getChildByName("btn2") as ContainerButton;
            btnDel.alphaWhenDisabled = 0.5;
            btnDel.addEventListener("triggered",triggeredDeleteButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            var _loc2_:* = Engine;
            if(gudetama.engine.Engine.isIosPlatform() || true)
            {
               TweenAnimator.startItself(btnYes,"ios");
               TweenAnimator.startItself(btnNo,"ios");
            }
            else
            {
               TweenAnimator.startItself(btnYes,"android");
               TweenAnimator.startItself(btnNo,"android");
            }
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CacheCheckSelectDialog);
         setBackButtonCallback(backButtonCallback);
         if(fromTitle)
         {
            setVisibleState(12);
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
            Engine.unlockTouchInput(CacheCheckSelectDialog);
         });
      }
      
      override public function isSkipUnchangedFrames() : Boolean
      {
         return false;
      }
      
      private function triggeredYesButton(param1:Event) : void
      {
         CacheCheckProgressDialog.show(fromTitle);
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         setBackButtonCallback(null);
         Engine.lockTouchInput(CacheCheckSelectDialog);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CacheCheckSelectDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredNoButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function triggeredDeleteButton(param1:Event) : void
      {
         var event:Event = param1;
         LocalMessageDialog.show(1,GameSetting.getInitUIText("cache.delete.confirm"),function(param1:int):void
         {
            var choose:int = param1;
            if(choose != 0)
            {
               return;
            }
            RsrcManager.clearFileCache();
            LocalMessageDialog.show(0,GameSetting.getInitUIText("cache.delete.finish"),function(param1:int):void
            {
               backButtonCallback();
            },GameSetting.getInitUIText("cache.delete.finish.title"),!!fromTitle ? 12 : 94);
         },GameSetting.getInitUIText("%cache.delete"),!!fromTitle ? 12 : 94);
      }
      
      override public function dispose() : void
      {
         btnYes.removeEventListener("triggered",triggeredYesButton);
         btnYes = null;
         btnNo.removeEventListener("triggered",triggeredNoButton);
         btnNo = null;
         btnDel.removeEventListener("triggered",triggeredDeleteButton);
         btnDel = null;
         super.dispose();
      }
   }
}
