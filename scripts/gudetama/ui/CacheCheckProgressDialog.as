package gudetama.ui
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.TweenAnimator;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class CacheCheckProgressDialog extends BaseScene
   {
       
      
      private const CANCEL_TIMEOUT:Number = 30000;
      
      private var fromTitle:Boolean;
      
      private var titleText:ColorTextField;
      
      private var numCheckedText:ColorTextField;
      
      private var numBrokenText:ColorTextField;
      
      private var cancelButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      private var canceled:Boolean = false;
      
      private var cancelTimer:Timer;
      
      private var numChecked:int = 0;
      
      private var numBroken:int = 0;
      
      public function CacheCheckProgressDialog(param1:Boolean)
      {
         super(2);
         this.fromTitle = param1;
      }
      
      public static function show(param1:Boolean) : void
      {
         Engine.pushScene(new CacheCheckProgressDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CacheCheckProgressDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            numCheckedText = _loc2_.getChildByName("num_checked") as ColorTextField;
            numBrokenText = _loc2_.getChildByName("num_broken") as ColorTextField;
            cancelButton = _loc2_.getChildByName("btn_cancel") as ContainerButton;
            cancelButton.alphaWhenDisabled = 0.5;
            cancelButton.addEventListener("triggered",triggeredCancelButton);
            closeButton = _loc2_.getChildByName("btn_close") as ContainerButton;
            closeButton.alphaWhenDisabled = 0.5;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            closeButton.visible = false;
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
         Engine.lockTouchInput(CacheCheckProgressDialog);
         setBackButtonCallback(triggeredCancelButton);
         if(!fromTitle)
         {
            setVisibleState(70);
         }
         else
         {
            setVisibleState(4);
         }
         cancelButton.enabled = true;
         closeButton.enabled = false;
         RsrcManager.getInstance().checkCacheFiles(function(param1:Boolean):void
         {
            trace("Checking cache files done");
            checkingDone();
         },scene);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CacheCheckProgressDialog);
         });
      }
      
      override public function isSkipUnchangedFrames() : Boolean
      {
         return false;
      }
      
      public function get isCanceled() : Boolean
      {
         return canceled;
      }
      
      public function increaseChecked() : int
      {
         numChecked++;
         numCheckedText.text#2 = numChecked.toString();
         return numChecked;
      }
      
      public function increaseBroken() : int
      {
         numBroken++;
         numBrokenText.text#2 = numBroken.toString();
         return numBroken;
      }
      
      private function triggeredCancelButton() : void
      {
         if(!canceled)
         {
            cancelTimer = new Timer(30000,1);
            cancelTimer.addEventListener("timer",cancelDetectTimeout);
            cancelTimer.stop();
            cancelTimer.reset();
            cancelTimer.start();
         }
         canceled = true;
      }
      
      private function cancelDetectTimeout(param1:TimerEvent) : void
      {
         if(!closeButton.enabled)
         {
            Logger.warn("[CacheCheckProgressDialog] Cancel button pressed was not detected.");
            checkingDone();
         }
      }
      
      public function checkingDone() : void
      {
         titleText.text#2 = GameSetting.getInitUIText("cache.check.finish");
         cancelButton.enabled = false;
         cancelButton.visible = false;
         closeButton.enabled = true;
         closeButton.visible = true;
         setBackButtonCallback(triggeredCloseButton);
         if(!fromTitle)
         {
            setVisibleState(94);
         }
         else
         {
            setVisibleState(12);
         }
         if(cancelTimer && cancelTimer.running)
         {
            cancelTimer.stop();
            cancelTimer.reset();
            trace("[CacheCheckProgressDialog] CancelTimer was force stopped");
         }
         cancelTimer = null;
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton() : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         titleText = null;
         numCheckedText = null;
         numBrokenText = null;
         cancelButton.removeEventListener("triggered",triggeredCancelButton);
         cancelButton = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         cancelTimer = null;
         super.dispose();
      }
   }
}
