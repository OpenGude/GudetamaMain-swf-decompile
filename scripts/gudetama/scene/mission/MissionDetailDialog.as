package gudetama.scene.mission
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.MissionData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.RecipeMakeButton;
   import gudetama.util.GudeActUtil;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.GeneralGauge;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class MissionDetailDialog extends BaseScene
   {
       
      
      private var missionData:MissionData;
      
      private var titleText:ColorTextField;
      
      private var itemIconImage:Image;
      
      private var completeImage:Image;
      
      private var descText:ColorTextField;
      
      private var gauge:GeneralGauge;
      
      private var numText:ColorTextField;
      
      private var maxText:ColorTextField;
      
      private var itemNameText:ColorTextField;
      
      private var itemNumText:ColorTextField;
      
      private var metalIconImage:Image;
      
      private var moneyIconImage:Image;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var cookingButton:RecipeMakeButton;
      
      private var simple:Boolean;
      
      public function MissionDetailDialog(param1:MissionData, param2:Boolean = false)
      {
         super(1);
         this.missionData = param1;
         this.simple = param2;
      }
      
      public static function show(param1:MissionData, param2:Boolean = false) : void
      {
         Engine.pushScene(new MissionDetailDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"MissionDetailDialog_1",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            itemIconImage = _loc2_.getChildByName("itemIcon") as Image;
            completeImage = _loc2_.getChildByName("complete") as Image;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            gauge = _loc2_.getChildByName("gauge") as GeneralGauge;
            numText = _loc2_.getChildByName("num") as ColorTextField;
            maxText = _loc2_.getChildByName("max") as ColorTextField;
            itemNameText = _loc2_.getChildByName("itemName") as ColorTextField;
            itemNumText = _loc2_.getChildByName("itemNum") as ColorTextField;
            metalIconImage = _loc2_.getChildByName("metalIcon") as Image;
            moneyIconImage = _loc2_.getChildByName("moneyIcon") as Image;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.enableDrawCache();
            closeButton.addEventListener("triggered",triggeredCloseButton);
            cookingButton = new RecipeMakeButton(_loc2_.getChildByName("cookingButton") as ContainerButton,GudeActUtil.getCookCheckStates(),backButtonCallback,true);
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
         var itemParam:ItemParam = missionData.rewards[0];
         titleText.text#2 = StringUtil.format(GameSetting.getUIText("%missionDetail.title"),missionData.number);
         completeImage.visible = UserDataWrapper.missionPart.isCleared(missionData.key);
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc(GudetamaUtil.getItemIconName(itemParam.kind,itemParam.id#2),function(param1:Texture):void
            {
               itemIconImage.texture = param1;
               queue.taskDone();
            });
         });
         descText.text#2 = missionData.title;
         gauge.percent = Math.min(1,missionData.currentValue / missionData.goal);
         numText.text#2 = Math.min(missionData.currentValue,missionData.goal).toString();
         maxText.text#2 = missionData.goal.toString();
         itemNameText.text#2 = GudetamaUtil.getItemParamName(itemParam);
         itemNumText.text#2 = GudetamaUtil.getItemParamNum(itemParam);
         metalIconImage.visible = itemParam.kind == 2 || itemParam.kind == 1;
         moneyIconImage.visible = itemParam.kind == 0 || itemParam.kind == 14;
         var titleParam:Array = missionData.param.titleParam;
         if(titleParam && titleParam[0] == "GudetamaTarget")
         {
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(titleParam[1]);
            cookingButton.setup(0,gudetamaDef.id#2,gudetamaDef.recipeNoteId);
         }
         else
         {
            cookingButton.visible = false;
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(MissionDetailDialog);
         setVisibleState(94);
         setBackButtonCallback(backButtonCallback);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(MissionDetailDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(MissionDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MissionDetailDialog);
            Engine.popScene(scene);
            if(simple)
            {
               showResidentMenuUI(94);
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         currentBackButtonCallback();
         if(simple)
         {
            showResidentMenuUI(94);
         }
      }
      
      override public function dispose() : void
      {
         missionData = null;
         titleText = null;
         itemIconImage = null;
         completeImage = null;
         descText = null;
         gauge = null;
         numText = null;
         maxText = null;
         itemNameText = null;
         itemNumText = null;
         metalIconImage = null;
         moneyIconImage = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
