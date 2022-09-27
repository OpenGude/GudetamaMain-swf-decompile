package gudetama.scene.kitchen
{
   import gudetama.common.GudetamaUtil;
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.data.compati.UsefulData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.LessMetalDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class HurryUpConfirmDialog extends BaseScene
   {
       
      
      private var kitchenwareType:int;
      
      private var refreshFunc:Function;
      
      private var metalText:ColorTextField;
      
      private var timeText:ColorTextField;
      
      private var rightButton:ContainerButton;
      
      private var leftButton:ContainerButton;
      
      private var useButton:ContainerButton;
      
      private var lessImage:Image;
      
      private var chargeButton:SimpleImageButton;
      
      private var offerwallButton:SimpleImageButton;
      
      private var usefulIconImage:Image;
      
      private var usefulNumText:ColorTextField;
      
      private var usefulUseButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var minutes:Array;
      
      private var currentIndex:int = 0;
      
      private var usefulId:int;
      
      public function HurryUpConfirmDialog(param1:int, param2:Function)
      {
         minutes = [];
         super(2);
         this.kitchenwareType = param1;
         this.refreshFunc = param2;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:int, param2:Function) : void
      {
         Engine.pushScene(new HurryUpConfirmDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HurryUpConfirmDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            metalText = _loc3_.getChildByName("metal") as ColorTextField;
            timeText = _loc3_.getChildByName("time") as ColorTextField;
            rightButton = _loc3_.getChildByName("rightButton") as ContainerButton;
            rightButton.enableDrawCache();
            rightButton.addEventListener("triggered",triggeredRightButton);
            leftButton = _loc3_.getChildByName("leftButton") as ContainerButton;
            leftButton.enableDrawCache();
            leftButton.addEventListener("triggered",triggeredLeftButton);
            useButton = _loc3_.getChildByName("useButton") as ContainerButton;
            useButton.addEventListener("triggered",triggeredUseButton);
            lessImage = _loc3_.getChildByName("less") as Image;
            var _loc4_:Sprite;
            chargeButton = (_loc4_ = _loc3_.getChildByName("chargeGroup") as Sprite).getChildByName("chargeButton") as SimpleImageButton;
            chargeButton.addEventListener("triggered",triggeredChargeButton);
            offerwallButton = _loc4_.getChildByName("offerwallButton") as SimpleImageButton;
            offerwallButton.addEventListener("triggered",triggeredOfferwallButton);
            var _loc2_:Sprite = _loc3_.getChildByName("usefulGroup") as Sprite;
            usefulIconImage = _loc2_.getChildByName("icon") as Image;
            usefulNumText = _loc2_.getChildByName("num") as ColorTextField;
            usefulUseButton = _loc2_.getChildByName("useButton") as ContainerButton;
            usefulUseButton.addEventListener("triggered",triggeredUsefulUseButton);
            closeButton = _loc3_.getChildByName("closeButton") as ContainerButton;
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
         var _loc4_:int = 0;
         var _loc5_:int = UserDataWrapper.kitchenwarePart.getRestCookingTime(kitchenwareType);
         var _loc2_:int = GameSetting.def.rule.hurryUpReduceMinutesPerMetal * 60;
         var _loc1_:int = Math.ceil(_loc5_ / _loc2_);
         _loc4_ = 0;
         while(_loc4_ < _loc1_)
         {
            minutes.push(GameSetting.def.rule.hurryUpReduceMinutesPerMetal * (_loc4_ + 1));
            _loc4_++;
         }
         var _loc3_:int = UserDataWrapper.wrapper.getMetal();
         currentIndex = Math.max(0,Math.min(_loc3_ - 1,minutes.length - 1));
         update();
      }
      
      private function update() : void
      {
         var gudetamaId:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         var useMetal:int = (currentIndex + 1) * GameSetting.getRule().hurryUpMetalBase;
         var hasMetal:Boolean = UserDataWrapper.wrapper.hasMetal(useMetal);
         var hasMetalAll:Boolean = UserDataWrapper.wrapper.hasMetal(minutes.length * GameSetting.getRule().hurryUpMetalBase);
         metalText.text#2 = useMetal.toString();
         var time:int = minutes[currentIndex];
         var hour:int = time / 60;
         var minute:int = time - hour * 60;
         if(hour > 0 && minute > 0)
         {
            timeText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.time.hourAndMinute"),hour,minute);
         }
         else if(hour > 0)
         {
            timeText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.time.hour"),hour);
         }
         else
         {
            timeText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.time.minute"),minute);
         }
         rightButton.visible = currentIndex < minutes.length - 1;
         leftButton.visible = currentIndex > 0;
         useButton.setEnableWithDrawCache(hasMetal);
         lessImage.visible = !hasMetal;
         offerwallButton.visible = UserDataWrapper.wrapper.isEnabledOfferwall();
         if(usefulId > 0)
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemIconName(8,usefulId),function(param1:Texture):void
            {
               usefulIconImage.texture = param1;
            });
            usefulNumText.text#2 = String(UserDataWrapper.usefulPart.getNumUseful(usefulId));
         }
         var flags:int = 0;
         if(!hasMetalAll)
         {
            var flags:int = flags | 1;
         }
         if(usefulId > 0)
         {
            flags |= 2;
         }
         TweenAnimator.startItself(displaySprite,"pos" + flags);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(HurryUpConfirmDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(HurryUpConfirmDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(HurryUpConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(HurryUpConfirmDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredRightButton(param1:Event) : void
      {
         currentIndex++;
         update();
      }
      
      private function triggeredLeftButton(param1:Event) : void
      {
         currentIndex--;
         update();
      }
      
      private function triggeredUseButton(param1:Event) : void
      {
         var event:Event = param1;
         var useMetal:int = (currentIndex + 1) * GameSetting.getRule().hurryUpMetalBase;
         if(!UserDataWrapper.wrapper.hasMetal(useMetal))
         {
            showLessMetalDialog();
            return;
         }
         Engine.showLoading(HurryUpConfirmDialog);
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217911,[kitchenwareType,currentIndex]),function(param1:Array):void
         {
            Engine.hideLoading(HurryUpConfirmDialog);
            if(param1[0] is int)
            {
               if(param1[0] == 0)
               {
                  LocalMessageDialog.show(0,GameSetting.getUIText("cooking.cancel.completed.desc"),null,GameSetting.getUIText("%hurryUpConfirm.title"));
               }
               return;
            }
            var _loc2_:KitchenwareData = param1[0];
            var _loc3_:int = param1[1][0];
            UserDataWrapper.kitchenwarePart.addKitchenware(_loc2_);
            if(_loc3_ > 0)
            {
               ResidentMenuUI_Gudetama.consumeMetal(_loc3_);
            }
            ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
            if(refreshFunc)
            {
               refreshFunc();
            }
            backButtonCallback();
         });
      }
      
      private function triggeredUsefulUseButton(param1:Event) : void
      {
         var event:Event = param1;
         Engine.showLoading(HurryUpConfirmDialog);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217971,[kitchenwareType,usefulId]),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(HurryUpConfirmDialog);
            if(response[0] is int)
            {
               if(response[0] == 0)
               {
                  LocalMessageDialog.show(0,GameSetting.getUIText("cooking.cancel.completed.desc"),null,GameSetting.getUIText("%hurryUpConfirm.title"));
               }
               else if(response[0] == 1)
               {
                  LocalMessageDialog.show(0,GameSetting.getUIText("hurryUpConfirm.useful.outOfTerm"),function(param1:int):void
                  {
                     Engine.broadcastEventToSceneStackWith("update_scene");
                  },GameSetting.getUIText("%hurryUpConfirm.title"));
               }
               return;
            }
            var kitchenwareData:KitchenwareData = response[0];
            var usefulData:UsefulData = response[1];
            UserDataWrapper.kitchenwarePart.addKitchenware(kitchenwareData);
            UserDataWrapper.usefulPart.updateUseful(usefulData);
            ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
            if(refreshFunc)
            {
               refreshFunc();
            }
            backButtonCallback();
         });
      }
      
      private function showLessMetalDialog() : void
      {
         LessMetalDialog.show();
      }
      
      private function triggeredChargeButton(param1:Event) : void
      {
         ResidentMenuUI_Gudetama.getInstance().showMetalShop();
      }
      
      private function triggeredOfferwallButton(param1:Event) : void
      {
         OfferwallAdvertisingManager.showOfferwallAds();
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      public function updateScene() : void
      {
         update();
      }
      
      override public function dispose() : void
      {
         removeEventListener("update_scene",updateScene);
         refreshFunc = null;
         metalText = null;
         timeText = null;
         if(rightButton)
         {
            rightButton.removeEventListener("triggered",triggeredRightButton);
            rightButton = null;
         }
         if(leftButton)
         {
            leftButton.removeEventListener("triggered",triggeredLeftButton);
            leftButton = null;
         }
         if(useButton)
         {
            useButton.removeEventListener("triggered",triggeredUseButton);
            useButton = null;
         }
         lessImage = null;
         if(chargeButton)
         {
            chargeButton.removeEventListener("triggered",triggeredChargeButton);
            chargeButton = null;
         }
         if(offerwallButton)
         {
            offerwallButton.removeEventListener("triggered",triggeredOfferwallButton);
            offerwallButton = null;
         }
         usefulNumText = null;
         if(usefulUseButton)
         {
            usefulUseButton.removeEventListener("triggered",triggeredUsefulUseButton);
            usefulUseButton = null;
         }
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         minutes.length = 0;
         minutes = null;
         super.dispose();
      }
   }
}
