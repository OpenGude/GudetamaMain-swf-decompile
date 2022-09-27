package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class FeatureNoticeDialog extends BaseScene
   {
       
      
      private var type:int;
      
      private var titleText:ColorTextField;
      
      private var iconImage:Image;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function FeatureNoticeDialog(param1:int)
      {
         super(2);
         this.type = param1;
      }
      
      public static function show(param1:int) : void
      {
         Engine.pushScene(new FeatureNoticeDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"FeatureNoticeDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            iconImage = _loc2_.getChildByName("icon") as Image;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
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
         titleText.text#2 = GameSetting.getUIText("featureNotice.title." + type);
         descText.text#2 = GameSetting.getUIText("featureNotice.desc." + type);
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("home1@feature" + type,function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(FeatureNoticeDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("MaxComboSuccess");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(FeatureNoticeDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(FeatureNoticeDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(FeatureNoticeDialog);
            Engine.popScene(scene);
            processResumeNoticeTutorial();
         });
      }
      
      private function processResumeNoticeTutorial() : void
      {
         switch(int(type) - 1)
         {
            case 0:
               resumeNoticeTutorial(17);
               break;
            case 9:
               resumeNoticeTutorial(18);
               break;
            case 12:
               resumeNoticeTutorial(19);
         }
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         titleText = null;
         iconImage = null;
         descText = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
