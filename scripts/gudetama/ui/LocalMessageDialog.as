package gudetama.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class LocalMessageDialog extends BaseScene
   {
      
      public static const TYPE_MESSAGE:int = 0;
      
      public static const TYPE_MESSAGE_CONFIRM:int = 1;
      
      public static const TYPE_MESSAGE_YES:int = 2;
      
      public static const TYPE_MESSAGE_PERMISSION_CONFIG:int = 3;
      
      public static const TYPE_MESSAGE_SCREEN_RECORD:int = 4;
      
      public static const TYPE_CONTINUE:int = 5;
      
      public static const TYPE_SYSTEMMAIL_REVIEW_CONFIRM:int = 6;
      
      public static const TYPE_SYSTEMMAIL_REVIEW:int = 7;
      
      public static const TYPE_SYSTEMMAIL_OPINION:int = 8;
      
      public static const TYPE_MESSAGE_CLOSE:int = 9;
      
      public static const TYPE_MESSAGE_CONFIRM_MISSION:int = 10;
      
      public static const TYPE_NOT_SHOW:int = 11;
      
      public static const TYPE_MESSAGE_CONFIRM_PREMIUM:int = 12;
      
      public static const TYPE_MESSAGE_SHARE:int = 13;
      
      public static const TYPE_MESSAGE_CONFIRM_PRESENT_DEL:int = 14;
      
      public static const RESULT_POSITIVE:int = 0;
      
      public static const RESULT_NEGATIVE:int = 1;
      
      public static const RESULT_FLAT:int = 2;
      
      private static const DEFAULT_BTN_WIDTH:int = 161;
      
      private static const DEFAULT_TEXT_WIDTH:int = 141;
       
      
      private var type:int;
      
      private var message:String;
      
      private var callback:Function;
      
      private var title:String;
      
      private var dialogSprite:Sprite;
      
      private var titleText:ColorTextField;
      
      private var messageText:ColorTextField;
      
      private var buttonSprite:Sprite;
      
      private var button0:ContainerButton;
      
      private var buttonWidth:Number;
      
      private var button1:ContainerButton;
      
      private var button2:ContainerButton;
      
      private var button0Text:ColorTextField;
      
      private var button1Text:ColorTextField;
      
      private var button2Text:ColorTextField;
      
      private var frameImage:Image;
      
      private var titleBgImage:Image;
      
      private var image:Image;
      
      private var closeTexture:Texture;
      
      private var orangeTexture:Texture;
      
      private var redTexture:Texture;
      
      private var yellowTexture:Texture;
      
      private var choose:int = 1;
      
      private var state:int;
      
      private var imagePath:String;
      
      private var noFrame:Boolean;
      
      private var frame:Image;
      
      private var messageBgMat:Image;
      
      private var defaultData:Object;
      
      private var loadCount:int;
      
      private var bitmapData:BitmapData;
      
      private var originalMessageHeight:Number;
      
      private var originalImageWidth:Number;
      
      private var originalImageHeight:Number;
      
      public function LocalMessageDialog(param1:int, param2:String, param3:Function, param4:String, param5:int, param6:*, param7:Boolean)
      {
         super(2);
         this.type = param1;
         this.message = param2;
         this.callback = param3;
         this.title = param4;
         this.state = param5;
         this.imagePath = param6;
         this.noFrame = param7;
      }
      
      public static function show(param1:int, param2:String, param3:Function = null, param4:String = null, param5:int = 94, param6:String = null, param7:Boolean = false) : void
      {
         Engine.pushScene(new LocalMessageDialog(param1,param2,param3,param4,param5,param6,param7),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,!!imagePath ? "LocalImageDialog" : "LocalMessageDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            frameImage = dialogSprite.getChildByName("frame") as Image;
            titleBgImage = dialogSprite.getChildByName("titleBg") as Image;
            image = dialogSprite.getChildByName("image") as Image;
            if(image)
            {
               originalImageWidth = image.width;
               originalImageHeight = image.height;
            }
            titleText = dialogSprite.getChildByName("title") as ColorTextField;
            messageText = dialogSprite.getChildByName("message") as ColorTextField;
            originalMessageHeight = messageText.height;
            messageText.autoSize = "vertical";
            buttonSprite = dialogSprite.getChildByName("buttonSprite") as Sprite;
            button0 = buttonSprite.getChildByName("btn0") as ContainerButton;
            button0.addEventListener("triggered",triggeredPositiveButton);
            buttonWidth = button0.width;
            button1 = buttonSprite.getChildByName("btn1") as ContainerButton;
            button1.addEventListener("triggered",triggeredNegativeButton);
            button2 = buttonSprite.getChildByName("btn2") as ContainerButton;
            button2.addEventListener("triggered",triggeredFlatButton);
            button0Text = button0.getChildByName("text") as ColorTextField;
            button1Text = button1.getChildByName("text") as ColorTextField;
            button2Text = button2.getChildByName("text") as ColorTextField;
            frame = dialogSprite.getChildByName("frame") as Image;
            messageBgMat = dialogSprite.getChildByName("message_mat") as Image;
            defaultData = {};
            defaultData.messageBgHeight = messageBgMat.height;
            defaultData.frameHeight = frame.height;
            defaultData.messageTextY = messageText.y;
            defaultData.dialogY = dialogSprite.y;
            defaultData.buttonSpriteY = buttonSprite.y;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         addTask(function():void
         {
            TextureCollector.loadTexture("common1@btn_green",function(param1:Texture):void
            {
               closeTexture = param1;
               taskDone();
            });
         });
         addTask(function():void
         {
            TextureCollector.loadTexture("common1@btn_orange",function(param1:Texture):void
            {
               orangeTexture = param1;
               taskDone();
            });
         });
         addTask(function():void
         {
            TextureCollector.loadTexture("common1@btn_red",function(param1:Texture):void
            {
               redTexture = param1;
               taskDone();
            });
         });
         addTask(function():void
         {
            TextureCollector.loadTexture("common1@btn_yellow",function(param1:Texture):void
            {
               yellowTexture = param1;
               taskDone();
            });
         });
         if(imagePath)
         {
            if(imagePath.indexOf("://") > 0)
            {
               addTask(function():void
               {
                  RsrcManager.getInstance().loadBitmapData(imagePath,function(param1:BitmapData):void
                  {
                     bitmapData = param1;
                     taskDone();
                  });
               });
            }
            else
            {
               addTask(function():void
               {
                  RsrcManager.loadDialogPicture(imagePath,function(param1:BitmapData):void
                  {
                     bitmapData = param1;
                     taskDone();
                  });
               });
            }
         }
         queue.registerOnProgress(function(param1:Number):void
         {
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
         titleText.text#2 = !!title ? title : "";
         messageText.text#2 = !!message ? message : "";
         if(message && message.length > 0)
         {
            var tween:Boolean = TweenAnimator.startItself(dialogSprite,"withMessage" + (!!isThreeButtonType() ? "Three" : ""));
            messageText.text#2 = message;
            messageText.visible = true;
         }
         else
         {
            TweenAnimator.startItself(dialogSprite,"noMessage" + (!!isThreeButtonType() ? "Three" : ""));
            messageText.text#2 = null;
            messageText.visible = false;
         }
         TweenAnimator.finishItself(dialogSprite);
         if(bitmapData)
         {
            image.texture = Texture.fromBitmap(new Bitmap(bitmapData));
            image.width = bitmapData.width;
            image.height = bitmapData.height;
            image.x = 0.5 * dialogSprite.width - 0.5 * image.width;
            bitmapData = null;
         }
         if(noFrame)
         {
            frameImage.visible = false;
            titleBgImage.visible = false;
            titleText.visible = false;
         }
         var offsetBtnWidth:Number = 0;
         button0.width = buttonWidth;
         button0Text.width = buttonWidth - 20;
         switch(int(type))
         {
            case 0:
               button0.background = closeTexture;
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.ok");
               break;
            case 1:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.yes");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.no");
               break;
            case 2:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.yes");
               break;
            case 3:
               button0.background = orangeTexture;
               button1.background = closeTexture;
               button0Text.text#2 = GameSetting.getUIText("%ar.btn.config");
               button1Text.text#2 = GameSetting.getUIText("%common.button.close");
               break;
            case 4:
               button0.background = redTexture;
               button0Text.text#2 = GameSetting.getUIText("%ar.btn.screenRecord");
               button0.width = 161 + 30;
               button0Text.width = 141 + 30;
               break;
            case 5:
               button0Text.text#2 = GameSetting.getInitUIText("common.continue");
               button1Text.text#2 = GameSetting.getInitUIText("%common.button.close");
               break;
            case 6:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.enjoy");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.bored");
               break;
            case 7:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.review");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 8:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.toform");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 9:
               button0.background = closeTexture;
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 10:
               button0.width = buttonWidth + 50;
               button0Text.width = buttonWidth + 30;
               button1.background = closeTexture;
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.mission");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 12:
               button0Text.text#2 = GameSetting.getUIText("%shop.metal.buy");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 13:
               button2.background = yellowTexture;
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.check");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               button2Text.text#2 = GameSetting.getUIText("%ar.btn.share");
               break;
            case 14:
               button2.background = yellowTexture;
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.del");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
         }
         if(isTwoButtonType() || isThreeButtonType())
         {
            button1.visible = true;
            button2.visible = isThreeButtonType();
            var _loc2_:* = Engine;
            if(gudetama.engine.Engine.isIosPlatform() || true)
            {
               TweenAnimator.startItself(button0,"ios");
               TweenAnimator.startItself(button1,"ios");
               TweenAnimator.finishItself(button0);
               TweenAnimator.finishItself(button1);
               if(type == 10)
               {
                  button0.x = button0.x - 50 + 15;
                  button1.x -= 15;
               }
            }
            else
            {
               TweenAnimator.startItself(button0,"android");
               TweenAnimator.startItself(button1,"android");
               TweenAnimator.finishItself(button0);
               TweenAnimator.finishItself(button1);
            }
         }
         else
         {
            button1.visible = false;
            button2.visible = false;
            TweenAnimator.startItself(button0,"pos0",false,function(param1:DisplayObject):void
            {
               if(type == 4)
               {
                  button0.x -= 15;
               }
            });
         }
         if(!isThreeButtonType())
         {
            button2.y = 0;
         }
         calcHeight();
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(LocalMessageDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(state);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LocalMessageDialog);
            if(type == 10)
            {
               if(resumeNoticeTutorial(21,noticeTutorialAction,getGuideArrowPos))
               {
                  button1.touchable = false;
                  setBackButtonCallback(null);
                  setVisibleState(state & ~8);
               }
            }
         });
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         return GudetamaUtil.getCenterPosAndWHOnEngine(button0);
      }
      
      private function isTwoButtonType() : Boolean
      {
         return type == 1 || type == 3 || type == 5 || type == 6 || type == 7 || type == 8 || type == 10 || type == 12 || type == 14;
      }
      
      private function isThreeButtonType() : Boolean
      {
         return type == 13;
      }
      
      private function triggeredPositiveButton(param1:Event) : void
      {
         choose = 0;
         backButtonCallback();
      }
      
      private function triggeredNegativeButton(param1:Event) : void
      {
         choose = 1;
         backButtonCallback();
      }
      
      private function triggeredFlatButton(param1:Event) : void
      {
         choose = 2;
         backButtonCallback();
      }
      
      private function calcHeight() : void
      {
         var _loc1_:Number = NaN;
         messageText.y = 0;
         if(image)
         {
            _loc1_ = image.height - originalImageHeight;
            if(_loc1_ > 0)
            {
               frame.height += _loc1_;
               messageBgMat.y += _loc1_;
               messageText.y += _loc1_;
               buttonSprite.y += _loc1_;
            }
         }
         if(messageText.visible)
         {
            _loc1_ = messageText.height + 16 - originalMessageHeight;
            if(_loc1_ > 0)
            {
               frame.height += _loc1_;
               messageBgMat.height += _loc1_;
               buttonSprite.y += _loc1_;
            }
            messageText.y += defaultData.messageTextY + 0.5 * (messageBgMat.height - messageText.height);
         }
         else
         {
            frame.height -= originalMessageHeight;
         }
         _loc1_ = buttonSprite.height - button0.height;
         if(_loc1_ > 0)
         {
            frame.height += _loc1_;
         }
         dialogSprite.alignPivot();
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(LocalMessageDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LocalMessageDialog);
            button0.width = 161;
            button0Text.width = 141;
            Engine.popScene(scene);
            if(callback)
            {
               callback(choose);
            }
         });
      }
      
      override public function dispose() : void
      {
         message = null;
         title = null;
         titleText = null;
         messageText = null;
         button0.removeEventListener("triggered",triggeredPositiveButton);
         button0 = null;
         button1.removeEventListener("triggered",triggeredNegativeButton);
         button1 = null;
         button0Text = null;
         button1Text = null;
         closeTexture = null;
         super.dispose();
      }
   }
}
