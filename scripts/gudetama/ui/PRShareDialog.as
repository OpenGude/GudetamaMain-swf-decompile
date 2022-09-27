package gudetama.ui
{
   import flash.display.BitmapData;
   import gudetama.common.NativeExtensions;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.IdentifiedPresentDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class PRShareDialog extends BaseScene
   {
      
      private static const SHARE_NONE:int = 0;
      
      private static const SHARE_START:int = 1;
      
      private static const SHARE_FINISH:int = 2;
       
      
      private var identifiedPresentId:int;
      
      private var bitmapData:BitmapData;
      
      private var callback:Function;
      
      private var buttonGroup:Sprite;
      
      private var SNSButtonUIs:Vector.<SNSButtonUI>;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var phase:int = 0;
      
      private var currentType:int = -1;
      
      public function PRShareDialog(param1:int, param2:BitmapData, param3:Function)
      {
         SNSButtonUIs = new Vector.<SNSButtonUI>();
         super(2);
         this.callback = param3;
         this.bitmapData = param2;
         this.identifiedPresentId = param1;
      }
      
      public static function show(param1:int, param2:BitmapData, param3:Function) : void
      {
         Engine.pushScene(new PRShareDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"PRShareDialog",function(param1:Object):void
         {
            var _loc4_:int = 0;
            var _loc2_:* = null;
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc5_:Sprite = _loc3_.getChildByName("rewardGroup") as Sprite;
            buttonGroup = _loc3_.getChildByName("buttonGroup") as Sprite;
            _loc4_ = 0;
            while(_loc4_ < buttonGroup.numChildren)
            {
               _loc2_ = buttonGroup.getChildByName("button" + _loc4_) as SimpleImageButton;
               if(_loc2_)
               {
                  SNSButtonUIs.push(new SNSButtonUI(_loc2_,triggeredSNSButton));
               }
               _loc4_++;
            }
            closeButton = _loc3_.getChildByName("closeButton") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
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
      
      private function setupSNSButtonPosition(param1:TaskQueue, param2:int) : void
      {
         var queue:TaskQueue = param1;
         var num:int = param2;
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,"num" + (num - 1),false,function():void
            {
               queue.taskDone();
            });
         });
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
         switch(Engine.getLocale())
         {
            case "ja":
               SNSButtonUIs[0].load(queue,"twitter");
               SNSButtonUIs[1].load(queue,"instagram");
               SNSButtonUIs[2].load(queue,"line");
               SNSButtonUIs[3].load(queue,"fb");
               setupSNSButtonPosition(queue,4);
               break;
            case "ko":
               SNSButtonUIs[0].load(queue,"fb");
               SNSButtonUIs[1].load(queue,"instagram");
               SNSButtonUIs[2].load(queue,"kakao");
               SNSButtonUIs[3].load(queue,"twitter");
               setupSNSButtonPosition(queue,4);
               break;
            case "tw":
               SNSButtonUIs[0].load(queue,"plurk");
               SNSButtonUIs[1].load(queue,"fb");
               SNSButtonUIs[2].load(queue,"instagram");
               SNSButtonUIs[3].load(queue,"line");
               SNSButtonUIs[4].load(queue,"twitter");
               setupSNSButtonPosition(queue,5);
               break;
            case "cn":
               SNSButtonUIs[0].load(queue,"instagram");
               SNSButtonUIs[1].load(queue,"wechat");
               SNSButtonUIs[2].load(queue,"fb");
               SNSButtonUIs[3].load(queue,"weibo");
               SNSButtonUIs[4].load(queue,"twitter");
               setupSNSButtonPosition(queue,5);
               break;
            case "en":
            default:
               SNSButtonUIs[0].load(queue,"twitter");
               SNSButtonUIs[1].load(queue,"instagram");
               SNSButtonUIs[2].load(queue,"fb");
               setupSNSButtonPosition(queue,3);
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(PRShareDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(4);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(PRShareDialog);
         });
      }
      
      private function triggeredSNSButton(param1:String) : void
      {
         var type:String = param1;
         var _loc2_:* = Engine;
         if(!(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0))
         {
            completeShare();
            return;
         }
         var message:String = null;
         if(identifiedPresentId > 0)
         {
            var identifiedPresentDef:IdentifiedPresentDef = GameSetting.getIdentifiedPresent(identifiedPresentId);
            message = GameSetting.getUIText(identifiedPresentDef.url#2 + "." + type);
            if(message.indexOf(identifiedPresentDef.url#2) >= 0)
            {
               message = GameSetting.getUIText(identifiedPresentDef.url#2 + ".default");
            }
         }
         if(bitmapData)
         {
            var _loc4_:* = Engine;
            if(gudetama.engine.Engine.platform == 1 && type == "fb")
            {
               var _loc5_:* = NativeExtensions;
               gudetama.common.NativeExtensions.shareExt.showShareMessage(message);
               phase = 1;
            }
            else
            {
               var _loc6_:* = Engine;
               if(gudetama.engine.Engine.platform == 0)
               {
                  var _loc7_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.shareExt.setSharedCallback(sharedCallbackForiOS);
               }
               var _loc8_:* = NativeExtensions;
               gudetama.common.NativeExtensions.shareExt.showShareBitmapData(bitmapData,message,function():void
               {
                  phase = 1;
               });
            }
         }
         else if(message)
         {
            var _loc9_:* = Engine;
            if(gudetama.engine.Engine.platform == 0)
            {
               var _loc10_:* = NativeExtensions;
               gudetama.common.NativeExtensions.shareExt.setSharedCallback(sharedCallbackForiOS);
            }
            var _loc11_:* = NativeExtensions;
            gudetama.common.NativeExtensions.shareExt.showShareMessage(message);
            phase = 1;
         }
         currentType = SNSButtonUI.getSNSId(type);
      }
      
      private function sharedCallbackForiOS(param1:Boolean) : void
      {
         if(param1)
         {
            completeShare();
         }
      }
      
      override protected function focusGainedFinish() : void
      {
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.platform != 1)
         {
            return;
         }
         if(phase != 1)
         {
            return;
         }
         phase = 2;
         completeShare();
      }
      
      private function completeShare() : void
      {
         if(identifiedPresentId > 0 && UserDataWrapper.wrapper.isAcquirableIdentifiedPresent(identifiedPresentId))
         {
            Engine.lockTouchInput(PRShareDialog);
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(240,[identifiedPresentId,currentType]),function(param1:Array):void
            {
               var response:Array = param1;
               Engine.unlockTouchInput(PRShareDialog);
               var items:Array = response[0];
               var params:Array = response[1];
               UserDataWrapper.wrapper.addItems(items,params);
               UserDataWrapper.wrapper.increaseNumAcquiredIdentifiedPresent(identifiedPresentId);
               AcquiredItemDialog.show(items,params,function():void
               {
                  backButtonCallback();
               });
            });
         }
         else
         {
            Engine.lockTouchInput(PRShareDialog);
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(236,currentType),function(param1:Array):void
            {
               Engine.unlockTouchInput(PRShareDialog);
               backButtonCallback();
            });
         }
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(PRShareDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(PRShareDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      override public function dispose() : void
      {
         bitmapData = null;
         buttonGroup = null;
         if(SNSButtonUIs)
         {
            for each(var _loc1_ in SNSButtonUIs)
            {
               _loc1_.dispose();
            }
            SNSButtonUIs.length = 0;
            SNSButtonUIs = null;
         }
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}

import gudetama.engine.TextureCollector;
import muku.core.TaskQueue;
import muku.display.SimpleImageButton;
import starling.events.Event;
import starling.textures.Texture;

class SNSButtonUI
{
   
   public static const SNS_TWITTER:String = "twitter";
   
   public static const SNS_INSTAGRAM:String = "instagram";
   
   public static const SNS_LINE:String = "line";
   
   public static const SNS_FACEBOOK:String = "fb";
   
   public static const SNS_KAKAO:String = "kakao";
   
   public static const SNS_PLURK:String = "plurk";
   
   public static const SNS_WEIBO:String = "weibo";
   
   public static const SNS_WEIXIN:String = "wechat";
    
   
   private var button:SimpleImageButton;
   
   private var callback:Function;
   
   private var type:String;
   
   function SNSButtonUI(param1:SimpleImageButton, param2:Function)
   {
      super();
      this.button = param1;
      this.callback = param2;
      param1.addEventListener("triggered",triggeredButton);
   }
   
   public static function getSNSId(param1:String) : int
   {
      switch(param1)
      {
         case "twitter":
            return 0;
         case "instagram":
            return 1;
         case "line":
            return 2;
         case "fb":
            return 3;
         case "kakao":
            return 4;
         case "plurk":
            return 5;
         case "weibo":
            return 6;
         case "wechat":
            return 7;
         default:
            return -1;
      }
   }
   
   public function load(param1:TaskQueue, param2:String) : void
   {
      var queue:TaskQueue = param1;
      var type:String = param2;
      this.type = type;
      queue.addTask(function():void
      {
         TextureCollector.loadTextureForTask(queue,"ar0@btn_" + type,function(param1:Texture):void
         {
            if(button)
            {
               button.texture = param1;
            }
            queue.taskDone();
         });
      });
   }
   
   public function set visible(param1:Boolean) : void
   {
      button.visible = param1;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(type);
   }
   
   public function dispose() : void
   {
      if(button)
      {
         button.removeEventListener("triggered",triggeredButton);
         button = null;
      }
   }
}
