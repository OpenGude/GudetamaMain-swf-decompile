package gudetama.scene.kitchen
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.data.compati.UsefulData;
   import gudetama.data.compati.UsefulDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class HurryUpUsuallyDialog extends BaseScene
   {
       
      
      private var iconMap:Object;
      
      private var kitchenwareType:int;
      
      private var refreshFunc:Function;
      
      private var titleText:ColorTextField;
      
      private var numText:ColorTextField;
      
      private var timeText:ColorTextField;
      
      private var rightButton:ContainerButton;
      
      private var leftButton:ContainerButton;
      
      private var useButton:ContainerButton;
      
      private var itemIcon:Image;
      
      private var lessImage:Image;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var minutes:Array;
      
      private var currentIndex:int = 0;
      
      private var usefulId:int;
      
      private var iconId:int;
      
      private var usefulDef:UsefulDef;
      
      public function HurryUpUsuallyDialog(param1:int, param2:UsefulDef, param3:Function)
      {
         iconMap = {64:4};
         minutes = [];
         super(2);
         this.kitchenwareType = param1;
         this.refreshFunc = param3;
         this.usefulDef = param2;
         this.usefulId = usefulDef.id#2;
         if(iconMap[usefulId])
         {
            iconId = iconMap[usefulId];
         }
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:int, param2:int, param3:Function) : void
      {
         var _loc4_:UsefulDef;
         if(!(_loc4_ = GameSetting.getUseful(param2)))
         {
            return;
         }
         Engine.pushScene(new HurryUpUsuallyDialog(param1,_loc4_,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HurryUpUsuallyDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = dialogSprite.getChildByName("title") as ColorTextField;
            titleText.text#2 = GameSetting.getUIText("hurryUpConfirm.item.title").replace("%1",usefulDef.name#2);
            numText = dialogSprite.getChildByName("num") as ColorTextField;
            timeText = dialogSprite.getChildByName("time") as ColorTextField;
            rightButton = dialogSprite.getChildByName("rightButton") as ContainerButton;
            rightButton.enableDrawCache();
            rightButton.addEventListener("triggered",triggeredRightButton);
            leftButton = dialogSprite.getChildByName("leftButton") as ContainerButton;
            leftButton.enableDrawCache();
            leftButton.addEventListener("triggered",triggeredLeftButton);
            useButton = dialogSprite.getChildByName("useButton") as ContainerButton;
            useButton.addEventListener("triggered",triggeredUseButton);
            itemIcon = dialogSprite.getChildByName("itemIcon") as Image;
            itemIcon.visible = false;
            TextureCollector.loadTexture("cooking0@isogi" + iconId,function(param1:Texture):void
            {
               itemIcon.texture = param1;
               itemIcon.visible = true;
            });
            lessImage = dialogSprite.getChildByName("less") as Image;
            var chargeGroup:Sprite = dialogSprite.getChildByName("chargeGroup") as Sprite;
            closeButton = dialogSprite.getChildByName("closeButton") as ContainerButton;
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
         var _loc5_:int = GameSetting.def.rule.hurryUpReduceMinutesPerItem[usefulId];
         var _loc6_:int = UserDataWrapper.kitchenwarePart.getRestCookingTime(kitchenwareType);
         var _loc2_:int = _loc5_ * 60;
         var _loc1_:* = int(Math.ceil(_loc6_ / _loc2_));
         var _loc3_:int = UserDataWrapper.usefulPart.getNumUseful(usefulId);
         if(_loc1_ > _loc3_)
         {
            _loc1_ = _loc3_;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc1_)
         {
            minutes.push(_loc5_ * (_loc4_ + 1));
            _loc4_++;
         }
         update();
      }
      
      private function update() : void
      {
         var _loc1_:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         var _loc6_:int = 1;
         if(GameSetting.getRule().hurryUpItemBaseMap)
         {
            _loc6_ = !!GameSetting.getRule().hurryUpItemBaseMap[usefulId] ? GameSetting.getRule().hurryUpItemBaseMap[usefulId] : 1;
         }
         var _loc3_:int = (currentIndex + 1) * _loc6_;
         var _loc7_:UsefulDef = GameSetting.getUseful(usefulId);
         var _loc4_:int;
         var _loc5_:* = (_loc4_ = UserDataWrapper.usefulPart.getNumUseful(usefulId)) > 0;
         numText.text#2 = _loc3_.toString();
         var _loc8_:int;
         var _loc2_:int = (_loc8_ = minutes[currentIndex]) / 60;
         var _loc9_:int = _loc8_ - _loc2_ * 60;
         if(_loc2_ > 0 && _loc9_ > 0)
         {
            timeText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.time.hourAndMinute"),_loc2_,_loc9_);
         }
         else if(_loc2_ > 0)
         {
            timeText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.time.hour"),_loc2_);
         }
         else
         {
            timeText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.time.minute"),_loc9_);
         }
         rightButton.visible = currentIndex < minutes.length - 1;
         leftButton.visible = currentIndex > 0;
         useButton.setEnableWithDrawCache(_loc5_);
         lessImage.visible = !_loc5_;
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
         Engine.showLoading(HurryUpConfirmDialog);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217976,[kitchenwareType,usefulId,currentIndex]),function(param1:Array):void
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
            var _loc3_:UsefulData = param1[1];
            UserDataWrapper.kitchenwarePart.addKitchenware(_loc2_);
            UserDataWrapper.usefulPart.updateUseful(_loc3_);
            ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
            if(refreshFunc)
            {
               refreshFunc();
            }
            backButtonCallback();
         });
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
         numText = null;
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
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         minutes.length = 0;
         minutes = null;
         super.dispose();
      }
   }
}
