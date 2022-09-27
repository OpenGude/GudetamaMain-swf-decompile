package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.compati.MonthlyPremiumBonusDef;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class NoticeMonthlyDialog extends ChargeDialogBase
   {
       
      
      private var monthlyPremiumBonus:MonthlyPremiumBonusDef;
      
      private var callback:Function;
      
      private var monthlyItemUI:MonthlyItemUI;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function NoticeMonthlyDialog(param1:MonthlyPremiumBonusDef, param2:Function)
      {
         super(2);
         this.monthlyPremiumBonus = param1;
         this.callback = param2;
      }
      
      public static function show(param1:MonthlyPremiumBonusDef, param2:Function) : void
      {
         Engine.pushScene(new NoticeMonthlyDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"NoticeMonthlyDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            monthlyItemUI = new MonthlyItemUI(_loc2_.getChildByName("_MetalMonthlyItem") as Sprite,onMonthlyTriggered);
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.addTask(function():void
         {
            loadPrice(GameSetting.getMetalShop(2),function():void
            {
               queue.taskDone();
            });
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
         var _loc1_:Array = getPrice(monthlyPremiumBonus.item,!!priceMap ? priceMap[monthlyPremiumBonus.item.product_id] : null);
         monthlyItemUI.updateData({
            "monthlyPremiumBonus":monthlyPremiumBonus,
            "price":_loc1_[0],
            "mark":_loc1_[1]
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(NoticeMonthlyDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(NoticeMonthlyDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(NoticeMonthlyDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(NoticeMonthlyDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function onMonthlyTriggered(param1:MonthlyPremiumBonusDef) : void
      {
         purchase(param1.item,backButtonCallback);
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         if(monthlyItemUI)
         {
            monthlyItemUI.dispose();
            monthlyItemUI = null;
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
