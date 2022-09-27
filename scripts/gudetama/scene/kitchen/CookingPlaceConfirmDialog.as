package gudetama.scene.kitchen
{
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CookingPlaceConfirmDialog extends BaseScene
   {
      
      public static const RESULT_POSITIVE:int = 0;
      
      public static const RESULT_NEGATIVE:int = 1;
       
      
      private var callback:Function;
      
      private var okButton:ContainerButton;
      
      private var cancelButton:ContainerButton;
      
      private var loadCount:int;
      
      public function CookingPlaceConfirmDialog(param1:Function)
      {
         super(2);
         this.callback = param1;
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new CookingPlaceConfirmDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"CookingPlaceConfirmDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            okButton = _loc2_.getChildByName("btn0") as ContainerButton;
            okButton.addEventListener("triggered",triggeredOkButton);
            cancelButton = _loc2_.getChildByName("btn1") as ContainerButton;
            cancelButton.addEventListener("triggered",triggeredCancelButton);
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
         TweenAnimator.startItself(displaySprite,!!UserDataWrapper.featurePart.existsFeature(4) ? "pos0" : "pos1");
         TweenAnimator.finishItself(displaySprite);
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.isIosPlatform() || true)
         {
            TweenAnimator.startItself(okButton,"ios");
            TweenAnimator.startItself(cancelButton,"ios");
         }
         else
         {
            TweenAnimator.startItself(okButton,"android");
            TweenAnimator.startItself(cancelButton,"android");
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CookingPlaceConfirmDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(76);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CookingPlaceConfirmDialog);
         });
      }
      
      private function triggeredOkButton(param1:Event) : void
      {
         back(0);
      }
      
      private function triggeredCancelButton(param1:Event) : void
      {
         back(1);
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:int = 1) : void
      {
         var choose:int = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(CookingPlaceConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CookingPlaceConfirmDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback(choose);
            }
         });
      }
      
      override public function dispose() : void
      {
         if(okButton)
         {
            okButton.removeEventListener("triggered",triggeredOkButton);
            okButton = null;
         }
         if(cancelButton)
         {
            cancelButton.removeEventListener("triggered",triggeredCancelButton);
            cancelButton = null;
         }
         super.dispose();
      }
   }
}
