package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.MissionData;
   import gudetama.data.compati.MissionDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.home.HomeScene;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class MissionRewardDialog extends BaseScene
   {
       
      
      private var rewardedMissionDataList:Array;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var itemNameText:ColorTextField;
      
      private var itemIconImage:Image;
      
      private var itemNumText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var currentMissionIndex:int;
      
      public function MissionRewardDialog(param1:Array, param2:Function)
      {
         super(2);
         this.rewardedMissionDataList = param1;
         this.callback = param2;
      }
      
      public static function show(param1:Array, param2:Function) : void
      {
         Engine.pushScene(new MissionRewardDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"MissionRewardDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            itemNameText = _loc2_.getChildByName("name") as ColorTextField;
            itemIconImage = _loc2_.getChildByName("icon") as Image;
            itemNumText = _loc2_.getChildByName("num") as ColorTextField;
            closeButton = _loc2_.getChildByName("closeButton") as ContainerButton;
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
         Engine.lockTouchInput(MissionRewardDialog);
         var missionData:MissionData = rewardedMissionDataList[currentMissionIndex];
         var itemParam:ItemParam = missionData.rewards[0];
         var isLast:Boolean = currentMissionIndex >= rewardedMissionDataList.length - 1;
         if(isLast)
         {
            setBackButtonCallback(backButtonCallback);
         }
         else
         {
            setBackButtonCallback(next);
         }
         if(UserDataWrapper.missionPart.isDailyMission(missionData.key))
         {
            titleText.text#2 = StringUtil.format(GameSetting.getUIText("common.mission.title.daily"),missionData.number);
         }
         else
         {
            var missionDef:MissionDef = GameSetting.getMission(missionData.id#2);
            titleText.text#2 = StringUtil.format(GameSetting.getUIText("common.mission.title" + (missionDef.eventId > 0 ? ".event" : "")),missionData.number);
         }
         descText.text#2 = missionData.title;
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc(GudetamaUtil.getItemIconName(itemParam.kind,itemParam.id#2),function(param1:Texture):void
            {
               itemIconImage.texture = param1;
               queue.taskDone();
            });
         });
         itemNameText.text#2 = GudetamaUtil.getItemParamName(itemParam);
         itemNumText.text#2 = GudetamaUtil.getItemParamNum(itemParam);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(MissionRewardDialog);
         setVisibleState(78);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("challenge_clear");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            processNoticeTutorial(8,noticeTutorialAction);
            Engine.unlockTouchInput(MissionRewardDialog);
         });
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
         var index:int = param1;
         switch(int(index))
         {
            case 0:
               TweenAnimator.startItself(displaySprite,"hide",false,function():void
               {
                  Engine.unlockTouchInput(MissionRewardDialog);
                  ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
                  {
                     Engine.switchScene(new HomeScene());
                  });
               });
         }
      }
      
      private function next() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         Engine.lockTouchInput(MissionRewardDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            currentMissionIndex++;
            var queue:TaskQueue = new TaskQueue();
            setup(queue);
            queue.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               SoundManager.playEffect("challenge_clear");
               TweenAnimator.startItself(displaySprite,"show",false,function():void
               {
                  Engine.unlockTouchInput(MissionRewardDialog);
               });
            });
            queue.startTask();
         });
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         super.backButtonCallback();
         Engine.lockTouchInput(MissionRewardDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MissionRewardDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         currentBackButtonCallback();
      }
      
      override public function dispose() : void
      {
         rewardedMissionDataList = null;
         titleText = null;
         descText = null;
         itemNameText = null;
         itemIconImage = null;
         itemNumText = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
