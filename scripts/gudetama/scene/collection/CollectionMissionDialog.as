package gudetama.scene.collection
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.controls.supportClasses.ListDataViewPort;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.MissionData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.ranking.RankingRecordDialog;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CollectionMissionDialog extends BaseScene
   {
       
      
      private var collectionType:int;
      
      private var list:List;
      
      private var loadCount:int;
      
      private var rewardRavelExtractor:SpriteExtractor;
      
      private var achieveStr:String;
      
      private var maxAchieveStr:String;
      
      private var achieveText:ColorTextField;
      
      private var maxAchieveText:ColorTextField;
      
      public function CollectionMissionDialog(param1:int, param2:String, param3:String)
      {
         collectionType = param1;
         super(1);
         achieveStr = param2;
         maxAchieveStr = param3;
      }
      
      public static function show(param1:int, param2:String, param3:String) : void
      {
         Engine.pushScene(new CollectionMissionDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"SimpleMissionDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc5_:Sprite;
            var _loc6_:Sprite;
            list = (_loc5_ = (_loc6_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("listGroup") as Sprite).getChildByName("list") as List;
            displaySprite.visible = false;
            var _loc2_:Sprite = _loc6_.getChildByName("headerSprite") as Sprite;
            _loc2_.visibleAllChildren(false);
            var _loc3_:Sprite = _loc2_.getChildByName("labelSprite" + collectionType) as Sprite;
            _loc3_.visible = true;
            var _loc4_:Sprite;
            achieveText = (_loc4_ = _loc3_.getChildByName("stackLabel") as Sprite).getChildByName("achieve") as ColorTextField;
            maxAchieveText = _loc4_.getChildByName("maxAchieve") as ColorTextField;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_CollectionMissionLabel",function(param1:Object):void
         {
            rewardRavelExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            checkInit();
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
         var collection:ListCollection = new ListCollection();
         var layout:FlowLayout = new FlowLayout();
         layout.verticalAlign = "top";
         layout.horizontalAlign = "left";
         layout.paddingLeft = 12;
         layout.paddingTop = 5;
         layout.paddingBottom = 5;
         layout.gap = 10;
         list.layout = layout;
         list.factoryIDFunction = function(param1:Object):String
         {
            return "label";
         };
         list.setItemRendererFactoryWithID("label",function():IListItemRenderer
         {
            return new CollectionRewardItemRenderer(rewardRavelExtractor);
         });
         list.dataProvider = collection;
         list.verticalScrollBarFactory = function():IScrollBar
         {
            var _loc1_:ScrollBar = new ScrollBar();
            _loc1_.trackLayoutMode = "single";
            return _loc1_;
         };
         list.scrollBarDisplayMode = "fixedFloat";
         list.horizontalScrollPolicy = "off";
         list.verticalScrollPolicy = "auto";
         list.interactionMode = "touchAndScrollBars";
         list.addEventListener("scrollComplete",scrollComplete);
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         var data_array:Array = GameSetting.getMissionDataType(collectionType);
         var numAchieve:int = 0;
         var missioncount:int = 0;
         for each(obj in data_array)
         {
            var missionData:MissionData = obj.missionData as MissionData;
            if(UserDataWrapper.missionPart.isCleared(missionData.key))
            {
               numAchieve++;
            }
            missioncount++;
            collection.addItem({"missionDate":missionData});
         }
         achieveText.text#2 = achieveStr;
         maxAchieveText.text#2 = maxAchieveStr;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CollectionMissionDialog);
         setBackButtonCallback(backButtonCallback);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CollectionMissionDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(RankingRecordDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(RankingRecordDialog);
            Engine.popScene(scene);
         });
      }
      
      private function scrollComplete(param1:Event) : void
      {
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc2_:ListDataViewPort = list.getChildAt(0) as ListDataViewPort;
         while(_loc4_ < _loc2_.numChildren)
         {
            _loc3_ = _loc2_.getChildAt(_loc4_) as CollectionRewardItemRenderer;
            if(_loc3_)
            {
               _loc3_.update();
            }
            _loc4_++;
         }
      }
      
      private function triggeredClose(param1:Event) : void
      {
         backButtonCallback();
      }
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class CollectionRewardItemRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:CollectionRewardItemUI;
   
   function CollectionRewardItemRenderer(param1:SpriteExtractor)
   {
      super(param1,null);
   }
   
   override protected function createItemUI() : void
   {
      itemUI = new CollectionRewardItemUI(displaySprite);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override protected function disposeItemUI() : void
   {
      itemUI.dispose();
      itemUI = null;
   }
   
   public function update() : void
   {
      itemUI.updateData(data#2);
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.ItemParam;
import gudetama.data.compati.MissionData;
import gudetama.data.compati.MissionParam;
import gudetama.engine.TextureCollector;
import gudetama.scene.mission.MissionDetailDialog;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.display.GeneralGauge;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class CollectionRewardItemUI extends UIBase
{
    
   
   private var contentsText:ColorTextField;
   
   private var lblName:ColorTextField;
   
   private var icon:Image;
   
   private var imgComp:Image;
   
   private var mat_comp:Image;
   
   private var mat_noncomp:Image;
   
   private var gauge:GeneralGauge;
   
   private var numText:ColorTextField;
   
   private var maxText:ColorTextField;
   
   private var prizeNumText:ColorTextField;
   
   private var detailButton:ContainerButton;
   
   private var missionData:MissionData;
   
   function CollectionRewardItemUI(param1:Sprite)
   {
      super(param1);
      contentsText = param1.getChildByName("contentsText") as ColorTextField;
      lblName = param1.getChildByName("num") as ColorTextField;
      icon = param1.getChildByName("icon") as Image;
      imgComp = param1.getChildByName("imgComp") as Image;
      imgComp.visible = false;
      prizeNumText = param1.getChildByName("priceNum") as ColorTextField;
      mat_comp = param1.getChildByName("mat_comp") as Image;
      mat_noncomp = param1.getChildByName("mat_noncomp") as Image;
      gauge = param1.getChildByName("gauge") as GeneralGauge;
      numText = param1.getChildByName("num") as ColorTextField;
      maxText = param1.getChildByName("max") as ColorTextField;
      detailButton = param1.getChildByName("detailButton") as ContainerButton;
      detailButton.addEventListener("triggered",triggeredDetailButton);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      imgComp.visible = false;
      mat_comp.visible = true;
      mat_noncomp.visible = true;
      if(!data)
      {
         return;
      }
      missionData = data.missionDate;
      var title:String = missionData.title;
      var param:MissionParam = missionData.param;
      var goalValue:int = missionData.goal;
      contentsText.text#2 = title;
      var item:ItemParam = param.rewards[0];
      lblName.text#2 = GudetamaUtil.getItemParamNameAndNum(item);
      var imageName:String = GudetamaUtil.getItemIconName(item.kind,item.id#2);
      prizeNumText.text#2 = StringUtil.format(GameSetting.getUIText("ranking.next.pts.reward.num"),item.num);
      TextureCollector.loadTexture(imageName,function(param1:Texture):void
      {
         if(icon == null)
         {
            return;
         }
         icon.texture = param1;
      });
      if(missionData && UserDataWrapper.missionPart.isCleared(missionData.key))
      {
         imgComp.visible = true;
      }
      else
      {
         mat_comp.visible = false;
      }
      gauge.percent = Math.min(1,missionData.currentValue / goalValue);
      gauge.visible = true;
      numText.text#2 = Math.min(missionData.currentValue,goalValue).toString();
      maxText.text#2 = goalValue.toString();
   }
   
   private function triggeredDetailButton(param1:Event) : void
   {
      MissionDetailDialog.show(missionData,true);
   }
   
   public function refreshMissionData() : void
   {
      if(!missionData)
      {
         return;
      }
      var _loc1_:MissionData = UserDataWrapper.missionPart.getMissionDataById(missionData.id#2);
      if(!_loc1_)
      {
         return;
      }
      setupEnabled();
   }
   
   private function setupEnabled() : void
   {
      if(!missionData)
      {
         return;
      }
      contentsText.text#2 = missionData.title;
      gauge.percent = Math.min(1,missionData.currentValue / missionData.goal);
      gauge.visible = true;
      numText.text#2 = Math.min(missionData.currentValue,missionData.goal).toString();
      maxText.text#2 = missionData.goal.toString();
      detailButton.visible = true;
   }
   
   public function dispose() : void
   {
      contentsText = null;
      lblName = null;
      icon = null;
      imgComp = null;
   }
}
