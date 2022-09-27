package gudetama.scene.friend
{
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class SnsLinkBonusGuideDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var btnClose:ContainerButton;
      
      public function SnsLinkBonusGuideDialog(param1:Function)
      {
         super(2);
         this.callback = param1;
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new SnsLinkBonusGuideDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"SnsLinkBonusGuideDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc3_:ColorTextField = _loc2_.getChildByName("message") as ColorTextField;
            _loc3_.text#2 = GameSetting.getUIText("sns.link.guide.desc").replace("%1",GameSetting.def.rule.snsLinkBonusNum);
            btnClose = _loc2_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",backButtonCallback);
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
         Engine.lockTouchInput(SnsLinkBonusGuideDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(SnsLinkBonusGuideDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(SnsLinkBonusGuideDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(SnsLinkBonusGuideDialog);
            Engine.popScene(scene);
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      override public function dispose() : void
      {
         btnClose.removeEventListener("triggered",backButtonCallback);
         btnClose = null;
         super.dispose();
      }
   }
}
