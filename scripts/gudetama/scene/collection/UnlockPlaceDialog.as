package gudetama.scene.collection
{
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class UnlockPlaceDialog extends BaseScene
   {
       
      
      private var shopButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function UnlockPlaceDialog()
      {
         super(2);
      }
      
      public static function show() : void
      {
         Engine.pushScene(new UnlockPlaceDialog(),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"UnlockPlaceDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            shopButton = _loc2_.getChildByName("shopButton") as ContainerButton;
            shopButton.addEventListener("triggered",triggeredShopButton);
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
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
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(UnlockPlaceDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(UnlockPlaceDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(UnlockPlaceDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(UnlockPlaceDialog);
            Engine.popScene(scene);
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
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         if(shopButton)
         {
            shopButton.removeEventListener("triggered",triggeredShopButton);
            shopButton = null;
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
