package gudetama.scene.kitchen
{
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CookingCancelDialog extends BaseScene
   {
      
      public static const RESULT_POSITIVE:int = 0;
      
      public static const RESULT_NEGATIVE:int = 1;
       
      
      private var callback:Function;
      
      private var button0:ContainerButton;
      
      private var button1:ContainerButton;
      
      private var loadCount:int;
      
      public function CookingCancelDialog(param1:Function)
      {
         super(2);
         this.callback = param1;
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new CookingCancelDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"CookingCancelDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            button0 = _loc2_.getChildByName("btn0") as ContainerButton;
            button0.addEventListener("triggered",triggeredPositiveButton);
            button1 = _loc2_.getChildByName("btn1") as ContainerButton;
            button1.addEventListener("triggered",triggeredNegativeButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
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
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.isIosPlatform() || true)
         {
            TweenAnimator.startItself(button0,"ios");
            TweenAnimator.startItself(button1,"ios");
         }
         else
         {
            TweenAnimator.startItself(button0,"android");
            TweenAnimator.startItself(button1,"android");
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CookingCancelDialog);
         setBackButtonCallback(backButtonCallback);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CookingCancelDialog);
         });
      }
      
      private function triggeredPositiveButton(param1:Event) : void
      {
         back(0);
      }
      
      private function triggeredNegativeButton(param1:Event) : void
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
         Engine.lockTouchInput(CookingCancelDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CookingCancelDialog);
            Engine.popScene(scene);
            callback(choose);
         });
      }
      
      override public function dispose() : void
      {
         if(button0)
         {
            button0.removeEventListener("triggered",triggeredPositiveButton);
            button0 = null;
         }
         if(button1)
         {
            button1.removeEventListener("triggered",triggeredNegativeButton);
            button1 = null;
         }
         super.dispose();
      }
   }
}
