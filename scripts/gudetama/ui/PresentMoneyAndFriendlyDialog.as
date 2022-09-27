package gudetama.ui
{
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.FriendlyData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.friend.FriendlyRewardDialog;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class PresentMoneyAndFriendlyDialog extends BaseScene
   {
       
      
      private var addMoney:int;
      
      private var addFriendly:int;
      
      private var callback:Function;
      
      private var moneyText:ColorTextField;
      
      private var friendlyText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function PresentMoneyAndFriendlyDialog(param1:int, param2:int, param3:Function)
      {
         super(2);
         this.addMoney = param1;
         this.addFriendly = param2;
         this.callback = param3;
      }
      
      public static function show(param1:Function = null) : void
      {
         var callback:Function = param1;
         var param:Array = DataStorage.getLocalData().popPendingFriendTouchEventCounts();
         if(!param)
         {
            if(callback)
            {
               callback();
            }
            return;
         }
         Engine.showLoading(PresentMoneyAndFriendlyDialog);
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(228,param),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(PresentMoneyAndFriendlyDialog);
            if(response[0] is int && response[0] < 0)
            {
               if(callback)
               {
                  callback();
               }
               return;
            }
            var addMoney:int = response[0][0];
            var friendlyData:FriendlyData = response[1];
            var lastFriendly:int = response[2][0];
            var addFriendly:int = response[2][1];
            var lastFriendlyLevel:int = response[2][2];
            if(friendlyData)
            {
               UserDataWrapper.wrapper.updateFriendlyData(friendlyData);
            }
            var isMaxFriendly:Boolean = friendlyData && lastFriendly == UserDataWrapper.wrapper.getFriendly(friendlyData.encodedUid);
            if(isMaxFriendly)
            {
               addFriendly = 0;
            }
            showPresentMoneyAndFriendlyDialog(addMoney,addFriendly,function():void
            {
               if(friendlyData && !isMaxFriendly)
               {
                  FriendlyRewardDialog.show([[UserDataWrapper.wrapper.getFriendlyData(friendlyData.encodedUid),[lastFriendlyLevel],UserDataWrapper.friendPart.getFriendProfile(friendlyData.encodedUid)]],function():void
                  {
                     if(callback)
                     {
                        callback();
                     }
                  },92);
               }
               else if(callback)
               {
                  callback();
               }
            });
            Engine.broadcastEventToSceneStackWith("update_scene");
         });
      }
      
      private static function showPresentMoneyAndFriendlyDialog(param1:int, param2:int, param3:Function) : void
      {
         Engine.pushScene(new PresentMoneyAndFriendlyDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"PresentMoneyAndFriendlyDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc5_:Sprite;
            moneyText = (_loc5_ = _loc3_.getChildByName("moneyGroup") as Sprite).getChildByName("money") as ColorTextField;
            var _loc4_:Sprite;
            friendlyText = (_loc4_ = _loc3_.getChildByName("friendlyGroup") as Sprite).getChildByName("friendly") as ColorTextField;
            var _loc2_:Sprite = _loc3_.getChildByName("descGroup") as Sprite;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            closeButton = _loc3_.getChildByName("btn_back") as ContainerButton;
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
         moneyText.text#2 = StringUtil.format(GameSetting.getUIText("common.money"),addMoney);
         friendlyText.text#2 = StringUtil.format(GameSetting.getUIText("add.mark"),addFriendly);
         if(addFriendly > 0)
         {
            descText.text#2 = GameSetting.getUIText("friendRoom.friendPresent.result.desc.friendly.1");
            queue.addTask(function():void
            {
               TweenAnimator.startItself(displaySprite,"pos1",false,function():void
               {
                  queue.taskDone();
               });
            });
         }
         else
         {
            descText.text#2 = GameSetting.getUIText("friendRoom.friendPresent.result.desc.friendly.0");
            queue.addTask(function():void
            {
               TweenAnimator.startItself(displaySprite,"pos0",false,function():void
               {
                  queue.taskDone();
               });
            });
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(PresentMoneyAndFriendlyDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(76);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(PresentMoneyAndFriendlyDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(PresentMoneyAndFriendlyDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(PresentMoneyAndFriendlyDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         moneyText = null;
         friendlyText = null;
         descText = null;
      }
   }
}
