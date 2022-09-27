package gudetama.scene.title
{
   import feathers.controls.IScrollBar;
   import feathers.controls.ScrollBar;
   import feathers.controls.ScrollContainer;
   import flash.desktop.Clipboard;
   import flash.geom.Rectangle;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.LocalMessageDialog;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class TakeoverCodeConfirmDialog extends BaseScene
   {
       
      
      private var code:String = "";
      
      private var needResetPw:Boolean;
      
      private var btnCode:ContainerButton;
      
      private var btnPw:ContainerButton;
      
      private var btnClose:ContainerButton;
      
      public function TakeoverCodeConfirmDialog(param1:String, param2:Boolean)
      {
         super(2);
         this.code = param1;
         this.needResetPw = param2;
      }
      
      public static function show(param1:String, param2:Boolean) : void
      {
         Engine.pushScene(new TakeoverCodeConfirmDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"TakeoverCodeConfirmDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var scroll:ScrollContainer = dialogSprite.getChildByName("scroll") as ScrollContainer;
            scroll.verticalScrollBarFactory = function():IScrollBar
            {
               var _loc1_:ScrollBar = new ScrollBar();
               _loc1_.trackLayoutMode = "single";
               return _loc1_;
            };
            scroll.scrollBarDisplayMode = "fixedFloat";
            scroll.horizontalScrollPolicy = "off";
            scroll.verticalScrollPolicy = "auto";
            scroll.interactionMode = "touchAndScrollBars";
            var msg:ColorTextField = scroll.getChildByName("message") as ColorTextField;
            msg.height = 9999;
            var rect:Rectangle = msg.textBounds;
            var _h:Number = rect.height + msg.fontSize;
            msg.height = _h;
            btnCode = dialogSprite.getChildByName("btnCode") as ContainerButton;
            btnCode.addEventListener("triggered",triggeredCodeCopy);
            ColorTextField(btnCode.getChildByName("text")).text#2 = code;
            btnPw = dialogSprite.getChildByName("btnPw") as ContainerButton;
            btnPw.addEventListener("triggered",triggeredResetPw);
            btnClose = dialogSprite.getChildByName("btnClose") as ContainerButton;
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
            if(!needResetPw)
            {
               btnPw.visible = false;
               TweenAnimator.startItself(btnClose,"btn1");
            }
         });
         queue.startTask(onProgress);
      }
      
      private function triggeredCodeCopy() : void
      {
         Clipboard.generalClipboard.setData("air:text",code);
         LocalMessageDialog.show(0,GameSetting.getUIText("takeover.code.copy"),null,null,12);
      }
      
      private function triggeredResetPw() : void
      {
         TakeoverPasswordDialog.show(function(param1:String):void
         {
            if(param1.length == 0)
            {
               return;
            }
            LocalMessageDialog.show(0,GameSetting.getInitUIText("takeover.pw.reset.success"),null,null,12);
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(TakeoverCodeConfirmDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(12);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(TakeoverCodeConfirmDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(TakeoverCodeConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(TakeoverCodeConfirmDialog);
            Engine.popScene(scene);
         });
      }
      
      override public function dispose() : void
      {
         btnCode.removeEventListener("triggered",triggeredCodeCopy);
         btnCode = null;
         btnPw.removeEventListener("triggered",triggeredResetPw);
         btnPw = null;
         btnClose.removeEventListener("triggered",backButtonCallback);
         btnClose = null;
         super.dispose();
      }
   }
}
