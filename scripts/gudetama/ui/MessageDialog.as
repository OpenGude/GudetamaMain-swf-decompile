package gudetama.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.TweenAnimator;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   import starling.utils.AssetManager;
   
   public class MessageDialog extends BaseScene
   {
      
      public static const TYPE_MESSAGE:int = 0;
      
      public static const TYPE_MESSAGE_CHECK:int = 1;
      
      public static const TYPE_MESSAGE_CONFIRM:int = 2;
      
      public static const TYPE_MESSAGE_REDRAW:int = 3;
      
      public static const TYPE_MESSAGE_CONNECTION:int = 4;
      
      public static const TYPE_SYSTEMMAIL_URL:int = 5;
      
      public static const TYPE_SYSTEMMAIL_MESSAGE:int = 6;
      
      public static const TYPE_SYSTEMMAIL_REVIEW:int = 7;
      
      public static const TYPE_SYSTEMMAIL_TWITTER:int = 8;
      
      public static const TYPE_ERROR:int = 10;
      
      public static const TYPE_CONNECTION_ERROR:int = 11;
      
      public static const TYPE_CONNECTION_ERROR_ATLOGIN:int = 12;
      
      public static const TYPE_SCENE_TIMEOUT_ERROR:int = 13;
      
      public static const TYPE_SYSTEMMAIL_REVIEW_CONFIRM:int = 15;
      
      public static const TYPE_SYSTEMMAIL_OPINION:int = 16;
      
      public static const TYPE_DAILY_MISSION:int = 17;
      
      public static const TYPE_MESSAGE_NOT_CLOSE:int = 20;
      
      public static const TYPE_MESSAGE_THREE_CHOICES:int = 21;
      
      public static const TYPE_MESSAGE_THREE_CHOICES_TOS:int = 22;
      
      public static const TYPE_MESSAGE_CONFIRM2:int = 23;
      
      public static const TYPE_MESSAGE_REENTER:int = 24;
      
      public static const TYPE_MESSAGE_THREE_CHOICES_CACHE:int = 25;
      
      public static const TYPE_MESSAGE_FORMATION:int = 26;
      
      public static const TYPE_SYSTEMMAIL_URL_WITH_INSTALL:int = 27;
      
      public static const TYPE_COLLECTION:int = 28;
      
      public static const TYPE_COLLECTION_THREE:int = 29;
      
      public static const TYPE_DIALOG_NORMAL:int = 0;
      
      public static const TYPE_DIALOG_WITHIMAGE:int = 1;
      
      public static const RESULT_POSITIVE:int = 0;
      
      public static const RESULT_NEGATIVE:int = 1;
      
      public static const RESULT_FLAT:int = 2;
      
      public static const RESULT_HELP:int = 3;
      
      private static var singleton:MessageDialog;
      
      private static var objectPool:Vector.<Object> = new Vector.<Object>(0);
       
      
      private var show:Boolean;
      
      private var type:int;
      
      private var normaltype:Boolean = true;
      
      private var title:String;
      
      private var message:String;
      
      private var callback:Function;
      
      private var bgType:int;
      
      private var imagePath:String;
      
      private var isImageDialog:Boolean = false;
      
      private var imageBD:BitmapData;
      
      private var titleSprite:Sprite = null;
      
      private var displaySprite:Sprite;
      
      private var displaySpriteDefault:Sprite;
      
      private var displaySpriteInfo:Sprite;
      
      private var displaySpriteInfoImage:Sprite;
      
      private var button0:ContainerButton;
      
      private var button1:ContainerButton;
      
      private var button2:ContainerButton;
      
      private var button0Text:ColorTextField;
      
      private var button1Text:ColorTextField;
      
      private var button2Text:ColorTextField;
      
      private var messageField:ColorTextField;
      
      private var titleField:ColorTextField;
      
      private var image:Image;
      
      private var dialogSprite:Sprite;
      
      private var dialogSpriteDefault:Sprite;
      
      private var dialogSpriteInfo:Sprite;
      
      private var dialogSpriteInfoImage:Sprite;
      
      private var imgFrame:Image;
      
      private var imgMsgBG:Image;
      
      private var spButton:Sprite;
      
      private var orgFrameH:Number;
      
      private var orgMsgBGH:Number;
      
      private var orgMsgH:Number;
      
      private var orgSpButtonY:Number;
      
      private var queueList:Vector.<Object>;
      
      private var button2x:Number;
      
      private var button2y:Number;
      
      private var buttonHelp:ContainerButton;
      
      private var buttonHelpText:ColorTextField;
      
      private var titleText:ColorTextField;
      
      public function MessageDialog()
      {
         super(1);
         queueList = new Vector.<Object>();
         var assetManager:AssetManager = Engine.assetManager;
         Engine.setupLayout(assetManager.getObject("DialogLayout"),function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            displaySpriteDefault = displaySprite;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            dialogSpriteDefault = dialogSprite;
            imgFrame = dialogSprite.getChildByName("imgFrame") as Image;
            imgMsgBG = dialogSprite.getChildByName("imgMsgBG") as Image;
            spButton = dialogSprite.getChildByName("spButton") as Sprite;
            button0 = spButton.getChildByName("btn0") as ContainerButton;
            button0.addEventListener("triggered",function(param1:Event):void
            {
               if(isCloseable())
               {
                  close(0);
               }
            });
            button0Text = button0.getChildByName("text") as ColorTextField;
            button1 = spButton.getChildByName("btn1") as ContainerButton;
            button1.addEventListener("triggered",function(param1:Event):void
            {
               if(isCloseable())
               {
                  close(1);
               }
            });
            button1Text = button1.getChildByName("text") as ColorTextField;
            button2 = spButton.getChildByName("btn2") as ContainerButton;
            button2x = button2.x;
            button2y = button2.y;
            button2.addEventListener("triggered",function(param1:Event):void
            {
               if(isCloseable())
               {
                  close(2);
               }
            });
            button2Text = button2.getChildByName("text") as ColorTextField;
            messageField = dialogSprite.getChildByName("message") as ColorTextField;
            button0 = spButton.getChildByName("btn0") as ContainerButton;
            buttonHelp = dialogSprite.getChildByName("helpbtn") as ContainerButton;
            buttonHelp.addEventListener("triggered",function(param1:Event):void
            {
               if(isCloseable())
               {
                  close(3);
               }
            });
            buttonHelpText = buttonHelp.getChildByName("text") as ColorTextField;
            buttonHelp.visible = false;
            titleText = dialogSprite.getChildByName("title") as ColorTextField;
            titleText.visible = false;
            addChild(displaySprite);
         },1);
         Engine.setupLayout(assetManager.getObject("InformationDialog"),function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            displaySpriteInfo = displaySprite;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            dialogSpriteInfo = dialogSprite;
            imgFrame = dialogSprite.getChildByName("imgFrame") as Image;
            imgMsgBG = dialogSprite.getChildByName("imgMsgBG") as Image;
            spButton = dialogSprite.getChildByName("spButton") as Sprite;
            button0 = spButton.getChildByName("btn0") as ContainerButton;
            button0.addEventListener("triggered",function(param1:Event):void
            {
               if(isCloseable())
               {
                  close(0);
               }
            });
            button0Text = button0.getChildByName("text") as ColorTextField;
            button1 = spButton.getChildByName("btn1") as ContainerButton;
            button1.addEventListener("triggered",function(param1:Event):void
            {
               if(isCloseable())
               {
                  close(1);
               }
            });
            button1Text = button1.getChildByName("text") as ColorTextField;
            messageField = dialogSprite.getChildByName("message") as ColorTextField;
            titleField = dialogSprite.getChildByName("title") as ColorTextField;
            addChild(displaySprite);
         },1);
         Engine.setupLayout(assetManager.getObject("InformationImageDialog"),function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            displaySpriteInfoImage = displaySprite;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            dialogSpriteInfoImage = dialogSprite;
            button0 = dialogSprite.getChildByName("btn0") as ContainerButton;
            button0.addEventListener("triggered",function(param1:Event):void
            {
               if(isCloseable())
               {
                  close(0);
               }
            });
            button0Text = button0.getChildByName("text") as ColorTextField;
            button1 = dialogSprite.getChildByName("btn1") as ContainerButton;
            button1.addEventListener("triggered",function(param1:Event):void
            {
               if(isCloseable())
               {
                  close(1);
               }
            });
            button1Text = button1.getChildByName("text") as ColorTextField;
            button2 = dialogSprite.getChildByName("btn2") as ContainerButton;
            button2.addEventListener("triggered",function(param1:Event):void
            {
               if(isCloseable())
               {
                  close(2);
               }
            });
            button2Text = button2.getChildByName("text") as ColorTextField;
            titleField = dialogSprite.getChildByName("title") as ColorTextField;
            image = dialogSprite.getChildByName("image") as Image;
            addChild(displaySprite);
         },1);
      }
      
      public static function createSingleton() : void
      {
         if(singleton)
         {
            return;
         }
         singleton = new MessageDialog();
      }
      
      public static function clearSingleton() : void
      {
         if(singleton == null)
         {
            return;
         }
         singleton.dispose();
         singleton = null;
      }
      
      public static function show(param1:int, param2:String, param3:Function = null, param4:String = null, param5:int = 0, param6:String = null, param7:Boolean = true) : void
      {
         Engine.unlockTouchInputForce();
         if(singleton.isAvailablePopup())
         {
            singleton.setup(param1,param2,param3,param4,param5,param6,param7);
            singleton.addPopup(singleton,singleton.getBackButtonFunction());
            TweenAnimator.startItself(singleton,"show");
         }
         else
         {
            singleton.pushShowTask(param1,param2,param3,param4,param5,param6,param7);
         }
      }
      
      public static function showWithoutCallback(param1:int, param2:String, param3:String = null, param4:int = 0, param5:String = null, param6:Boolean = true) : void
      {
         if(singleton.isAvailablePopup())
         {
            singleton.setup(param1,param2,null,param3,param4,param5,param6);
            singleton.addPopup(singleton,singleton.getBackButtonFunction());
            TweenAnimator.startItself(singleton,"show");
         }
         else
         {
            singleton.pushShowTask(param1,param2,null,param3,param4,param5,param6);
         }
      }
      
      public static function removeAllStackedDialog() : void
      {
         singleton.queueList.length = 0;
      }
      
      public static function hide(param1:int = 0) : void
      {
         singleton.close(param1);
      }
      
      public static function isShow() : Boolean
      {
         return singleton.show;
      }
      
      private static function fromPool() : Object
      {
         if(objectPool.length)
         {
            return objectPool.pop();
         }
         return {};
      }
      
      private static function toPool(param1:Object) : void
      {
         objectPool.push(param1);
      }
      
      private function setupDefault() : void
      {
         displaySpriteDefault.visible = true;
         displaySpriteInfo.visible = false;
         displaySpriteInfoImage.visible = false;
         displaySprite = displaySpriteDefault;
         dialogSprite = dialogSpriteDefault;
         imgFrame = dialogSprite.getChildByName("imgFrame") as Image;
         imgMsgBG = dialogSprite.getChildByName("imgMsgBG") as Image;
         spButton = dialogSprite.getChildByName("spButton") as Sprite;
         button0 = spButton.getChildByName("btn0") as ContainerButton;
         button0Text = button0.getChildByName("text") as ColorTextField;
         button1 = spButton.getChildByName("btn1") as ContainerButton;
         button1Text = button1.getChildByName("text") as ColorTextField;
         button2 = spButton.getChildByName("btn2") as ContainerButton;
         button2Text = button2.getChildByName("text") as ColorTextField;
         messageField = dialogSprite.getChildByName("message") as ColorTextField;
      }
      
      private function setupInfo() : void
      {
         displaySpriteDefault.visible = false;
         displaySpriteInfo.visible = true;
         displaySpriteInfoImage.visible = false;
         displaySprite = displaySpriteInfo;
         dialogSprite = dialogSpriteInfo;
         imgFrame = dialogSprite.getChildByName("imgFrame") as Image;
         imgMsgBG = dialogSprite.getChildByName("imgMsgBG") as Image;
         spButton = dialogSprite.getChildByName("spButton") as Sprite;
         button0 = spButton.getChildByName("btn0") as ContainerButton;
         button0Text = button0.getChildByName("text") as ColorTextField;
         button1 = spButton.getChildByName("btn1") as ContainerButton;
         button1Text = button1.getChildByName("text") as ColorTextField;
         messageField = dialogSprite.getChildByName("message") as ColorTextField;
         titleField = dialogSprite.getChildByName("title") as ColorTextField;
      }
      
      private function setupInfoImage() : void
      {
         displaySpriteDefault.visible = false;
         displaySpriteInfo.visible = false;
         displaySpriteInfoImage.visible = true;
         displaySprite = displaySpriteInfoImage;
         dialogSprite = dialogSpriteInfoImage;
         button0 = dialogSprite.getChildByName("btn0") as ContainerButton;
         button0Text = button0.getChildByName("text") as ColorTextField;
         button1 = dialogSprite.getChildByName("btn1") as ContainerButton;
         button1Text = button1.getChildByName("text") as ColorTextField;
         button2 = dialogSprite.getChildByName("btn2") as ContainerButton;
         button2Text = button2.getChildByName("text") as ColorTextField;
         titleField = dialogSprite.getChildByName("title") as ColorTextField;
         messageField = dialogSprite.getChildByName("message") as ColorTextField;
         image = dialogSprite.getChildByName("image") as Image;
         if(message && message.length > 0)
         {
            TweenAnimator.startItself(dialogSprite,"withMessage" + (!!isThreeButtonType() ? "Three" : ""));
            messageField.text#2 = message;
            messageField.visible = true;
         }
         else
         {
            TweenAnimator.startItself(dialogSprite,"noMessage" + (!!isThreeButtonType() ? "Three" : ""));
            messageField.text#2 = null;
            messageField.visible = false;
         }
      }
      
      private function close(param1:int) : void
      {
         var result:int = param1;
         TweenAnimator.startItself(singleton,"hide",false,function(param1:DisplayObject):void
         {
            if(callback)
            {
               try
               {
                  callback(result);
               }
               catch(e:Error)
               {
                  Logger.error(e.getStackTrace());
               }
            }
            singleton.removePopup(singleton,false);
            button2.x = button2x;
            button2.y = button2y;
            TweenAnimator.startItself(button2,"def");
            button0.visible = true;
            if(orgFrameH > 0)
            {
               imgFrame.height = orgFrameH;
               orgFrameH = 0;
               imgMsgBG.height = orgMsgBGH;
               messageField.height = orgMsgH;
               spButton.y = orgSpButtonY;
               dialogSprite.alignPivot();
            }
            button0Text.flush();
            button1Text.flush();
            messageField.flush();
            titleField.flush();
            if(image.texture)
            {
               image.texture.dispose();
               image.texture = null;
            }
            image.dispose();
            imageBD = null;
            callback = null;
            dialogSpriteDefault.scale = 1;
            dialogSpriteInfo.scale = 1;
            dialogSpriteInfoImage.scale = 1;
            show = false;
            if(queueList.length > 0)
            {
               popShowTaskAndSetup();
            }
         });
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      public function isAvailablePopup() : Boolean
      {
         return !show && queueList.length == 0;
      }
      
      public function pushShowTask(param1:int, param2:String, param3:Function, param4:String, param5:int, param6:String, param7:Boolean) : void
      {
         var _loc8_:Object;
         (_loc8_ = fromPool()).type = param1;
         _loc8_.message = param2;
         _loc8_.callback = param3;
         _loc8_.title = param4;
         _loc8_.bgType = param5;
         _loc8_.imagePath = param6;
         _loc8_.resize = param7;
         queueList.push(_loc8_);
      }
      
      private function popShowTaskAndSetup() : void
      {
         var _loc1_:Object = queueList.shift();
         setup(_loc1_.type,_loc1_.message,_loc1_.callback,_loc1_.title,_loc1_.bgType,_loc1_.imagePath,_loc1_.resize);
         singleton.addPopup(singleton,singleton.getBackButtonFunction());
         TweenAnimator.startItself(singleton,"show");
         _loc1_.callback = null;
         toPool(_loc1_);
      }
      
      public function setup(param1:int, param2:String, param3:Function, param4:String, param5:int, param6:String, param7:Boolean) : void
      {
         var _type:int = param1;
         var _message:String = param2;
         var _callback:Function = param3;
         var _title:String = param4;
         var _bgType:int = param5;
         var _imagePath:String = param6;
         var _resize:Boolean = param7;
         show = true;
         type = _type;
         message = _message;
         callback = _callback;
         title = _title;
         bgType = _bgType;
         imagePath = _imagePath;
         if(imagePath)
         {
            isImageDialog = true;
            setupInfoImage();
            titleField.text#2 = title;
            if(imagePath.indexOf("://") > 0)
            {
               RsrcManager.getInstance().loadBitmapData(imagePath,function(param1:BitmapData):void
               {
                  imageBD = param1.clone();
                  image.texture = Texture.fromBitmap(new Bitmap(imageBD));
               });
            }
            else
            {
               RsrcManager.loadDialogPicture(imagePath,function(param1:BitmapData):void
               {
                  imageBD = param1.clone();
                  image.texture = Texture.fromBitmap(new Bitmap(imageBD));
               });
            }
         }
         else if(title)
         {
            setupInfo();
            titleField.text#2 = title;
         }
         else
         {
            setupDefault();
         }
         if(imagePath == null)
         {
            messageField.text#2 = message;
         }
         buttonHelp.visible = false;
         titleText.visible = false;
         switch(type)
         {
            case 0:
            case 20:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 1:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.ok");
               break;
            case 2:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.yes");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.no");
               break;
            case 3:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.redraw");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.decide");
               break;
            case 4:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.continue");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.leave");
               break;
            case 21:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.yes");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.no");
               button2Text.text#2 = GameSetting.getUIText("%dialog.button.cancel");
               break;
            case 22:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.tos.yes");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.tos.no");
               button2Text.text#2 = GameSetting.getUIText("%dialog.button.tos");
               break;
            case 5:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.check");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 6:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.ok");
               break;
            case 7:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.review");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 8:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.tweet");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 15:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.enjoy");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.bored");
               break;
            case 16:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.toform");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 10:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.ok");
               break;
            case 11:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.retry");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.totitle");
               break;
            case 12:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.maintenance");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 13:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.continue");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.totitle");
               break;
            case 23:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.yes");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.cancel");
               break;
            case 24:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.yes");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.totitle");
               break;
            case 26:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.formation");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               break;
            case 27:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.check");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               button2Text.text#2 = GameSetting.getUIText("%dialog.button.install");
               break;
            case 28:
               button2Text.text#2 = GameSetting.getUIText("%dialog.button.collection");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.close");
               buttonHelpText.text#2 = GameSetting.getUIText("%dialog.button.helper");
               titleText.text#2 = GameSetting.getUIText("dialog.title.helper");
               buttonHelp.visible = true;
               titleText.visible = true;
               break;
            case 29:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.yes");
               button1Text.text#2 = GameSetting.getUIText("%dialog.button.no");
               button2Text.text#2 = GameSetting.getUIText("%dialog.button.collection");
               buttonHelpText.text#2 = GameSetting.getUIText("%dialog.button.helper");
               titleText.text#2 = GameSetting.getUIText("dialog.title.helper");
               buttonHelp.visible = true;
               titleText.visible = true;
               break;
            default:
               button0Text.text#2 = GameSetting.getUIText("%dialog.button.close");
         }
         if(!isThreeButtonType())
         {
            TweenAnimator.startItself(dialogSprite,"def",false,function():void
            {
               resize(_resize,spButton);
            });
         }
         if(isTwoButtonType() || isThreeButtonType())
         {
            button1.visible = true;
            button2.visible = true;
            var _loc9_:* = Engine;
            if(gudetama.engine.Engine.isIosPlatform() || true)
            {
               TweenAnimator.startItself(button0,"ios");
               TweenAnimator.startItself(button1,"ios");
            }
            else
            {
               TweenAnimator.startItself(button0,"android");
               TweenAnimator.startItself(button1,"android");
            }
            if(type == 28)
            {
               button0.visible = false;
            }
            if(isThreeButtonType())
            {
               TweenAnimator.startItself(dialogSprite,"threeButton",false,function():void
               {
                  resize(_resize,spButton);
               });
            }
            else
            {
               button2.visible = false;
            }
            if(type == 28)
            {
               button0.visible = false;
               TweenAnimator.startItself(button2,"threeButton");
               button2.x = button0.x;
               button2.y = button0.y;
               button2.visible = true;
            }
         }
         else
         {
            button1.visible = false;
            TweenAnimator.startItself(button0,"pos0");
         }
         if(title == null)
         {
            var titleKey:String = "message.title";
            if(type == 10)
            {
               var titleKey:String = titleKey + ".error";
            }
            else if(type == 11 || type == 12 || type == 13)
            {
               titleKey += ".connection.error";
            }
            else if(type == 2)
            {
               titleKey += ".confirm";
            }
         }
      }
      
      private function resize(param1:Boolean, param2:Sprite) : void
      {
         var _loc3_:* = null;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         if(param1 && param2 != null)
         {
            orgMsgH = messageField.height;
            messageField.height = 9999;
            _loc3_ = messageField.textBounds;
            _loc5_ = _loc3_.height + messageField.fontSize;
            if(orgMsgH < _loc5_)
            {
               orgFrameH = imgFrame.height;
               orgMsgBGH = imgMsgBG.height;
               orgSpButtonY = param2.y;
               _loc4_ = _loc5_ - orgMsgH;
               messageField.height = _loc5_;
               imgFrame.height += _loc4_;
               imgMsgBG.height += _loc4_;
               param2.y += _loc4_;
               dialogSprite.alignPivot();
            }
            else
            {
               messageField.height = orgMsgH;
            }
         }
      }
      
      private function getBackButtonFunction() : Function
      {
         if(isTwoButtonType() || isThreeButtonType())
         {
            return function():void
            {
               if(isCloseable())
               {
                  close(1);
               }
            };
         }
         return function():void
         {
            if(isCloseable())
            {
               close(0);
            }
         };
      }
      
      private function isSystemMailType() : Boolean
      {
         return type == 5 || type == 6 || type == 7 || type == 8 || type == 15 || type == 16 || type == 28;
      }
      
      private function isErrorType() : Boolean
      {
         return type == 10 || type == 11 || type == 12 || type == 13;
      }
      
      private function isErrorTypeToTitle() : Boolean
      {
         return type == 11 || type == 13;
      }
      
      private function isTwoButtonType() : Boolean
      {
         return type == 2 || type == 5 || type == 7 || type == 8 || type == 15 || type == 16 || type == 11 || type == 12 || type == 13 || type == 4 || type == 23 || type == 24 || type == 26 || type == 28;
      }
      
      private function isThreeButtonType() : Boolean
      {
         return type == 21 || type == 22 || type == 27 || type == 29;
      }
      
      private function isCloseable() : Boolean
      {
         return type != 20;
      }
   }
}
