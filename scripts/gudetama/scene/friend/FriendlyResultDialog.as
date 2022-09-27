package gudetama.scene.friend
{
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class FriendlyResultDialog extends BaseScene
   {
       
      
      private var title:String;
      
      private var desc:String;
      
      private var value:int;
      
      private var callback:Function;
      
      private var state:int;
      
      private var titleText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var friendlyText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function FriendlyResultDialog(param1:String, param2:String, param3:int, param4:Function, param5:int)
      {
         super(2);
         this.title = param1;
         this.desc = param2;
         this.value = param3;
         this.callback = param4;
         this.state = param5;
      }
      
      public static function show(param1:String, param2:String, param3:int, param4:Function, param5:int = 94) : void
      {
         Engine.pushScene(new FriendlyResultDialog(param1,param2,param3,param4,param5),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"FriendlyResultDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            friendlyText = _loc2_.getChildByName("friendly") as ColorTextField;
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
         titleText.text#2 = title;
         descText.text#2 = desc;
         friendlyText.text#2 = StringUtil.format(GameSetting.getUIText("friendlyResult.value"),value);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(FriendlyResultDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(state);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(FriendlyResultDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(FriendlyResultDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(FriendlyResultDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         titleText = null;
         descText = null;
         friendlyText = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
