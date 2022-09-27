package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class LevelUpDialog extends BaseScene
   {
       
      
      private var lastLevel:int;
      
      private var callback:Function;
      
      private var detailText:ColorTextField;
      
      private var messageText:ColorTextField;
      
      private var spineModel:SpineModel;
      
      private var levelText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function LevelUpDialog(param1:int, param2:Function)
      {
         super(2);
         this.lastLevel = param1;
         this.callback = param2;
      }
      
      public static function show(param1:int, param2:Function) : void
      {
         Engine.pushScene(new LevelUpDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"LevelUpDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            detailText = _loc2_.getChildByName("detail") as ColorTextField;
            messageText = _loc2_.getChildByName("message") as ColorTextField;
            spineModel = _loc2_.getChildByName("spineModel") as SpineModel;
            levelText = _loc2_.getChildByName("level") as ColorTextField;
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
         var _loc1_:int = UserDataWrapper.wrapper.getRank();
         detailText.text#2 = StringUtil.format(GameSetting.getUIText("levelUp.detail"),lastLevel,_loc1_);
         spineModel.visible = false;
         levelText.text#2 = _loc1_.toString();
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(LevelUpDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(76);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("level_up");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LevelUpDialog);
            spineModel.show();
            spineModel.changeAnimation("level_up_start",false,function():void
            {
               spineModel.changeAnimation("level_up_loop");
            });
            TweenAnimator.startItself(levelText,"start");
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(LevelUpDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LevelUpDialog);
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
         detailText = null;
         messageText = null;
         Engine.removeSpineCache("efx_spine-level_up");
         spineModel = null;
         levelText = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
