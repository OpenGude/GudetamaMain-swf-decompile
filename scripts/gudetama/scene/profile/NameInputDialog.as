package gudetama.scene.profile
{
   import feathers.controls.TextInput;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.MessageDialog;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class NameInputDialog extends BaseScene
   {
       
      
      private var orgName:String;
      
      private var callback:Function;
      
      private var closeButton:ContainerButton;
      
      private var nameInput:TextInput;
      
      private var txtBlank:ColorTextField;
      
      private var isOpening:Boolean;
      
      public function NameInputDialog(param1:String, param2:Function, param3:Boolean)
      {
         super(2);
         orgName = param1;
         this.callback = param2;
         this.isOpening = param3;
      }
      
      public static function show(param1:String, param2:Function, param3:Boolean = false) : void
      {
         Engine.pushScene(new NameInputDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"NameInputDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            closeButton = dialogSprite.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredDecideButton);
            txtBlank = dialogSprite.getChildByName("txtBlank") as ColorTextField;
            txtBlank.visible = false;
            nameInput = dialogSprite.getChildByName("nameInput") as TextInput;
            nameInput.text#2 = orgName;
            nameInput.maxChars = 8;
            nameInput.addEventListener("change",function():void
            {
               var _loc1_:int = nameInput.text#2.length;
               txtBlank.visible = _loc1_ == 0;
            });
            nameInput.addEventListener("softKeyboardActivate",function():void
            {
               txtBlank.visible = false;
            });
            nameInput.addEventListener("softKeyboardDeactivate",function():void
            {
               txtBlank.visible = nameInput.text#2.length == 0;
            });
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
         Engine.lockTouchInput(NameInputDialog);
         setBackButtonCallback(backButtonCallback);
         if(!isOpening)
         {
            setVisibleState(94);
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(AvatarSelectDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(NameInputDialog);
            Engine.popScene(scene);
         });
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(NameInputDialog);
         });
      }
      
      private function triggeredDecideButton(param1:Event) : void
      {
         var event:Event = param1;
         var name:String = nameInput.text#2;
         var txtLen:int = name.length;
         if(orgName == name)
         {
            backButtonCallback();
            return;
         }
         if(isOpening)
         {
            var sendServletConstant:int = 220;
         }
         else
         {
            sendServletConstant = 201326792;
         }
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(sendServletConstant,name),function(param1:Array):void
         {
            var _loc3_:int = param1[0][0];
            var _loc2_:String = param1[1];
            setName(_loc3_,_loc2_);
         });
      }
      
      private function setName(param1:int, param2:String) : void
      {
         switch(int(param1))
         {
            case 0:
               UserDataWrapper.wrapper.setPlayerName(param2);
               callback(param2);
               backButtonCallback();
               break;
            case 1:
               MessageDialog.show(1,GameSetting.getUIText("nameinput.errorcode.invalid"));
               break;
            case 2:
               MessageDialog.show(1,GameSetting.getUIText("nameinput.errorcode.over"));
               break;
            case 3:
               MessageDialog.show(1,GameSetting.getUIText("nameinput.errorcode.zero"));
               break;
            case 4:
               MessageDialog.show(1,GameSetting.getUIText("%openingScene.wrong.playerName"));
         }
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         closeButton.removeEventListener("triggered",triggeredDecideButton);
         closeButton = null;
         nameInput.removeEventListeners();
         nameInput = null;
         txtBlank = null;
         super.dispose();
      }
   }
}
