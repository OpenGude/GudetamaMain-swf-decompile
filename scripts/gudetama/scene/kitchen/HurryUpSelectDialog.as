package gudetama.scene.kitchen
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class HurryUpSelectDialog extends BaseScene
   {
       
      
      private var kitchenwareType:int;
      
      private var refreshFunc:Function;
      
      private var metalButton:ContainerButton;
      
      private var goldButton:ContainerButton;
      
      private var silverButton:ContainerButton;
      
      private var silverBalloonLabelText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function HurryUpSelectDialog(param1:int, param2:Function)
      {
         super(2);
         this.kitchenwareType = param1;
         this.refreshFunc = param2;
      }
      
      public static function show(param1:int, param2:Function) : void
      {
         Engine.pushScene(new HurryUpSelectDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HurryUpSelectDialog_1",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            metalButton = _loc3_.getChildByName("metalButton") as ContainerButton;
            metalButton.enableDrawCache();
            metalButton.addEventListener("triggered",triggeredMetalButton);
            goldButton = _loc3_.getChildByName("goldButton") as ContainerButton;
            goldButton.enableDrawCache();
            goldButton.addEventListener("triggered",triggeredGoldButton);
            silverButton = _loc3_.getChildByName("silverButton") as ContainerButton;
            silverButton.enableDrawCache();
            silverButton.addEventListener("triggered",triggeredSilverButton);
            var _loc2_:Sprite = _loc3_.getChildByName("silverBalloon") as Sprite;
            silverBalloonLabelText = _loc2_.getChildByName("text") as ColorTextField;
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
         var _loc2_:int = 0;
         var _loc3_:* = null;
         var _loc1_:Array = UserDataWrapper.eventPart.getRankingIds(true);
         if(_loc1_ && _loc1_.length > 0)
         {
            _loc2_ = _loc1_[0];
            _loc3_ = GameSetting.getUIText("%hurryUpConfirm.select.balloon.silver." + _loc2_);
            if(_loc3_.charAt(0) == "?")
            {
               _loc3_ = GameSetting.getUIText("%hurryUpConfirm.select.balloon.silver.default");
            }
            silverBalloonLabelText.text#2 = StringUtil.format(_loc3_,GameSetting.getUIText("%ranking.pts." + _loc2_));
         }
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
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(HurryUpConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(HurryUpConfirmDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredMetalButton(param1:Event) : void
      {
         var event:Event = param1;
         back(function():void
         {
            HurryUpMetalDialog.show(kitchenwareType,refreshFunc);
         });
      }
      
      private function triggeredGoldButton(param1:Event) : void
      {
         var event:Event = param1;
         back(function():void
         {
            HurryUpItemDialog.show(kitchenwareType,62,refreshFunc);
         });
      }
      
      private function triggeredSilverButton(param1:Event) : void
      {
         var event:Event = param1;
         back(function():void
         {
            HurryUpItemDialog.show(kitchenwareType,63,refreshFunc);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         refreshFunc = null;
         if(metalButton)
         {
            metalButton.removeEventListener("triggered",triggeredMetalButton);
            metalButton = null;
         }
         if(goldButton)
         {
            goldButton.removeEventListener("triggered",triggeredGoldButton);
            goldButton = null;
         }
         if(silverButton)
         {
            silverButton.removeEventListener("triggered",triggeredSilverButton);
            silverButton = null;
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
