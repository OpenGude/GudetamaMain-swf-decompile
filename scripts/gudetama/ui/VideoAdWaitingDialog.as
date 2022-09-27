package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class VideoAdWaitingDialog extends BaseScene
   {
       
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      public function VideoAdWaitingDialog()
      {
         super(2);
      }
      
      public static function show() : void
      {
         Engine.pushScene(new VideoAdWaitingDialog(),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"VideoAdWaitingDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
            setup(queue);
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
      
      private function setup(param1:TaskQueue) : void
      {
         var _loc2_:int = UserDataWrapper.videoAdPart.getRestTimeSecs();
         descText.text#2 = StringUtil.format(GameSetting.getUIText("videoAdWaiting.desc"),1 + int(_loc2_ / 3600));
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(AcquiredRecipeNoteDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(AcquiredRecipeNoteDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(AcquiredRecipeNoteDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(AcquiredRecipeNoteDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
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
