package gudetama.scene.kitchen
{
   import gudetama.common.OfferwallAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
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
   
   public class HurryUpMetalDialog extends BaseScene
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
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var minutes:Array;
      
      private var currentIndex:int = 0;
      
      public function HurryUpMetalDialog(param1:int, param2:Function)
      {
         minutes = [];
         super(2);
         this.kitchenwareType = param1;
         this.refreshFunc = param2;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:int, param2:Function) : void
      {
         Engine.pushScene(new HurryUpMetalDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HurryUpMetalDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            metalText = _loc2_.getChildByName("metal") as ColorTextField;
            timeText = _loc2_.getChildByName("time") as ColorTextField;
            rightButton = _loc2_.getChildByName("rightButton") as ContainerButton;
            rightButton.enableDrawCache();
            rightButton.addEventListener("triggered",triggeredRightButton);
            leftButton = _loc2_.getChildByName("leftButton") as ContainerButton;
            leftButton.enableDrawCache();
            leftButton.addEventListener("triggered",triggeredLeftButton);
            useButton = _loc2_.getChildByName("useButton") as ContainerButton;
            useButton.addEventListener("triggered",triggeredUseButton);
            lessImage = _loc2_.getChildByName("less") as Image;
            var _loc3_:Sprite = _loc2_.getChildByName("chargeGroup") as Sprite;
            chargeButton = _loc3_.getChildByName("chargeButton") as SimpleImageButton;
            chargeButton.addEventListener("triggered",triggeredChargeButton);
            offerwallButton = _loc3_.getChildByName("offerwallButton") as SimpleImageButton;
            offerwallButton.addEventListener("triggered",triggeredOfferwallButton);
            closeButton = _loc2_.getChildByName("closeButton") as ContainerButton;
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
         var _loc1_:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         var _loc5_:int = (currentIndex + 1) * GameSetting.getRule().hurryUpMetalBase;
         var _loc6_:Boolean = UserDataWrapper.wrapper.hasMetal(_loc5_);
         var _loc2_:Boolean = UserDataWrapper.wrapper.hasMetal(minutes.length * GameSetting.getRule().hurryUpMetalBase);
         metalText.text#2 = _loc5_.toString();
         var _loc4_:int;
         var _loc3_:int = (_loc4_ = minutes[currentIndex]) / 60;
         var _loc7_:int = _loc4_ - _loc3_ * 60;
         if(_loc3_ > 0 && _loc7_ > 0)
         {
            timeText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.time.hourAndMinute"),_loc3_,_loc7_);
         }
         else if(_loc3_ > 0)
         {
            timeText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.time.hour"),_loc3_);
         }
         else
         {
            timeText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.time.minute"),_loc7_);
         }
         rightButton.visible = currentIndex < minutes.length - 1;
         leftButton.visible = currentIndex > 0;
         useButton.setEnableWithDrawCache(_loc6_);
         lessImage.visible = !_loc6_;
         offerwallButton.visible = UserDataWrapper.wrapper.isEnabledOfferwall();
         TweenAnimator.startItself(displaySprite,"pos" + (!!_loc2_ ? 0 : 1));
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
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         minutes.length = 0;
         minutes = null;
         super.dispose();
      }
   }
}
