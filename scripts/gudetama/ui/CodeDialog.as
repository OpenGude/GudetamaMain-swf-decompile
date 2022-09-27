package gudetama.ui
{
   import feathers.controls.TextInput;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CodeDialog extends BaseScene
   {
       
      
      private var textInput:TextInput;
      
      private var sendButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      public function CodeDialog()
      {
         super(2);
      }
      
      public static function show() : void
      {
         Engine.pushScene(new CodeDialog(),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CodeDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            textInput = _loc2_.getChildByName("textInput") as TextInput;
            textInput.maxChars = 13;
            textInput.backgroundSkin = null;
            textInput.validate();
            sendButton = _loc2_.getChildByName("sendButton") as ContainerButton;
            sendButton.addEventListener("triggered",triggeredSendButton);
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CodeDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CodeDialog);
         });
      }
      
      private function triggeredSendButton(param1:Event) : void
      {
         var event:Event = param1;
         if(!textInput.text#2 || textInput.text#2.length <= 0)
         {
            return;
         }
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(16777409,textInput.text#2),function(param1:Array):void
         {
            var _loc2_:int = param1[0];
            if(_loc2_ < 0)
            {
               LocalMessageDialog.show(0,GameSetting.getUIText("code.error." + Math.abs(_loc2_)),null,GameSetting.getUIText("code.result.title.error"));
               return;
            }
            LocalMessageDialog.show(0,GameSetting.getUIText("code.result.desc"),null,GameSetting.getUIText("code.result.title"));
            textInput.text#2 = "";
            UserDataWrapper.wrapper.addNumUnreadInfoAndPresents(param1[1]);
            Engine.broadcastEventToSceneStackWith("update_scene");
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(CodeDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CodeDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         textInput = null;
         sendButton.removeEventListener("triggered",triggeredSendButton);
         sendButton = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
