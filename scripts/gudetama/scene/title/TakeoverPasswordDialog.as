package gudetama.scene.title
{
   import feathers.controls.IScrollBar;
   import feathers.controls.ScrollBar;
   import feathers.controls.ScrollContainer;
   import feathers.controls.TextInput;
   import flash.geom.Rectangle;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class TakeoverPasswordDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var input1:TextInput;
      
      private var input2:TextInput;
      
      private var txtError:ColorTextField;
      
      private var btnOk:ContainerButton;
      
      private var btnCancel:ContainerButton;
      
      private var code:String = "";
      
      public function TakeoverPasswordDialog(param1:Function)
      {
         super(2);
         this.callback = param1;
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new TakeoverPasswordDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"TakeoverPasswordDialog",function(param1:Object):void
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
            msg.text#2 = GameSetting.getInitUIText("takeover.pw.desc").replace("%1",4).replace("%2",12);
            msg.height = 9999;
            var rect:Rectangle = msg.textBounds;
            var _h:Number = rect.height + msg.fontSize;
            msg.height = _h;
            var spBtm:Sprite = dialogSprite.getChildByName("spBtm") as Sprite;
            input1 = spBtm.getChildByName("input1") as TextInput;
            input1.maxChars = 12;
            input1.restrict = "a-zA-Z0-9";
            input1.displayAsPassword = true;
            input1.addEventListener("change",inputPassWordTextCallback);
            input1.backgroundSkin = null;
            input2 = spBtm.getChildByName("input2") as TextInput;
            input2.maxChars = 12;
            input2.restrict = "a-zA-Z0-9";
            input2.displayAsPassword = true;
            input2.addEventListener("change",inputPassWordTextCallback);
            input2.backgroundSkin = null;
            txtError = spBtm.getChildByName("error") as ColorTextField;
            txtError.text#2 = "";
            btnOk = spBtm.getChildByName("btnOk") as ContainerButton;
            btnOk.setEnableWithDrawCache(false);
            btnOk.addEventListener("triggered",triggeredOk);
            btnCancel = spBtm.getChildByName("btnCancel") as ContainerButton;
            btnCancel.addEventListener("triggered",backButtonCallback);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            var _loc2_:* = Engine;
            if(gudetama.engine.Engine.isIosPlatform() || true)
            {
               TweenAnimator.startItself(btnOk,"ios");
               TweenAnimator.startItself(btnCancel,"ios");
            }
         });
         queue.startTask(onProgress);
      }
      
      private function inputPassWordTextCallback() : void
      {
         btnOk.setEnableWithDrawCache(checkPassword());
      }
      
      private function checkHalf(param1:*) : Boolean
      {
         return checkCode(param1,0,127) || checkCode(param1,65377,65439) ? true : false;
      }
      
      private function checkCode(param1:*, param2:*, param3:*) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:int = param1.length;
         while(_loc4_--)
         {
            if((_loc5_ = param1.substr(_loc4_,1).charCodeAt(0)) < param2 || _loc5_ > param3)
            {
               return false;
            }
         }
         return true;
      }
      
      private function checkPassword() : Boolean
      {
         var _loc2_:String = input1.text#2;
         var _loc1_:String = input2.text#2;
         if(!checkHalf(_loc2_) || !checkHalf(_loc1_))
         {
            txtError.text#2 = GameSetting.getInitUIText("takeover.mismatch.charcode");
            return false;
         }
         if(_loc2_.length < 4 || _loc2_.length > 12 || _loc1_.length < 4 || _loc1_.length > 12)
         {
            return false;
         }
         if(_loc1_ != _loc2_)
         {
            txtError.text#2 = GameSetting.getInitUIText("takeover.pw.mismatch");
            return false;
         }
         txtError.text#2 = "";
         return true;
      }
      
      private function triggeredOk() : void
      {
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(GENERAL_REQUEST_TAKEOVER_CODE,input1.text#2),function(param1:*):void
         {
            code = param1;
            backButtonCallback();
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(TakeoverPasswordDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(12);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(TakeoverPasswordDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(TakeoverPasswordDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(TakeoverPasswordDialog);
            Engine.popScene(scene);
            callback(code);
         });
      }
      
      override public function dispose() : void
      {
         btnOk.removeEventListener("triggered",triggeredOk);
         btnOk = null;
         btnCancel.removeEventListener("triggered",backButtonCallback);
         btnCancel = null;
         super.dispose();
      }
   }
}
