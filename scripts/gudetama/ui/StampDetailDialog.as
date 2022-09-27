package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.StampData;
   import gudetama.data.compati.StampDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.ar.ARScene;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.util.PermissionRequestWrapper;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class StampDetailDialog extends BaseScene
   {
       
      
      private var id:int;
      
      private var titleText:ColorTextField;
      
      private var iconImage:Image;
      
      private var numText:ColorTextField;
      
      private var shopButton:ContainerButton;
      
      private var arButton:ContainerButton;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function StampDetailDialog(param1:int)
      {
         super(2);
         this.id = param1;
      }
      
      public static function show(param1:int) : void
      {
         Engine.pushScene(new StampDetailDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"StampDetailDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            iconImage = _loc2_.getChildByName("icon") as Image;
            numText = _loc2_.getChildByName("num") as ColorTextField;
            shopButton = _loc2_.getChildByName("shopButton") as ContainerButton;
            shopButton.enableDrawCache();
            shopButton.addEventListener("triggered",triggeredShopButton);
            arButton = _loc2_.getChildByName("arButton") as ContainerButton;
            arButton.addEventListener("triggered",triggeredARButton);
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.enableDrawCache();
            closeButton.addEventListener("triggered",triggeredCloseButton);
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
         var stampDef:StampDef = GameSetting.getStamp(id);
         var stampData:StampData = UserDataWrapper.stampPart.getStamp(id);
         var num:int = !!stampData ? stampData.num : 0;
         titleText.text#2 = stampDef.name#2;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemIconName(11,id),function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         numText.text#2 = StringUtil.getNumStringCommas(num);
         descText.text#2 = stampDef.desc;
         var numButton:int = 0;
         if(stampDef.price)
         {
            shopButton.visible = true;
            numButton++;
         }
         else
         {
            shopButton.visible = false;
         }
         if(UserDataWrapper.featurePart.existsFeature(1))
         {
            arButton.visible = true;
            arButton.setEnableWithDrawCache(num > 0);
            numButton++;
         }
         else
         {
            arButton.visible = false;
         }
         switch(int(numButton))
         {
            case 0:
               TweenAnimator.startItself(displaySprite,"pos0");
               break;
            case 1:
               TweenAnimator.startItself(displaySprite,"pos1");
               TweenAnimator.startItself(shopButton,"num0");
               TweenAnimator.startItself(arButton,"num0");
               break;
            case 2:
               TweenAnimator.startItself(displaySprite,"pos1");
               TweenAnimator.startItself(shopButton,"num1");
               TweenAnimator.startItself(arButton,"num1");
         }
      }
      
      private function start() : void
      {
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(UsefulDetailDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(UsefulDetailDialog);
         });
      }
      
      private function triggeredShopButton(param1:Event) : void
      {
         var event:Event = param1;
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
         {
            Engine.switchScene(new ShopScene_Gudetama());
         });
      }
      
      private function triggeredARButton(param1:Event) : void
      {
         var event:Event = param1;
         GudetamaUtil.cameraButtonSE();
         if(UserDataWrapper.wrapper.isDoneNoticeFlag(14))
         {
            openArScene();
            return;
         }
         var msg:String = GameSetting.getUIText("%ar.confirm.dialog.msg") + "\n\n" + GameSetting.getUIText("%ar.confirm.dialog.info");
         MessageDialog.show(23,msg,function(param1:int):void
         {
            if(param1 != 1)
            {
               openArScene();
            }
         });
      }
      
      private function openArScene() : void
      {
         Engine.lockTouchInput(this);
         PermissionRequestWrapper.requestAR(function(param1:int):void
         {
            var result:int = param1;
            if(result == 1)
            {
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(149,function():void
               {
                  Engine.unlockTouchInput(this);
                  ARScene.show();
               });
            }
            else if(result == -3)
            {
               Engine.unlockTouchInput(this);
               var _loc2_:* = Engine;
               if(gudetama.engine.Engine.platform == 1)
               {
                  var msg:String = GameSetting.getUIText("%ar.permissionRequest.reject.camera.android");
                  var msg:String = msg + ("\n" + GameSetting.getUIText("%ar.permissionRequestForDenied.android"));
               }
               else
               {
                  msg = GameSetting.getUIText("%ar.permissionRequest.reject.camera");
                  msg += "\n" + GameSetting.getUIText("%ar.permissionRequestForDenied");
                  var _loc4_:* = Engine;
                  msg = StringUtil.format(msg,GameSetting.getUIText("%ar.permission.cameraRoll." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))));
               }
               PermissionRequestWrapper.showInductionAppConfigDialog(msg);
            }
            else
            {
               Engine.unlockTouchInput(this);
               var _loc5_:* = Engine;
               if(gudetama.engine.Engine.platform == 1)
               {
                  msg = GameSetting.getUIText("%ar.permissionRequest.reject.camera.android");
               }
               else
               {
                  msg = GameSetting.getUIText("%ar.permissionRequest.reject.camera");
                  var _loc6_:* = Engine;
                  msg = StringUtil.format(msg,GameSetting.getUIText("%ar.permission.cameraRoll." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))));
               }
               LocalMessageDialog.show(2,msg,null,GameSetting.getUIText("%ar.permissionRequest.title"));
            }
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(UsefulDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(UsefulDetailDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         titleText = null;
         iconImage = null;
         numText = null;
         shopButton.removeEventListener("triggered",triggeredShopButton);
         shopButton = null;
         arButton.removeEventListener("triggered",triggeredARButton);
         arButton = null;
         descText = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
