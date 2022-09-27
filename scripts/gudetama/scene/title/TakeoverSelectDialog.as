package gudetama.scene.title
{
   import feathers.controls.IScrollBar;
   import feathers.controls.ScrollBar;
   import feathers.controls.ScrollContainer;
   import flash.geom.Rectangle;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.LocalMessageDialog;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class TakeoverSelectDialog extends BaseScene
   {
       
      
      private var loginFunc:Function;
      
      private var btnGenerate:ContainerButton;
      
      private var btnInput:ContainerButton;
      
      private var btnClose:ContainerButton;
      
      private var scroll:ScrollContainer;
      
      public function TakeoverSelectDialog(param1:Function)
      {
         super(2);
         this.loginFunc = param1;
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new TakeoverSelectDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"TakeoverSelectDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            scroll = dialogSprite.getChildByName("scroll") as ScrollContainer;
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
            btnGenerate = dialogSprite.getChildByName("btnGenerate") as ContainerButton;
            btnGenerate.addEventListener("triggered",triggeredGenerate);
            btnInput = dialogSprite.getChildByName("btnInput") as ContainerButton;
            btnInput.addEventListener("triggered",triggeredInput);
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
         });
         queue.startTask(onProgress);
      }
      
      private function triggeredGenerate() : void
      {
         if(!UserDataWrapper.isInitialized())
         {
            loginFunc(function():void
            {
               Engine.hideLoading();
               generateCode();
            });
         }
         else
         {
            generateCode();
         }
      }
      
      private function generateCode() : void
      {
         var _loc1_:* = UserDataWrapper;
         if(!gudetama.data.UserDataWrapper.wrapper._data.doneFirstLogin)
         {
            LocalMessageDialog.show(0,GameSetting.getInitUIText("takeover.err.noaccount"),null,null,12);
            return;
         }
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(124),function(param1:String):void
         {
            var res:String = param1;
            if(res != null)
            {
               backButtonCallback();
               TakeoverCodeConfirmDialog.show(res,true);
            }
            else
            {
               TakeoverPasswordDialog.show(function(param1:String):void
               {
                  if(param1.length == 0)
                  {
                     return;
                  }
                  backButtonCallback();
                  TakeoverCodeConfirmDialog.show(param1,false);
               });
            }
         });
      }
      
      private function triggeredInput() : void
      {
         TakeoverDialog.show(loginFunc);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(TakeoverSelectDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(12);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(TakeoverSelectDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(TakeoverSelectDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(TakeoverSelectDialog);
            Engine.popScene(scene);
         });
      }
      
      override public function dispose() : void
      {
         btnGenerate.removeEventListener("triggered",triggeredGenerate);
         btnGenerate = null;
         btnInput.removeEventListener("triggered",triggeredInput);
         btnInput = null;
         btnClose.removeEventListener("triggered",backButtonCallback);
         btnClose = null;
         super.dispose();
      }
   }
}
