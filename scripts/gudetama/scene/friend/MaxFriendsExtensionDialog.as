package gudetama.scene.friend
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class MaxFriendsExtensionDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var beforeText:ColorTextField;
      
      private var afterText:ColorTextField;
      
      private var priceText:ColorTextField;
      
      private var tradeButton:ContainerButton;
      
      private var purchaseButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function MaxFriendsExtensionDialog(param1:Function)
      {
         super(2);
         this.callback = param1;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new MaxFriendsExtensionDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"MaxFriendsExtensionDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            beforeText = _loc2_.getChildByName("before") as ColorTextField;
            afterText = _loc2_.getChildByName("after") as ColorTextField;
            priceText = _loc2_.getChildByName("price") as ColorTextField;
            tradeButton = _loc2_.getChildByName("tradeButton") as ContainerButton;
            tradeButton.addEventListener("triggered",triggeredTradeButton);
            purchaseButton = _loc2_.getChildByName("purchaseButton") as ContainerButton;
            purchaseButton.addEventListener("triggered",triggeredPurchaseButton);
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
         setup(queue);
      }
      
      private function setup(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         var maxFriends:int = UserDataWrapper.friendPart.getMaxFriends();
         var price:int = GameSetting.getRule().friendsExtensionPrices[UserDataWrapper.friendPart.getFriendsExtensionNum()];
         var isEnough:Boolean = UserDataWrapper.wrapper.hasMoney(price);
         beforeText.text#2 = maxFriends.toString();
         afterText.text#2 = (maxFriends + GameSetting.getRule().friendsExtensionValue).toString();
         priceText.text#2 = StringUtil.getNumStringCommas(price);
         tradeButton.setEnableWithDrawCache(isEnough);
         purchaseButton.visible = false;
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,!!isEnough ? "enough" : "less",false,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(MaxFriendsExtensionDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(MaxFriendsExtensionDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(MaxFriendsExtensionDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MaxFriendsExtensionDialog);
            Engine.popScene(scene);
            callback();
         });
      }
      
      private function triggeredTradeButton(param1:Event) : void
      {
         var event:Event = param1;
         MessageDialog.show(2,GameSetting.getUIText("%maxFriendsExtension.desc"),function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 1)
            {
               return;
            }
            Engine.showLoading(MaxFriendsExtensionDialog);
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(67109036),function(param1:Array):void
            {
               Engine.hideLoading(MaxFriendsExtensionDialog);
               UserDataWrapper.friendPart.increaseNumFriendsExtension();
               ResidentMenuUI_Gudetama.consumeMoney(GameSetting.getRule().friendsExtensionPrices[UserDataWrapper.friendPart.getFriendsExtensionNum() - 1]);
               backButtonCallback();
            });
         });
      }
      
      private function triggeredPurchaseButton(param1:Event) : void
      {
         ResidentMenuUI_Gudetama.getInstance().showMetalShop();
      }
      
      private function updateScene() : void
      {
         Engine.lockTouchInput(MaxFriendsExtensionDialog);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            var queue:TaskQueue = new TaskQueue();
            setup(queue);
            queue.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               TweenAnimator.startItself(displaySprite,"show",false,function():void
               {
                  Engine.unlockTouchInput(MaxFriendsExtensionDialog);
               });
            });
            queue.startTask();
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         beforeText = null;
         afterText = null;
         priceText = null;
         tradeButton.removeEventListener("triggered",triggeredTradeButton);
         tradeButton = null;
         purchaseButton.removeEventListener("triggered",triggeredPurchaseButton);
         purchaseButton = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
