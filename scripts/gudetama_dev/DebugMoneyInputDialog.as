package gudetama_dev
{
   import feathers.controls.TextInput;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.mission.MissionDetailDialog;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class DebugMoneyInputDialog extends BaseScene
   {
       
      
      private var textInput:TextInput;
      
      private var acquireButton:ContainerButton;
      
      private var backButton:ContainerButton;
      
      private var loadCount:int;
      
      public function DebugMoneyInputDialog()
      {
         super(2);
      }
      
      public static function show() : void
      {
         if(Engine.containsSceneStack(DebugMoneyInputDialog))
         {
            return;
         }
         Engine.pushScene(new DebugMoneyInputDialog(),0,true);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"DebugMoneyInputDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            textInput = dialogSprite.getChildByName("textInput") as TextInput;
            textInput.maxChars = 15;
            textInput.backgroundSkin = null;
            textInput.restrict = "0-9";
            textInput.addEventListener("focusIn",function():void
            {
               textInput.selectRange(0,textInput.text#2.length);
            });
            textInput.validate();
            acquireButton = dialogSprite.getChildByName("acquireButton") as ContainerButton;
            acquireButton.addEventListener("triggered",triggeredAcquireButton);
            backButton = dialogSprite.getChildByName("closeButton") as ContainerButton;
            backButton.addEventListener("triggered",onCloseTriggered);
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
         textInput.text#2 = UserDataWrapper.wrapper.getMoney().toString();
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(DebugMoneyInputDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(DebugMoneyInputDialog);
         });
      }
      
      private function triggeredAcquireButton(param1:Event) : void
      {
         if(textInput.text#2.length <= 0)
         {
            return;
         }
         var _loc2_:int = textInput.text#2;
         if(_loc2_ < 0)
         {
            return;
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(MissionDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MissionDetailDialog);
            Engine.popScene(scene);
         });
      }
      
      private function onCloseTriggered(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         acquireButton.removeEventListener("triggered",triggeredAcquireButton);
         acquireButton = null;
         backButton.removeEventListener("triggered",onCloseTriggered);
         backButton = null;
         super.dispose();
      }
   }
}
