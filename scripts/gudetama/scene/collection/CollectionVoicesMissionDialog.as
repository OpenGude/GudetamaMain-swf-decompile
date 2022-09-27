package gudetama.scene.collection
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.controls.supportClasses.ListDataViewPort;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.MissionData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.ranking.RankingRecordDialog;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CollectionVoicesMissionDialog extends BaseScene
   {
      
      private static const TAB_ALL:int = 1;
      
      private static const TAB_RARE2:int = 2;
       
      
      private var collectionType:int;
      
      private var list:List;
      
      private var loadCount:int;
      
      private var rewardRavelExtractor:SpriteExtractor;
      
      private var achieveText:ColorTextField;
      
      private var maxAchieveText:ColorTextField;
      
      private var labelSprite1:Sprite;
      
      private var labelSprite2:Sprite;
      
      private var tabGroup:TabGroup;
      
      private var mat_all:Image;
      
      private var mat_2:Image;
      
      public function CollectionVoicesMissionDialog(param1:int)
      {
         collectionType = param1;
         super(1);
      }
      
      public static function show(param1:int) : void
      {
         Engine.pushScene(new CollectionVoicesMissionDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"SimpleMissionVoiceDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc4_:Sprite;
            var _loc5_:Sprite;
            list = (_loc4_ = (_loc5_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("listGroup") as Sprite).getChildByName("list") as List;
            displaySprite.visible = false;
            tabGroup = new TabGroup(_loc4_.getChildByName("tabGroup") as Sprite,triggeredTabGroup);
            var _loc2_:Sprite = _loc5_.getChildByName("headerSprite") as Sprite;
            labelSprite1 = _loc2_.getChildByName("labelSprite1") as Sprite;
            labelSprite2 = _loc2_.getChildByName("labelSprite2") as Sprite;
            mat_all = _loc4_.getChildByName("mat_0") as Image;
            mat_2 = _loc4_.getChildByName("mat_2") as Image;
            tabGroup.onTouch(collectionType == 1 ? 1 : 0,false,false);
            updateUI();
            var _loc3_:Sprite = _loc2_.getChildByName("stackLabel") as Sprite;
            achieveText = _loc3_.getChildByName("achieve") as ColorTextField;
            maxAchieveText = _loc3_.getChildByName("maxAchieve") as ColorTextField;
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
         updateList();
      }
      
      private function updateList() : void
      {
         var _loc2_:* = null;
         var _loc4_:* = null;
         var _loc3_:ListCollection = new ListCollection();
         list.dataProvider = _loc3_;
         var _loc6_:Array = GameSetting.getMissionDataType(collectionType == 1 ? 2 : 8);
         var _loc5_:int = 0;
         var _loc1_:int = 0;
         for each(_loc2_ in _loc6_)
         {
            _loc4_ = _loc2_.missionData as MissionData;
            if(UserDataWrapper.missionPart.isCleared(_loc4_.key))
            {
               _loc5_++;
            }
            _loc1_++;
            _loc3_.addItem({"missionDate":_loc4_});
         }
         setAchieveLabel();
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
      
      private function triggeredTabGroup(param1:int) : void
      {
         if(param1 == 1)
         {
            collectionType = 1;
         }
         else
         {
            collectionType = 2;
         }
         updateUI();
         updateList();
      }
      
      private function updateUI() : void
      {
         if(collectionType == 1)
         {
            labelSprite2.visible = false;
            mat_2.visible = false;
            labelSprite1.visible = true;
            mat_all.visible = true;
         }
         else
         {
            labelSprite1.visible = false;
            mat_all.visible = false;
            labelSprite2.visible = true;
            mat_2.visible = true;
         }
      }
      
      private function triggeredClose(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function setAchieveLabel() : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:* = null;
         var _loc1_:Boolean = false;
         for each(_loc2_ in GameSetting.getGudetamaMap())
         {
            if(UserDataWrapper.wrapper.isScreenableInCollection(_loc2_.id#2))
            {
               _loc1_ = UserDataWrapper.gudetamaPart.isCooked(_loc2_.id#2);
               if(_loc1_)
               {
                  if(collectionType == 1 && UserDataWrapper.gudetamaPart.isUnlockedVoice(_loc2_.id#2,0))
                  {
                     _loc4_++;
                  }
                  if(UserDataWrapper.gudetamaPart.isUnlockedVoice(_loc2_.id#2,1))
                  {
                     _loc4_++;
                  }
               }
               if(_loc2_.type == 1)
               {
                  _loc3_++;
               }
               else if(GudetamaUtil.isPushEventGudetamaList(_loc2_))
               {
                  _loc3_++;
               }
            }
         }
         achieveText.text#2 = _loc4_.toString();
         maxAchieveText.text#2 = collectionType == 1 ? (_loc3_ * 2).toString() : _loc3_.toString();
      }
      
      override public function dispose() : void
      {
         if(tabGroup)
         {
            tabGroup.dispose();
            tabGroup = null;
         }
         list = null;
         super.dispose();
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

import gudetama.engine.SoundManager;
import gudetama.ui.UIBase;
import starling.display.Quad;
import starling.display.Sprite;

class TabGroup extends UIBase
{
    
   
   private var callback:Function;
   
   private var tabs:Sprite;
   
   private var tabUIs:Vector.<TabUI>;
   
   public var decorationQuad:Quad;
   
   function TabGroup(param1:Sprite, param2:Function)
   {
      var _loc5_:int = 0;
      var _loc3_:* = null;
      tabUIs = new Vector.<TabUI>();
      super(param1);
      this.callback = param2;
      tabs = param1.getChildByName("tabs") as Sprite;
      var _loc4_:Sprite = param1.getChildByName("quads") as Sprite;
      _loc5_ = 0;
      while(_loc5_ < tabs.numChildren)
      {
         _loc3_ = _loc4_.getChildAt(_loc5_) as Quad;
         tabUIs.push(new TabUI(tabs.getChildAt(_loc5_) as Sprite,_loc3_,_loc5_,onTouch));
         if(_loc5_ == 0)
         {
            decorationQuad = _loc3_;
         }
         _loc5_++;
      }
   }
   
   public function onTouch(param1:int, param2:Boolean = true, param3:Boolean = true) : void
   {
      var _loc4_:int = 0;
      _loc4_ = 0;
      while(_loc4_ < tabUIs.length)
      {
         tabUIs[_loc4_].setTouchable(_loc4_ != param1);
         _loc4_++;
      }
      tabs.swapChildrenAt(tabs.getChildIndex(tabUIs[param1].getDisplaySprite()),tabUIs.length - 1);
      if(param2)
      {
         SoundManager.playEffect("btn_ok");
      }
      if(param3)
      {
         callback(param1);
      }
   }
   
   public function set touchable(param1:Boolean) : void
   {
      var _loc2_:int = 0;
      tabs.touchable = param1;
      _loc2_ = 0;
      while(_loc2_ < tabUIs.length)
      {
         tabUIs[_loc2_].touchable = param1;
         _loc2_++;
      }
   }
   
   public function dispose() : void
   {
      if(tabUIs)
      {
         for each(var _loc1_ in tabUIs)
         {
            _loc1_.dispose();
         }
         tabUIs.length = 0;
         tabUIs = null;
      }
   }
}

import gudetama.ui.UIBase;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;

class TabUI extends UIBase
{
    
   
   private var index:int;
   
   private var callback:Function;
   
   private var quad:Quad;
   
   function TabUI(param1:Sprite, param2:Quad, param3:int, param4:Function)
   {
      super(param1);
      this.quad = param2;
      this.index = param3;
      this.callback = param4;
      param2.addEventListener("touch",onTouch);
   }
   
   private function onTouch(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(quad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         callback(index);
      }
   }
   
   public function set touchable(param1:Boolean) : void
   {
      quad.touchable = param1;
      setTouchable(param1);
   }
   
   public function dispose() : void
   {
      if(quad)
      {
         quad.removeEventListener("touch",onTouch);
         quad = null;
      }
   }
}
