package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.LinkageData;
   import gudetama.data.compati.LinkageDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class LinkageAchievementDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var notifyList:Array;
      
      private var index:int;
      
      public function LinkageAchievementDialog(param1:Function)
      {
         super(2);
         this.callback = param1;
      }
      
      public static function show(param1:Function) : void
      {
         if(UserDataWrapper.linkagePart.isAllNotified())
         {
            param1();
            return;
         }
         Engine.pushScene(new LinkageAchievementDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"LinkageAchievementDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
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
            init();
         });
         queue.startTask(onProgress);
      }
      
      private function init() : void
      {
         var queue:TaskQueue = new TaskQueue();
         notifyList = [];
         var linkageMap:Object = UserDataWrapper.linkagePart.getLinkageMap();
         for(id in linkageMap)
         {
            var linkageData:LinkageData = UserDataWrapper.linkagePart.getLinkage(id);
            if(!linkageData.notified)
            {
               notifyList.push(id);
            }
         }
         index = 0;
         setup(queue);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            start();
         });
         queue.startTask();
      }
      
      private function setup(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         var id:int = notifyList[index];
         var linkageDef:LinkageDef = GameSetting.getLinkage(id);
         descText.text#2 = StringUtil.format(GameSetting.getUIText("linkageAchievement.desc"),linkageDef.title);
         queue.addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(16777408,id),function(param1:*):void
            {
               UserDataWrapper.linkagePart.notify(id);
               queue.taskDone();
            });
         });
      }
      
      private function start() : void
      {
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(LinkageAchievementDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LinkageAchievementDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         if(++index < notifyList.length)
         {
            next();
         }
         else
         {
            back();
         }
      }
      
      private function back() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(LinkageAchievementDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LinkageAchievementDialog);
            Engine.popScene(scene);
            callback();
         });
      }
      
      private function next() : void
      {
         Engine.lockTouchInput(LinkageAchievementDialog);
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
                  Engine.unlockTouchInput(LinkageAchievementDialog);
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
         descText = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         notifyList = null;
         super.dispose();
      }
   }
}
