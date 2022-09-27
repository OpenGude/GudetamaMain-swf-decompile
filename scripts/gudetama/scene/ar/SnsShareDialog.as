package gudetama.scene.ar
{
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.escapeMultiByte;
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.NativeExtensions;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.Packet;
   import gudetama.data.compati.ShareBonusDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.BulkItemResultDialog;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class SnsShareDialog extends BaseScene
   {
       
      
      private var title:ColorTextField;
      
      private var message:ColorTextField;
      
      private var btnSnsSpriteW:Number;
      
      private var btnSns1:SimpleImageButton;
      
      private var btnSns2:SimpleImageButton;
      
      private var btnSns3:SimpleImageButton;
      
      private var btnSns4:SimpleImageButton;
      
      private var btnSns5:SimpleImageButton;
      
      private var texSnsFacebook:Texture;
      
      private var texSnsTwitter:Texture;
      
      private var texSnsInsta:Texture;
      
      private var texSnsLine:Texture;
      
      private var texSnsKakao:Texture;
      
      private var texSnsPlurk:Texture;
      
      private var texSnsWeibo:Texture;
      
      private var texSnsWeixin:Texture;
      
      private var eggImage:Image;
      
      private var closeBtn:ContainerButton;
      
      private var shareBitmapData:BitmapData;
      
      private var shareBonusItem:ItemParam;
      
      private var closeCallback:Function;
      
      private var withSave:Boolean;
      
      private var shareType:int;
      
      private var optionMsg:String;
      
      private var shareResourcePath:String;
      
      private var shareRecommendMessage:String;
      
      private var argi:int;
      
      private var shareBonusDef:ShareBonusDef;
      
      private var waitingShareBonusId:int;
      
      private var selectSns:int;
      
      private var dialogSprite:Sprite;
      
      private var imgFrame:Image;
      
      private var imgMsgBG:Image;
      
      private var spButton:Sprite;
      
      private var orgFrameH:Number;
      
      private var orgMsgBGH:Number;
      
      private var orgMsgH:Number;
      
      private var orgSpButtonY:Number;
      
      private var response:Array;
      
      private var sharedAR:Boolean;
      
      public function SnsShareDialog(param1:BitmapData, param2:String, param3:int, param4:ItemParam, param5:Boolean, param6:Function, param7:String, param8:int = 0, param9:ShareBonusDef = null, param10:int = 0)
      {
         var _loc11_:int = 0;
         if(param3 == -1 || param3 == 1)
         {
            _loc11_ = 2;
         }
         else
         {
            _loc11_ = 1;
         }
         super(_loc11_);
         this.shareBitmapData = param1;
         this.shareBonusItem = param4;
         this.withSave = param5;
         this.closeCallback = param6;
         this.shareType = param3;
         this.optionMsg = param7;
         this.shareResourcePath = param2;
         this.argi = param8;
         this.shareBonusDef = param9;
         this.waitingShareBonusId = param10;
         BannerAdvertisingManager.visibleBanner(false);
      }
      
      public static function show(param1:BitmapData, param2:int, param3:Boolean = false, param4:Function = null, param5:String = null, param6:int = 0) : void
      {
         var shareBitmapData:BitmapData = param1;
         var shareType:int = param2;
         var withSave:Boolean = param3;
         var closeCallback:Function = param4;
         var optionMsg:String = param5;
         var argi:int = param6;
         Engine.lockTouchInput(SnsShareDialog);
         if(shareType == 0 || shareType == 4)
         {
            var event:int = 218;
         }
         else if(shareType == 2)
         {
            event = 16777448;
         }
         else if(shareType == 5)
         {
            event = 247;
         }
         else if(shareType == 3 || shareType == 1)
         {
            event = 0;
         }
         if(event == 0)
         {
            Engine.unlockTouchInput(SnsShareDialog);
            Engine.pushScene(new SnsShareDialog(shareBitmapData,null,shareType,null,withSave,closeCallback,optionMsg));
            return;
         }
         var packet:Packet = PacketUtil.createWithInt(event,argi);
         var _loc8_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(packet,function(param1:Object):void
         {
            Engine.unlockTouchInput(SnsShareDialog);
            var _loc2_:ItemParam = null;
            var _loc4_:ShareBonusDef = null;
            var _loc3_:int = 0;
            if(param1)
            {
               if(param1[0] is ItemParam)
               {
                  _loc2_ = param1[0];
               }
               else
               {
                  _loc4_ = GameSetting.getShareBonus(param1[0]);
                  if(param1.length >= 2)
                  {
                     _loc3_ = param1[1];
                  }
               }
            }
            Engine.pushScene(new SnsShareDialog(shareBitmapData,null,shareType,_loc2_,withSave,closeCallback,optionMsg,argi,_loc4_,_loc3_));
         });
      }
      
      public static function showShareVideo(param1:String, param2:int, param3:Boolean = false, param4:Function = null, param5:String = null) : void
      {
         var shareResourcePath:String = param1;
         var shareType:int = param2;
         var withSave:Boolean = param3;
         var closeCallback:Function = param4;
         var optionMsg:String = param5;
         var packet:Packet = PacketUtil.create(218);
         var _loc7_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(packet,function(param1:Object):void
         {
            Engine.unlockTouchInput(SnsShareDialog);
            var _loc2_:ItemParam = !!param1 ? param1[0] as ItemParam : null;
            Engine.pushScene(new SnsShareDialog(null,shareResourcePath,shareType,_loc2_,withSave,closeCallback,optionMsg));
         });
      }
      
      public static function showShareBonus(param1:ItemParam, param2:String, param3:Function = null) : void
      {
         var _loc4_:SnsShareDialog;
         (_loc4_ = new SnsShareDialog(null,null,-1,param1,false,param3,null)).shareRecommendMessage = StringUtil.format(param2,GudetamaUtil.getItemParamName(param1),GudetamaUtil.getItemParamNum(param1));
         Engine.pushScene(_loc4_);
      }
      
      override public function dispose() : void
      {
         BannerAdvertisingManager.visibleBanner(true);
         if(shareBitmapData)
         {
            shareBitmapData.dispose();
            shareBitmapData = null;
         }
         super.dispose();
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"SnsShareDialogLayout",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object as Sprite;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            eggImage = dialogSprite.getChildByName("eggImage") as Image;
            title = dialogSprite.getChildByName("title") as ColorTextField;
            var shareSprite:Sprite = dialogSprite.getChildByName("sprite") as Sprite;
            message = shareSprite.getChildByName("message") as ColorTextField;
            var shareButtonSprite:Sprite = shareSprite.getChildByName("sprite") as Sprite;
            var snsButtonSprite:Sprite = shareButtonSprite.getChildByName("snsButtonSprite") as Sprite;
            btnSnsSpriteW = snsButtonSprite.width;
            btnSns1 = snsButtonSprite.getChildByName("btnSns1") as SimpleImageButton;
            btnSns1.addEventListener("triggered",triggeredSns1);
            btnSns2 = snsButtonSprite.getChildByName("btnSns2") as SimpleImageButton;
            btnSns2.addEventListener("triggered",triggeredSns2);
            btnSns3 = snsButtonSprite.getChildByName("btnSns3") as SimpleImageButton;
            btnSns3.addEventListener("triggered",triggeredSns3);
            btnSns4 = snsButtonSprite.getChildByName("btnSns4") as SimpleImageButton;
            btnSns4.addEventListener("triggered",triggeredSns4);
            btnSns5 = snsButtonSprite.getChildByName("btnSns5") as SimpleImageButton;
            btnSns5.addEventListener("triggered",triggeredSns5);
            closeBtn = shareButtonSprite.getChildByName("closeBtn") as ContainerButton;
            closeBtn.addEventListener("triggered",triggeredCloseBtn);
            imgFrame = dialogSprite.getChildByName("frame_mat") as Image;
            imgMsgBG = (dialogSprite.getChildByName("sprite") as Sprite).getChildByName("message_mat") as Image;
            spButton = (dialogSprite.getChildByName("sprite") as Sprite).getChildByName("sprite") as Sprite;
            if(shareBonusItem && shareType == -1)
            {
               title.text#2 = GameSetting.getUIText("ar.shareBonus.title");
               message.text#2 = shareRecommendMessage;
               eggImage.visible = true;
               snsButtonSprite.visible = snsButtonSprite.touchable = false;
            }
            else if(shareBonusItem)
            {
               var msg:String = GameSetting.getUIText("ar.shareBonus.msg");
               message.text#2 = "";
               if(withSave)
               {
                  var shareResource:String = shareType == 1 ? "ar.save.video" : "ar.save.image";
                  var _loc4_:* = Engine;
                  message.text#2 = StringUtil.format(GameSetting.getUIText("ar.save.msg"),GameSetting.getUIText(shareResource),GameSetting.getUIText("%ar.savedImage.locate." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android")))) + "\n\n";
               }
               message.text#2 += StringUtil.format(msg,GudetamaUtil.getItemParamName(shareBonusItem),GudetamaUtil.getItemParamNum(shareBonusItem));
               title.text#2 = GameSetting.getUIText("ar.shareBonus.title");
               eggImage.visible = true;
            }
            else if(shareBonusDef)
            {
               if(GudetamaUtil.isAlternativeItem(shareBonusDef.item))
               {
                  msg = shareBonusDef.alternativeMessage;
                  if(msg.charAt(0) == "?")
                  {
                     msg = shareBonusDef.message;
                  }
               }
               else
               {
                  msg = shareBonusDef.message;
               }
               if(msg.charAt(0) == "?")
               {
                  msg = GameSetting.getUIText("ar.shareBonus.msg");
               }
               message.text#2 = "";
               if(withSave)
               {
                  shareResource = shareType == 1 ? "ar.save.video" : "ar.save.image";
                  var _loc5_:* = Engine;
                  message.text#2 = StringUtil.format(GameSetting.getUIText("ar.save.msg"),GameSetting.getUIText(shareResource),GameSetting.getUIText("%ar.savedImage.locate." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android")))) + "\n\n";
               }
               message.text#2 += StringUtil.format(msg,GudetamaUtil.getItemParamName(shareBonusDef.item),GudetamaUtil.getItemParamNum(shareBonusDef.item));
               title.text#2 = GameSetting.getUIText("ar.shareBonus.title");
               eggImage.visible = true;
               if(shareBonusDef.item)
               {
                  queue.addTask(function():void
                  {
                     TextureCollector.loadTexture(GudetamaUtil.getItemImageName(shareBonusDef.item.kind,shareBonusDef.item.id#2),function(param1:Texture):void
                     {
                        eggImage.texture = param1;
                        queue.taskDone();
                     });
                  });
               }
            }
            else
            {
               updateNoShareBonusLayout();
            }
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         var locale:String = Engine.getLocale();
         TextureCollector.loadTextureForTask(queue,"ar0@btn_fb",function(param1:Texture):void
         {
            texSnsFacebook = param1;
         });
         TextureCollector.loadTextureForTask(queue,"ar0@btn_twitter",function(param1:Texture):void
         {
            texSnsTwitter = param1;
         });
         TextureCollector.loadTextureForTask(queue,"ar0@btn_instagram",function(param1:Texture):void
         {
            texSnsInsta = param1;
         });
         if(locale == "ja" || locale == "tw")
         {
            TextureCollector.loadTextureForTask(queue,"ar0@btn_line",function(param1:Texture):void
            {
               texSnsLine = param1;
            });
         }
         if(locale == "ko")
         {
            TextureCollector.loadTextureForTask(queue,"ar0@btn_kakao",function(param1:Texture):void
            {
               texSnsKakao = param1;
            });
         }
         if(locale == "tw")
         {
            TextureCollector.loadTextureForTask(queue,"ar0@btn_plurk",function(param1:Texture):void
            {
               texSnsPlurk = param1;
            });
         }
         if(locale == "cn")
         {
            TextureCollector.loadTextureForTask(queue,"ar0@btn_weibo",function(param1:Texture):void
            {
               texSnsWeibo = param1;
            });
            TextureCollector.loadTextureForTask(queue,"ar0@btn_wechat",function(param1:Texture):void
            {
               texSnsWeixin = param1;
            });
         }
         queue.registerOnProgress(function(param1:Number):void
         {
            var _loc2_:int = 0;
            var _loc3_:Number = NaN;
            var _loc5_:Number = NaN;
            var _loc4_:* = NaN;
            if(param1 < 1)
            {
               return;
            }
            switch(Engine.getLocale())
            {
               case "ja":
                  _loc2_ = 4;
                  btnSns1.texture = texSnsTwitter;
                  btnSns2.texture = texSnsInsta;
                  btnSns3.texture = texSnsLine;
                  btnSns4.texture = texSnsFacebook;
                  btnSns5.visible = false;
                  break;
               case "ko":
                  _loc2_ = 4;
                  btnSns1.texture = texSnsFacebook;
                  btnSns2.texture = texSnsInsta;
                  btnSns3.texture = texSnsKakao;
                  btnSns4.texture = texSnsTwitter;
                  btnSns5.visible = false;
                  break;
               case "tw":
                  _loc2_ = 5;
                  btnSns1.texture = texSnsPlurk;
                  btnSns2.texture = texSnsFacebook;
                  btnSns3.texture = texSnsInsta;
                  btnSns4.texture = texSnsLine;
                  btnSns5.texture = texSnsTwitter;
                  break;
               case "cn":
                  _loc2_ = 5;
                  btnSns1.texture = texSnsInsta;
                  btnSns2.texture = texSnsWeixin;
                  btnSns3.texture = texSnsFacebook;
                  btnSns4.texture = texSnsWeibo;
                  btnSns5.texture = texSnsTwitter;
                  break;
               case "en":
               default:
                  _loc2_ = 3;
                  btnSns1.texture = texSnsTwitter;
                  btnSns2.texture = texSnsInsta;
                  btnSns3.texture = texSnsFacebook;
                  btnSns4.visible = false;
                  btnSns5.visible = false;
            }
            if(_loc2_ < 5)
            {
               _loc3_ = btnSns1.width;
               _loc4_ = _loc5_ = (btnSnsSpriteW - _loc3_ * _loc2_) / (_loc2_ + 1);
               btnSns1.x = _loc4_;
               _loc4_ += _loc3_ + _loc5_;
               btnSns2.x = _loc4_;
               _loc4_ += _loc3_ + _loc5_;
               btnSns3.x = _loc4_;
               if(_loc2_ >= 4)
               {
                  _loc4_ += _loc3_ + _loc5_;
                  btnSns4.x = _loc4_;
               }
            }
         });
         queue.startTask(onProgress);
      }
      
      private function updateNoShareBonusLayout() : void
      {
         var _loc1_:* = null;
         message.text#2 = "";
         if(withSave)
         {
            _loc1_ = shareType == 1 ? "ar.save.video" : "ar.save.image";
            var _loc2_:* = Engine;
            message.text#2 = StringUtil.format(GameSetting.getUIText("ar.save.msg"),GameSetting.getUIText(_loc1_),GameSetting.getUIText("%ar.savedImage.locate." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android")))) + "\n\n";
         }
         message.text#2 += GameSetting.getUIText("ar.share.msg");
         title.text#2 = GameSetting.getUIText("ar.share.title");
         eggImage.visible = false;
      }
      
      override protected function addedToContainer() : void
      {
         initTween(function():void
         {
            displaySprite.visible = true;
            TweenAnimator.startItself(displaySprite,"show");
         });
         setBackButtonCallback(function():void
         {
            triggeredCloseBtn(null);
         });
      }
      
      private function initTween(param1:Function) : void
      {
         var callback:Function = param1;
         var twname:String = shareBonusItem || shareBonusDef ? "bonus" : "default";
         if(withSave)
         {
            var twname:String = twname + "WithSave";
         }
         if(shareType == -1)
         {
            twname += "Message";
         }
         TweenAnimator.startItself(displaySprite,twname,false,function(param1:DisplayObject):void
         {
            if(callback != null)
            {
               callback();
            }
            resize();
         });
      }
      
      private function resize() : void
      {
         var _loc2_:Number = NaN;
         orgMsgH = message.height;
         message.height = 9999;
         var _loc1_:Rectangle = message.textBounds;
         var _loc3_:Number = _loc1_.height + message.fontSize;
         if(orgMsgH < _loc3_)
         {
            orgFrameH = imgFrame.height;
            orgMsgBGH = imgMsgBG.height;
            orgSpButtonY = spButton.y;
            _loc2_ = _loc3_ - orgMsgH;
            message.height = _loc3_;
            imgFrame.height += _loc2_;
            imgMsgBG.height += _loc2_;
            spButton.y += _loc2_;
            dialogSprite.alignPivot();
         }
         else
         {
            message.height = orgMsgH;
         }
      }
      
      private function triggeredSns1(param1:Event) : void
      {
         switch(Engine.getLocale())
         {
            case "ja":
               triggeredTwitterBtn(param1);
               break;
            case "en":
               triggeredFacebookBtn(param1);
               break;
            case "ko":
               procSimpleSnsShare(5);
               break;
            case "tw":
               triggeredInstagramBtn(param1);
               break;
            case "cn":
         }
      }
      
      private function triggeredSns2(param1:Event) : void
      {
         switch(Engine.getLocale())
         {
            case "ja":
            case "en":
               triggeredInstagramBtn(param1);
               break;
            case "ko":
               triggeredFacebookBtn(param1);
               break;
            case "tw":
               procSimpleSnsShare(7);
               break;
            case "cn":
         }
      }
      
      private function triggeredSns3(param1:Event) : void
      {
         switch(Engine.getLocale())
         {
            case "ja":
               triggeredLineBtn(param1);
               break;
            case "en":
               triggeredFacebookBtn(param1);
               break;
            case "cn":
               procSimpleSnsShare(4);
               break;
            case "ko":
               triggeredInstagramBtn(param1);
               break;
            case "tw":
         }
      }
      
      private function triggeredSns4(param1:Event) : void
      {
         switch(Engine.getLocale())
         {
            case "ja":
               triggeredFacebookBtn(param1);
               break;
            case "ko":
               triggeredTwitterBtn(param1);
               break;
            case "tw":
               triggeredLineBtn(param1);
               break;
            case "cn":
               procSimpleSnsShare(6);
         }
      }
      
      private function triggeredSns5(param1:Event) : void
      {
         switch(Engine.getLocale())
         {
            case "tw":
               triggeredTwitterBtn(param1);
               break;
            case "cn":
         }
      }
      
      private function triggeredTwitterBtn(param1:Event) : void
      {
         var event:Event = param1;
         if(procSnsShareByPC())
         {
            return;
         }
         selectSns = 0;
         sendShareRequest(function():void
         {
            if(shareResourcePath)
            {
               var _loc1_:* = Engine;
               if(gudetama.engine.Engine.platform == 0)
               {
                  var url:String = GameSetting.getUIText("url.twitter").replace("%1",escapeMultiByte(getSnsMessage(0)));
                  navigateToURL(new URLRequest(url),"_self");
               }
               else
               {
                  var _loc3_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.arExt.shareScreenRecording(shareResourcePath,getSnsMessage(0));
               }
               sharedAR = true;
            }
            else
            {
               var _loc4_:* = Engine;
               if(gudetama.engine.Engine.platform == 0)
               {
                  var _loc5_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.shareExt.setSharedCallback(processSharedCallback);
               }
               var _loc6_:* = NativeExtensions;
               gudetama.common.NativeExtensions.shareExt.showShareBitmapData(shareBitmapData,getSnsMessage(0),function():void
               {
                  sharedAR = true;
               });
            }
         });
      }
      
      private function triggeredInstagramBtn(param1:Event) : void
      {
         var event:Event = param1;
         if(procSnsShareByPC())
         {
            return;
         }
         selectSns = 1;
         sendShareRequest(function():void
         {
            if(shareResourcePath)
            {
               var _loc1_:* = Engine;
               if(gudetama.engine.Engine.platform == 0)
               {
                  var url:String = GameSetting.getUIText("url.instagram");
                  navigateToURL(new URLRequest(url),"_self");
               }
               else
               {
                  var _loc3_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.arExt.shareScreenRecording(shareResourcePath,getSnsMessage(1));
               }
               sharedAR = true;
            }
            else
            {
               var _loc4_:* = Engine;
               if(gudetama.engine.Engine.platform == 0)
               {
                  var _loc5_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.shareExt.setSharedCallback(processSharedCallback);
                  var _loc6_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.shareExt.showShareBitmapData(shareBitmapData,null,function():void
                  {
                     sharedAR = true;
                  });
               }
               else
               {
                  var _loc7_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.shareExt.showShareBitmapData(shareBitmapData,getSnsMessage(1),function():void
                  {
                     sharedAR = true;
                  });
               }
            }
         });
      }
      
      private function triggeredLineBtn(param1:Event) : void
      {
         procSimpleSnsShare(2);
      }
      
      private function triggeredFacebookBtn(param1:Event) : void
      {
         procSimpleSnsShare(3);
      }
      
      private function procSimpleSnsShare(param1:int) : void
      {
         var snsType:int = param1;
         if(procSnsShareByPC())
         {
            return;
         }
         selectSns = snsType;
         sendShareRequest(function():void
         {
            if(shareResourcePath)
            {
               var _loc1_:* = Engine;
               if(gudetama.engine.Engine.platform == 0)
               {
                  var _loc2_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.shareExt.setSharedCallback(processSharedCallback);
               }
               var _loc3_:* = NativeExtensions;
               gudetama.common.NativeExtensions.arExt.shareScreenRecording(shareResourcePath,getSnsMessage(snsType));
               sharedAR = true;
            }
            else
            {
               var _loc4_:* = Engine;
               if(gudetama.engine.Engine.platform == 0)
               {
                  var _loc5_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.shareExt.setSharedCallback(processSharedCallback);
               }
               var _loc6_:* = NativeExtensions;
               gudetama.common.NativeExtensions.shareExt.showShareBitmapData(shareBitmapData,getSnsMessage(snsType),function():void
               {
                  sharedAR = true;
               });
            }
         });
      }
      
      private function sendShareRequest(param1:Function) : void
      {
         var callback:Function = param1;
         if(GameSetting.getRule().snsShareBonusType != 1)
         {
            callback();
            return;
         }
         if(response)
         {
            return;
         }
         var event:int = 236;
         if(shareType == 0 || shareType == 4)
         {
            event = 217;
         }
         else if(shareType == 2)
         {
            event = 16777450;
         }
         else if(shareType == 5)
         {
            event = 248;
         }
         else if(shareType == 1)
         {
            event = 217;
         }
         else if(shareType == 6)
         {
            event = 217;
         }
         var packet:Packet = PacketUtil.createWithInt(event,[selectSns,argi]);
         Engine.lockTouchInput(SnsShareDialog);
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(packet,function(param1:Array):void
         {
            Engine.unlockTouchInput(SnsShareDialog);
            response = param1;
            callback();
         });
      }
      
      private function getSnsMessage(param1:int) : String
      {
         var _loc7_:* = null;
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc9_:* = null;
         var _loc10_:* = null;
         switch(int(param1))
         {
            case 0:
               _loc2_ = GameSetting.getUIText("common.hashtag.twitter");
               break;
            case 1:
               _loc2_ = GameSetting.getUIText("common.hashtag.instagram");
               break;
            case 2:
               _loc2_ = GameSetting.getUIText("common.hashtag.line");
               break;
            case 3:
               _loc2_ = GameSetting.getUIText("common.hashtag.facebook");
               break;
            case 5:
               _loc2_ = GameSetting.getUIText("common.hashtag.plurk");
               break;
            case 6:
               _loc2_ = GameSetting.getUIText("common.hashtag.weibo");
               break;
            default:
               _loc2_ = "";
         }
         var _loc11_:int = waitingShareBonusId;
         if(shareBonusDef)
         {
            _loc11_ = shareBonusDef.id#2;
         }
         var _loc5_:Vector.<String> = Vector.<String>(["share.main.msg.ar.image.","share.main.msg.ar.movie.","share.main.msg.hide.","share.main.msg.wanted.","share.main.msg.gude.image.","share.all.msg.dialog.","share.all.msg.dialog."]);
         var _loc8_:uint = 1;
         var _loc4_:uint = 20;
         _loc8_ = 1;
         while(_loc8_ < _loc4_)
         {
            if((_loc10_ = GameSetting.getUIText(_loc5_[shareType] + _loc8_)) === "?" + (_loc5_[shareType] + _loc8_))
            {
               _loc8_--;
               break;
            }
            _loc8_++;
         }
         var _loc6_:uint = uint(Math.random() * _loc8_) + 1;
         switch(int(shareType))
         {
            case 0:
               _loc7_ = GameSetting.getUIText("share.main.msg.ar.image." + _loc6_);
               _loc3_ = GameSetting.getInitOtherText("url.store.share.ar.image");
               break;
            case 1:
               _loc7_ = GameSetting.getUIText("share.main.msg.ar.movie." + _loc6_);
               _loc3_ = GameSetting.getInitOtherText("url.store.share.ar.movie");
               break;
            case 2:
               _loc7_ = GameSetting.getUIText("share.main.msg.hide." + _loc6_).replace("<GUDETAMA_NAME>",optionMsg);
               _loc3_ = GameSetting.getInitOtherText("url.store.share.hide");
               break;
            case 3:
               _loc7_ = GameSetting.getUIText("share.main.msg.wanted." + _loc6_).replace("<ID>",optionMsg);
               _loc3_ = GameSetting.getInitOtherText("url.store.share.wanted");
               break;
            case 4:
               _loc7_ = GameSetting.getUIText("share.main.msg.gude.image." + _loc6_);
               _loc3_ = GameSetting.getInitOtherText("url.store.share.gude.image");
               break;
            default:
               break;
            case 5:
               if(_loc11_ > 0)
               {
                  _loc7_ = GameSetting.getUIText("share.all.msg.dialog." + _loc11_);
               }
               else
               {
                  _loc7_ = "";
               }
               return _loc7_ + "\n";
            case 6:
               return (_loc7_ = GameSetting.getUIText("share.homedeco.msg.dialog")) + "\n";
         }
         _loc9_ = GameSetting.getUIText("share.sub.msg.install.url");
         return _loc7_ + "\n" + _loc9_ + "\n" + _loc3_ + "\n\n" + _loc2_;
      }
      
      private function triggeredCloseBtn(param1:Event) : void
      {
         var event:Event = param1;
         checkShareResponse(function():void
         {
            backButtonCallback();
            TweenAnimator.startItself(displaySprite,"hide",false,function(param1:DisplayObject):void
            {
               Engine.popScene(scene);
               if(closeCallback)
               {
                  closeCallback();
                  closeCallback = null;
               }
               if(orgFrameH > 0)
               {
                  imgFrame.height = orgFrameH;
                  orgFrameH = 0;
                  imgMsgBG.height = orgMsgBGH;
                  message.height = orgMsgH;
                  spButton.y = orgSpButtonY;
                  dialogSprite.alignPivot();
               }
            });
         });
      }
      
      private function triggeredCloseBtnWithoutCallback(param1:Event = null) : void
      {
         var event:Event = param1;
         checkShareResponse(function():void
         {
            backButtonCallback();
            TweenAnimator.startItself(displaySprite,"hide",false,function(param1:DisplayObject):void
            {
               Engine.popScene(scene);
               if(orgFrameH > 0)
               {
                  imgFrame.height = orgFrameH;
                  orgFrameH = 0;
                  imgMsgBG.height = orgMsgBGH;
                  message.height = orgMsgH;
                  spButton.y = orgSpButtonY;
                  dialogSprite.alignPivot();
               }
            });
         });
      }
      
      private function checkShareResponse(param1:Function) : void
      {
         var callback:Function = param1;
         if(!response)
         {
            callback();
            return;
         }
         var _response:Array = response;
         response = null;
         BulkItemResultDialog.show(_response,function():void
         {
            callback();
         },"ar.shareBonus.get.msg","ar.shareBonus.title");
      }
      
      private function procSnsShareByPC() : Boolean
      {
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0)
         {
            return false;
         }
         return true;
      }
      
      override protected function focusGainedFinish() : void
      {
         if(sharedAR)
         {
            sendSharedComplete();
            sharedAR = false;
         }
      }
      
      private function sendSharedComplete() : void
      {
         if(GameSetting.getRule().snsShareBonusType == 1)
         {
            if(response)
            {
               var _response:Array = response;
               response = null;
               Engine.lockTouchInput(SnsShareDialog);
               var _loc2_:* = Starling;
               (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
               {
                  Engine.unlockTouchInput(SnsShareDialog);
                  BulkItemResultDialog.show(_response,function():void
                  {
                     if(closeCallback)
                     {
                        closeCallback();
                        closeCallback = null;
                     }
                  },"ar.shareBonus.get.msg","ar.shareBonus.title");
                  var _loc1_:* = Starling;
                  (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
                  {
                     triggeredCloseBtnWithoutCallback();
                  },0.5);
               },1);
            }
         }
         else
         {
            var event:int = 236;
            if(shareType == 0 || shareType == 4)
            {
               event = 217;
            }
            else if(shareType == 2)
            {
               event = 16777450;
            }
            else if(shareType == 5)
            {
               event = 248;
            }
            else if(shareType == 1)
            {
               event = 217;
            }
            var packet:Packet = PacketUtil.createWithInt(event,[selectSns,argi]);
            Engine.lockTouchInput(SnsShareDialog);
            var _loc3_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(packet,function(param1:Array):void
            {
               var response:Array = param1;
               Engine.unlockTouchInput(SnsShareDialog);
               if(!response)
               {
                  return;
               }
               BulkItemResultDialog.show(response,function():void
               {
                  if(closeCallback)
                  {
                     closeCallback();
                     closeCallback = null;
                  }
               },"ar.shareBonus.get.msg","ar.shareBonus.title");
               var _loc2_:* = Starling;
               (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
               {
                  triggeredCloseBtnWithoutCallback();
               },0.5);
            });
         }
      }
      
      private function processSharedCallback(param1:Boolean) : void
      {
         if(param1)
         {
            sendSharedComplete();
         }
         else
         {
            Engine.unlockTouchInput(SnsShareDialog);
         }
      }
   }
}
